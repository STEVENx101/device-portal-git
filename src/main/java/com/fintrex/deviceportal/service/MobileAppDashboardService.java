package com.fintrex.deviceportal.service;

import com.fintrex.deviceportal.config.MobileAppDataSourceConfig;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;

@Service
public class MobileAppDashboardService {

    private static final Logger log = LoggerFactory.getLogger(MobileAppDashboardService.class);
    private static final BigDecimal CEFT_FEE_PER_TXN = BigDecimal.valueOf(25);
    private static final LocalDate DATA_FLOOR_DATE = LocalDate.of(2026, 6, 1);

    private static final LinkedHashMap<String, String> CEFT_CODES = new LinkedHashMap<>();

    static {
        CEFT_CODES.put("CC_OTHER_TO_OTHER", "Credit Card Payments via JustPay");
        CEFT_CODES.put("CC_OWN_TO_OTHER", "Credit Card Payments via Fintrex S/A");
        CEFT_CODES.put("FT_OTHER_TO_OTHER", "JustPay to Other Bank");
        CEFT_CODES.put("FT_OWN_TO_OTHER", "Fintrex to Other Bank");
    }

    private static final List<String> ORDERED_GROUPS = List.of(
            "Leasing",
            "Loan Payments",
            "Pawning",
            "Bill Payments",
            "Fund Transfers",
            "Credit Card",
            "QR Payments",
            "Other"
    );

    private final MobileAppDataSourceConfig mobileAppDataSourceConfig;
    private final JdbcTemplate primaryJdbc;

    public MobileAppDashboardService(
            MobileAppDataSourceConfig mobileAppDataSourceConfig,
            JdbcTemplate primaryJdbc) {
        this.mobileAppDataSourceConfig = mobileAppDataSourceConfig;
        this.primaryJdbc = primaryJdbc;
    }

    private NamedParameterJdbcTemplate mobileAppJdbc() {
        return mobileAppDataSourceConfig.getJdbcTemplate();
    }

    @PostConstruct
    public void ensureScreenRegistered() {
        try {
            Integer count = primaryJdbc.queryForObject(
                    "SELECT COUNT(*) FROM device_portal.screen WHERE path = '/mobile-app-dashboard'",
                    Integer.class);
            if (count != null && count == 0) {
                primaryJdbc.update(
                        "INSERT INTO device_portal.screen (name, path, icon, group_name) VALUES (?, ?, ?, ?)",
                        "Mobile App", "/mobile-app-dashboard", "fas fa-signal", "General");
                Integer screenId = primaryJdbc.queryForObject(
                        "SELECT id FROM device_portal.screen WHERE path = '/mobile-app-dashboard' LIMIT 1",
                        Integer.class);
                if (screenId != null) {
                    primaryJdbc.update(
                            "INSERT IGNORE INTO device_portal.user_type_screen (user_type_id, screen_id) VALUES (1, ?)",
                            screenId);
                }
                log.info("Registered '/mobile-app-dashboard' screen and granted access to Admin role.");
            }
        } catch (Exception e) {
            log.warn("Unable to auto-register '/mobile-app-dashboard' screen: {}", e.getMessage());
        }
    }

    public Map<String, Object> getDashboardSummary(String fromDateStr, String toDateStr, String compareModeStr) {
        LocalDate fromDate = parseDateOrDefault(fromDateStr, DATA_FLOOR_DATE);
        if (fromDate.isBefore(DATA_FLOOR_DATE)) {
            fromDate = DATA_FLOOR_DATE;
        }
        LocalDate toDate = parseDateOrDefault(toDateStr, LocalDate.now());
        if (toDate.isBefore(fromDate)) {
            toDate = fromDate;
        }

        String compareMode = "MONTH".equalsIgnoreCase(compareModeStr) ? "MONTH" : "DAY";
        LocalDate prevCutoff = "MONTH".equals(compareMode) ? toDate.minusMonths(1) : toDate.minusDays(1);
        LocalDate trendStart = toDate.minusDays(13);
        if (trendStart.isBefore(fromDate)) {
            trendStart = fromDate;
        }

        MapSqlParameterSource params = new MapSqlParameterSource()
                .addValue("fromDate", fromDate.toString())
                .addValue("toDate", toDate.toString())
                .addValue("prevCutoff", prevCutoff.toString())
                .addValue("trendStartDate", trendStart.toString());

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("fromDate", fromDate.toString());
        result.put("toDate", toDate.toString());
        result.put("compareMode", compareMode);
        result.put("prevCutoffDate", prevCutoff.toString());

        // 1. Total App Downloads / Initiated from user_device (>= 2026-06-01)
        String deviceSql = """
                SELECT
                    COUNT(*) AS total_initiated,
                    SUM(CASE WHEN DATE(created_date_time) <= :prevCutoff THEN 1 ELSE 0 END) AS prev_initiated
                FROM user_device
                WHERE DATE(created_date_time) >= :fromDate
                  AND DATE(created_date_time) <= :toDate
                """;
        Map<String, Object> deviceRow = mobileAppJdbc().queryForMap(deviceSql, params);

        // 2 & 3. Total Active Customers (status = 'ACTIVE' only, incl. Non-Fintrex)
        //        and Non-Fintrex Users (valid_fintrex_user = b'0') from app_user (>= 2026-06-01)
        String userSql = """
                SELECT
                    SUM(CASE WHEN UPPER(COALESCE(status, '')) = 'ACTIVE' THEN 1 ELSE 0 END) AS total_active,
                    SUM(CASE WHEN UPPER(COALESCE(status, '')) = 'ACTIVE'
                              AND DATE(COALESCE(registered_at, created_date_time)) <= :prevCutoff THEN 1 ELSE 0 END) AS prev_active,

                    SUM(CASE WHEN UPPER(COALESCE(status, '')) = 'ACTIVE'
                              AND valid_fintrex_user IS NOT NULL AND CAST(valid_fintrex_user AS UNSIGNED) = 0 THEN 1 ELSE 0 END) AS total_non_fintrex,
                    SUM(CASE WHEN UPPER(COALESCE(status, '')) = 'ACTIVE'
                              AND valid_fintrex_user IS NOT NULL AND CAST(valid_fintrex_user AS UNSIGNED) = 0
                              AND DATE(COALESCE(registered_at, created_date_time)) <= :prevCutoff THEN 1 ELSE 0 END) AS prev_non_fintrex
                FROM app_user
                WHERE DATE(COALESCE(registered_at, created_date_time)) >= :fromDate
                  AND DATE(COALESCE(registered_at, created_date_time)) <= :toDate
                """;
        Map<String, Object> userRow = mobileAppJdbc().queryForMap(userSql, params);

        // 4. Total & Active Savings Accounts Opened from savings_account (>= 2026-06-01)
        String savingsSql = """
                SELECT
                    SUM(CASE WHEN LOWER(COALESCE(status, '')) = 'success' THEN 1 ELSE 0 END) AS total_savings,
                    SUM(CASE WHEN LOWER(COALESCE(status, '')) = 'success'
                              AND DATE(created_date_time) <= :prevCutoff THEN 1 ELSE 0 END) AS prev_savings,
                    SUM(CASE WHEN LOWER(COALESCE(status, '')) = 'success'
                              AND LOWER(COALESCE(acc_status, '')) = 'active' THEN 1 ELSE 0 END) AS active_savings
                FROM savings_account
                WHERE DATE(created_date_time) >= :fromDate
                  AND DATE(created_date_time) <= :toDate
                """;
        Map<String, Object> savingsRow = mobileAppJdbc().queryForMap(savingsSql, params);

        Map<String, Object> customerInfo = new LinkedHashMap<>();
        customerInfo.put("totalInitiated", toLong(deviceRow.get("total_initiated")));
        customerInfo.put("prevInitiated", toLong(deviceRow.get("prev_initiated")));

        customerInfo.put("totalActive", toLong(userRow.get("total_active")));
        customerInfo.put("prevActive", toLong(userRow.get("prev_active")));

        customerInfo.put("totalNonFintrex", toLong(userRow.get("total_non_fintrex")));
        customerInfo.put("prevNonFintrex", toLong(userRow.get("prev_non_fintrex")));

        customerInfo.put("totalSavings", toLong(savingsRow.get("total_savings")));
        customerInfo.put("prevSavings", toLong(savingsRow.get("prev_savings")));
        customerInfo.put("activeSavings", toLong(savingsRow.get("active_savings")));

        result.put("customerInfo", customerInfo);

        // 5 & 6. Successful Transactions & Type-wise Breakdown from `transaction` (>= 2026-06-01)
        String txnBreakdownSql = """
                SELECT
                    UPPER(COALESCE(NULLIF(TRIM(transaction_type), ''), 'OTHER')) AS txn_code,
                    COUNT(*) AS total_count,
                    COALESCE(SUM(COALESCE(raw_amount, paying_amount, 0)), 0) AS total_value,
                    SUM(CASE WHEN DATE(COALESCE(transaction_date, created_date_time)) <= :prevCutoff THEN 1 ELSE 0 END) AS prev_count,
                    COALESCE(SUM(CASE WHEN DATE(COALESCE(transaction_date, created_date_time)) <= :prevCutoff
                                      THEN COALESCE(raw_amount, paying_amount, 0) ELSE 0 END), 0) AS prev_value
                FROM `transaction`
                WHERE UPPER(COALESCE(status, '')) = 'SUCCESS'
                  AND DATE(COALESCE(transaction_date, created_date_time)) >= :fromDate
                  AND DATE(COALESCE(transaction_date, created_date_time)) <= :toDate
                GROUP BY txn_code
                ORDER BY total_value DESC, total_count DESC
                """;

        List<Map<String, Object>> rawBreakdown = mobileAppJdbc().queryForList(txnBreakdownSql, params);

        long totalTxnCount = 0L;
        BigDecimal totalTxnValue = BigDecimal.ZERO;
        long prevTxnCount = 0L;
        BigDecimal prevTxnValue = BigDecimal.ZERO;

        Map<String, Map<String, Object>> breakdownByCode = new HashMap<>();
        List<Map<String, Object>> transactionBreakdown = new ArrayList<>();

        // Initialize ordered group accumulators
        Map<String, GroupAccumulator> groupAccMap = new LinkedHashMap<>();
        for (String g : ORDERED_GROUPS) {
            groupAccMap.put(g, new GroupAccumulator(g));
        }

        for (Map<String, Object> row : rawBreakdown) {
            String code = String.valueOf(row.get("txn_code"));
            long count = toLong(row.get("total_count"));
            BigDecimal val = toBigDecimal(row.get("total_value"));
            long pCount = toLong(row.get("prev_count"));
            BigDecimal pVal = toBigDecimal(row.get("prev_value"));

            totalTxnCount += count;
            totalTxnValue = totalTxnValue.add(val);
            prevTxnCount += pCount;
            prevTxnValue = prevTxnValue.add(pVal);

            String group = resolveGroup(code);
            boolean isCeft = CEFT_CODES.containsKey(code);
            BigDecimal ceftRev = isCeft ? CEFT_FEE_PER_TXN.multiply(BigDecimal.valueOf(count)) : BigDecimal.ZERO;
            BigDecimal prevCeftRev = isCeft ? CEFT_FEE_PER_TXN.multiply(BigDecimal.valueOf(pCount)) : BigDecimal.ZERO;

            Map<String, Object> item = new LinkedHashMap<>();
            item.put("txnCode", code);
            item.put("group", group);
            item.put("displayName", buildFriendlyLabel(code, group));
            item.put("totalCount", count);
            item.put("totalValue", val);
            item.put("prevCount", pCount);
            item.put("prevValue", pVal);
            item.put("diffCount", count - pCount);
            item.put("diffValue", val.subtract(pVal));
            item.put("isCeft", isCeft);
            item.put("ceftRevenue", ceftRev);
            item.put("prevCeftRevenue", prevCeftRev);

            transactionBreakdown.add(item);
            breakdownByCode.put(code, item);

            GroupAccumulator acc = groupAccMap.computeIfAbsent(group, GroupAccumulator::new);
            acc.totalCount += count;
            acc.totalValue = acc.totalValue.add(val);
            acc.prevCount += pCount;
            acc.prevValue = acc.prevValue.add(pVal);
            if (isCeft) {
                acc.ceftCount += count;
                acc.ceftRevenue = acc.ceftRevenue.add(ceftRev);
            }
        }

        Map<String, Object> transactionInfo = new LinkedHashMap<>();
        transactionInfo.put("totalSuccessCount", totalTxnCount);
        transactionInfo.put("totalSuccessValue", totalTxnValue);
        transactionInfo.put("prevSuccessCount", prevTxnCount);
        transactionInfo.put("prevSuccessValue", prevTxnValue);
        result.put("transactionInfo", transactionInfo);
        result.put("transactionBreakdown", transactionBreakdown);

        List<Map<String, Object>> groupSummary = new ArrayList<>();
        for (GroupAccumulator acc : groupAccMap.values()) {
            if (acc.totalCount > 0 || !"Other".equals(acc.group)) {
                groupSummary.add(acc.toMap());
            }
        }
        result.put("groupSummary", groupSummary);

        // 7. CEFT Revenue Breakdown (4 specified CEFT codes x LKR 25)
        List<Map<String, Object>> ceftBreakdown = new ArrayList<>();
        long ceftTotalCount = 0L;
        long ceftPrevCount = 0L;

        for (Map.Entry<String, String> entry : CEFT_CODES.entrySet()) {
            String code = entry.getKey();
            String label = entry.getValue();
            Map<String, Object> found = breakdownByCode.get(code);

            long count = found != null ? toLong(found.get("totalCount")) : 0L;
            long pCount = found != null ? toLong(found.get("prevCount")) : 0L;
            BigDecimal val = found != null ? toBigDecimal(found.get("totalValue")) : BigDecimal.ZERO;

            ceftTotalCount += count;
            ceftPrevCount += pCount;

            Map<String, Object> row = new LinkedHashMap<>();
            row.put("transactionType", label);
            row.put("transactionCode", code);
            row.put("group", resolveGroup(code));
            row.put("successCount", count);
            row.put("prevCount", pCount);
            row.put("diffCount", count - pCount);
            row.put("totalValue", val);
            row.put("feePerTxn", CEFT_FEE_PER_TXN);
            row.put("revenue", CEFT_FEE_PER_TXN.multiply(BigDecimal.valueOf(count)));
            row.put("prevRevenue", CEFT_FEE_PER_TXN.multiply(BigDecimal.valueOf(pCount)));
            ceftBreakdown.add(row);
        }

        Map<String, Object> ceftSummary = new LinkedHashMap<>();
        ceftSummary.put("feePerTxn", CEFT_FEE_PER_TXN);
        ceftSummary.put("totalCeftCount", ceftTotalCount);
        ceftSummary.put("prevCeftCount", ceftPrevCount);
        ceftSummary.put("totalCeftRevenue", CEFT_FEE_PER_TXN.multiply(BigDecimal.valueOf(ceftTotalCount)));
        ceftSummary.put("prevCeftRevenue", CEFT_FEE_PER_TXN.multiply(BigDecimal.valueOf(ceftPrevCount)));
        ceftSummary.put("breakdown", ceftBreakdown);
        result.put("ceftRevenue", ceftSummary);

        // 8. Daily Trend (up to last 14 days within [fromDate, toDate])
        String trendSql = """
                SELECT
                    DATE_FORMAT(DATE(COALESCE(transaction_date, created_date_time)), '%Y-%m-%d') AS txn_day,
                    COUNT(*) AS txn_count,
                    COALESCE(SUM(COALESCE(raw_amount, paying_amount, 0)), 0) AS txn_value,
                    SUM(CASE WHEN UPPER(COALESCE(TRIM(transaction_type), ''))
                                  IN ('CC_OTHER_TO_OTHER', 'CC_OWN_TO_OTHER', 'FT_OTHER_TO_OTHER', 'FT_OWN_TO_OTHER')
                             THEN 1 ELSE 0 END) AS ceft_count
                FROM `transaction`
                WHERE UPPER(COALESCE(status, '')) = 'SUCCESS'
                  AND DATE(COALESCE(transaction_date, created_date_time)) BETWEEN :trendStartDate AND :toDate
                GROUP BY txn_day
                ORDER BY txn_day ASC
                """;

        List<Map<String, Object>> trendRows = mobileAppJdbc().queryForList(trendSql, params);
        Map<String, Map<String, Object>> trendByDay = new HashMap<>();
        for (Map<String, Object> r : trendRows) {
            trendByDay.put(String.valueOf(r.get("txn_day")), r);
        }

        List<Map<String, Object>> dailyTrend = new ArrayList<>();
        for (LocalDate d = trendStart; !d.isAfter(toDate); d = d.plusDays(1)) {
            String key = d.toString();
            Map<String, Object> r = trendByDay.get(key);
            long ceftCnt = r != null ? toLong(r.get("ceft_count")) : 0L;

            Map<String, Object> point = new LinkedHashMap<>();
            point.put("date", key);
            point.put("txnCount", r != null ? toLong(r.get("txn_count")) : 0L);
            point.put("txnValue", r != null ? toBigDecimal(r.get("txn_value")) : BigDecimal.ZERO);
            point.put("ceftCount", ceftCnt);
            point.put("ceftRevenue", CEFT_FEE_PER_TXN.multiply(BigDecimal.valueOf(ceftCnt)));
            dailyTrend.add(point);
        }
        result.put("dailyTrend", dailyTrend);

        return result;
    }

    private String resolveGroup(String code) {
        if (code == null || code.isBlank()) return "Other";
        String c = code.toUpperCase(Locale.ROOT);
        if (c.startsWith("CR_") || c.equals("CR") || c.startsWith("LS_") || c.contains("LEAS")) {
            return "Leasing";
        }
        if (c.startsWith("MF_") || c.equals("MF") || c.startsWith("LN_") || c.contains("LOAN")) {
            return "Loan Payments";
        }
        if (c.startsWith("GL_") || c.startsWith("PW_") || c.contains("PAWN") || c.contains("GOLD")) {
            return "Pawning";
        }
        if (c.startsWith("BP_") || c.equals("BP") || c.contains("BILL")) {
            return "Bill Payments";
        }
        if (c.startsWith("FT_") || c.equals("FT") || c.contains("FUND")) {
            return "Fund Transfers";
        }
        if (c.startsWith("CC_") || c.equals("CC") || c.contains("CREDIT_CARD")) {
            return "Credit Card";
        }
        if (c.startsWith("QR_") || c.equals("QR")) {
            return "QR Payments";
        }
        return "Other";
    }

    private String buildFriendlyLabel(String code, String group) {
        if (CEFT_CODES.containsKey(code)) {
            return CEFT_CODES.get(code);
        }
        if (code == null || code.isBlank()) {
            return "Other";
        }
        String c = code.toUpperCase(Locale.ROOT);
        String route = "";
        if (c.contains("OWN_TO_OWN")) {
            route = "Fintrex to Fintrex";
        } else if (c.contains("OTHER_TO_OWN")) {
            route = "JustPay to Fintrex";
        } else if (c.contains("OWN_TO_OTHER")) {
            route = "Fintrex to JustPay / Other";
        } else if (c.contains("OTHER_TO_OTHER")) {
            route = "JustPay to Other";
        } else if (c.contains("_OWN") || c.endsWith("OWN")) {
            route = "via Fintrex";
        } else if (c.contains("_OTHER") || c.endsWith("OTHER")) {
            route = "via JustPay";
        }

        if (!"Other".equals(group) && !route.isEmpty()) {
            return group + " (" + route + ")";
        }
        if (!"Other".equals(group)) {
            return group + " — " + formatCodeWords(code);
        }
        return formatCodeWords(code);
    }

    private String formatCodeWords(String code) {
        String[] parts = code.toLowerCase(Locale.ROOT).split("_");
        StringBuilder sb = new StringBuilder();
        for (String p : parts) {
            if (p.isEmpty()) continue;
            if (sb.length() > 0) sb.append(' ');
            if ("own".equals(p)) {
                sb.append("Fintrex");
            } else if ("other".equals(p)) {
                sb.append("JustPay");
            } else {
                sb.append(Character.toUpperCase(p.charAt(0))).append(p.substring(1));
            }
        }
        return sb.toString();
    }

    private static class GroupAccumulator {
        final String group;
        long totalCount = 0L;
        BigDecimal totalValue = BigDecimal.ZERO;
        long prevCount = 0L;
        BigDecimal prevValue = BigDecimal.ZERO;
        long ceftCount = 0L;
        BigDecimal ceftRevenue = BigDecimal.ZERO;

        GroupAccumulator(String group) {
            this.group = group;
        }

        Map<String, Object> toMap() {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("group", group);
            m.put("totalCount", totalCount);
            m.put("totalValue", totalValue);
            m.put("prevCount", prevCount);
            m.put("prevValue", prevValue);
            m.put("diffCount", totalCount - prevCount);
            m.put("diffValue", totalValue.subtract(prevValue));
            m.put("ceftCount", ceftCount);
            m.put("ceftRevenue", ceftRevenue);
            return m;
        }
    }

    private LocalDate parseDateOrDefault(String dateStr, LocalDate fallback) {
        if (dateStr != null && !dateStr.isBlank()) {
            try {
                return LocalDate.parse(dateStr.trim());
            } catch (Exception ignored) {
            }
        }
        return fallback;
    }

    private long toLong(Object val) {
        if (val instanceof Number n) {
            return n.longValue();
        }
        return 0L;
    }

    private BigDecimal toBigDecimal(Object val) {
        if (val instanceof BigDecimal bd) {
            return bd;
        }
        if (val instanceof Number n) {
            return BigDecimal.valueOf(n.doubleValue());
        }
        return BigDecimal.ZERO;
    }
}
