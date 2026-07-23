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

        // 1. Total Accounts
        Integer totalAccounts = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM cbs.loan", Integer.class);
        stats.put("totalAccounts", totalAccounts != null ? totalAccounts : 0);

        // 2. Current Month Loans Count
        Integer currentMonthLoans = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM cbs.loan WHERE MONTH(disbursed_date) = MONTH(CURRENT_DATE()) AND YEAR(disbursed_date) = YEAR(CURRENT_DATE())",
            Integer.class
        );
        stats.put("currentMonthLoans", currentMonthLoans != null ? currentMonthLoans : 0);

        // 3. Knox and Datacultr Counts
        Integer knoxCount = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM loan.mobileloan WHERE knox_compatibility = 'yes'", Integer.class);
        Integer dataculteCount = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM loan.mobileloan WHERE knox_compatibility = 'no' OR knox_compatibility IS NULL", Integer.class);
        stats.put("knoxCount", knoxCount != null ? knoxCount : 0);
        stats.put("dataculteCount", dataculteCount != null ? dataculteCount : 0);

        // 4. Device Locked & Unlocked Counts (Laptop vs Mobile)
        Integer mobileLocked = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM cbs.loan l JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val LEFT JOIN loan.mobileloan lm1 ON lm1.finance_no = l.account_no LEFT JOIN loan.mobileloan lm2 ON lm2.finance_no = l.legacy_account_no WHERE pr.product_code = 'MF' AND COALESCE(lm1.locked, lm2.locked) = 1",
            Integer.class
        );
        Integer mobileUnlocked = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM cbs.loan l JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val LEFT JOIN loan.mobileloan lm1 ON lm1.finance_no = l.account_no LEFT JOIN loan.mobileloan lm2 ON lm2.finance_no = l.legacy_account_no WHERE pr.product_code = 'MF' AND (COALESCE(lm1.locked, lm2.locked) = 0 OR COALESCE(lm1.locked, lm2.locked) IS NULL)",
            Integer.class
        );
        Integer laptopLocked = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM cbs.loan l JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val LEFT JOIN cbs.device_loan dl1 ON dl1.account_no = l.account_no LEFT JOIN cbs.device_loan dl2 ON dl2.account_no = l.legacy_account_no WHERE pr.product_code IN ('LF', 'laptop') AND COALESCE(dl1.device_status, dl2.device_status) = 'Locked'",
            Integer.class
        );
        Integer laptopUnlocked = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM cbs.loan l JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val LEFT JOIN cbs.device_loan dl1 ON dl1.account_no = l.account_no LEFT JOIN cbs.device_loan dl2 ON dl2.account_no = l.legacy_account_no WHERE pr.product_code IN ('LF', 'laptop') AND (COALESCE(dl1.device_status, dl2.device_status) = 'Unlocked' OR COALESCE(dl1.device_status, dl2.device_status) IS NULL)",
            Integer.class
        );
        stats.put("mobileLocked", mobileLocked != null ? mobileLocked : 0);
        stats.put("mobileUnlocked", mobileUnlocked != null ? mobileUnlocked : 0);
        stats.put("laptopLocked", laptopLocked != null ? laptopLocked : 0);
        stats.put("laptopUnlocked", laptopUnlocked != null ? laptopUnlocked : 0);

        // 5. Active, NPL, Arrears Counts
        Integer activeCount = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM cbs.portfolio p WHERE p.portfolio_date = (SELECT MAX(portfolio_date) FROM cbs.portfolio) AND p.loan_status = 'A'",
            Integer.class
        );
        Integer nplCount = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM cbs.portfolio p WHERE p.portfolio_date = (SELECT MAX(portfolio_date) FROM cbs.portfolio) AND (p.loan_status = 'N' OR p.dpd > 90)",
            Integer.class
        );
        Integer arrearsCount = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM cbs.portfolio p WHERE p.portfolio_date = (SELECT MAX(portfolio_date) FROM cbs.portfolio) AND p.loan_status = 'A' AND p.dpd > 0",
            Integer.class
        );
        stats.put("activeCount", activeCount != null ? activeCount : 0);
        stats.put("nplCount", nplCount != null ? nplCount : 0);
        stats.put("arrearsCount", arrearsCount != null ? arrearsCount : 0);

        return stats;
    }

    public List<Map<String, Object>> getArrearsAnalysis() {
        return jdbcTemplate.queryForList(
            "SELECT pr.product_code AS label, SUM(p.total_due) AS arrears, SUM(p.exposure) AS exposure FROM cbs.portfolio p LEFT JOIN cbs.loan l1 ON p.account_no = l1.account_no LEFT JOIN cbs.loan l2 ON p.account_no = l2.legacy_account_no JOIN cbs.product pr ON CAST(COALESCE(l1.product, l2.product) AS UNSIGNED) = pr.code_val WHERE p.portfolio_date = (SELECT MAX(portfolio_date) FROM cbs.portfolio) GROUP BY pr.product_code"
        );
    }

    public List<Map<String, Object>> getDpdAnalysis() {
        return jdbcTemplate.queryForList(
            "SELECT CASE WHEN p.dpd = 0 THEN '0' WHEN p.dpd BETWEEN 1 AND 30 THEN '1-30' WHEN p.dpd BETWEEN 31 AND 60 THEN '31-60' WHEN p.dpd BETWEEN 61 AND 90 THEN '61-90' WHEN p.dpd BETWEEN 91 AND 180 THEN '91-180' WHEN p.dpd BETWEEN 181 AND 270 THEN '181-270' WHEN p.dpd BETWEEN 271 AND 360 THEN '271-360' ELSE 'Loss' END AS bucket, COUNT(*) AS count FROM cbs.portfolio p WHERE p.portfolio_date = (SELECT MAX(portfolio_date) FROM cbs.portfolio) GROUP BY bucket"
        );
    }

    public Map<String, Object> getDealerPerformance() {
        Map<String, Object> res = new HashMap<>();
        List<Map<String, Object>> currentMonthDealers = jdbcTemplate.queryForList(
            "SELECT v.name AS dealer_name, COUNT(*) AS business_count, SUM(l.loan_amount) AS business_amount FROM cbs.loan l JOIN cbs.vendor v ON l.vendor = v.code WHERE MONTH(l.disbursed_date) = MONTH(CURRENT_DATE()) AND YEAR(l.disbursed_date) = YEAR(CURRENT_DATE()) GROUP BY v.name"
        );
        List<Map<String, Object>> portfolioDealers = jdbcTemplate.queryForList(
            "SELECT v.name AS dealer_name, COUNT(*) AS portfolio_count, SUM(l.loan_amount) AS portfolio_amount FROM cbs.loan l JOIN cbs.vendor v ON l.vendor = v.code GROUP BY v.name"
        );
        List<Map<String, Object>> collectionsDealerWise = jdbcTemplate.queryForList(
            "SELECT v.name AS dealer_name, SUM(t.amount) AS total_collected FROM cbs.transaction t LEFT JOIN cbs.loan l1 ON t.account_no = l1.account_no LEFT JOIN cbs.loan l2 ON t.account_no = l2.legacy_account_no JOIN cbs.vendor v ON COALESCE(l1.vendor, l2.vendor) = v.code WHERE MONTH(t.date) = MONTH(CURRENT_DATE()) AND YEAR(t.date) = YEAR(CURRENT_DATE()) GROUP BY v.name"
        );
        res.put("currentMonthDealers", currentMonthDealers);
        res.put("portfolioDealers", portfolioDealers);
        res.put("collectionsDealerWise", collectionsDealerWise);
        return res;
    }

    public Map<String, Object> getTopNplConcentrations() {
        Map<String, Object> res = new HashMap<>();
        List<Map<String, Object>> highestNplModels = jdbcTemplate.queryForList(
            "SELECT lmm.name AS model_name, COUNT(*) AS npl_count FROM cbs.portfolio p LEFT JOIN cbs.loan l1 ON p.account_no = l1.account_no LEFT JOIN cbs.loan l2 ON p.account_no = l2.legacy_account_no LEFT JOIN loan.mobileloan lm1 ON lm1.finance_no = l1.account_no LEFT JOIN loan.mobileloan lm2 ON lm2.finance_no = l2.legacy_account_no LEFT JOIN loan.device_loan dl2_1 ON dl2_1.finance_no = l1.account_no LEFT JOIN loan.device_loan dl2_2 ON dl2_2.finance_no = l2.legacy_account_no JOIN loan.mobileloan_model lmm ON lmm.id = COALESCE(lm1.model, lm2.model, dl2_1.model, dl2_2.model) WHERE p.portfolio_date = (SELECT MAX(portfolio_date) FROM cbs.portfolio) AND (p.loan_status = 'N' OR p.dpd > 90) GROUP BY lmm.name ORDER BY npl_count DESC LIMIT 5"
        );
        List<Map<String, Object>> highestNplDealers = jdbcTemplate.queryForList(
            "SELECT v.name AS dealer_name, COUNT(*) AS npl_count FROM cbs.portfolio p LEFT JOIN cbs.loan l1 ON p.account_no = l1.account_no LEFT JOIN cbs.loan l2 ON p.account_no = l2.legacy_account_no JOIN cbs.vendor v ON COALESCE(l1.vendor, l2.vendor) = v.code WHERE p.portfolio_date = (SELECT MAX(portfolio_date) FROM cbs.portfolio) AND (p.loan_status = 'N' OR p.dpd > 90) GROUP BY v.name ORDER BY npl_count DESC LIMIT 5"
        );
        res.put("highestNplModels", highestNplModels);
        res.put("highestNplDealers", highestNplDealers);
        return res;
    }

    public Map<String, Object> getDashboardStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.putAll(getSummaryKpis());
        stats.put("arrearsAnalysis", getArrearsAnalysis());
        stats.put("dpdAnalysis", getDpdAnalysis());
        stats.putAll(getDealerPerformance());
        stats.putAll(getTopNplConcentrations());
        return stats;
    }
}
