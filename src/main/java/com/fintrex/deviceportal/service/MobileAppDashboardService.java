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
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Service
public class MobileAppDashboardService {

    private static final Logger log = LoggerFactory.getLogger(MobileAppDashboardService.class);
    private static final BigDecimal CEFT_FEE_PER_TXN = BigDecimal.valueOf(25);

    private static final LinkedHashMap<String, String> CEFT_CODES = new LinkedHashMap<>();

    static {
        CEFT_CODES.put("CC_OTHER_TO_OTHER", "Credit Card Payments via JustPay");
        CEFT_CODES.put("CC_OWN_TO_OTHER", "Credit Card Payments via Fintrex S/A");
        CEFT_CODES.put("FT_OTHER_TO_OTHER", "JustPay to Other Bank");
        CEFT_CODES.put("FT_OWN_TO_OTHER", "Fintrex to Other Bank");
    }

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
                        "Mobile App", "/mobile-app-dashboard", "fas fa-mobile-alt", "General");
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

    public Map<String, Object> getDashboardSummary(String asAtDateStr) {
        LocalDate asAtDate = parseAsAtDate(asAtDateStr);
        LocalDate prevDate = asAtDate.minusDays(1);
        LocalDate trendStartDate = asAtDate.minusDays(13);

        MapSqlParameterSource params = new MapSqlParameterSource()
                .addValue("asAtDate", asAtDate.toString())
                .addValue("prevDate", prevDate.toString())
                .addValue("trendStartDate", trendStartDate.toString());

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("asAtDate", asAtDate.toString());
        result.put("prevDate", prevDate.toString());
        result.put("lastUpdated", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));

        // 1. Customer / App Information from app_user
        String userSql = """
                SELECT
                    COUNT(*) AS total_initiated,
                    SUM(CASE WHEN DATE(COALESCE(registered_at, created_date_time)) = :asAtDate THEN 1 ELSE 0 END) AS initiated_today,
                    SUM(CASE WHEN DATE(COALESCE(registered_at, created_date_time)) = :prevDate THEN 1 ELSE 0 END) AS initiated_prev,

                    SUM(CASE WHEN UPPER(COALESCE(status, '')) = 'ACTIVE' THEN 1 ELSE 0 END) AS total_active,
                    SUM(CASE WHEN UPPER(COALESCE(status, '')) = 'ACTIVE'
                              AND DATE(COALESCE(approved_at, registered_at, created_date_time)) = :asAtDate THEN 1 ELSE 0 END) AS active_today,
                    SUM(CASE WHEN UPPER(COALESCE(status, '')) = 'ACTIVE'
                              AND DATE(COALESCE(approved_at, registered_at, created_date_time)) = :prevDate THEN 1 ELSE 0 END) AS active_prev,

                    SUM(CASE WHEN valid_fintrex_user = 0 THEN 1 ELSE 0 END) AS total_non_fintrex,
                    SUM(CASE WHEN valid_fintrex_user = 0
                              AND DATE(COALESCE(registered_at, created_date_time)) = :asAtDate THEN 1 ELSE 0 END) AS non_fintrex_today,
                    SUM(CASE WHEN valid_fintrex_user = 0
                              AND DATE(COALESCE(registered_at, created_date_time)) = :prevDate THEN 1 ELSE 0 END) AS non_fintrex_prev
                FROM app_user
                WHERE DATE(COALESCE(registered_at, created_date_time)) <= :asAtDate
                   OR (registered_at IS NULL AND created_date_time IS NULL)
                """;

        Map<String, Object> userRow = mobileAppJdbc().queryForMap(userSql, params);

        // 2. Total Savings Accounts Opened from savings_account
        String savingsSql = """
                SELECT
                    COUNT(*) AS total_savings,
                    SUM(CASE WHEN DATE(created_date_time) = :asAtDate THEN 1 ELSE 0 END) AS savings_today,
                    SUM(CASE WHEN DATE(created_date_time) = :prevDate THEN 1 ELSE 0 END) AS savings_prev
                FROM savings_account
                WHERE (DATE(created_date_time) <= :asAtDate OR created_date_time IS NULL)
                  AND UPPER(COALESCE(status, '')) NOT IN ('FAILED', 'REJECTED', 'PENDING', 'CANCELLED')
                """;

        Map<String, Object> savingsRow = mobileAppJdbc().queryForMap(savingsSql, params);

        Map<String, Object> customerInfo = new LinkedHashMap<>();
        customerInfo.put("totalInitiated", toLong(userRow.get("total_initiated")));
        customerInfo.put("initiatedToday", toLong(userRow.get("initiated_today")));
        customerInfo.put("initiatedPrev", toLong(userRow.get("initiated_prev")));

        customerInfo.put("totalActive", toLong(userRow.get("total_active")));
        customerInfo.put("activeToday", toLong(userRow.get("active_today")));
        customerInfo.put("activePrev", toLong(userRow.get("active_prev")));

        customerInfo.put("totalNonFintrex", toLong(userRow.get("total_non_fintrex")));
        customerInfo.put("nonFintrexToday", toLong(userRow.get("non_fintrex_today")));
        customerInfo.put("nonFintrexPrev", toLong(userRow.get("non_fintrex_prev")));

        customerInfo.put("totalSavings", toLong(savingsRow.get("total_savings")));
        customerInfo.put("savingsToday", toLong(savingsRow.get("savings_today")));
        customerInfo.put("savingsPrev", toLong(savingsRow.get("savings_prev")));

        result.put("customerInfo", customerInfo);

        // 3. Successful Transactions & Type-wise Breakdown from transaction
        String txnBreakdownSql = """
                SELECT
                    UPPER(COALESCE(NULLIF(TRIM(transaction_type), ''), NULLIF(TRIM(payment_type), ''), 'OTHER')) AS txn_code,
                    COUNT(*) AS total_count,
                    COALESCE(SUM(COALESCE(raw_amount, paying_amount, 0)), 0) AS total_value,
                    SUM(CASE WHEN DATE(COALESCE(transaction_date, created_date_time)) = :asAtDate THEN 1 ELSE 0 END) AS today_count,
                    COALESCE(SUM(CASE WHEN DATE(COALESCE(transaction_date, created_date_time)) = :asAtDate
                                      THEN COALESCE(raw_amount, paying_amount, 0) ELSE 0 END), 0) AS today_value,
                    SUM(CASE WHEN DATE(COALESCE(transaction_date, created_date_time)) = :prevDate THEN 1 ELSE 0 END) AS prev_count,
                    COALESCE(SUM(CASE WHEN DATE(COALESCE(transaction_date, created_date_time)) = :prevDate
                                      THEN COALESCE(raw_amount, paying_amount, 0) ELSE 0 END), 0) AS prev_value
                FROM `transaction`
                WHERE UPPER(COALESCE(status, '')) IN ('SUCCESS', 'SUCCESSFUL', 'COMPLETED')
                  AND (DATE(COALESCE(transaction_date, created_date_time)) <= :asAtDate
                       OR (transaction_date IS NULL AND created_date_time IS NULL))
                GROUP BY txn_code
                ORDER BY total_value DESC, total_count DESC
                """;

        List<Map<String, Object>> rawBreakdown = mobileAppJdbc().queryForList(txnBreakdownSql, params);

        long totalTxnCount = 0L;
        BigDecimal totalTxnValue = BigDecimal.ZERO;
        long todayTxnCount = 0L;
        BigDecimal todayTxnValue = BigDecimal.ZERO;
        long prevTxnCount = 0L;
        BigDecimal prevTxnValue = BigDecimal.ZERO;

        Map<String, Map<String, Object>> breakdownByCode = new HashMap<>();
        List<Map<String, Object>> transactionBreakdown = new ArrayList<>();

        for (Map<String, Object> row : rawBreakdown) {
            String code = String.valueOf(row.get("txn_code"));
            long count = toLong(row.get("total_count"));
            BigDecimal val = toBigDecimal(row.get("total_value"));
            long tCount = toLong(row.get("today_count"));
            BigDecimal tVal = toBigDecimal(row.get("today_value"));
            long pCount = toLong(row.get("prev_count"));
            BigDecimal pVal = toBigDecimal(row.get("prev_value"));

            totalTxnCount += count;
            totalTxnValue = totalTxnValue.add(val);
            todayTxnCount += tCount;
            todayTxnValue = todayTxnValue.add(tVal);
            prevTxnCount += pCount;
            prevTxnValue = prevTxnValue.add(pVal);

            boolean isCeft = CEFT_CODES.containsKey(code);
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("txnCode", code);
            item.put("displayName", CEFT_CODES.getOrDefault(code, formatCodeLabel(code)));
            item.put("totalCount", count);
            item.put("totalValue", val);
            item.put("todayCount", tCount);
            item.put("todayValue", tVal);
            item.put("prevCount", pCount);
            item.put("prevValue", pVal);
            item.put("isCeft", isCeft);
            item.put("ceftRevenue", isCeft ? CEFT_FEE_PER_TXN.multiply(BigDecimal.valueOf(count)) : BigDecimal.ZERO);

            transactionBreakdown.add(item);
            breakdownByCode.put(code, item);
        }

        Map<String, Object> transactionInfo = new LinkedHashMap<>();
        transactionInfo.put("totalSuccessCount", totalTxnCount);
        transactionInfo.put("totalSuccessValue", totalTxnValue);
        transactionInfo.put("todaySuccessCount", todayTxnCount);
        transactionInfo.put("todaySuccessValue", todayTxnValue);
        transactionInfo.put("prevSuccessCount", prevTxnCount);
        transactionInfo.put("prevSuccessValue", prevTxnValue);
        result.put("transactionInfo", transactionInfo);
        result.put("transactionBreakdown", transactionBreakdown);

        // 4. CEFT Revenue Breakdown (always includes the 4 specified CEFT codes)
        List<Map<String, Object>> ceftBreakdown = new ArrayList<>();
        long ceftTotalCount = 0L;
        long ceftTodayCount = 0L;
        long ceftPrevCount = 0L;

        for (Map.Entry<String, String> entry : CEFT_CODES.entrySet()) {
            String code = entry.getKey();
            String label = entry.getValue();
            Map<String, Object> found = breakdownByCode.get(code);

            long count = found != null ? toLong(found.get("totalCount")) : 0L;
            long tCount = found != null ? toLong(found.get("todayCount")) : 0L;
            long pCount = found != null ? toLong(found.get("prevCount")) : 0L;
            BigDecimal val = found != null ? toBigDecimal(found.get("totalValue")) : BigDecimal.ZERO;

            ceftTotalCount += count;
            ceftTodayCount += tCount;
            ceftPrevCount += pCount;

            Map<String, Object> row = new LinkedHashMap<>();
            row.put("transactionType", label);
            row.put("transactionCode", code);
            row.put("successCount", count);
            row.put("todayCount", tCount);
            row.put("prevCount", pCount);
            row.put("totalValue", val);
            row.put("feePerTxn", CEFT_FEE_PER_TXN);
            row.put("revenue", CEFT_FEE_PER_TXN.multiply(BigDecimal.valueOf(count)));
            row.put("todayRevenue", CEFT_FEE_PER_TXN.multiply(BigDecimal.valueOf(tCount)));
            row.put("prevRevenue", CEFT_FEE_PER_TXN.multiply(BigDecimal.valueOf(pCount)));
            ceftBreakdown.add(row);
        }

        Map<String, Object> ceftSummary = new LinkedHashMap<>();
        ceftSummary.put("feePerTxn", CEFT_FEE_PER_TXN);
        ceftSummary.put("totalCeftCount", ceftTotalCount);
        ceftSummary.put("totalCeftRevenue", CEFT_FEE_PER_TXN.multiply(BigDecimal.valueOf(ceftTotalCount)));
        ceftSummary.put("todayCeftCount", ceftTodayCount);
        ceftSummary.put("todayCeftRevenue", CEFT_FEE_PER_TXN.multiply(BigDecimal.valueOf(ceftTodayCount)));
        ceftSummary.put("prevCeftCount", ceftPrevCount);
        ceftSummary.put("prevCeftRevenue", CEFT_FEE_PER_TXN.multiply(BigDecimal.valueOf(ceftPrevCount)));
        ceftSummary.put("breakdown", ceftBreakdown);
        result.put("ceftRevenue", ceftSummary);

        // 5. Last 14 Days Daily Trend (Transactions & CEFT Revenue)
        String trendSql = """
                SELECT
                    DATE_FORMAT(DATE(COALESCE(transaction_date, created_date_time)), '%Y-%m-%d') AS txn_day,
                    COUNT(*) AS txn_count,
                    COALESCE(SUM(COALESCE(raw_amount, paying_amount, 0)), 0) AS txn_value,
                    SUM(CASE WHEN UPPER(COALESCE(NULLIF(TRIM(transaction_type), ''), NULLIF(TRIM(payment_type), ''), ''))
                                  IN ('CC_OTHER_TO_OTHER', 'CC_OWN_TO_OTHER', 'FT_OTHER_TO_OTHER', 'FT_OWN_TO_OTHER')
                             THEN 1 ELSE 0 END) AS ceft_count
                FROM `transaction`
                WHERE UPPER(COALESCE(status, '')) IN ('SUCCESS', 'SUCCESSFUL', 'COMPLETED')
                  AND DATE(COALESCE(transaction_date, created_date_time)) BETWEEN :trendStartDate AND :asAtDate
                GROUP BY txn_day
                ORDER BY txn_day ASC
                """;

        List<Map<String, Object>> trendRows = mobileAppJdbc().queryForList(trendSql, params);
        Map<String, Map<String, Object>> trendByDay = new HashMap<>();
        for (Map<String, Object> r : trendRows) {
            trendByDay.put(String.valueOf(r.get("txn_day")), r);
        }

        List<Map<String, Object>> dailyTrend = new ArrayList<>();
        for (int i = 0; i < 14; i++) {
            LocalDate d = trendStartDate.plusDays(i);
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

    private LocalDate parseAsAtDate(String asAtDateStr) {
        if (asAtDateStr != null && !asAtDateStr.isBlank()) {
            try {
                return LocalDate.parse(asAtDateStr.trim());
            } catch (Exception ignored) {
            }
        }
        return LocalDate.now();
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

    private String formatCodeLabel(String code) {
        if (code == null || code.isBlank()) {
            return "Other";
        }
        String[] parts = code.toLowerCase().split("_");
        StringBuilder sb = new StringBuilder();
        for (String p : parts) {
            if (!p.isEmpty()) {
                if (sb.length() > 0) sb.append(' ');
                sb.append(Character.toUpperCase(p.charAt(0))).append(p.substring(1));
            }
        }
        return sb.toString();
    }
}
