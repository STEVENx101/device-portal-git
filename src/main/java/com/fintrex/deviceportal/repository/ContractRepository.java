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
                SELECT l.account_no AS FINANCE_NO, c.full_name AS FULL_NAME, c.id_no AS NIC_NO 
                FROM cbs.loan l
                JOIN cbs.client c ON l.client = c.client_code
                LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                WHERE pr.product_code IN ('MF', 'LF') AND (
                    l.account_no LIKE ? 
                    OR c.id_no LIKE ?
                ) LIMIT 6""";
            params = new Object[]{searchPattern, searchPattern};
        } else {
            sql = """
                SELECT l.account_no AS FINANCE_NO, c.full_name AS FULL_NAME, c.id_no AS NIC_NO 
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
                l.account_no AS FINANCE_NO, 
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
                dl.current_device_status AS CURRENT_DEVICE_STATUS 
            FROM cbs.loan l
            LEFT JOIN cbs.portfolio p 
                ON p.account_no = l.account_no 
                AND (p.portfolio_date, p.sync_time) = (
                    SELECT portfolio_date, sync_time 
                    FROM cbs.portfolio 
                    WHERE account_no = l.account_no
                    ORDER BY portfolio_date DESC, sync_time DESC 
                    LIMIT 1
                ) 
            LEFT JOIN cbs.product pr 
                ON CAST(l.product AS UNSIGNED) = pr.code_val
            LEFT JOIN cbs.client cust 
                ON cust.client_code = l.client
            LEFT JOIN cbs.client g1 
                ON g1.client_code = l.guarantor1 
            LEFT JOIN loan.mobileloan lm 
                ON lm.finance_no = l.account_no 
            LEFT JOIN loan.device_loan dl 
                ON dl.finance_no = l.account_no 
            LEFT JOIN loan.mobileloan_model lmm 
                ON lmm.id = COALESCE(lm.model, dl.model) 
            WHERE l.account_no = ?""";
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
                null,
                null,
                null,
                null,
                null,
                null,
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
                rs.getString("CURRENT_DEVICE_STATUS")
        ), financeNo);

        return results.isEmpty() ? null : results.get(0);
    }
}
