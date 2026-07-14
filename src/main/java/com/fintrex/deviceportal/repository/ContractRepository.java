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
                SELECT FINANCE_NO, FULL_NAME, NIC_NO FROM call_center.contract 
                WHERE Product IN ('MF', 'LF') AND (
                    FINANCE_NO LIKE ? 
                    OR NIC_NO LIKE ?
                ) LIMIT 6""";
            params = new Object[]{searchPattern, searchPattern};
        } else {
            sql = """
                SELECT FINANCE_NO, FULL_NAME, NIC_NO FROM call_center.contract 
                WHERE Product IN ('MF', 'LF') AND (
                    FULL_NAME LIKE ?
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
                cc.FINANCE_NO, 
                cs.CONTRACT_STATUS, 
                cs.AMT_TO_COLLECTED, 
                cs.PERFORMING_STATUS, 
                CASE 
                    WHEN cc.Product IN ('LF', 'laptop') THEN 'ABSOLUTE' 
                    WHEN cc.Product = 'MF' AND lm.knox_compatibility = 'yes' THEN 'KNOX' 
                    WHEN cc.Product = 'MF' AND (lm.knox_compatibility = 'no' OR lm.knox_compatibility IS NULL) THEN 'DATACULTE' 
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
                cc.FACILITY_GRANT_DATE, 
                cc.MATURITY_DATE, 
                cc.DUE_DATE, 
                cc.RENTAL, 
                cc.PERIOD, 
                cc.FINANCE_AMOUNT, 
                cs.ARR_DAYS, 
                COALESCE(lm.next_lock_date) AS NEXT_LOCK_DATE, 
                COALESCE(lm.locked) AS LOCKED, 
                cc.Product AS PRODUCT, 
                dl.current_device_status AS CURRENT_DEVICE_STATUS 
            FROM call_center.contract cc 
            LEFT JOIN call_center.snapshot cs 
                ON cs.FINANCE_NO = cc.FINANCE_NO 
                AND (cs.SNAP_DATE, cs.SNAP_TIME) = (
                    SELECT SNAP_DATE, SNAP_TIME 
                    FROM call_center.snapshot 
                    WHERE FINANCE_NO = cc.FINANCE_NO 
                    ORDER BY SNAP_DATE DESC, SNAP_TIME DESC 
                    LIMIT 1
                ) 
            LEFT JOIN loan.mobileloan lm 
                ON lm.finance_no = cc.FINANCE_NO 
            LEFT JOIN loan.device_loan dl 
                ON dl.finance_no = cc.FINANCE_NO 
            LEFT JOIN loan.mobileloan_model lmm 
                ON lmm.id = COALESCE(lm.model, dl.model) 
            LEFT JOIN call_center.nimble_client cust 
                ON cust.client_code = cc.CLIENT_CODE 
            LEFT JOIN call_center.nimble_client g1 
                ON g1.client_code = cc.G1_CODE 
            WHERE cc.FINANCE_NO = ?""";
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
