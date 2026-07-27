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
                COALESCE(SUM(p.exposure), 0) AS npl_exposure,
                COALESCE(SUM(p.total_due), 0) AS npl_arrears
            FROM cbs.portfolio p
            LEFT JOIN cbs.loan l1 ON p.account_no = l1.account_no
            LEFT JOIN cbs.loan l2 ON p.account_no = l2.legacy_account_no
            WHERE COALESCE(l1.account_status, l2.account_status) = 'N'
              AND p.portfolio_date = (SELECT MAX(portfolio_date) FROM cbs.portfolio)
        """;
        Map<String, Object> nplStats = jdbcTemplate.queryForMap(sqlNplStats);

        // 5. Security-wise Locked / Unlocked count query
        String sqlSecurityStats = """
            SELECT 
                CASE 
                    WHEN pr.product_code IN ('LF', 'laptop') THEN 'ABSOLUTE' 
                    WHEN pr.product_code = 'MF' AND COALESCE(lm1.knox_compatibility, lm2.knox_compatibility) = 'yes' THEN 'KNOX' 
                    WHEN pr.product_code = 'MF' AND (COALESCE(lm1.knox_compatibility, lm2.knox_compatibility) = 'no' OR COALESCE(lm1.knox_compatibility, lm2.knox_compatibility) IS NULL) THEN 'DATACULTR' 
                    ELSE 'OTHER' 
                END AS security_type,
                COUNT(CASE WHEN COALESCE(lm1.locked, lm2.locked) = 1 THEN 1 END) AS locked_count,
                COUNT(CASE WHEN COALESCE(lm1.locked, lm2.locked) = 0 OR COALESCE(lm1.locked, lm2.locked) IS NULL THEN 1 END) AS unlocked_count
            FROM cbs.loan l
            LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
            LEFT JOIN loan.mobileloan lm1 ON lm1.finance_no = l.account_no
            LEFT JOIN loan.mobileloan lm2 ON lm2.finance_no = l.legacy_account_no
            GROUP BY security_type
        """;
        List<Map<String, Object>> securityStats = jdbcTemplate.queryForList(sqlSecurityStats);

        stats.put("nMonthCount", monthStats.get("month_count") != null ? monthStats.get("month_count") : 0);
        stats.put("nMonthAmount", monthStats.get("month_amount") != null ? monthStats.get("month_amount") : 0);
        stats.put("nYtdCount", ytdStats.get("ytd_count") != null ? ytdStats.get("ytd_count") : 0);
        stats.put("nYtdAmount", ytdStats.get("ytd_amount") != null ? ytdStats.get("ytd_amount") : 0);
        stats.put("nPortfolioCount", portfolioStats.get("portfolio_count") != null ? portfolioStats.get("portfolio_count") : 0);
        stats.put("nPortfolioAmount", portfolioStats.get("portfolio_amount") != null ? portfolioStats.get("portfolio_amount") : 0);
        
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
