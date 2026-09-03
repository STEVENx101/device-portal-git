package com.fintrex.deviceportal.repository;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;

@Repository
public class DashboardRepository {

    private final JdbcTemplate jdbcTemplate;

    public DashboardRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    private String getProductFilterSql(String product) {
        if ("MF".equalsIgnoreCase(product)) {
            return " AND pr.product_code = 'MF' ";
        } else if ("LF".equalsIgnoreCase(product)) {
            return " AND pr.product_code IN ('LF', 'laptop') ";
        }
        return "";
    }

    private String getPortfolioDateSubquery(String month) {
        if (month != null && month.matches("^\\d{4}-\\d{2}$")) {
            return String.format("""
                (SELECT COALESCE(
                    (SELECT MAX(portfolio_date) FROM cbs.portfolio WHERE portfolio_date >= '%s-01' AND portfolio_date <= LAST_DAY('%s-01')),
                    (SELECT MAX(portfolio_date) FROM cbs.portfolio WHERE portfolio_date <= LAST_DAY('%s-01')),
                    (SELECT MAX(portfolio_date) FROM cbs.portfolio)
                ))
            """, month, month, month);
        }
        return "(SELECT MAX(portfolio_date) FROM cbs.portfolio)";
    }

    private String getMonthStartExpr(String month) {
        if (month != null && month.matches("^\\d{4}-\\d{2}$")) {
            return "'" + month + "-01'";
        }
        return "DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')";
    }

    private String getMonthEndExpr(String month) {
        if (month != null && month.matches("^\\d{4}-\\d{2}$")) {
            return "DATE_ADD('" + month + "-01', INTERVAL 1 MONTH)";
        }
        return "DATE_ADD(DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01'), INTERVAL 1 MONTH)";
    }

    private String getMonthRefDate(String month) {
        if (month != null && month.matches("^\\d{4}-\\d{2}$")) {
            return "'" + month + "-01'";
        }
        return "CURRENT_DATE()";
    }

    public Map<String, Object> getNStatusKpis(String product) {
        return getNStatusKpis(product, null);
    }

    public Map<String, Object> getNStatusKpis(String product, String month) {
        Map<String, Object> stats = new HashMap<>();
        String filter = getProductFilterSql(product);
        String portfolioSubquery = getPortfolioDateSubquery(month);

        // 1. Month stats query
        String sqlMonth = String.format("""
                    SELECT
                        COUNT(*) AS month_count,
                        COALESCE(SUM(l.loan_amount), 0) AS month_amount
                    FROM cbs.loan l
                    LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                    WHERE l.disbursed_date >= %s
                      AND l.disbursed_date < %s
                      %s
                """, getMonthStartExpr(month), getMonthEndExpr(month), filter);
        Map<String, Object> monthStats = jdbcTemplate.queryForMap(sqlMonth);

        // 2. YTD stats query
        String refDate = getMonthRefDate(month);
        String sqlYtd = String.format("""
                    SELECT
                        COUNT(*) AS ytd_count,
                        COALESCE(SUM(l.loan_amount), 0) AS ytd_amount
                    FROM cbs.loan l
                    LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                    WHERE l.disbursed_date >= CASE WHEN MONTH(%s) >= 4 THEN DATE_FORMAT(%s, '%%Y-04-01') ELSE DATE_FORMAT(DATE_SUB(%s, INTERVAL 1 YEAR), '%%Y-04-01') END
                      AND l.disbursed_date < CASE WHEN MONTH(%s) >= 4 THEN DATE_FORMAT(DATE_ADD(%s, INTERVAL 1 YEAR), '%%Y-04-01') ELSE DATE_FORMAT(%s, '%%Y-04-01') END
                      %s
                """, refDate, refDate, refDate, refDate, refDate, refDate, filter);
        Map<String, Object> ytdStats = jdbcTemplate.queryForMap(sqlYtd);

        // 3. Portfolio stats query
        String sqlPortfolio = String.format("""
                    SELECT
                        COUNT(DISTINCT p.account_no) AS portfolio_count,
                        COALESCE(SUM(p.exposure), 0) AS portfolio_amount
                    FROM cbs.portfolio p
                    JOIN cbs.loan l ON l.account_no = p.account_no
                    LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                    WHERE p.portfolio_date = %s
                      AND p.loan_status IN ('A', 'N')
                    %s
                """, portfolioSubquery, filter);
        Map<String, Object> portfolioStats = jdbcTemplate.queryForMap(sqlPortfolio);

        // 4. NPL outstanding and count query where account_status = 'N'
        String sqlNplStats = String.format("""
                    SELECT
                        COUNT(DISTINCT p.account_no) AS npl_count,
                        SUM(p.exposure) AS npl_exposure,
                        SUM(p.total_due) AS npl_arrears
                    FROM cbs.portfolio p
                    JOIN cbs.loan l ON l.account_no = p.account_no
                    LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                    WHERE p.portfolio_date = %s
                      AND p.performing_status = 'Non-Performing'
                      AND p.loan_status IN ('A', 'N')
                    %s
                """, portfolioSubquery, filter);
        Map<String, Object> nplStats = jdbcTemplate.queryForMap(sqlNplStats);

        // 5. Security-wise Locked / Unlocked count query
        String sqlSecurityStats = String.format("""
                    SELECT
                        CASE
                            WHEN pr.product_code IN ('LF','laptop') THEN 'ABSOLUTE'
                            WHEN pr.product_code='MF'
                                  AND ml.knox_compatibility='yes'
                                  THEN 'KNOX'
                            WHEN pr.product_code='MF'
                                  THEN 'DATACULTR'
                            ELSE 'OTHER'
                        END AS security_type,
                        SUM(ml.locked=1) AS locked_count,
                        SUM(ml.locked=0 OR ml.locked IS NULL) AS unlocked_count
                    FROM (
                        SELECT
                            account_no AS finance_no,
                            product
                        FROM cbs.loan
                        UNION ALL
                        SELECT
                            legacy_account_no,
                            product
                        FROM cbs.loan
                        WHERE legacy_account_no IS NOT NULL
                    ) l
                    LEFT JOIN loan.mobileloan ml
                           ON ml.finance_no=l.finance_no
                    LEFT JOIN cbs.product pr
                           ON pr.code_val = CAST(l.product AS UNSIGNED)
                    WHERE 1=1 %s
                    GROUP BY security_type
                """, filter);
        List<Map<String, Object>> securityStats = jdbcTemplate.queryForList(sqlSecurityStats);

        // 6. Active loan count
        String sqlActiveCount = String.format("""
                    SELECT COUNT(*) AS active_count
                    FROM cbs.loan l
                    LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                    WHERE l.account_status = 'A'
                    %s
                """, filter);
        Map<String, Object> activeStats = jdbcTemplate.queryForMap(sqlActiveCount);

        // 7. Arrears count and amount from target portfolio
        String sqlArrearsStats = String.format("""
                    SELECT
                        COUNT(DISTINCT p.account_no) AS arrears_count,
                        COALESCE(SUM(p.total_due), 0) AS arrears_amount
                    FROM cbs.portfolio p
                    JOIN cbs.loan l ON l.account_no = p.account_no
                    LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                    WHERE p.portfolio_date = %s
                      AND p.total_due > 0
                      AND p.loan_status IN ('A')
                      AND p.performing_status = 'Performing'
                    %s
                """, portfolioSubquery, filter);
        Map<String, Object> arrearsStats = jdbcTemplate.queryForMap(sqlArrearsStats);

        // 8. Settled loans count and amount during the selected month
        String sqlSettledStats = String.format("""
                    SELECT
                        COUNT(DISTINCT l.account_no) AS settled_count,
                        COALESCE(SUM(l.loan_amount), 0) AS settled_amount
                    FROM cbs.loan l
                    LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                    WHERE l.closed_date >= %s
                      AND l.closed_date < %s
                    %s
                """, getMonthStartExpr(month), getMonthEndExpr(month), filter);
        Map<String, Object> settledStats = jdbcTemplate.queryForMap(sqlSettledStats);

        // 8a. Overall loans count and amount (Overall Business)
        String sqlOverallStats = String.format("""
                    SELECT
                        COUNT(*) AS overall_count,
                        COALESCE(SUM(l.loan_amount), 0) AS overall_amount
                    FROM cbs.loan l
                    LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                    WHERE 1=1
                    %s
                """, filter);
        Map<String, Object> overallStats = jdbcTemplate.queryForMap(sqlOverallStats);

        // 9. Performing Arrears (0-90 DPD, performing_status = Performing)
        String sqlPerfArrears = String.format("""
                    SELECT
                        COUNT(DISTINCT p.account_no) AS count_val,
                        COALESCE(SUM(p.exposure), 0) AS amount_val
                    FROM cbs.portfolio p
                    JOIN cbs.loan l ON l.account_no = p.account_no
                    LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                    WHERE p.portfolio_date = %s
                    AND p.dpd BETWEEN 1 AND 90
                    AND p.performing_status = 'Performing'
                    %s
                """, portfolioSubquery, filter);
        Map<String, Object> perfArrearsStats = jdbcTemplate.queryForMap(sqlPerfArrears);

        // 10. DPD 0 Portfolio (dpd = 0)
        String sqlDpdZeroPortfolio = String.format("""
                    SELECT
                        COUNT(DISTINCT p.account_no) AS count_val,
                        COALESCE(SUM(p.exposure), 0) AS amount_val
                    FROM cbs.portfolio p
                    JOIN cbs.loan l ON l.account_no = p.account_no
                    LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                    WHERE p.portfolio_date = %s
                      AND p.dpd = 0
                      AND p.loan_status IN ('A', 'N')
                    %s
                """, portfolioSubquery, filter);
        Map<String, Object> dpdZeroPortfolioStats = jdbcTemplate.queryForMap(sqlDpdZeroPortfolio);

        stats.put("nMonthCount", monthStats.get("month_count") != null ? monthStats.get("month_count") : 0);
        stats.put("nMonthAmount", monthStats.get("month_amount") != null ? monthStats.get("month_amount") : 0);
        stats.put("nYtdCount", ytdStats.get("ytd_count") != null ? ytdStats.get("ytd_count") : 0);
        stats.put("nYtdAmount", ytdStats.get("ytd_amount") != null ? ytdStats.get("ytd_amount") : 0);
        stats.put("nOverallCount", overallStats.get("overall_count") != null ? overallStats.get("overall_count") : 0);
        stats.put("nOverallAmount", overallStats.get("overall_amount") != null ? overallStats.get("overall_amount") : 0);
        stats.put("nPortfolioCount",
                portfolioStats.get("portfolio_count") != null ? portfolioStats.get("portfolio_count") : 0);
        stats.put("nPortfolioAmount",
                portfolioStats.get("portfolio_amount") != null ? portfolioStats.get("portfolio_amount") : 0);

        stats.put("nNplCount", nplStats.get("npl_count") != null ? nplStats.get("npl_count") : 0);
        stats.put("nNplExposure", nplStats.get("npl_exposure") != null ? nplStats.get("npl_exposure") : 0);
        stats.put("nNplArrears", nplStats.get("npl_arrears") != null ? nplStats.get("npl_arrears") : 0);

        stats.put("activeCount", activeStats.get("active_count") != null ? activeStats.get("active_count") : 0);
        stats.put("arrearsCount", arrearsStats.get("arrears_count") != null ? arrearsStats.get("arrears_count") : 0);
        stats.put("arrearsAmount", arrearsStats.get("arrears_amount") != null ? arrearsStats.get("arrears_amount") : 0);

        stats.put("settledCount", settledStats.get("settled_count") != null ? settledStats.get("settled_count") : 0);
        stats.put("settledAmount", settledStats.get("settled_amount") != null ? settledStats.get("settled_amount") : 0);

        stats.put("perfArrearsCount", perfArrearsStats.get("count_val") != null ? perfArrearsStats.get("count_val") : 0);
        stats.put("perfArrearsAmount", perfArrearsStats.get("amount_val") != null ? perfArrearsStats.get("amount_val") : 0);
        stats.put("dpdZeroPortfolioCount", dpdZeroPortfolioStats.get("count_val") != null ? dpdZeroPortfolioStats.get("count_val") : 0);
        stats.put("dpdZeroPortfolioAmount", dpdZeroPortfolioStats.get("amount_val") != null ? dpdZeroPortfolioStats.get("amount_val") : 0);

        stats.put("securityStats", securityStats);

        return stats;
    }

    public Map<String, Object> getDashboardStats(String product) {
        return getNStatusKpis(product, null);
    }

    public Map<String, Object> getDashboardStats(String product, String month) {
        return getNStatusKpis(product, month);
    }

    public List<Map<String, Object>> getDpdChartData(String product, String dimension) {
        String sqlLatest = """
                    SELECT portfolio_date
                    FROM cbs.portfolio
                    WHERE portfolio_date IS NOT NULL
                    ORDER BY portfolio_date DESC
                    LIMIT 1
                """;
        Map<String, Object> latest = jdbcTemplate.queryForMap(sqlLatest);
        Object latestPortfolioDate = latest.get("portfolio_date");

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

        String filter = getProductFilterSql(product);

        String sql = String.format(
                """
                                            SELECT
                                                %s AS category_name,
                                                SUM(CASE WHEN COALESCE(p1.dpd, 0) = 0 THEN COALESCE(p1.exposure, l.loan_amount, 0) ELSE 0 END) AS dpd0_val,
                                                SUM(CASE WHEN COALESCE(p1.dpd, 0) BETWEEN 1 AND 30 THEN COALESCE(p1.exposure, l.loan_amount, 0) ELSE 0 END) AS dpd1_30_val,
                                                SUM(CASE WHEN COALESCE(p1.dpd, 0) BETWEEN 31 AND 60 THEN COALESCE(p1.exposure, l.loan_amount, 0) ELSE 0 END) AS dpd31_60_val,
                                                SUM(CASE WHEN COALESCE(p1.dpd, 0) BETWEEN 61 AND 90 THEN COALESCE(p1.exposure, l.loan_amount, 0) ELSE 0 END) AS dpd61_90_val,
                                                SUM(CASE WHEN COALESCE(p1.dpd, 0) > 90 OR p1.loan_status = 'N' THEN COALESCE(p1.exposure, l.loan_amount, 0) ELSE 0 END) AS dpdAbove90_val
                                            FROM cbs.loan l
                                            LEFT JOIN cbs.portfolio p1
                                                ON p1.account_no = l.account_no
                                                AND p1.series = l.account_series
                                                AND p1.portfolio_date = ?
                                            LEFT JOIN cbs.branch br ON CAST(l.branch AS UNSIGNED) = br.branch_code
                                            LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                                            %s
                                            WHERE 1=1 %s
                                            GROUP BY category_name
                                            ORDER BY category_name ASC
                        """,
                categoryExpr, dimensionJoin, filter);

        return jdbcTemplate.queryForList(sql, latestPortfolioDate);
    }

    public List<Map<String, Object>> getMonthWiseBusiness(String product) {
        String filter = getProductFilterSql(product);
        String sql = String.format("""
                    SELECT
                        DATE_FORMAT(l.disbursed_date, '%%b %%Y') AS month_name,
                        DATE_FORMAT(l.disbursed_date, '%%Y-%%m') AS month_key,
                        COUNT(*) AS business_count,
                        COALESCE(SUM(l.loan_amount), 0) AS business_amount
                    FROM cbs.loan l
                    LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                    WHERE l.disbursed_date >= DATE_SUB(DATE_FORMAT(CURRENT_DATE(), '%%Y-%%m-01'), INTERVAL 5 MONTH)
                      AND l.disbursed_date < DATE_ADD(DATE_FORMAT(CURRENT_DATE(), '%%Y-%%m-01'), INTERVAL 1 MONTH)
                      %s
                    GROUP BY DATE_FORMAT(l.disbursed_date, '%%b %%Y'), DATE_FORMAT(l.disbursed_date, '%%Y-%%m')
                    ORDER BY month_key ASC
                """, filter);
        return jdbcTemplate.queryForList(sql);
    }

    public List<Map<String, Object>> getMonthWiseDpdComparison(String product) {
        String filter = getProductFilterSql(product);
        String sql = String.format("""
                    SELECT
                        DATE_FORMAT(p.portfolio_date, '%%b %%Y') AS month_name,
                        DATE_FORMAT(p.portfolio_date, '%%Y-%%m') AS month_key,
                        SUM(CASE WHEN COALESCE(p.dpd, 0) = 0 THEN p.exposure ELSE 0 END) AS dpd0_val,
                        SUM(CASE WHEN COALESCE(p.dpd, 0) BETWEEN 1 AND 30 THEN p.exposure ELSE 0 END) AS dpd1_30_val,
                        SUM(CASE WHEN COALESCE(p.dpd, 0) BETWEEN 31 AND 60 THEN p.exposure ELSE 0 END) AS dpd31_60_val,
                        SUM(CASE WHEN COALESCE(p.dpd, 0) BETWEEN 61 AND 90 THEN p.exposure ELSE 0 END) AS dpd61_90_val,
                        SUM(CASE WHEN COALESCE(p.dpd, 0) > 90 OR p.loan_status = 'N' THEN p.exposure ELSE 0 END) AS dpdAbove90_val
                    FROM cbs.portfolio p
                    INNER JOIN (
                        SELECT
                            DATE_FORMAT(portfolio_date, '%%Y-%%m') AS month_key,
                            MAX(portfolio_date) AS max_date
                        FROM cbs.portfolio
                        WHERE portfolio_date >= CASE WHEN MONTH(CURRENT_DATE()) >= 4 THEN DATE_FORMAT(CURRENT_DATE(), '%%Y-04-01') ELSE DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 YEAR), '%%Y-04-01') END
                          AND portfolio_date < CASE WHEN MONTH(CURRENT_DATE()) >= 4 THEN DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 1 YEAR), '%%Y-04-01') ELSE DATE_FORMAT(CURRENT_DATE(), '%%Y-04-01') END
                        GROUP BY DATE_FORMAT(portfolio_date, '%%Y-%%m')
                    ) m ON p.portfolio_date = m.max_date
                    JOIN (
                        SELECT account_no AS finance_no, product FROM cbs.loan
                        UNION ALL
                        SELECT legacy_account_no AS finance_no, product FROM cbs.loan WHERE legacy_account_no IS NOT NULL
                    ) l ON l.finance_no = p.account_no
                    LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                    WHERE 1=1 %s
                    GROUP BY p.portfolio_date, DATE_FORMAT(p.portfolio_date, '%%b %%Y'), DATE_FORMAT(p.portfolio_date, '%%Y-%%m')
                    ORDER BY month_key ASC
                """, filter);
        return jdbcTemplate.queryForList(sql);
    }

    public List<Map<String, Object>> getVendorPaymentsChannelChart(String product) {
        return getVendorPaymentsChannelChart(product, null);
    }

    public List<Map<String, Object>> getVendorPaymentsChannelChart(String product, String month) {
        String filter = getProductFilterSql(product);
        String dateClause;
        if (month != null && month.matches("^\\d{4}-\\d{2}$")) {
            dateClause = String.format("l.disbursed_date >= DATE_SUB(LAST_DAY('%s-01'), INTERVAL 6 DAY) AND l.disbursed_date <= LAST_DAY('%s-01')", month, month);
        } else {
            dateClause = "l.disbursed_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 6 DAY) AND l.disbursed_date <= CURRENT_DATE()";
        }
        String sql = String.format("""
                SELECT
                    DATE_FORMAT(l.disbursed_date, '%%d %%b') AS channel_name,
                    DATE_FORMAT(l.disbursed_date, '%%Y-%%m-%%d') AS db_date,
                    COALESCE(SUM(l.loan_amount), 0) AS total_amount
                FROM cbs.loan l
                LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                WHERE %s
                  %s
                GROUP BY DATE_FORMAT(l.disbursed_date, '%%d %%b'), DATE_FORMAT(l.disbursed_date, '%%Y-%%m-%%d')
                ORDER BY db_date ASC
                """, dateClause, filter);
        return jdbcTemplate.queryForList(sql);
    }

    public Map<String, Object> getDeviceStatusCharts(String product) {
        return getDeviceStatusCharts(product, null);
    }

    public Map<String, Object> getDeviceStatusCharts(String product, String month) {
        Map<String, Object> result = new HashMap<>();
        String filter = getProductFilterSql(product);

        // Fetch latest portfolio date dynamically for month or overall
        String sqlLatest;
        if (month != null && month.matches("^\\d{4}-\\d{2}$")) {
            sqlLatest = String.format("""
                SELECT COALESCE(
                    (SELECT portfolio_date FROM cbs.portfolio WHERE portfolio_date >= '%s-01' AND portfolio_date <= LAST_DAY('%s-01') ORDER BY portfolio_date DESC LIMIT 1),
                    (SELECT portfolio_date FROM cbs.portfolio WHERE portfolio_date <= LAST_DAY('%s-01') ORDER BY portfolio_date DESC LIMIT 1),
                    (SELECT portfolio_date FROM cbs.portfolio WHERE portfolio_date IS NOT NULL ORDER BY portfolio_date DESC LIMIT 1)
                ) AS portfolio_date
            """, month, month, month);
        } else {
            sqlLatest = """
                SELECT portfolio_date
                FROM cbs.portfolio
                WHERE portfolio_date IS NOT NULL
                ORDER BY portfolio_date DESC
                LIMIT 1
            """;
        }
        Map<String, Object> latest = jdbcTemplate.queryForMap(sqlLatest);
        Object latestPortfolioDate = latest.get("portfolio_date");

        // Mobile Security Stacked Bar query
        String mobileSecBarSql = String.format("""
                     SELECT 
                         CASE WHEN ml.locked = 1 THEN 'Locked' ELSE 'Unlocked' END AS lock_status,
                         COALESCE(p.performing_status, 'Performing') AS performing_status,
                         CASE WHEN ml.knox_compatibility = 'yes' THEN 'Knox' ELSE 'Datacultr' END AS provider,
                         COUNT(*) AS cnt
                     FROM loan.mobileloan ml
                     INNER JOIN cbs.loan l ON l.key_account = ml.finance_no
                     LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                     LEFT JOIN cbs.portfolio p ON p.account_no = l.account_no
                         AND p.series = l.account_series
                         AND p.portfolio_date = ?
                     WHERE (ml.locked IN (0, 1) OR ml.locked IS NULL) AND l.account_status IN ('A', 'N', 'P', 'F')
                       AND p.loan_status IN ('A', 'N') %s
                     GROUP BY lock_status, performing_status, provider
                 """, filter);

        // Laptop Performing vs Non-Performing
        String laptopPerfSql = String.format("""
                    SELECT
                        CASE
                            WHEN p1.performing_status = 'Non-Performing'
                                THEN 'Non-Performing'
                            ELSE 'Performing'
                        END AS state_name,
                        COUNT(*) AS count_val
                    FROM cbs.loan l
                    INNER JOIN cbs.product pr
                        ON CAST(l.product AS UNSIGNED) = pr.code_val
                    LEFT JOIN cbs.portfolio p1
                        ON p1.account_no = l.account_no
                        AND p1.series = l.account_series
                        AND p1.portfolio_date = ?
                    WHERE pr.product_code IN ('LF', 'laptop') %s
                    GROUP BY state_name
                    ORDER BY state_name
                """, filter);
        List<Map<String, Object>> laptopPerf = "MF".equalsIgnoreCase(product) ? new ArrayList<>() :
                jdbcTemplate.queryForList(laptopPerfSql, latestPortfolioDate);

        String laptopLockSql = String.format("""
                     SELECT
                         CASE
                             WHEN dl.locked = 1 THEN 'Locked'
                             ELSE 'Unlocked'
                         END AS device_status,
                         COUNT(*) AS device_count
                     FROM loan.device_loan dl
                     INNER JOIN cbs.loan l ON l.key_account = dl.finance_no
                     LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                     WHERE (dl.locked IN (0, 1) OR dl.locked IS NULL) AND l.account_status IN ('A', 'N', 'P', 'F') %s
                     GROUP BY dl.locked
                     ORDER BY dl.locked DESC
                 """, filter);

        List<Map<String, Object>> laptopLock = new ArrayList<>();
        if (!"MF".equalsIgnoreCase(product)) {
            List<Map<String, Object>> laptopLockRaw = jdbcTemplate.queryForList(laptopLockSql);
            for (Map<String, Object> raw : laptopLockRaw) {
                Map<String, Object> map = new HashMap<>();
                map.put("state_name", raw.get("device_status"));
                map.put("count_val", raw.get("device_count"));
                laptopLock.add(map);
            }
        }

        int lockedKnox = 0;
        int lockedDatacultr = 0;
        int unlockedKnox = 0;
        int unlockedDatacultr = 0;
        int performingKnox = 0;
        int performingDatacultr = 0;
        int nonPerformingKnox = 0;
        int nonPerformingDatacultr = 0;

        List<Map<String, Object>> mobilePerforming = new ArrayList<>();
        List<Map<String, Object>> mobileLock = new ArrayList<>();

        if (!"LF".equalsIgnoreCase(product)) {
            List<Map<String, Object>> mobileSecBarRaw = jdbcTemplate.queryForList(mobileSecBarSql, latestPortfolioDate);
            for (Map<String, Object> row : mobileSecBarRaw) {
                String lockStatus = (String) row.get("lock_status");
                String performingStatus = (String) row.get("performing_status");
                String provider = (String) row.get("provider");
                int count = ((Number) row.get("cnt")).intValue();

                if ("Knox".equals(provider)) {
                    if ("Locked".equals(lockStatus)) {
                        lockedKnox += count;
                    } else {
                        unlockedKnox += count;
                    }
                    if ("Non-Performing".equalsIgnoreCase(performingStatus)) {
                        nonPerformingKnox += count;
                    } else {
                        performingKnox += count;
                    }
                } else {
                    if ("Locked".equals(lockStatus)) {
                        lockedDatacultr += count;
                    } else {
                        unlockedDatacultr += count;
                    }
                    if ("Non-Performing".equalsIgnoreCase(performingStatus)) {
                        nonPerformingDatacultr += count;
                    } else {
                        performingDatacultr += count;
                    }
                }
            }

            // Populate fallback/compatibility lists for mobilePerforming
            Map<String, Object> perfMap = new HashMap<>();
            perfMap.put("state_name", "Performing");
            perfMap.put("count_val", performingKnox + performingDatacultr);
            mobilePerforming.add(perfMap);

            Map<String, Object> nonPerfMap = new HashMap<>();
            nonPerfMap.put("state_name", "Non-Performing");
            nonPerfMap.put("count_val", nonPerformingKnox + nonPerformingDatacultr);
            mobilePerforming.add(nonPerfMap);

            // Populate fallback/compatibility lists for mobileLock
            Map<String, Object> lockedMap = new HashMap<>();
            lockedMap.put("state_name", "Locked");
            lockedMap.put("count_val", lockedKnox + lockedDatacultr);
            mobileLock.add(lockedMap);

            Map<String, Object> unlockedMap = new HashMap<>();
            unlockedMap.put("state_name", "Unlocked");
            unlockedMap.put("count_val", unlockedKnox + unlockedDatacultr);
            mobileLock.add(unlockedMap);
        }

        List<Integer> knoxList = new ArrayList<>();
        knoxList.add(lockedKnox);
        knoxList.add(unlockedKnox);
        knoxList.add(performingKnox);
        knoxList.add(nonPerformingKnox);

        List<Integer> datacultrList = new ArrayList<>();
        datacultrList.add(lockedDatacultr);
        datacultrList.add(unlockedDatacultr);
        datacultrList.add(performingDatacultr);
        datacultrList.add(nonPerformingDatacultr);

        Map<String, Object> mobileSecurityBarData = new HashMap<>();
        mobileSecurityBarData.put("knox", knoxList);
        mobileSecurityBarData.put("datacultr", datacultrList);

        result.put("mobilePerforming", mobilePerforming);
        result.put("mobileLock", mobileLock);
        result.put("laptopPerforming", laptopPerf);
        result.put("laptopLock", laptopLock);
        result.put("mobileSecurityBarData", mobileSecurityBarData);
        return result;
    }

    public List<Map<String, Object>> getDealerCurrentMonthBusiness(String product) {
        return getDealerCurrentMonthBusiness(product, null);
    }

    public List<Map<String, Object>> getDealerCurrentMonthBusiness(String product, String month) {
        String filter = getProductFilterSql(product);
        String sql = String.format("""
                SELECT
                    COALESCE(v.name, 'Unknown Dealer') AS dealer_name,
                    COUNT(*) AS loan_count,
                    COALESCE(SUM(l.loan_amount), 0) AS total_amount
                FROM cbs.loan l
                LEFT JOIN cbs.vendor v ON l.vendor = v.code
                LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                WHERE l.disbursed_date >= %s
                  AND l.disbursed_date < %s
                  %s
                GROUP BY dealer_name
                ORDER BY total_amount DESC
                """, getMonthStartExpr(month), getMonthEndExpr(month), filter);
        return jdbcTemplate.queryForList(sql);
    }

    public List<Map<String, Object>> getDealerPortfolioBusiness(String product) {
        return getDealerPortfolioBusiness(product, null);
    }

    public List<Map<String, Object>> getDealerPortfolioBusiness(String product, String month) {
        String filter = getProductFilterSql(product);
        String portfolioSubquery = getPortfolioDateSubquery(month);
        String sql = String.format("""
                SELECT
                    COALESCE(v.name, 'Unknown Dealer') AS dealer_name,
                    COUNT(DISTINCT p.account_no) AS loan_count,
                    COALESCE(SUM(p.exposure), 0) AS total_exposure
                FROM cbs.portfolio p
                INNER JOIN cbs.loan l ON p.account_no = l.account_no AND p.series = l.account_series
                LEFT JOIN cbs.vendor v ON l.vendor = v.code
                LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                WHERE p.portfolio_date = %s
                %s
                GROUP BY dealer_name
                ORDER BY total_exposure DESC
                """, portfolioSubquery, filter);
        return jdbcTemplate.queryForList(sql);
    }

    public List<Map<String, Object>> getArrearsAnalysis(String product) {
        return getArrearsAnalysis(product, null);
    }

    public List<Map<String, Object>> getArrearsAnalysis(String product, String month) {
        String filter = getProductFilterSql(product);
        String portfolioSubquery = getPortfolioDateSubquery(month);
        String sql = String.format("""
                SELECT
                    CASE
                        WHEN COALESCE(p.dpd, 0) BETWEEN 1 AND 30 THEN '1-30 DPD'
                        WHEN COALESCE(p.dpd, 0) BETWEEN 31 AND 60 THEN '31-60 DPD'
                        WHEN COALESCE(p.dpd, 0) BETWEEN 61 AND 90 THEN '61-90 DPD'
                        WHEN COALESCE(p.dpd, 0) > 90 THEN '90+ DPD'
                        ELSE 'Current'
                    END AS dpd_bucket,
                    COUNT(DISTINCT p.account_no) AS account_count,
                    COALESCE(SUM(p.total_due), 0) AS arrears_amount,
                    COALESCE(SUM(p.exposure), 0) AS exposure_amount
                FROM cbs.portfolio p
                JOIN cbs.loan l ON l.account_no = p.account_no
                LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                WHERE p.portfolio_date = %s
                AND p.total_due > 0
                %s
                GROUP BY dpd_bucket
                ORDER BY FIELD(dpd_bucket, 'Current', '1-30 DPD', '31-60 DPD', '61-90 DPD', '90+ DPD')
                """, portfolioSubquery, filter);
        return jdbcTemplate.queryForList(sql);
    }

    public List<Map<String, Object>> getCollectionsDealerWise(String product) {
        return getCollectionsDealerWise(product, null, null);
    }

    public List<Map<String, Object>> getCollectionsDealerWise(String product, String startMonth, String endMonth) {
        String dateFilter;
        if (startMonth != null && !startMonth.trim().isEmpty() && endMonth != null && !endMonth.trim().isEmpty()) {
            dateFilter = String.format("vp.trx_date >= '%s-01' AND vp.trx_date < DATE_ADD('%s-01', INTERVAL 1 MONTH)", startMonth, endMonth);
        } else if (startMonth != null && !startMonth.trim().isEmpty()) {
            dateFilter = String.format("vp.trx_date >= '%s-01'", startMonth);
        } else {
            dateFilter = "vp.trx_date >= DATE_FORMAT(CURRENT_DATE(), '%%Y-%%m-01')";
        }

        String productFilter = "";
        if ("MF".equalsIgnoreCase(product)) {
            productFilter = "AND EXISTS (SELECT 1 FROM cbs.loan l LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val WHERE (vp.account_id = l.account_no OR vp.account_id = l.legacy_account_no) AND pr.product_code = 'MF')";
        } else if ("LF".equalsIgnoreCase(product)) {
            productFilter = "AND EXISTS (SELECT 1 FROM cbs.loan l LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val WHERE (vp.account_id = l.account_no OR vp.account_id = l.legacy_account_no) AND pr.product_code IN ('LF', 'laptop'))";
        }

        String sql = String.format("""
                SELECT
                    COALESCE(vp.status, 'Unknown') AS dealer_name,
                    COUNT(*) AS trx_count,
                    COALESCE(SUM(vp.amount), 0) AS total_collected
                FROM cbs.vendor_payments vp
                WHERE %s
                %s
                GROUP BY COALESCE(vp.status, 'Unknown')
                ORDER BY total_collected DESC
                """, dateFilter, productFilter);
        return jdbcTemplate.queryForList(sql);
    }

    public List<Map<String, Object>> getProductBusinessChart(String product) {
        return getProductBusinessChart(product, null);
    }

    public List<Map<String, Object>> getProductBusinessChart(String product, String month) {
        String filter = getProductFilterSql(product);
        String sql = String.format("""
                SELECT
                    COALESCE(pr.product_name, l.product) AS product_name,
                    COUNT(*) AS business_count,
                    COALESCE(SUM(l.loan_amount), 0) AS business_amount
                FROM cbs.loan l
                LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                WHERE l.disbursed_date >= %s
                  AND l.disbursed_date < %s
                %s
                GROUP BY product_name
                ORDER BY business_amount DESC
                """, getMonthStartExpr(month), getMonthEndExpr(month), filter);
        return jdbcTemplate.queryForList(sql);
    }

    public Map<String, Object> getMobileLockArrearsAnalysis() {
        Map<String, Object> result = new HashMap<>();
        
        String sql = """
            SELECT a.s AS status, IFNULL(b.amt, 0) AS amt
            FROM (SELECT 'Active with Arrears' AS s UNION SELECT 'Locked With no Arrears') a
            LEFT JOIN (
                SELECT 
                    (CASE 
                        WHEN k.locked = 0 AND k.total_due > 200 AND k.dpld >= 5 THEN 'Active with Arrears' 
                        WHEN k.locked = 1 AND k.total_due <= 200 THEN 'Locked With no Arrears' 
                     END) AS st,
                    COUNT(*) AS amt
                FROM call_center.knox_unlock_query_new k 
                GROUP BY 1
            ) b ON a.s = b.st
        """;

        try {
            List<Map<String, Object>> rows = jdbcTemplate.queryForList(sql);
            for (Map<String, Object> row : rows) {
                String status = (String) row.get("status");
                Number amtVal = (Number) row.get("amt");
                int amt = amtVal != null ? amtVal.intValue() : 0;
                if ("Active with Arrears".equalsIgnoreCase(status)) {
                    result.put("unlock_but_more_200", amt);
                } else if ("Locked With no Arrears".equalsIgnoreCase(status)) {
                    result.put("lock_but_less_200", amt);
                }
            }
        } catch (Exception e) {
            result.put("lock_but_less_200", 0);
            result.put("unlock_but_more_200", 0);
        }

        result.put("due_200_500", 0);
        result.put("due_500_1000", 0);
        result.put("due_1000_2000", 0);
        result.put("due_above_2000", 0);

        return result;
    }

    public List<Map<String, Object>> getMaturedNonPerformingAnalysis(String product) {
        return getMaturedNonPerformingAnalysis(product, null);
    }

    public List<Map<String, Object>> getMaturedNonPerformingAnalysis(String product, String month) {
        String sqlLatest;
        if (month != null && month.matches("^\\d{4}-\\d{2}$")) {
            sqlLatest = String.format("""
                SELECT COALESCE(
                    (SELECT portfolio_date FROM cbs.portfolio WHERE portfolio_date >= '%s-01' AND portfolio_date <= LAST_DAY('%s-01') ORDER BY portfolio_date DESC LIMIT 1),
                    (SELECT portfolio_date FROM cbs.portfolio WHERE portfolio_date <= LAST_DAY('%s-01') ORDER BY portfolio_date DESC LIMIT 1),
                    (SELECT portfolio_date FROM cbs.portfolio WHERE portfolio_date IS NOT NULL ORDER BY portfolio_date DESC LIMIT 1)
                ) AS portfolio_date
            """, month, month, month);
        } else {
            sqlLatest = """
                SELECT portfolio_date
                FROM cbs.portfolio
                WHERE portfolio_date IS NOT NULL
                ORDER BY portfolio_date DESC
                LIMIT 1
            """;
        }
        Object latestPortfolioDate = null;
        try {
            Map<String, Object> latest = jdbcTemplate.queryForMap(sqlLatest);
            latestPortfolioDate = latest.get("portfolio_date");
        } catch (Exception e) {
            // fallback if no portfolio exists
        }

        String filter = getProductFilterSql(product);
        String sql = String.format("""
            SELECT
                CASE WHEN l.maturity_date <= %s THEN 'Matured' ELSE 'Non-Matured' END AS maturity_status,
                CASE WHEN COALESCE(p1.performing_status, 'Performing') = 'Non-Performing' THEN 'Non-Performing' ELSE 'Performing' END AS performing_status,
                COUNT(DISTINCT l.account_no) AS contract_count
            FROM cbs.loan l
            LEFT JOIN cbs.portfolio p1 ON p1.account_no = l.account_no 
                AND p1.series = l.account_series
                AND p1.portfolio_date = ?
            LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
            WHERE p1.loan_status IN ('A', 'N')
              %s
            GROUP BY 
                CASE WHEN l.maturity_date <= %s THEN 'Matured' ELSE 'Non-Matured' END,
                CASE WHEN COALESCE(p1.performing_status, 'Performing') = 'Non-Performing' THEN 'Non-Performing' ELSE 'Performing' END
        """, getMonthRefDate(month), filter, getMonthRefDate(month));
        return jdbcTemplate.queryForList(sql, latestPortfolioDate);
    }

    public List<Map<String, Object>> getOutstandingAnalysis(String product) {
        return getOutstandingAnalysis(product, null);
    }

    public List<Map<String, Object>> getOutstandingAnalysis(String product, String month) {
        String filter = getProductFilterSql(product);
        String portfolioSubquery = getPortfolioDateSubquery(month);
        String sql = String.format("""
            SELECT
                CASE WHEN COALESCE(p.exposure, 0) > 1000 THEN 'Above 1000' ELSE 'Below 1000' END AS outstanding_bucket,
                COUNT(DISTINCT p.account_no) AS account_count,
                COALESCE(SUM(p.exposure), 0) AS total_exposure
            FROM cbs.portfolio p
            JOIN cbs.loan l ON l.account_no = p.account_no
            LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
            WHERE p.portfolio_date = %s
              %s
            GROUP BY outstanding_bucket
        """, portfolioSubquery, filter);
        return jdbcTemplate.queryForList(sql);
    }

    public List<Map<String, Object>> getPaymentsStatusChart(String product) {
        String productFilter = "";
        if ("MF".equalsIgnoreCase(product)) {
            productFilter = "AND EXISTS (SELECT 1 FROM cbs.loan l LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val WHERE (vp.account_id = l.account_no OR vp.account_id = l.legacy_account_no) AND pr.product_code = 'MF')";
        } else if ("LF".equalsIgnoreCase(product)) {
            productFilter = "AND EXISTS (SELECT 1 FROM cbs.loan l LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val WHERE (vp.account_id = l.account_no OR vp.account_id = l.legacy_account_no) AND pr.product_code IN ('LF', 'laptop'))";
        }

        String sql = String.format("""
                SELECT
                    DATE_FORMAT(vp.trx_date, '%%Y-%%m') AS month_key,
                    DATE_FORMAT(vp.trx_date, '%%b %%Y') AS month_name,
                    COALESCE(vp.status, 'Unknown') AS status_name,
                    COUNT(*) AS count_val,
                    COALESCE(SUM(vp.amount), 0) AS total_amount
                FROM cbs.vendor_payments vp
                WHERE vp.trx_date >= DATE_SUB(DATE_FORMAT(CURRENT_DATE(), '%%Y-%%m-01'), INTERVAL 5 MONTH)
                %s
                GROUP BY month_key, month_name, status_name
                ORDER BY month_key ASC, status_name ASC
                """, productFilter);
        try {
            return jdbcTemplate.queryForList(sql);
        } catch (Exception e) {
            return new ArrayList<>();
        }
    }

    public List<Map<String, Object>> getTransactionChannelChartData(String product) {
        return getTransactionChannelChartData(product, null);
    }

    public List<Map<String, Object>> getTransactionChannelChartData(String product, String month) {
        String productFilter = "";
        if ("MF".equalsIgnoreCase(product)) {
            productFilter = "AND EXISTS (SELECT 1 FROM cbs.loan l LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val WHERE t.account_no = l.account_no AND pr.product_code = 'MF')";
        } else if ("LF".equalsIgnoreCase(product)) {
            productFilter = "AND EXISTS (SELECT 1 FROM cbs.loan l LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val WHERE t.account_no = l.account_no AND pr.product_code IN ('LF', 'laptop'))";
        }

        String targetMonth = (month != null && month.matches("^\\d{4}-\\d{2}$"))
                ? month
                : new java.text.SimpleDateFormat("yyyy-MM").format(new java.util.Date());

        String dateFilter = String.format("t.date >= '%s-01' AND t.date < DATE_ADD('%s-01', INTERVAL 1 MONTH)", targetMonth, targetMonth);

        String sql = String.format("""
                SELECT 
                    COALESCE(t.channel, 'OTHER') AS channel_name,
                    COUNT(*) AS tx_count,
                    COALESCE(SUM(t.amount), 0) AS total_amount
                FROM cbs.transaction t
                WHERE %s %s
                GROUP BY COALESCE(t.channel, 'OTHER')
                ORDER BY tx_count DESC
                """, dateFilter, productFilter);
        return jdbcTemplate.queryForList(sql);
    }
}
