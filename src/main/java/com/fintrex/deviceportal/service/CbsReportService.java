package com.fintrex.deviceportal.service;

import com.fintrex.deviceportal.config.DataTableRequest;
import com.fintrex.deviceportal.config.DataTableResponse;
import com.fintrex.deviceportal.config.DataTableRepo;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class CbsReportService {

    private final NamedParameterJdbcTemplate jdbc;
    private final DataTableRepo datatableRepo;

    public CbsReportService(NamedParameterJdbcTemplate jdbc, DataTableRepo datatableRepo) {
        this.jdbc = jdbc;
        this.datatableRepo = datatableRepo;
    }

    public Map<String, Object> getMetadata() {
        Map<String, Object> metadata = new HashMap<>();
        
        List<Map<String, Object>> branches = jdbc.queryForList(
                "SELECT legacy_branch_code, branch_code, branch_name FROM cbs.branch ORDER BY branch_name ASC",
                Map.of()
        );
        List<Map<String, Object>> products = jdbc.queryForList(
                "SELECT product_name, product_code, code_val FROM cbs.product ORDER BY product_name ASC",
                Map.of()
        );

        metadata.put("branches", branches);
        metadata.put("products", products);
        return metadata;
    }

    public DataTableResponse fetchReport1(DataTableRequest request) {
        Map<String, Object> params = new HashMap<>();
        String sql = buildReport1Query(request.getData(), params);
        return datatableRepo.dataTable(request, sql, params);
    }

    public List<Map<String, Object>> getReport1Data(String branch, List<String> products, String asAt) {
        Map<String, Object> filterMap = new HashMap<>();
        filterMap.put("branch", branch);
        filterMap.put("products", products);
        filterMap.put("asAt", asAt);

        Map<String, Object> params = new HashMap<>();
        String sql = buildReport1Query(filterMap, params);
        return jdbc.queryForList(sql, params);
    }

    public DataTableResponse fetchReport2(DataTableRequest request) {
        Map<String, Object> params = new HashMap<>();
        String sql = buildReport2Query(request.getData(), params);
        return datatableRepo.dataTable(request, sql, params);
    }

    public List<Map<String, Object>> getReport2Data(String branch, String fromDate, String toDate) {
        Map<String, Object> filterMap = new HashMap<>();
        filterMap.put("branch", branch);
        filterMap.put("fromDate", fromDate);
        filterMap.put("toDate", toDate);

        Map<String, Object> params = new HashMap<>();
        String sql = buildReport2Query(filterMap, params);
        return jdbc.queryForList(sql, params);
    }

    public DataTableResponse fetchReport3(DataTableRequest request) {
        Map<String, Object> params = new HashMap<>();
        String sql = buildReport3Query(request.getData(), params);
        return datatableRepo.dataTable(request, sql, params);
    }

    public List<Map<String, Object>> getReport3Data(String branch, List<String> products, String fromDate, String toDate) {
        Map<String, Object> filterMap = new HashMap<>();
        filterMap.put("branch", branch);
        filterMap.put("products", products);
        filterMap.put("fromDate", fromDate);
        filterMap.put("toDate", toDate);

        Map<String, Object> params = new HashMap<>();
        String sql = buildReport3Query(filterMap, params);
        return jdbc.queryForList(sql, params);
    }

    private String buildReport1Query(Object rawFilter, Map<String, Object> params) {
        String subQuery = """
            SELECT 
                p.portfolio_date, 
                l.account_no, 
                l.account_series AS `series`, 
                p.loan_status AS `portfolio_loan_status`, 
                p.total_due, 
                p.exposure, 
                p.dpd, 
                p.performing_status, 
                l.legacy_account_no, 
                COALESCE(pr.product_name, l.product) AS `product_name`, 
                COALESCE(br.branch_name, l.branch) AS `branch_name`, 
                l.client AS `client_code`, 
                l.loan_amount, 
                l.rental, 
                l.rate, 
                l.period,
                dl.device_id AS `device_id`,
                dl.device_status AS `device_status`,
                dl.external_id AS `external_id`,
                dl.platform AS `platform`
            FROM cbs.loan l
            LEFT JOIN cbs.portfolio p ON p.account_no = l.account_no AND p.series = l.account_series 
            LEFT JOIN cbs.branch br ON CAST(l.branch AS UNSIGNED) = br.branch_code 
            LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val 
            LEFT JOIN cbs.device_loan dl ON dl.account_no = l.account_no OR dl.account_no = l.legacy_account_no
            WHERE 1=1""";

        if (rawFilter instanceof Map) {
            Map<?, ?> filter = (Map<?, ?>) rawFilter;
            String branch = (String) filter.get("branch");
            if (branch != null && !branch.trim().isEmpty() && !branch.equalsIgnoreCase("All")) {
                subQuery += " AND br.legacy_branch_code = :branch";
                params.put("branch", branch.trim());
            }

            Object productsObj = filter.get("products");
            if (productsObj instanceof List) {
                List<?> products = (List<?>) productsObj;
                if (!products.isEmpty()) {
                    subQuery += " AND pr.product_code IN (:products)";
                    params.put("products", products);
                }
            }

            String asAt = (String) filter.get("asAt");
            if (asAt != null && !asAt.trim().isEmpty()) {
                subQuery += " AND p.portfolio_date <= :asAt";
                params.put("asAt", asAt.trim());
            }
        }

        return """
            SELECT 
                t.portfolio_date, 
                t.account_no, 
                t.series, 
                t.portfolio_loan_status AS `portfolio_loan_status`, 
                t.total_due, 
                t.exposure, 
                t.dpd, 
                t.performing_status, 
                t.legacy_account_no, 
                t.product_name AS `product_name`, 
                t.branch_name AS `branch_name`, 
                t.client_code AS `client_code`, 
                t.loan_amount, 
                t.rental, 
                t.rate, 
                t.period,
                t.device_id,
                t.device_status,
                t.external_id,
                t.platform
            FROM (""" + subQuery + ") t WHERE TRUE";
    }

    private String buildReport2Query(Object rawFilter, Map<String, Object> params) {
        String subQuery = """
            SELECT DISTINCT 
                c.client_code, 
                c.client_type, 
                c.title, 
                c.full_name, 
                c.id_no, 
                c.mobile, 
                c.address, 
                COALESCE(br.branch_name, l.branch) AS `branch_name`, 
                c.entered_date 
            FROM cbs.client c 
            LEFT JOIN cbs.loan l ON c.client_code = l.client 
            LEFT JOIN cbs.branch br ON CAST(l.branch AS UNSIGNED) = br.branch_code 
            WHERE 1=1""";

        if (rawFilter instanceof Map) {
            Map<?, ?> filter = (Map<?, ?>) rawFilter;
            String branch = (String) filter.get("branch");
            if (branch != null && !branch.trim().isEmpty() && !branch.equalsIgnoreCase("All")) {
                subQuery += " AND br.legacy_branch_code = :branch";
                params.put("branch", branch.trim());
            }

            String fromDate = (String) filter.get("fromDate");
            String toDate = (String) filter.get("toDate");
            if (fromDate != null && !fromDate.trim().isEmpty()) {
                subQuery += " AND DATE(c.entered_date) >= :fromDate";
                params.put("fromDate", fromDate.trim());
            }
            if (toDate != null && !toDate.trim().isEmpty()) {
                subQuery += " AND DATE(c.entered_date) <= :toDate";
                params.put("toDate", toDate.trim());
            }
        }

        return """
            SELECT 
                t.client_code AS `client_code`, 
                t.client_type AS `client_type`, 
                t.title, 
                t.full_name AS `full_name`, 
                t.id_no AS `id_no`, 
                t.mobile, 
                t.address, 
                t.branch_name AS `branch_name`, 
                t.entered_date AS `entered_date` 
            FROM (""" + subQuery + ") t WHERE TRUE";
    }

    private String buildReport3Query(Object rawFilter, Map<String, Object> params) {
        String subQuery = """
            SELECT 
                t.tran_id, 
                t.account_no, 
                t.legacy_account_no, 
                t.amount, 
                t.date, 
                t.user, 
                t.narration, 
                COALESCE(br.branch_name, l.branch) AS `branch_name`, 
                COALESCE(pr.product_name, l.product) AS `product_name` 
            FROM cbs.transaction t 
            LEFT JOIN cbs.loan l ON t.account_no = l.account_no 
            LEFT JOIN cbs.branch br ON CAST(l.branch AS UNSIGNED) = br.branch_code 
            LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val 
            WHERE 1=1""";

        if (rawFilter instanceof Map) {
            Map<?, ?> filter = (Map<?, ?>) rawFilter;
            String branch = (String) filter.get("branch");
            if (branch != null && !branch.trim().isEmpty() && !branch.equalsIgnoreCase("All")) {
                subQuery += " AND br.legacy_branch_code = :branch";
                params.put("branch", branch.trim());
            }

            Object productsObj = filter.get("products");
            if (productsObj instanceof List) {
                List<?> products = (List<?>) productsObj;
                if (!products.isEmpty()) {
                    subQuery += " AND pr.product_code IN (:products)";
                    params.put("products", products);
                }
            }

            String fromDate = (String) filter.get("fromDate");
            String toDate = (String) filter.get("toDate");
            if (fromDate != null && !fromDate.trim().isEmpty()) {
                subQuery += " AND DATE(t.date) >= :fromDate";
                params.put("fromDate", fromDate.trim());
            }
            if (toDate != null && !toDate.trim().isEmpty()) {
                subQuery += " AND DATE(t.date) <= :toDate";
                params.put("toDate", toDate.trim());
            }
        }

        return """
            SELECT 
                t.tran_id AS `tran_id`, 
                t.account_no, 
                t.legacy_account_no, 
                t.amount, 
                t.date, 
                t.user, 
                t.narration, 
                t.branch_name AS `branch_name`, 
                t.product_name AS `product_name` 
            FROM (""" + subQuery + ") t WHERE TRUE";
    }
}
