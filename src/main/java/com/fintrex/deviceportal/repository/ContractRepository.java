package com.fintrex.deviceportal.repository;

import com.fintrex.deviceportal.dto.ContractDetails;
import com.fintrex.deviceportal.dto.ContractSearchResult;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;
import java.util.HashMap;

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
            params = new Object[] { searchPattern, searchPattern, searchPattern };
        } else {
            sql = """
                    SELECT COALESCE(l.legacy_account_no, l.account_no) AS FINANCE_NO, c.full_name AS FULL_NAME, c.id_no AS NIC_NO
                    FROM cbs.loan l
                    JOIN cbs.client c ON l.client = c.client_code
                    LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                    WHERE pr.product_code IN ('MF', 'LF') AND (
                        c.full_name LIKE ?
                    ) LIMIT 6""";
            params = new Object[] { searchPattern };
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
                    l.account_no AS ACCOUNT_NO,
                    l.legacy_account_no AS LEGACY_ACCOUNT_NO,
                    l.account_status AS CONTRACT_STATUS,
                    COALESCE(p1.total_due, p2.total_due) AS AMT_TO_COLLECTED,
                    COALESCE(p1.exposure, p2.exposure) AS EXPOSURE,
                    COALESCE(p1.performing_status, p2.performing_status) AS PERFORMING_STATUS,
                    CASE
                        WHEN pr.product_code IN ('LF', 'laptop') THEN 'ABSOLUTE'
                        WHEN pr.product_code = 'MF' AND COALESCE(lm1.knox_compatibility, lm2.knox_compatibility) = 'yes' THEN 'KNOX'
                        WHEN pr.product_code = 'MF' AND (COALESCE(lm1.knox_compatibility, lm2.knox_compatibility) = 'no' OR COALESCE(lm1.knox_compatibility, lm2.knox_compatibility) IS NULL) THEN 'DATACULTR'
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
                    COALESCE(p1.dpd, p2.dpd) AS ARR_DAYS,
                    COALESCE(lm1.next_lock_date, lm2.next_lock_date) AS NEXT_LOCK_DATE,
                    COALESCE(lm1.locked, lm2.locked) AS LOCKED,
                    pr.product_code AS PRODUCT,
                    COALESCE(dl1.device_status, dl2.device_status) AS CURRENT_DEVICE_STATUS,
                    COALESCE(dl1.device_id, dl2.device_id) AS IMEI_NO,
                    COALESCE(dl1.external_id, dl2.external_id) AS WORKHUB_SP_NO,
                    v.name AS VENDOR_NAME
                FROM (
                    SELECT * FROM cbs.loan
                    WHERE account_no = ? OR legacy_account_no = ?
                ) l
                LEFT JOIN cbs.portfolio p1
                    ON p1.account_no = l.account_no
                    AND p1.portfolio_date = (
                        SELECT portfolio_date
                        FROM cbs.portfolio
                        WHERE portfolio_date IS NOT NULL
                        ORDER BY portfolio_date DESC
                        LIMIT 1
                    )
                LEFT JOIN cbs.portfolio p2
                    ON p2.account_no = l.legacy_account_no
                    AND p2.portfolio_date = (
                        SELECT portfolio_date
                        FROM cbs.portfolio
                        WHERE portfolio_date IS NOT NULL
                        ORDER BY portfolio_date DESC
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
                LEFT JOIN loan.mobileloan lm1
                    ON lm1.finance_no = l.account_no
                LEFT JOIN loan.mobileloan lm2
                    ON lm2.finance_no = l.legacy_account_no
                LEFT JOIN cbs.device_loan dl1
                    ON dl1.account_no = l.account_no
                LEFT JOIN cbs.device_loan dl2
                    ON dl2.account_no = l.legacy_account_no
                LEFT JOIN loan.device_loan dl2_1
                    ON dl2_1.finance_no = l.account_no
                LEFT JOIN loan.device_loan dl2_2
                    ON dl2_2.finance_no = l.legacy_account_no
                LEFT JOIN loan.mobileloan_model lmm
                    ON lmm.id = COALESCE(lm1.model, lm2.model, dl2_1.model, dl2_2.model)
                LEFT JOIN cbs.vendor v
                    ON l.vendor = v.code
                WHERE 1=1""";
        System.out.println(sql);

        List<ContractDetails> results = jdbcTemplate.query(sql, (rs, rowNum) -> new ContractDetails(
                rs.getString("FINANCE_NO"),
                rs.getString("ACCOUNT_NO"),
                rs.getString("LEGACY_ACCOUNT_NO"),
                rs.getString("CONTRACT_STATUS"),
                rs.getBigDecimal("AMT_TO_COLLECTED"),
                rs.getBigDecimal("EXPOSURE"),
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
                rs.getString("VENDOR_NAME")), financeNo, financeNo);

        return results.isEmpty() ? null : results.get(0);
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
                    String.class, financeNo, financeNo);
        } catch (Exception e) {
            // fallback
        }
        String sql = "INSERT INTO device_portal.contract_remark (finance_no, remark, created_by, created_date) VALUES (?, ?, ?, NOW())";
        jdbcTemplate.update(sql, resolvedFinanceNo, remark, createdBy);
    }

    public Map<String, Object> getAccountMapping(String financeNo) {
        String sql = "SELECT account_no AS ACCOUNT_NO, legacy_account_no AS LEGACY_ACCOUNT_NO FROM cbs.loan WHERE account_no = ? OR legacy_account_no = ? LIMIT 1";
        try {
            return jdbcTemplate.queryForMap(sql, financeNo, financeNo);
        } catch (Exception e) {
            Map<String, Object> fallback = new HashMap<>();
            fallback.put("ACCOUNT_NO", financeNo);
            fallback.put("LEGACY_ACCOUNT_NO", financeNo);
            return fallback;
        }
    }
}
