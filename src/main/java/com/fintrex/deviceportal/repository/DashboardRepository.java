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

    public Map<String, Object> getNStatusKpis(String product) {
        Map<String, Object> stats = new HashMap<>();
        String filter = getProductFilterSql(product);

        // 1. Month stats query
        String sqlMonth = String.format("""
                    SELECT
                        COUNT(*) AS month_count,
                        COALESCE(SUM(l.loan_amount), 0) AS month_amount
                    FROM cbs.loan l
                    LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                    WHERE l.disbursed_date >= DATE_FORMAT(CURRENT_DATE(), '%%Y-%%m-01')
                      AND l.disbursed_date < DATE_ADD(DATE_FORMAT(CURRENT_DATE(), '%%Y-%%m-01'), INTERVAL 1 MONTH)
                      %s
                """, filter);
        Map<String, Object> monthStats = jdbcTemplate.queryForMap(sqlMonth);

        // 2. YTD stats query
        String sqlYtd = String.format("""
                    SELECT
                        COUNT(*) AS ytd_count,
                        COALESCE(SUM(l.loan_amount), 0) AS ytd_amount
                    FROM cbs.loan l
                    LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                    WHERE l.disbursed_date >= CASE WHEN MONTH(CURRENT_DATE()) >= 4 THEN DATE_FORMAT(CURRENT_DATE(), '%%Y-04-01') ELSE DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 YEAR), '%%Y-04-01') END
                      AND l.disbursed_date < CASE WHEN MONTH(CURRENT_DATE()) >= 4 THEN DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 1 YEAR), '%%Y-04-01') ELSE DATE_FORMAT(CURRENT_DATE(), '%%Y-04-01') END
                      %s
                """, filter);
        Map<String, Object> ytdStats = jdbcTemplate.queryForMap(sqlYtd);

        // 3. Portfolio stats query
        String sqlPortfolio = String.format("""
                    SELECT
                        COUNT(DISTINCT p.account_no) AS portfolio_count,
                        COALESCE(SUM(p.exposure), 0) AS portfolio_amount
                    FROM cbs.portfolio p
                    JOIN (
                        SELECT account_no AS finance_no, product FROM cbs.loan
                        UNION ALL
                        SELECT legacy_account_no AS finance_no, product FROM cbs.loan WHERE legacy_account_no IS NOT NULL
                    ) l ON l.finance_no = p.account_no
                    LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                    WHERE p.portfolio_date = (
                        SELECT MAX(portfolio_date)
                        FROM cbs.portfolio
                    )
                    %s
                """, filter);
        Map<String, Object> portfolioStats = jdbcTemplate.queryForMap(sqlPortfolio);

        // 4. NPL outstanding and count query where account_status = 'N'
        String sqlNplStats = String.format("""
                    SELECT
                        COUNT(DISTINCT p.account_no) AS npl_count,
                        SUM(p.exposure) AS npl_exposure,
                        SUM(p.total_due) AS npl_arrears
                    FROM cbs.portfolio p
                    JOIN (
                        SELECT account_no AS finance_no,
                               account_status, product
                        FROM cbs.loan
                        UNION ALL
                        SELECT legacy_account_no AS finance_no,
                               account_status, product
                        FROM cbs.loan
                        WHERE legacy_account_no IS NOT NULL
                    ) l
                    ON l.finance_no = p.account_no
                    LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                    WHERE p.portfolio_date = (
                            SELECT MAX(portfolio_date)
                            FROM cbs.portfolio
                    )
                    AND l.account_status='N'
                    %s
                """, filter);
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

        // 7. Arrears count and amount from latest portfolio
        String sqlArrearsStats = String.format("""
                    SELECT
                        COUNT(DISTINCT p.account_no) AS arrears_count,
                        COALESCE(SUM(p.total_due), 0) AS arrears_amount
                    FROM cbs.portfolio p
                    JOIN (
                        SELECT account_no AS finance_no, product FROM cbs.loan
                        UNION ALL
                        SELECT legacy_account_no AS finance_no, product FROM cbs.loan WHERE legacy_account_no IS NOT NULL
                    ) l ON l.finance_no = p.account_no
                    LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                    WHERE p.portfolio_date = (
                        SELECT MAX(portfolio_date) FROM cbs.portfolio
                    )
                    AND p.total_due > 0
                    %s
                """, filter);
        Map<String, Object> arrearsStats = jdbcTemplate.queryForMap(sqlArrearsStats);

        // 8. Settled loans count and amount during the current month
        String sqlSettledStats = String.format("""
                    SELECT
                        COUNT(*) AS settled_count,
                        COALESCE(SUM(l.loan_amount), 0) AS settled_amount
                    FROM cbs.loan l
                    LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                    WHERE l.account_status IN ('P', 'F')
                      AND l.closed_date >= DATE_FORMAT(CURRENT_DATE(), '%%Y-%%m-01')
                      %s
                """, filter);
        Map<String, Object> settledStats = jdbcTemplate.queryForMap(sqlSettledStats);

        stats.put("nMonthCount", monthStats.get("month_count") != null ? monthStats.get("month_count") : 0);
        stats.put("nMonthAmount", monthStats.get("month_amount") != null ? monthStats.get("month_amount") : 0);
        stats.put("nYtdCount", ytdStats.get("ytd_count") != null ? ytdStats.get("ytd_count") : 0);
        stats.put("nYtdAmount", ytdStats.get("ytd_amount") != null ? ytdStats.get("ytd_amount") : 0);
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

        stats.put("securityStats", securityStats);

        return stats;
    }

    public Map<String, Object> getDashboardStats(String product) {
        return getNStatusKpis(product);
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
                                                SUM(CASE WHEN COALESCE(p1.dpd, p2.dpd, 0) = 0 THEN COALESCE(p1.exposure, p2.exposure, l.loan_amount, 0) ELSE 0 END) AS dpd0_val,
                                                SUM(CASE WHEN COALESCE(p1.dpd, p2.dpd, 0) BETWEEN 1 AND 30 THEN COALESCE(p1.exposure, p2.exposure, l.loan_amount, 0) ELSE 0 END) AS dpd1_30_val,
                                                SUM(CASE WHEN COALESCE(p1.dpd, p2.dpd, 0) BETWEEN 31 AND 60 THEN COALESCE(p1.exposure, p2.exposure, l.loan_amount, 0) ELSE 0 END) AS dpd31_60_val,
                                                SUM(CASE WHEN COALESCE(p1.dpd, p2.dpd, 0) BETWEEN 61 AND 90 THEN COALESCE(p1.exposure, p2.exposure, l.loan_amount, 0) ELSE 0 END) AS dpd61_90_val,
                                                SUM(CASE WHEN COALESCE(p1.dpd, p2.dpd, 0) > 90 OR COALESCE(p1.loan_status, p2.loan_status) = 'N' THEN COALESCE(p1.exposure, p2.exposure, l.loan_amount, 0) ELSE 0 END) AS dpdAbove90_val
                                            FROM cbs.loan l
                                            LEFT JOIN cbs.portfolio p1
                                                ON p1.account_no = l.account_no
                                                AND p1.series = l.account_series
                                                AND p1.portfolio_date = ?
                                            LEFT JOIN cbs.portfolio p2
                                                ON p2.account_no = l.legacy_account_no
                                                AND p2.series = l.account_series
                                                AND p2.portfolio_date = ?
                                            LEFT JOIN cbs.branch br ON CAST(l.branch AS UNSIGNED) = br.branch_code
                                            LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                                            %s
                                            WHERE 1=1 %s
                                            GROUP BY category_name
                                            ORDER BY category_name ASC
                        """,
                categoryExpr, dimensionJoin, filter);

        return jdbcTemplate.queryForList(sql, latestPortfolioDate, latestPortfolioDate);
    }

    public List<Map<String, Object>> getMonthWiseBusiness(String product) {
        String filter = getProductFilterSql(product);
        String sql = String.format("""
                    SELECT
                        DATE_FORMAT(l.disbursed_date, '%b %Y') AS month_name,
                        DATE_FORMAT(l.disbursed_date, '%Y-%m') AS month_key,
                        COUNT(*) AS business_count,
                        COALESCE(SUM(l.loan_amount), 0) AS business_amount
                    FROM cbs.loan l
                    LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                    WHERE l.disbursed_date >= DATE_SUB(DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01'), INTERVAL 5 MONTH)
                      AND l.disbursed_date < DATE_ADD(DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01'), INTERVAL 1 MONTH)
                      %s
                    GROUP BY DATE_FORMAT(l.disbursed_date, '%b %Y'), DATE_FORMAT(l.disbursed_date, '%Y-%m')
                    ORDER BY month_key ASC
                """, filter);
        return jdbcTemplate.queryForList(sql);
    }

    public List<Map<String, Object>> getMonthWiseDpdComparison(String product) {
        String filter = getProductFilterSql(product);
        String sql = String.format("""
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
                            DATE_FORMAT(portfolio_date, '%Y-%m') AS month_key,
                            MAX(portfolio_date) AS max_date
                        FROM cbs.portfolio
                        WHERE portfolio_date >= CASE WHEN MONTH(CURRENT_DATE()) >= 4 THEN DATE_FORMAT(CURRENT_DATE(), '%Y-04-01') ELSE DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 YEAR), '%Y-04-01') END
                          AND portfolio_date < CASE WHEN MONTH(CURRENT_DATE()) >= 4 THEN DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 1 YEAR), '%Y-04-01') ELSE DATE_FORMAT(CURRENT_DATE(), '%Y-04-01') END
                        GROUP BY DATE_FORMAT(portfolio_date, '%Y-%m')
                    ) m ON p.portfolio_date = m.max_date
                    JOIN (
                        SELECT account_no AS finance_no, product FROM cbs.loan
                        UNION ALL
                        SELECT legacy_account_no AS finance_no, product FROM cbs.loan WHERE legacy_account_no IS NOT NULL
                    ) l ON l.finance_no = p.account_no
                    LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                    WHERE 1=1 %s
                    GROUP BY p.portfolio_date, DATE_FORMAT(p.portfolio_date, '%b %Y'), DATE_FORMAT(p.portfolio_date, '%Y-%m')
                    ORDER BY month_key ASC
                """, filter);
        return jdbcTemplate.queryForList(sql);
    }

    public List<Map<String, Object>> getVendorPaymentsChannelChart(String product) {
        String filter = getProductFilterSql(product);
        String sql = String.format("""
                SELECT
                    DATE_FORMAT(l.disbursed_date, '%d %b') AS channel_name,
                    DATE_FORMAT(l.disbursed_date, '%Y-%m-%d') AS db_date,
                    COALESCE(SUM(l.loan_amount), 0) AS total_amount
                FROM cbs.loan l
                LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                WHERE l.disbursed_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 6 DAY)
                  AND l.disbursed_date <= CURRENT_DATE()
                  %s
                GROUP BY DATE_FORMAT(l.disbursed_date, '%d %b'), DATE_FORMAT(l.disbursed_date, '%Y-%m-%d')
                ORDER BY db_date ASC
                """, filter);
        return jdbcTemplate.queryForList(sql);
    }

    public Map<String, Object> getDeviceStatusCharts(String product) {
        Map<String, Object> result = new HashMap<>();
        String filter = getProductFilterSql(product);

        // Fetch latest portfolio date dynamically
        String sqlLatest = """
                    SELECT portfolio_date
                    FROM cbs.portfolio
                    WHERE portfolio_date IS NOT NULL
                    ORDER BY portfolio_date DESC
                    LIMIT 1
                """;
        Map<String, Object> latest = jdbcTemplate.queryForMap(sqlLatest);
        Object latestPortfolioDate = latest.get("portfolio_date");

        // Mobile Performing vs Non-Performing
        String mobilePerfSql = String.format("""
                    SELECT
                        CASE
                            WHEN COALESCE(p1.performing_status, p2.performing_status) = 'Non-Performing'
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
                    LEFT JOIN cbs.portfolio p2
                        ON p2.account_no = l.legacy_account_no
                        AND p2.series = l.account_series
                        AND p2.portfolio_date = ?
                    WHERE pr.product_code = 'MF' %s
                    GROUP BY state_name
                    ORDER BY state_name
                """, filter);
        List<Map<String, Object>> mobilePerf = "LF".equalsIgnoreCase(product) ? new ArrayList<>() :
                jdbcTemplate.queryForList(mobilePerfSql, latestPortfolioDate, latestPortfolioDate);

        // Laptop Performing vs Non-Performing
        String laptopPerfSql = String.format("""
                    SELECT
                        CASE
                            WHEN COALESCE(p1.performing_status, p2.performing_status) = 'Non-Performing'
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
                    LEFT JOIN cbs.portfolio p2
                        ON p2.account_no = l.legacy_account_no
                        AND p2.series = l.account_series
                        AND p2.portfolio_date = ?
                    WHERE pr.product_code IN ('LF', 'laptop') %s
                    GROUP BY state_name
                    ORDER BY state_name
                """, filter);
        List<Map<String, Object>> laptopPerf = "MF".equalsIgnoreCase(product) ? new ArrayList<>() :
                jdbcTemplate.queryForList(laptopPerfSql, latestPortfolioDate, latestPortfolioDate);

        String mobileLockSql = String.format("""
                    SELECT
                    CASE
                        WHEN ml.locked = 1 THEN 'Locked'
                        ELSE 'Unlocked'
                    END AS device_status,
                    COUNT(*) AS device_count
                FROM loan.mobileloan ml
                INNER JOIN (
                    SELECT legacy_account_no AS finance_no, product
                    FROM cbs.loan
                    WHERE account_status = 'A'
                      AND legacy_account_no IS NOT NULL
                    UNION
                    SELECT account_no AS finance_no, product
                    FROM cbs.loan
                    WHERE account_status = 'A'
                      AND legacy_account_no IS NULL
                ) active_loans
                    ON active_loans.finance_no = ml.finance_no
                LEFT JOIN cbs.product pr ON CAST(active_loans.product AS UNSIGNED) = pr.code_val
                WHERE ml.locked IN (0, 1) %s
                GROUP BY ml.locked
                ORDER BY ml.locked DESC
                """, filter);

        String laptopLockSql = String.format("""
                    SELECT
                    CASE
                        WHEN dl.locked = 1 THEN 'Locked'
                        ELSE 'Unlocked'
                    END AS device_status,
                    COUNT(*) AS device_count
                FROM loan.device_loan dl
                INNER JOIN (
                    SELECT legacy_account_no AS finance_no, product
                    FROM cbs.loan
                    WHERE account_status = 'A'
                      AND legacy_account_no IS NOT NULL
                    UNION
                    SELECT account_no AS finance_no, product
                    FROM cbs.loan
                    WHERE account_status = 'A'
                      AND legacy_account_no IS NULL
                ) active_loans
                    ON active_loans.finance_no = dl.finance_no
                LEFT JOIN cbs.product pr ON CAST(active_loans.product AS UNSIGNED) = pr.code_val
                WHERE dl.locked IN (0, 1) %s
                GROUP BY dl.locked
                ORDER BY dl.locked DESC
                """, filter);

        List<Map<String, Object>> mobileLock = new ArrayList<>();
        if (!"LF".equalsIgnoreCase(product)) {
            List<Map<String, Object>> mobileLockRaw = jdbcTemplate.queryForList(mobileLockSql);
            for (Map<String, Object> raw : mobileLockRaw) {
                Map<String, Object> map = new HashMap<>();
                map.put("state_name", raw.get("device_status"));
                map.put("count_val", raw.get("device_count"));
                mobileLock.add(map);
            }
        }

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

        result.put("mobilePerforming", mobilePerf);
        result.put("mobileLock", mobileLock);
        result.put("laptopPerforming", laptopPerf);
        result.put("laptopLock", laptopLock);
        return result;
    }

    public List<Map<String, Object>> getDealerCurrentMonthBusiness(String product) {
        String filter = getProductFilterSql(product);
        String sql = String.format("""
                SELECT
                    COALESCE(v.name, 'Unknown Dealer') AS dealer_name,
                    COUNT(*) AS loan_count,
                    COALESCE(SUM(l.loan_amount), 0) AS total_amount
                FROM cbs.loan l
                LEFT JOIN cbs.vendor v ON l.vendor = v.code
                LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                WHERE l.disbursed_date >= DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
                  AND l.disbursed_date < DATE_ADD(DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01'), INTERVAL 1 MONTH)
                  %s
                GROUP BY dealer_name
                ORDER BY total_amount DESC
                """, filter);
        return jdbcTemplate.queryForList(sql);
    }

    public List<Map<String, Object>> getDealerPortfolioBusiness(String product) {
        String filter = getProductFilterSql(product);
        String sql = String.format("""
                SELECT
                    COALESCE(v.name, 'Unknown Dealer') AS dealer_name,
                    COUNT(DISTINCT p.account_no) AS loan_count,
                    COALESCE(SUM(p.exposure), 0) AS total_exposure
                FROM cbs.portfolio p
                INNER JOIN (
                    SELECT account_no, legacy_account_no, vendor, account_series, product
                    FROM cbs.loan
                ) l ON (p.account_no = l.account_no AND p.series = l.account_series)
                    OR (p.account_no = l.legacy_account_no AND p.series = l.account_series)
                LEFT JOIN cbs.vendor v ON l.vendor = v.code
                LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                WHERE p.portfolio_date = (
                    SELECT MAX(portfolio_date) FROM cbs.portfolio
                )
                %s
                GROUP BY dealer_name
                ORDER BY total_exposure DESC
                """, filter);
        return jdbcTemplate.queryForList(sql);
    }

    public List<Map<String, Object>> getArrearsAnalysis(String product) {
        String filter = getProductFilterSql(product);
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
                JOIN (
                    SELECT account_no AS finance_no, product FROM cbs.loan
                    UNION ALL
                    SELECT legacy_account_no AS finance_no, product FROM cbs.loan WHERE legacy_account_no IS NOT NULL
                ) l ON l.finance_no = p.account_no
                LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                WHERE p.portfolio_date = (
                    SELECT MAX(portfolio_date) FROM cbs.portfolio
                )
                AND p.total_due > 0
                %s
                GROUP BY dpd_bucket
                ORDER BY FIELD(dpd_bucket, 'Current', '1-30 DPD', '31-60 DPD', '61-90 DPD', '90+ DPD')
                """, filter);
        return jdbcTemplate.queryForList(sql);
    }

    public Map<String, Object> getHighestNplModel(String product) {
        String filter = getProductFilterSql(product);
        String sql = String.format("""
                SELECT 
                    COALESCE(lmm.name, 'Unknown Model') AS model_name,
                    COUNT(DISTINCT active_loans.account_no) AS accounts_count,
                    COALESCE(SUM(p.exposure), 0) AS exposure
                FROM (
                    SELECT account_no, account_series, product, account_no AS join_no FROM cbs.loan WHERE account_status = 'N'
                    UNION ALL
                    SELECT account_no, account_series, product, legacy_account_no AS join_no FROM cbs.loan WHERE account_status = 'N' AND legacy_account_no IS NOT NULL
                ) active_loans
                LEFT JOIN loan.mobileloan lm ON lm.finance_no = active_loans.join_no
                LEFT JOIN loan.device_loan dl ON dl.finance_no = active_loans.join_no
                LEFT JOIN loan.mobileloan_model lmm ON lmm.id = COALESCE(lm.model, dl.model)
                LEFT JOIN cbs.product pr ON CAST(active_loans.product AS UNSIGNED) = pr.code_val
                LEFT JOIN cbs.portfolio p 
                    ON p.account_no = active_loans.join_no 
                    AND p.series = active_loans.account_series
                    AND p.portfolio_date = (SELECT MAX(portfolio_date) FROM cbs.portfolio)
                WHERE 1=1 %s
                GROUP BY model_name
                ORDER BY accounts_count DESC
                LIMIT 1
                """, filter);
        try {
            return jdbcTemplate.queryForMap(sql);
        } catch (Exception e) {
            Map<String, Object> empty = new HashMap<>();
            empty.put("model_name", "N/A");
            empty.put("accounts_count", 0);
            empty.put("exposure", 0);
            return empty;
        }
    }

    public Map<String, Object> getHighestNplDealer(String product) {
        String filter = getProductFilterSql(product);
        String sql = String.format("""
                SELECT 
                    COALESCE(v.name, 'Unknown Dealer') AS dealer_name,
                    COUNT(DISTINCT active_loans.account_no) AS accounts_count,
                    COALESCE(SUM(p.exposure), 0) AS exposure
                FROM (
                    SELECT account_no, account_series, vendor, product, account_no AS join_no FROM cbs.loan WHERE account_status = 'N'
                    UNION ALL
                    SELECT account_no, account_series, vendor, product, legacy_account_no AS join_no FROM cbs.loan WHERE account_status = 'N' AND legacy_account_no IS NOT NULL
                ) active_loans
                LEFT JOIN cbs.vendor v ON active_loans.vendor = v.code
                LEFT JOIN cbs.product pr ON CAST(active_loans.product AS UNSIGNED) = pr.code_val
                LEFT JOIN cbs.portfolio p 
                    ON p.account_no = active_loans.join_no 
                    AND p.series = active_loans.account_series
                    AND p.portfolio_date = (SELECT MAX(portfolio_date) FROM cbs.portfolio)
                WHERE 1=1 %s
                GROUP BY dealer_name
                ORDER BY accounts_count DESC
                LIMIT 1
                """, filter);
        try {
            return jdbcTemplate.queryForMap(sql);
        } catch (Exception e) {
            Map<String, Object> empty = new HashMap<>();
            empty.put("dealer_name", "N/A");
            empty.put("accounts_count", 0);
            empty.put("exposure", 0);
            return empty;
        }
    }

    public List<Map<String, Object>> getCollectionsDealerWise(String product) {
        String filter = getProductFilterSql(product);
        String sql = String.format("""
                SELECT
                    COALESCE(vp.vendor_name, 'Unknown') AS dealer_name,
                    COUNT(*) AS trx_count,
                    COALESCE(SUM(vp.amount), 0) AS total_collected
                FROM cbs.vendor_payments vp
                LEFT JOIN cbs.loan l ON vp.account_id = l.account_no OR vp.account_id = l.legacy_account_no
                LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                WHERE vp.trx_date >= DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
                %s
                GROUP BY dealer_name
                ORDER BY total_collected DESC
                """, filter);
        return jdbcTemplate.queryForList(sql);
    }

    public List<Map<String, Object>> getProductBusinessChart(String product) {
        String filter = getProductFilterSql(product);
        String sql = String.format("""
                SELECT
                    COALESCE(pr.product_name, l.product) AS product_name,
                    COUNT(*) AS business_count,
                    COALESCE(SUM(l.loan_amount), 0) AS business_amount
                FROM cbs.loan l
                LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                WHERE l.disbursed_date >= DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
                %s
                GROUP BY product_name
                ORDER BY business_amount DESC
                """, filter);
        return jdbcTemplate.queryForList(sql);
    }

    public Map<String, Object> getMobileLockArrearsAnalysis() {
        String sql = """
            SELECT
                SUM(CASE WHEN COALESCE(p.total_due, 0) < 200 THEN 1 ELSE 0 END) AS unlock_count,
                SUM(CASE WHEN COALESCE(p.total_due, 0) >= 200 THEN 1 ELSE 0 END) AS lock_count,
                SUM(CASE WHEN COALESCE(p.total_due, 0) BETWEEN 200 AND 500 THEN 1 ELSE 0 END) AS due_200_500,
                SUM(CASE WHEN COALESCE(p.total_due, 0) BETWEEN 501 AND 1000 THEN 1 ELSE 0 END) AS due_500_1000,
                SUM(CASE WHEN COALESCE(p.total_due, 0) BETWEEN 1001 AND 2000 THEN 1 ELSE 0 END) AS due_1000_2000,
                SUM(CASE WHEN COALESCE(p.total_due, 0) > 2000 THEN 1 ELSE 0 END) AS due_above_2000
            FROM cbs.portfolio p
            JOIN (
                SELECT account_no AS finance_no, product FROM cbs.loan
                UNION ALL
                SELECT legacy_account_no AS finance_no, product FROM cbs.loan WHERE legacy_account_no IS NOT NULL
            ) l ON l.finance_no = p.account_no
            LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
            WHERE p.portfolio_date = (SELECT MAX(portfolio_date) FROM cbs.portfolio)
              AND pr.product_code = 'MF'
        """;
        try {
            return jdbcTemplate.queryForMap(sql);
        } catch (Exception e) {
            Map<String, Object> fallback = new HashMap<>();
            fallback.put("unlock_count", 0);
            fallback.put("lock_count", 0);
            fallback.put("due_200_500", 0);
            fallback.put("due_500_1000", 0);
            fallback.put("due_1000_2000", 0);
            fallback.put("due_above_2000", 0);
            return fallback;
        }
    }

    public List<Map<String, Object>> getMaturedNonPerformingAnalysis(String product) {
        String filter = getProductFilterSql(product);
        String sql = String.format("""
            SELECT
                CASE WHEN l.maturity_date <= CURRENT_DATE() THEN 'Matured' ELSE 'Non-Matured' END AS maturity_status,
                CASE WHEN COALESCE(p.performing_status, 'Performing') = 'Non-Performing' THEN 'Non-Performing' ELSE 'Performing' END AS performing_status,
                COUNT(DISTINCT l.account_no) AS contract_count
            FROM cbs.loan l
            LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
            LEFT JOIN cbs.portfolio p ON (p.account_no = l.account_no OR p.account_no = l.legacy_account_no)
              AND p.portfolio_date = (SELECT MAX(portfolio_date) FROM cbs.portfolio)
            WHERE 1=1 %s
            GROUP BY maturity_status, performing_status
        """, filter);
        return jdbcTemplate.queryForList(sql);
    }

    public List<Map<String, Object>> getOutstandingAnalysis(String product) {
        String filter = getProductFilterSql(product);
        String sql = String.format("""
            SELECT
                CASE WHEN COALESCE(p.exposure, 0) > 1000 THEN 'Above 1000' ELSE 'Below 1000' END AS outstanding_bucket,
                COUNT(DISTINCT p.account_no) AS account_count,
                COALESCE(SUM(p.exposure), 0) AS total_exposure
            FROM cbs.portfolio p
            JOIN (
                SELECT account_no AS finance_no, product FROM cbs.loan
                UNION ALL
                SELECT legacy_account_no AS finance_no, product FROM cbs.loan WHERE legacy_account_no IS NOT NULL
            ) l ON l.finance_no = p.account_no
            LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
            WHERE p.portfolio_date = (SELECT MAX(portfolio_date) FROM cbs.portfolio)
              %s
            GROUP BY outstanding_bucket
        """, filter);
        return jdbcTemplate.queryForList(sql);
    }
}
