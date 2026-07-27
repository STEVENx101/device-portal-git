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
                    WHERE disbursed_date >= DATE_FORMAT(CURRENT_DATE(), '%Y-01-01')
                      AND disbursed_date < DATE_ADD(DATE_FORMAT(CURRENT_DATE(), '%Y-01-01'), INTERVAL 1 YEAR)
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
}
