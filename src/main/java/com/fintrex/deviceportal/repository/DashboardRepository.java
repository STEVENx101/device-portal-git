package com.fintrex.deviceportal.repository;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import java.util.Map;
import java.util.HashMap;

@Repository
public class DashboardRepository {

    private final JdbcTemplate jdbcTemplate;

    public DashboardRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public Map<String, Object> getNStatusKpis() {
        Map<String, Object> stats = new HashMap<>();

        // 1. Current Month & YTD & Portfolio count and amount (Overall)
        String sqlLoanStats = """
            SELECT 
                COUNT(CASE WHEN disbursed_date >= DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01') AND disbursed_date < DATE_ADD(DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01'), INTERVAL 1 MONTH) THEN 1 END) AS month_count,
                COALESCE(SUM(CASE WHEN disbursed_date >= DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01') AND disbursed_date < DATE_ADD(DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01'), INTERVAL 1 MONTH) THEN loan_amount END), 0) AS month_amount,
                COUNT(CASE WHEN disbursed_date >= DATE_FORMAT(CURRENT_DATE(), '%Y-01-01') AND disbursed_date < DATE_ADD(DATE_FORMAT(CURRENT_DATE(), '%Y-01-01'), INTERVAL 1 YEAR) THEN 1 END) AS ytd_count,
                COALESCE(SUM(CASE WHEN disbursed_date >= DATE_FORMAT(CURRENT_DATE(), '%Y-01-01') AND disbursed_date < DATE_ADD(DATE_FORMAT(CURRENT_DATE(), '%Y-01-01'), INTERVAL 1 YEAR) THEN loan_amount END), 0) AS ytd_amount,
                COUNT(*) AS portfolio_count,
                COALESCE(SUM(loan_amount), 0) AS portfolio_amount
            FROM cbs.loan
        """;
        Map<String, Object> loanStats = jdbcTemplate.queryForMap(sqlLoanStats);
        
        // 2. NPL outstanding and count where account_status = 'N'
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

        stats.put("nMonthCount", loanStats.get("month_count") != null ? loanStats.get("month_count") : 0);
        stats.put("nMonthAmount", loanStats.get("month_amount") != null ? loanStats.get("month_amount") : 0);
        stats.put("nYtdCount", loanStats.get("ytd_count") != null ? loanStats.get("ytd_count") : 0);
        stats.put("nYtdAmount", loanStats.get("ytd_amount") != null ? loanStats.get("ytd_amount") : 0);
        stats.put("nPortfolioCount", loanStats.get("portfolio_count") != null ? loanStats.get("portfolio_count") : 0);
        stats.put("nPortfolioAmount", loanStats.get("portfolio_amount") != null ? loanStats.get("portfolio_amount") : 0);
        
        stats.put("nNplCount", nplStats.get("npl_count") != null ? nplStats.get("npl_count") : 0);
        stats.put("nNplExposure", nplStats.get("npl_exposure") != null ? nplStats.get("npl_exposure") : 0);
        stats.put("nNplArrears", nplStats.get("npl_arrears") != null ? nplStats.get("npl_arrears") : 0);

        return stats;
    }

    public Map<String, Object> getDashboardStats() {
        return getNStatusKpis();
    }
}
