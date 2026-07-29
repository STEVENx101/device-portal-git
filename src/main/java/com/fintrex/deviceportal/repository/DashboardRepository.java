package com.fintrex.deviceportal.repository;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.Collections;

@Repository
public class DashboardRepository {

    private static final long DASHBOARD_CACHE_TTL_MS = 120_000L; // 2 minutes

    private final JdbcTemplate jdbcTemplate;

    private final Object kpiCacheLock = new Object();
    private final Object dpdChartCacheLock = new Object();
    private final Object monthBusinessCacheLock = new Object();
    private final Object monthDpdCacheLock = new Object();

    private volatile Map<String, Object> kpiCache = Collections.emptyMap();
    private volatile long kpiCacheLoadedAt;

    private volatile Map<String, List<Map<String, Object>>> dpdChartCache = Collections.emptyMap();
    private volatile long dpdChartCacheLoadedAt;

    private volatile List<Map<String, Object>> monthBusinessCache = Collections.emptyList();
    private volatile long monthBusinessCacheLoadedAt;

    private volatile List<Map<String, Object>> monthDpdCache = Collections.emptyList();
    private volatile long monthDpdCacheLoadedAt;

    public DashboardRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public Map<String, Object> getNStatusKpis() {
        long now = System.currentTimeMillis();
        if (kpiCacheLoadedAt > 0L && now - kpiCacheLoadedAt < DASHBOARD_CACHE_TTL_MS) {
            return new HashMap<>(kpiCache);
        }

        synchronized (kpiCacheLock) {
            now = System.currentTimeMillis();
            if (kpiCacheLoadedAt > 0L && now - kpiCacheLoadedAt < DASHBOARD_CACHE_TTL_MS) {
                return new HashMap<>(kpiCache);
            }

            Map<String, Object> stats = new HashMap<>();

            // Combined month + YTD + portfolio stats in a single query
            String sqlCombined = """
                SELECT
                    COUNT(CASE
                        WHEN disbursed_date >= DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
                         AND disbursed_date < DATE_ADD(DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01'), INTERVAL 1 MONTH)
                        THEN 1 END) AS month_count,
                    COALESCE(SUM(CASE
                        WHEN disbursed_date >= DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
                         AND disbursed_date < DATE_ADD(DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01'), INTERVAL 1 MONTH)
                        THEN loan_amount END), 0) AS month_amount,
                    COUNT(CASE
                        WHEN disbursed_date >= CASE WHEN MONTH(CURRENT_DATE()) >= 4 THEN DATE_FORMAT(CURRENT_DATE(), '%Y-04-01') ELSE DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 YEAR), '%Y-04-01') END
                         AND disbursed_date < CASE WHEN MONTH(CURRENT_DATE()) >= 4 THEN DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 1 YEAR), '%Y-04-01') ELSE DATE_FORMAT(CURRENT_DATE(), '%Y-04-01') END
                        THEN 1 END) AS ytd_count,
                    COALESCE(SUM(CASE
                        WHEN disbursed_date >= CASE WHEN MONTH(CURRENT_DATE()) >= 4 THEN DATE_FORMAT(CURRENT_DATE(), '%Y-04-01') ELSE DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 YEAR), '%Y-04-01') END
                         AND disbursed_date < CASE WHEN MONTH(CURRENT_DATE()) >= 4 THEN DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 1 YEAR), '%Y-04-01') ELSE DATE_FORMAT(CURRENT_DATE(), '%Y-04-01') END
                        THEN loan_amount END), 0) AS ytd_amount,
                    COUNT(*) AS portfolio_count,
                    COALESCE(SUM(loan_amount), 0) AS portfolio_amount
                FROM cbs.loan
            """;
            Map<String, Object> combined = jdbcTemplate.queryForMap(sqlCombined);

            // NPL stats query
            String sqlNplStats = """
                SELECT
                    COUNT(DISTINCT p.account_no) AS npl_count,
                    SUM(p.exposure) AS npl_exposure,
                    SUM(p.total_due) AS npl_arrears
                FROM cbs.portfolio p
                JOIN (
                    SELECT account_no AS finance_no, account_status FROM cbs.loan
                    UNION ALL
                    SELECT legacy_account_no AS finance_no, account_status FROM cbs.loan WHERE legacy_account_no IS NOT NULL
                ) l ON l.finance_no = p.account_no
                WHERE p.portfolio_date = (SELECT MAX(portfolio_date) FROM cbs.portfolio)
                AND l.account_status='N'
            """;
            Map<String, Object> nplStats = jdbcTemplate.queryForMap(sqlNplStats);

            // Security-wise Locked / Unlocked count query
            String sqlSecurityStats = """
                SELECT
                    CASE
                        WHEN pr.product_code IN ('LF','laptop') THEN 'ABSOLUTE'
                        WHEN pr.product_code='MF' AND ml.knox_compatibility='yes' THEN 'KNOX'
                        WHEN pr.product_code='MF' THEN 'DATACULTR'
                        ELSE 'OTHER'
                    END AS security_type,
                    SUM(ml.locked=1) AS locked_count,
                    SUM(ml.locked=0 OR ml.locked IS NULL) AS unlocked_count
                FROM (
                    SELECT account_no AS finance_no, product FROM cbs.loan
                    UNION ALL
                    SELECT legacy_account_no, product FROM cbs.loan WHERE legacy_account_no IS NOT NULL
                ) l
                LEFT JOIN loan.mobileloan ml ON ml.finance_no=l.finance_no
                LEFT JOIN cbs.product pr ON pr.code_val = CAST(l.product AS UNSIGNED)
                GROUP BY security_type
            """;
            List<Map<String, Object>> securityStats = jdbcTemplate.queryForList(sqlSecurityStats);

            stats.put("nMonthCount", combined.get("month_count") != null ? combined.get("month_count") : 0);
            stats.put("nMonthAmount", combined.get("month_amount") != null ? combined.get("month_amount") : 0);
            stats.put("nYtdCount", combined.get("ytd_count") != null ? combined.get("ytd_count") : 0);
            stats.put("nYtdAmount", combined.get("ytd_amount") != null ? combined.get("ytd_amount") : 0);
            stats.put("nPortfolioCount", combined.get("portfolio_count") != null ? combined.get("portfolio_count") : 0);
            stats.put("nPortfolioAmount", combined.get("portfolio_amount") != null ? combined.get("portfolio_amount") : 0);
            stats.put("nNplCount", nplStats.get("npl_count") != null ? nplStats.get("npl_count") : 0);
            stats.put("nNplExposure", nplStats.get("npl_exposure") != null ? nplStats.get("npl_exposure") : 0);
            stats.put("nNplArrears", nplStats.get("npl_arrears") != null ? nplStats.get("npl_arrears") : 0);
            stats.put("securityStats", securityStats);

            kpiCache = Collections.unmodifiableMap(stats);
            kpiCacheLoadedAt = now;
            return new HashMap<>(kpiCache);
        }
    }

    public Map<String, Object> getDashboardStats() {
        return getNStatusKpis();
    }

    public List<Map<String, Object>> getDpdChartData(String dimension) {
        long now = System.currentTimeMillis();
        String cacheKey = dimension != null ? dimension : "dealer";

        if (dpdChartCacheLoadedAt > 0L && now - dpdChartCacheLoadedAt < DASHBOARD_CACHE_TTL_MS) {
            List<Map<String, Object>> cached = dpdChartCache.get(cacheKey);
            if (cached != null) return cached;
        }

        synchronized (dpdChartCacheLock) {
            now = System.currentTimeMillis();
            if (dpdChartCacheLoadedAt > 0L && now - dpdChartCacheLoadedAt < DASHBOARD_CACHE_TTL_MS) {
                List<Map<String, Object>> cached = dpdChartCache.get(cacheKey);
                if (cached != null) return cached;
            }

            String sqlLatest = """
                SELECT portfolio_date, sync_time FROM cbs.portfolio
                WHERE portfolio_date IS NOT NULL AND sync_time IS NOT NULL
                ORDER BY portfolio_date DESC, sync_time DESC LIMIT 1
            """;
            Map<String, Object> latest = jdbcTemplate.queryForMap(sqlLatest);
            Object latestPortfolioDate = latest.get("portfolio_date");
            Object latestSyncTime = latest.get("sync_time");

            String categoryExpr;
            String dimensionJoin = "";

            if ("security".equalsIgnoreCase(dimension)) {
                categoryExpr = """
                    CASE
                        WHEN pr.product_code IN ('LF', 'laptop') THEN 'ABSOLUTE'
                        WHEN pr.product_code = 'MF' AND COALESCE(lm1.knox_compatibility, lm2.knox_compatibility) = 'yes' THEN 'KNOX'
                        WHEN pr.product_code = 'MF' AND (COALESCE(lm1.knox_compatibility, lm2.knox_compatibility) = 'no' OR COALESCE(lm1.knox_compatibility, lm2.knox_compatibility) IS NULL) THEN 'DATACULTR'
                        ELSE 'OTHER'
                    END
                """;
                dimensionJoin = """
                    LEFT JOIN loan.mobileloan lm1 ON lm1.finance_no = l.account_no
                    LEFT JOIN loan.mobileloan lm2 ON lm2.finance_no = l.legacy_account_no
                """;
            } else if ("model".equalsIgnoreCase(dimension)) {
                categoryExpr = "COALESCE(lmm.name, 'Unknown Model')";
                dimensionJoin = """
                    LEFT JOIN loan.mobileloan lm1 ON lm1.finance_no = l.account_no
                    LEFT JOIN loan.mobileloan lm2 ON lm2.finance_no = l.legacy_account_no
                    LEFT JOIN loan.device_loan dl2_1 ON dl2_1.finance_no = l.account_no
                    LEFT JOIN loan.device_loan dl2_2 ON dl2_2.finance_no = l.legacy_account_no
                    LEFT JOIN loan.mobileloan_model lmm ON lmm.id = COALESCE(lm1.model, lm2.model, dl2_1.model, dl2_2.model)
                """;
            } else {
                categoryExpr = "COALESCE(v.name, 'Unknown Dealer')";
                dimensionJoin = "LEFT JOIN cbs.vendor v ON l.vendor = v.code";
            }

            String sql = String.format("""
                SELECT
                    %s AS category_name,
                    SUM(CASE WHEN COALESCE(p.dpd, 0) = 0 THEN COALESCE(p.exposure, l.loan_amount, 0) ELSE 0 END) AS dpd0_val,
                    SUM(CASE WHEN COALESCE(p.dpd, 0) BETWEEN 1 AND 30 THEN COALESCE(p.exposure, l.loan_amount, 0) ELSE 0 END) AS dpd1_30_val,
                    SUM(CASE WHEN COALESCE(p.dpd, 0) BETWEEN 31 AND 60 THEN COALESCE(p.exposure, l.loan_amount, 0) ELSE 0 END) AS dpd31_60_val,
                    SUM(CASE WHEN COALESCE(p.dpd, 0) BETWEEN 61 AND 90 THEN COALESCE(p.exposure, l.loan_amount, 0) ELSE 0 END) AS dpd61_90_val,
                    SUM(CASE WHEN COALESCE(p.dpd, 0) > 90 OR p.loan_status = 'N' THEN COALESCE(p.exposure, l.loan_amount, 0) ELSE 0 END) AS dpdAbove90_val
                FROM cbs.portfolio p
                INNER JOIN cbs.loan l
                    ON (l.account_no = p.account_no OR l.legacy_account_no = p.account_no)
                    AND l.account_series = p.series
                LEFT JOIN cbs.branch br ON l.branch = CAST(br.branch_code AS CHAR)
                LEFT JOIN cbs.product pr ON l.product = CAST(pr.code_val AS CHAR)
                %s
                WHERE p.portfolio_date = ? AND p.sync_time = ?
                GROUP BY category_name
                ORDER BY category_name ASC
            """, categoryExpr, dimensionJoin);

            List<Map<String, Object>> result = jdbcTemplate.queryForList(sql, latestPortfolioDate, latestSyncTime);

            Map<String, List<Map<String, Object>>> newCache = new HashMap<>(dpdChartCache);
            newCache.put(cacheKey, result);
            dpdChartCache = Collections.unmodifiableMap(newCache);
            dpdChartCacheLoadedAt = now;

            return result;
        }
    }

    public List<Map<String, Object>> getMonthWiseBusiness() {
        long now = System.currentTimeMillis();
        if (monthBusinessCacheLoadedAt > 0L && now - monthBusinessCacheLoadedAt < DASHBOARD_CACHE_TTL_MS) {
            return monthBusinessCache;
        }

        synchronized (monthBusinessCacheLock) {
            now = System.currentTimeMillis();
            if (monthBusinessCacheLoadedAt > 0L && now - monthBusinessCacheLoadedAt < DASHBOARD_CACHE_TTL_MS) {
                return monthBusinessCache;
            }

            String sql = """
                SELECT
                    DATE_FORMAT(disbursed_date, '%b %Y') AS month_name,
                    DATE_FORMAT(disbursed_date, '%Y-%m') AS month_key,
                    COUNT(*) AS business_count,
                    COALESCE(SUM(loan_amount), 0) AS business_amount
                FROM cbs.loan
                WHERE disbursed_date >= CASE WHEN MONTH(CURRENT_DATE()) >= 4 THEN DATE_FORMAT(CURRENT_DATE(), '%Y-04-01') ELSE DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 YEAR), '%Y-04-01') END
                  AND disbursed_date < CASE WHEN MONTH(CURRENT_DATE()) >= 4 THEN DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 1 YEAR), '%Y-04-01') ELSE DATE_FORMAT(CURRENT_DATE(), '%Y-04-01') END
                GROUP BY DATE_FORMAT(disbursed_date, '%b %Y'), DATE_FORMAT(disbursed_date, '%Y-%m')
                ORDER BY month_key ASC
            """;
            monthBusinessCache = jdbcTemplate.queryForList(sql);
            monthBusinessCacheLoadedAt = now;
            return monthBusinessCache;
        }
    }

    public List<Map<String, Object>> getMonthWiseDpdComparison() {
        long now = System.currentTimeMillis();
        if (monthDpdCacheLoadedAt > 0L && now - monthDpdCacheLoadedAt < DASHBOARD_CACHE_TTL_MS) {
            return monthDpdCache;
        }

        synchronized (monthDpdCacheLock) {
            now = System.currentTimeMillis();
            if (monthDpdCacheLoadedAt > 0L && now - monthDpdCacheLoadedAt < DASHBOARD_CACHE_TTL_MS) {
                return monthDpdCache;
            }

            String sql = """
                SELECT
                    DATE_FORMAT(p.portfolio_date, '%b %Y') AS month_name,
                    DATE_FORMAT(p.portfolio_date, '%Y-%m') AS month_key,
                    SUM(CASE WHEN COALESCE(p.dpd, 0) = 0 THEN p.exposure ELSE 0 END) AS dpd0_val,
                    SUM(CASE WHEN COALESCE(p.dpd, 0) BETWEEN 1 AND 30 THEN p.exposure ELSE 0 END) AS dpd1_30_val,
                    SUM(CASE WHEN COALESCE(p.dpd, 0) BETWEEN 31 AND 60 THEN p.exposure ELSE 0 END) AS dpd31_60_val,
                    SUM(CASE WHEN COALESCE(p.dpd, 0) BETWEEN 61 AND 90 THEN p.exposure ELSE 0 END) AS dpd61_90_val,
                    SUM(CASE WHEN COALESCE(p.dpd, 0) > 90 OR p.loan_status = 'N' THEN p.exposure ELSE 0 END) AS dpdAbove90_val
                FROM cbs.portfolio p
                INNER JOIN (
                    SELECT
                        p2.portfolio_date,
                        MAX(p2.sync_time) AS max_sync_time
                    FROM cbs.portfolio p2
                    INNER JOIN (
                        SELECT
                            DATE_FORMAT(portfolio_date, '%Y-%m') AS month_key,
                            MAX(portfolio_date) AS max_date
                        FROM cbs.portfolio
                        WHERE portfolio_date >= CASE WHEN MONTH(CURRENT_DATE()) >= 4 THEN DATE_FORMAT(CURRENT_DATE(), '%Y-04-01') ELSE DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 YEAR), '%Y-04-01') END
                          AND portfolio_date < CASE WHEN MONTH(CURRENT_DATE()) >= 4 THEN DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 1 YEAR), '%Y-04-01') ELSE DATE_FORMAT(CURRENT_DATE(), '%Y-04-01') END
                        GROUP BY DATE_FORMAT(portfolio_date, '%Y-%m')
                    ) m ON p2.portfolio_date = m.max_date
                    GROUP BY p2.portfolio_date
                ) s ON p.portfolio_date = s.portfolio_date AND p.sync_time = s.max_sync_time
                GROUP BY p.portfolio_date, DATE_FORMAT(p.portfolio_date, '%b %Y'), DATE_FORMAT(p.portfolio_date, '%Y-%m')
                ORDER BY month_key ASC
            """;
            monthDpdCache = jdbcTemplate.queryForList(sql);
            monthDpdCacheLoadedAt = now;
            return monthDpdCache;
        }
    }
}
