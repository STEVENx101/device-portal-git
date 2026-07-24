package com.fintrex.deviceportal.repository;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

@Repository
public class DashboardRepository {

    private final JdbcTemplate jdbcTemplate;

    public DashboardRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public Map<String, Object> getSummaryKpis() {
        Map<String, Object> stats = new HashMap<>();

        // 1. Total Accounts & Current Month Loans Count (Index-friendly date range)
        String loanCountsSql = """
            SELECT 
                COUNT(*) AS total_accounts,
                COUNT(CASE WHEN disbursed_date >= DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01') AND disbursed_date < DATE_ADD(DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01'), INTERVAL 1 MONTH) THEN 1 END) AS current_month_loans
            FROM cbs.loan
        """;
        Map<String, Object> loanCounts = jdbcTemplate.queryForMap(loanCountsSql);
        stats.put("totalAccounts", loanCounts.get("total_accounts") != null ? loanCounts.get("total_accounts") : 0);
        stats.put("currentMonthLoans", loanCounts.get("current_month_loans") != null ? loanCounts.get("current_month_loans") : 0);

        // 2. Knox and Datacultr Counts (Single scan)
        String securityCountsSql = """
            SELECT 
                COUNT(CASE WHEN knox_compatibility = 'yes' THEN 1 END) AS knox_count,
                COUNT(CASE WHEN knox_compatibility = 'no' OR knox_compatibility IS NULL THEN 1 END) AS dataculte_count
            FROM loan.mobileloan
        """;
        Map<String, Object> securityCounts = jdbcTemplate.queryForMap(securityCountsSql);
        stats.put("knoxCount", securityCounts.get("knox_count") != null ? securityCounts.get("knox_count") : 0);
        stats.put("dataculteCount", securityCounts.get("dataculte_count") != null ? securityCounts.get("dataculte_count") : 0);

        // 3. Device Locked & Unlocked Counts (Laptop vs Mobile) - Consolidated single scan
        String deviceStatusSql = """
            SELECT 
                COUNT(CASE WHEN pr.product_code = 'MF' AND COALESCE(lm1.locked, lm2.locked) = 1 THEN 1 END) AS mobile_locked,
                COUNT(CASE WHEN pr.product_code = 'MF' AND (COALESCE(lm1.locked, lm2.locked) = 0 OR COALESCE(lm1.locked, lm2.locked) IS NULL) THEN 1 END) AS mobile_unlocked,
                COUNT(CASE WHEN pr.product_code IN ('LF', 'laptop') AND COALESCE(dl1.device_status, dl2.device_status) = 'Locked' THEN 1 END) AS laptop_locked,
                COUNT(CASE WHEN pr.product_code IN ('LF', 'laptop') AND (COALESCE(dl1.device_status, dl2.device_status) = 'Unlocked' OR COALESCE(dl1.device_status, dl2.device_status) IS NULL) THEN 1 END) AS laptop_unlocked
            FROM cbs.loan l
            JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
            LEFT JOIN loan.mobileloan lm1 ON lm1.finance_no = l.account_no
            LEFT JOIN loan.mobileloan lm2 ON lm2.finance_no = l.legacy_account_no
            LEFT JOIN cbs.device_loan dl1 ON dl1.account_no = l.account_no
            LEFT JOIN cbs.device_loan dl2 ON dl2.account_no = l.legacy_account_no
            WHERE pr.product_code IN ('MF', 'LF', 'laptop')
        """;
        Map<String, Object> deviceCounts = jdbcTemplate.queryForMap(deviceStatusSql);
        stats.put("mobileLocked", deviceCounts.get("mobile_locked") != null ? deviceCounts.get("mobile_locked") : 0);
        stats.put("mobileUnlocked", deviceCounts.get("mobile_unlocked") != null ? deviceCounts.get("mobile_unlocked") : 0);
        stats.put("laptopLocked", deviceCounts.get("laptop_locked") != null ? deviceCounts.get("laptop_locked") : 0);
        stats.put("laptopUnlocked", deviceCounts.get("laptop_unlocked") != null ? deviceCounts.get("laptop_unlocked") : 0);

        // 4. Active, NPL, Arrears Counts - Consolidated single portfolio scan
        String portfolioCountsSql = """
            SELECT 
                COUNT(CASE WHEN p.loan_status = 'A' THEN 1 END) AS active_count,
                COUNT(CASE WHEN p.loan_status = 'N' OR p.dpd > 90 THEN 1 END) AS npl_count,
                COUNT(CASE WHEN p.loan_status = 'A' AND p.dpd > 0 THEN 1 END) AS arrears_count
            FROM cbs.portfolio p
            WHERE p.portfolio_date = (SELECT MAX(portfolio_date) FROM cbs.portfolio)
        """;
        Map<String, Object> portfolioCounts = jdbcTemplate.queryForMap(portfolioCountsSql);
        stats.put("activeCount", portfolioCounts.get("active_count") != null ? portfolioCounts.get("active_count") : 0);
        stats.put("nplCount", portfolioCounts.get("npl_count") != null ? portfolioCounts.get("npl_count") : 0);
        stats.put("arrearsCount", portfolioCounts.get("arrears_count") != null ? portfolioCounts.get("arrears_count") : 0);

        return stats;
    }

    private Object getLatestPortfolioDate() {
        return jdbcTemplate.queryForObject("SELECT MAX(portfolio_date) FROM cbs.portfolio", Object.class);
    }

    public List<Map<String, Object>> getArrearsAnalysis() {
        Object latestDate = getLatestPortfolioDate();
        if (latestDate == null) {
            return List.of();
        }
        String sql = """
            SELECT 
                pr.product_code AS label, 
                SUM(p.total_due) AS arrears, 
                SUM(p.exposure) AS exposure 
            FROM cbs.portfolio p 
            LEFT JOIN cbs.loan l1 ON p.account_no = l1.account_no 
            LEFT JOIN cbs.loan l2 ON p.account_no = l2.legacy_account_no 
            JOIN cbs.product pr ON CAST(COALESCE(l1.product, l2.product) AS UNSIGNED) = pr.code_val 
            WHERE p.portfolio_date = ? 
            GROUP BY pr.product_code
        """;
        return jdbcTemplate.queryForList(sql, latestDate);
    }

    public List<Map<String, Object>> getDpdAnalysis() {
        Object latestDate = getLatestPortfolioDate();
        if (latestDate == null) {
            return List.of();
        }
        String sql = """
            SELECT 
                CASE 
                    WHEN p.dpd = 0 THEN '0' 
                    WHEN p.dpd BETWEEN 1 AND 30 THEN '1-30' 
                    WHEN p.dpd BETWEEN 31 AND 60 THEN '31-60' 
                    WHEN p.dpd BETWEEN 61 AND 90 THEN '61-90' 
                    WHEN p.dpd BETWEEN 91 AND 180 THEN '91-180' 
                    WHEN p.dpd BETWEEN 181 AND 270 THEN '181-270' 
                    WHEN p.dpd BETWEEN 271 AND 360 THEN '271-360' 
                    ELSE 'Loss' 
                END AS bucket, 
                COUNT(*) AS count 
            FROM cbs.portfolio p 
            WHERE p.portfolio_date = ? 
            GROUP BY bucket
        """;
        return jdbcTemplate.queryForList(sql, latestDate);
    }

    public Map<String, Object> getDealerPerformance() {
        Map<String, Object> res = new HashMap<>();

        // Index-friendly current month date range filter for loans and transactions
        String currentMonthDealersSql = """
            SELECT 
                v.name AS dealer_name, 
                COUNT(*) AS business_count, 
                SUM(l.loan_amount) AS business_amount 
            FROM cbs.loan l 
            JOIN cbs.vendor v ON l.vendor = v.code 
            WHERE l.disbursed_date >= DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01') 
              AND l.disbursed_date < DATE_ADD(DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01'), INTERVAL 1 MONTH) 
            GROUP BY v.name
        """;
        List<Map<String, Object>> currentMonthDealers = jdbcTemplate.queryForList(currentMonthDealersSql);

        String portfolioDealersSql = """
            SELECT 
                v.name AS dealer_name, 
                COUNT(*) AS portfolio_count, 
                SUM(l.loan_amount) AS portfolio_amount 
            FROM cbs.loan l 
            JOIN cbs.vendor v ON l.vendor = v.code 
            GROUP BY v.name
        """;
        List<Map<String, Object>> portfolioDealers = jdbcTemplate.queryForList(portfolioDealersSql);

        String collectionsDealerWiseSql = """
            SELECT 
                v.name AS dealer_name, 
                SUM(t.amount) AS total_collected 
            FROM cbs.transaction t 
            LEFT JOIN cbs.loan l1 ON t.account_no = l1.account_no 
            LEFT JOIN cbs.loan l2 ON t.account_no = l2.legacy_account_no 
            JOIN cbs.vendor v ON COALESCE(l1.vendor, l2.vendor) = v.code 
            WHERE t.date >= DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01') 
              AND t.date < DATE_ADD(DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01'), INTERVAL 1 MONTH) 
            GROUP BY v.name
        """;
        List<Map<String, Object>> collectionsDealerWise = jdbcTemplate.queryForList(collectionsDealerWiseSql);

        res.put("currentMonthDealers", currentMonthDealers);
        res.put("portfolioDealers", portfolioDealers);
        res.put("collectionsDealerWise", collectionsDealerWise);
        return res;
    }

    public Map<String, Object> getTopNplConcentrations() {
        Map<String, Object> res = new HashMap<>();
        Object latestDate = getLatestPortfolioDate();
        if (latestDate == null) {
            res.put("highestNplModels", List.of());
            res.put("highestNplDealers", List.of());
            return res;
        }

        String highestNplModelsSql = """
            SELECT 
                lmm.name AS model_name, 
                COUNT(*) AS npl_count 
            FROM cbs.portfolio p 
            LEFT JOIN cbs.loan l1 ON p.account_no = l1.account_no 
            LEFT JOIN cbs.loan l2 ON p.account_no = l2.legacy_account_no 
            LEFT JOIN loan.mobileloan lm1 ON lm1.finance_no = l1.account_no 
            LEFT JOIN loan.mobileloan lm2 ON lm2.finance_no = l2.legacy_account_no 
            LEFT JOIN loan.device_loan dl2_1 ON dl2_1.finance_no = l1.account_no 
            LEFT JOIN loan.device_loan dl2_2 ON dl2_2.finance_no = l2.legacy_account_no 
            JOIN loan.mobileloan_model lmm ON lmm.id = COALESCE(lm1.model, lm2.model, dl2_1.model, dl2_2.model) 
            WHERE p.portfolio_date = ? 
              AND (p.loan_status = 'N' OR p.dpd > 90) 
            GROUP BY lmm.name 
            ORDER BY npl_count DESC 
            LIMIT 5
        """;
        List<Map<String, Object>> highestNplModels = jdbcTemplate.queryForList(highestNplModelsSql, latestDate);

        String highestNplDealersSql = """
            SELECT 
                v.name AS dealer_name, 
                COUNT(*) AS npl_count 
            FROM cbs.portfolio p 
            LEFT JOIN cbs.loan l1 ON p.account_no = l1.account_no 
            LEFT JOIN cbs.loan l2 ON p.account_no = l2.legacy_account_no 
            JOIN cbs.vendor v ON COALESCE(l1.vendor, l2.vendor) = v.code 
            WHERE p.portfolio_date = ? 
              AND (p.loan_status = 'N' OR p.dpd > 90) 
            GROUP BY v.name 
            ORDER BY npl_count DESC 
            LIMIT 5
        """;
        List<Map<String, Object>> highestNplDealers = jdbcTemplate.queryForList(highestNplDealersSql, latestDate);

        res.put("highestNplModels", highestNplModels);
        res.put("highestNplDealers", highestNplDealers);
        return res;
    }

    public Map<String, Object> getNStatusKpis() {
        Map<String, Object> stats = new HashMap<>();

        // 1. Current Month & YTD & Portfolio count and amount where account_status = 'N'
        String sqlLoanStats = """
            SELECT 
                COUNT(CASE WHEN disbursed_date >= DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01') AND disbursed_date < DATE_ADD(DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01'), INTERVAL 1 MONTH) THEN 1 END) AS month_count,
                COALESCE(SUM(CASE WHEN disbursed_date >= DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01') AND disbursed_date < DATE_ADD(DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01'), INTERVAL 1 MONTH) THEN loan_amount END), 0) AS month_amount,
                COUNT(CASE WHEN disbursed_date >= DATE_FORMAT(CURRENT_DATE(), '%Y-01-01') AND disbursed_date < DATE_ADD(DATE_FORMAT(CURRENT_DATE(), '%Y-01-01'), INTERVAL 1 YEAR) THEN 1 END) AS ytd_count,
                COALESCE(SUM(CASE WHEN disbursed_date >= DATE_FORMAT(CURRENT_DATE(), '%Y-01-01') AND disbursed_date < DATE_ADD(DATE_FORMAT(CURRENT_DATE(), '%Y-01-01'), INTERVAL 1 YEAR) THEN loan_amount END), 0) AS ytd_amount,
                COUNT(*) AS portfolio_count,
                COALESCE(SUM(loan_amount), 0) AS portfolio_amount
            FROM cbs.loan
            WHERE account_status = 'N'
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
        Map<String, Object> stats = new HashMap<>();
        stats.putAll(getSummaryKpis());
        stats.put("arrearsAnalysis", getArrearsAnalysis());
        stats.put("dpdAnalysis", getDpdAnalysis());
        stats.putAll(getDealerPerformance());
        stats.putAll(getTopNplConcentrations());
        stats.putAll(getNStatusKpis());
        return stats;
    }
}
