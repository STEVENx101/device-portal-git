package com.fintrex.deviceportal.repository;

import com.fintrex.deviceportal.dto.ContractDetails;
import com.fintrex.deviceportal.dto.ContractSearchResult;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class ContractRepository {

    private final JdbcTemplate jdbcTemplate;

    public ContractRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<ContractSearchResult> search(String query) {
        boolean startsWithDigit = query != null && !query.isEmpty() && Character.isDigit(query.charAt(0));
        String sql;
        Object[] params;
        String searchPattern = "%" + query + "%";

        if (startsWithDigit) {
            sql = """
                SELECT COALESCE(l.legacy_account_no, l.account_no) AS FINANCE_NO, c.full_name AS FULL_NAME, c.id_no AS NIC_NO 
                FROM cbs.loan l
                JOIN cbs.client c ON l.client = c.client_code
                LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                WHERE pr.product_code IN ('MF', 'LF') AND (
                    l.account_no LIKE ? 
                    OR l.legacy_account_no LIKE ?
                    OR c.id_no LIKE ?
                ) LIMIT 6""";
            params = new Object[]{searchPattern, searchPattern, searchPattern};
        } else {
            sql = """
                SELECT COALESCE(l.legacy_account_no, l.account_no) AS FINANCE_NO, c.full_name AS FULL_NAME, c.id_no AS NIC_NO 
                FROM cbs.loan l
                JOIN cbs.client c ON l.client = c.client_code
                LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                WHERE pr.product_code IN ('MF', 'LF') AND (
                    c.full_name LIKE ?
                ) LIMIT 6""";
            params = new Object[]{searchPattern};
        }

        return jdbcTemplate.query(sql, (rs, rowNum) -> new ContractSearchResult(
                rs.getString("FINANCE_NO"),
                rs.getString("FULL_NAME"),
                rs.getString("NIC_NO")), params);
    }

    public ContractDetails getDetails(String financeNo) {
        String sql = """
            SELECT 
                COALESCE(l.legacy_account_no, l.account_no) AS FINANCE_NO, 
                p.loan_status AS CONTRACT_STATUS, 
                p.total_due AS AMT_TO_COLLECTED, 
                p.performing_status AS PERFORMING_STATUS, 
                CASE 
                    WHEN pr.product_code IN ('LF', 'laptop') THEN 'ABSOLUTE' 
                    WHEN pr.product_code = 'MF' AND lm.knox_compatibility = 'yes' THEN 'KNOX' 
                    WHEN pr.product_code = 'MF' AND (lm.knox_compatibility = 'no' OR lm.knox_compatibility IS NULL) THEN 'DATACULTE' 
                    ELSE NULL 
                END AS SECURITY, 
                lmm.name AS MODEL, 
                cust.id_no AS NIC_NO, 
                cust.full_name AS FULL_NAME, 
                cust.address AS ADDRESS, 
                cust.mobile AS MOBILE_NO, 
                g1.full_name AS G1, 
                g1.address AS G1_ADDRESS, 
                g1.mobile AS G1_CONTACT, 
                g1.id_no AS G1_NIC,
                g2.full_name AS G2, 
                g2.address AS G2_ADDRESS, 
                g2.mobile AS G2_CONTACT, 
                g2.id_no AS G2_NIC,
                g3.full_name AS G3, 
                g3.address AS G3_ADDRESS, 
                g3.mobile AS G3_CONTACT, 
                g3.id_no AS G3_NIC,
                l.start_date AS FACILITY_GRANT_DATE, 
                l.maturity_date AS MATURITY_DATE, 
                l.due_day AS DUE_DATE, 
                l.rental AS RENTAL, 
                l.period AS PERIOD, 
                l.loan_amount AS FINANCE_AMOUNT, 
                p.dpd AS ARR_DAYS, 
                COALESCE(lm.next_lock_date) AS NEXT_LOCK_DATE, 
                COALESCE(lm.locked) AS LOCKED, 
                pr.product_code AS PRODUCT, 
                dl.device_status AS CURRENT_DEVICE_STATUS,
                dl.device_id AS IMEI_NO,
                dl.external_id AS WORKHUB_SP_NO,
                v.name AS VENDOR_NAME
            FROM (
                SELECT * FROM cbs.loan 
                WHERE account_no = ? OR legacy_account_no = ?
            ) l
            LEFT JOIN cbs.portfolio p 
                ON (p.account_no = l.account_no OR p.account_no = l.legacy_account_no) 
                AND (p.portfolio_date, p.sync_time) = (
                    SELECT portfolio_date, sync_time 
                    FROM cbs.portfolio 
                    WHERE account_no = l.account_no OR account_no = l.legacy_account_no
                    ORDER BY portfolio_date DESC, sync_time DESC 
                    LIMIT 1
                ) 
            LEFT JOIN cbs.product pr 
                ON CAST(l.product AS UNSIGNED) = pr.code_val
            LEFT JOIN cbs.client cust 
                ON cust.client_code = l.client
            LEFT JOIN cbs.client g1 
                ON g1.client_code = l.guarantor1 
            LEFT JOIN cbs.client g2 
                ON g2.client_code = l.guarantor2 
            LEFT JOIN cbs.client g3 
                ON g3.client_code = l.guarantor3 
            LEFT JOIN loan.mobileloan lm 
                ON lm.finance_no = l.account_no OR lm.finance_no = l.legacy_account_no
            LEFT JOIN cbs.device_loan dl 
                ON dl.account_no = l.account_no OR dl.account_no = l.legacy_account_no
            LEFT JOIN loan.device_loan dl2 
                ON dl2.finance_no = l.account_no OR dl2.finance_no = l.legacy_account_no
            LEFT JOIN loan.mobileloan_model lmm 
                ON lmm.id = COALESCE(lm.model, dl2.model) 
            LEFT JOIN cbs.vendor v 
                ON l.vendor = v.code
            WHERE 1=1""";
        System.out.println(sql);

        List<ContractDetails> results = jdbcTemplate.query(sql, (rs, rowNum) -> new ContractDetails(
                rs.getString("FINANCE_NO"),
                rs.getString("CONTRACT_STATUS"),
                rs.getBigDecimal("AMT_TO_COLLECTED"),
                rs.getString("PERFORMING_STATUS"),
                rs.getString("SECURITY"),
                rs.getString("MODEL"),
                rs.getString("NIC_NO"),
                rs.getString("FULL_NAME"),
                rs.getString("ADDRESS"),
                rs.getString("MOBILE_NO"),
                rs.getString("G1"),
                rs.getString("G1_ADDRESS"),
                rs.getString("G1_CONTACT"),
                rs.getString("G2"),
                rs.getString("G2_ADDRESS"),
                rs.getString("G2_CONTACT"),
                rs.getString("G3"),
                rs.getString("G3_ADDRESS"),
                rs.getString("G3_CONTACT"),
                rs.getString("FACILITY_GRANT_DATE"),
                rs.getString("MATURITY_DATE"),
                rs.getString("DUE_DATE"),
                rs.getBigDecimal("RENTAL"),
                rs.getObject("PERIOD", Integer.class),
                rs.getBigDecimal("FINANCE_AMOUNT"),
                rs.getObject("ARR_DAYS", Integer.class),
                rs.getString("NEXT_LOCK_DATE"),
                rs.getObject("LOCKED", Integer.class),
                rs.getString("PRODUCT"),
                rs.getString("CURRENT_DEVICE_STATUS"),
                rs.getString("IMEI_NO"),
                rs.getString("WORKHUB_SP_NO"),
                rs.getString("G1_NIC"),
                rs.getString("G2_NIC"),
                rs.getString("G3_NIC"),
                rs.getString("VENDOR_NAME")
        ), financeNo, financeNo);

        return results.isEmpty() ? null : results.get(0);
    }

    public java.util.Map<String, Object> getDashboardStats() {
        java.util.Map<String, Object> stats = new java.util.HashMap<>();
        
        Integer totalAccounts = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM cbs.loan", Integer.class);
        stats.put("totalAccounts", totalAccounts != null ? totalAccounts : 0);
        
        Integer totalLocked = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM loan.mobileloan WHERE locked = 1", Integer.class);
        stats.put("totalLocked", totalLocked != null ? totalLocked : 0);
        
        Double totalOutstanding = jdbcTemplate.queryForObject(
            "SELECT SUM(p.total_due) FROM cbs.portfolio p WHERE p.portfolio_date = (SELECT MAX(portfolio_date) FROM cbs.portfolio)", 
            Double.class
        );
        stats.put("totalOutstanding", totalOutstanding != null ? totalOutstanding : 0.0);
        
        Integer knoxCount = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM loan.mobileloan WHERE knox_compatibility = 'yes'", Integer.class);
        Integer dataculteCount = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM loan.mobileloan WHERE knox_compatibility = 'no' OR knox_compatibility IS NULL", Integer.class);
        Integer laptopCount = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM cbs.loan l JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val WHERE pr.product_code IN ('LF', 'laptop')", 
            Integer.class
        );
        stats.put("knoxCount", knoxCount != null ? knoxCount : 0);
        stats.put("dataculteCount", dataculteCount != null ? dataculteCount : 0);
        stats.put("laptopCount", laptopCount != null ? laptopCount : 0);
        
        return stats;
    }

    public List<java.util.Map<String, Object>> getRecentLocks() {
        return jdbcTemplate.queryForList(
            "SELECT finance_no, status, date, changed_by, reason FROM loan.lock_log ORDER BY date DESC LIMIT 5"
        );
    }

    public void initRemarksTable() {
        String sql = """
            CREATE TABLE IF NOT EXISTS device_portal.contract_remark (
                id INT AUTO_INCREMENT PRIMARY KEY,
                finance_no VARCHAR(50) NOT NULL,
                remark TEXT NOT NULL,
                created_by VARCHAR(50) NOT NULL,
                created_date DATETIME NOT NULL
            )
        """;
        jdbcTemplate.execute(sql);
    }

    public List<java.util.Map<String, Object>> getRemarks(String financeNo) {
        initRemarksTable();
        String sql = """
            SELECT r.remark, r.created_by, DATE_FORMAT(r.created_date, '%Y-%m-%d %H:%i:%s') AS created_date 
            FROM device_portal.contract_remark r
            JOIN cbs.loan l ON r.finance_no = l.account_no
            WHERE l.account_no = ? OR l.legacy_account_no = ?
            ORDER BY r.created_date DESC
        """;
        return jdbcTemplate.queryForList(sql, financeNo, financeNo);
    }

    public void addRemark(String financeNo, String remark, String createdBy) {
        initRemarksTable();
        String resolvedFinanceNo = financeNo;
        try {
            resolvedFinanceNo = jdbcTemplate.queryForObject(
                "SELECT account_no FROM cbs.loan WHERE account_no = ? OR legacy_account_no = ? LIMIT 1",
                String.class, financeNo, financeNo
            );
        } catch (Exception e) {
            // fallback
        }
        String sql = "INSERT INTO device_portal.contract_remark (finance_no, remark, created_by, created_date) VALUES (?, ?, ?, NOW())";
        jdbcTemplate.update(sql, resolvedFinanceNo, remark, createdBy);
    }
}
