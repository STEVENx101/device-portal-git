package com.fintrex.deviceportal.repository;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import java.util.Map;
import java.util.HashMap;
import java.util.List;

@Repository
public class DashboardRepository {

    private final JdbcTemplate jdbcTemplate;

    public DashboardRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public Map<String, Object> getNStatusKpis() {
        Map<String, Object> stats = new HashMap<>();

        // 1. Month stats query
        String sqlMonth = """
                    SELECT
                        COUNT(*) AS month_count,
                        COALESCE(SUM(loan_amount), 0) AS month_amount
                    FROM cbs.loan
                    WHERE disbursed_date >= DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01')
                      AND disbursed_date < DATE_ADD(DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01'), INTERVAL 1 MONTH)
                """;
        Map<String, Object> monthStats = jdbcTemplate.queryForMap(sqlMonth);

        // 2. YTD stats query
        String sqlYtd = """
                    SELECT
                        COUNT(*) AS ytd_count,
                        COALESCE(SUM(loan_amount), 0) AS ytd_amount
                    FROM cbs.loan
                    WHERE disbursed_date >= CASE WHEN MONTH(CURRENT_DATE()) >= 4 THEN DATE_FORMAT(CURRENT_DATE(), '%Y-04-01') ELSE DATE_FORMAT(DATE_SUB(CURRENT_DATE(), INTERVAL 1 YEAR), '%Y-04-01') END
                      AND disbursed_date < CASE WHEN MONTH(CURRENT_DATE()) >= 4 THEN DATE_FORMAT(DATE_ADD(CURRENT_DATE(), INTERVAL 1 YEAR), '%Y-04-01') ELSE DATE_FORMAT(CURRENT_DATE(), '%Y-04-01') END
                """;
        Map<String, Object> ytdStats = jdbcTemplate.queryForMap(sqlYtd);

        // 3. Portfolio stats query
        String sqlPortfolio = """
                    SELECT
                        COUNT(*) AS portfolio_count,
                        COALESCE(SUM(loan_amount), 0) AS portfolio_amount
                    FROM cbs.loan
                """;
        Map<String, Object> portfolioStats = jdbcTemplate.queryForMap(sqlPortfolio);

        // 4. NPL outstanding and count query where account_status = 'N'
        String sqlNplStats = """
                            SELECT
                    COUNT(DISTINCT p.account_no) AS npl_count,
                    SUM(p.exposure) AS npl_exposure,
                    SUM(p.total_due) AS npl_arrears
                FROM cbs.portfolio p
                JOIN (
                    SELECT account_no AS finance_no,
                           account_status
                    FROM cbs.loan

                    UNION ALL

                    SELECT legacy_account_no AS finance_no,
                           account_status
                    FROM cbs.loan
                    WHERE legacy_account_no IS NOT NULL
                ) l
                ON l.finance_no = p.account_no
                WHERE p.portfolio_date = (
                        SELECT MAX(portfolio_date)
                        FROM cbs.portfolio
                )
                AND l.account_status='N';
                        """;
        Map<String, Object> nplStats = jdbcTemplate.queryForMap(sqlNplStats);

        // 5. Security-wise Locked / Unlocked count query
        String sqlSecurityStats = """
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

                GROUP BY security_type;
                                """;
        List<Map<String, Object>> securityStats = jdbcTemplate.queryForList(sqlSecurityStats);

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

        stats.put("securityStats", securityStats);

        return stats;
    }

    public Map<String, Object> getDashboardStats() {
        return getNStatusKpis();
    }

    public List<Map<String, Object>> getDpdChartData(String dimension) {
        String sqlLatest = """
            SELECT portfolio_date, sync_time
            FROM cbs.portfolio
            WHERE portfolio_date IS NOT NULL
              AND sync_time IS NOT NULL
            ORDER BY portfolio_date DESC, sync_time DESC
            LIMIT 1
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
                AND p1.sync_time = ?
            LEFT JOIN cbs.portfolio p2
                ON p2.account_no = l.legacy_account_no
                AND p2.series = l.account_series
                AND p2.portfolio_date = ?
                AND p2.sync_time = ?
            LEFT JOIN cbs.branch br ON CAST(l.branch AS UNSIGNED) = br.branch_code
            LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
            %s
            GROUP BY category_name
            ORDER BY category_name ASC
        """, categoryExpr, dimensionJoin);

        return jdbcTemplate.queryForList(sql, latestPortfolioDate, latestSyncTime, latestPortfolioDate, latestSyncTime);
    }

    public List<Map<String, Object>> getMonthWiseBusiness() {
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
        return jdbcTemplate.queryForList(sql);
    }

    public List<Map<String, Object>> getMonthWiseDpdComparison() {
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
        return jdbcTemplate.queryForList(sql);
    }
}
