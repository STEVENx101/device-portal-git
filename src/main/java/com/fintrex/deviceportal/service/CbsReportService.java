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
        initReportLogTable();
        initDownloadScreen();
        initAgreementScreen();
        try {
            jdbc.getJdbcTemplate().execute("UPDATE device_portal.screen SET name = 'Facility Information' WHERE path = '/mobile'");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void initAgreementScreen() {
        try {
            jdbc.getJdbcTemplate().execute("""
                INSERT INTO device_portal.screen (name, path, icon, group_name)
                SELECT 'Agreement Report', '/agreement', 'fas fa-file-contract', 'Reports'
                WHERE NOT EXISTS (SELECT 1 FROM device_portal.screen WHERE path = '/agreement')
            """);
            jdbc.getJdbcTemplate().execute("""
                INSERT INTO device_portal.user_type_screen (user_type_id, screen_id)
                SELECT ut.id, s.id
                FROM device_portal.user_type ut, device_portal.screen s
                WHERE s.path = '/agreement'
                AND NOT EXISTS (
                    SELECT 1 FROM device_portal.user_type_screen uts 
                    WHERE uts.user_type_id = ut.id AND uts.screen_id = s.id
                )
            """);
            jdbc.getJdbcTemplate().execute("""
                INSERT INTO device_portal.screen (name, path, icon, group_name)
                SELECT 'Report Logs', '/report-logs', 'fas fa-history', 'Reports'
                WHERE NOT EXISTS (SELECT 1 FROM device_portal.screen WHERE path = '/report-logs')
            """);
            jdbc.getJdbcTemplate().execute("""
                INSERT INTO device_portal.user_type_screen (user_type_id, screen_id)
                SELECT ut.id, s.id
                FROM device_portal.user_type ut, device_portal.screen s
                WHERE s.path = '/report-logs'
                AND NOT EXISTS (
                    SELECT 1 FROM device_portal.user_type_screen uts 
                    WHERE uts.user_type_id = ut.id AND uts.screen_id = s.id
                )
            """);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void initReportLogTable() {
        try {
            jdbc.getJdbcTemplate().execute("""
                CREATE TABLE IF NOT EXISTS device_portal.report_log (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    username VARCHAR(100) NOT NULL,
                    report_name VARCHAR(100) NOT NULL,
                    action_type VARCHAR(20) NOT NULL,
                    filters TEXT,
                    created_date DATETIME NOT NULL
                )
            """);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void initDownloadScreen() {
        try {
            jdbc.getJdbcTemplate().execute("""
                INSERT INTO device_portal.screen (name, path, icon, group_name)
                SELECT 'Download Reports', '/download-reports', 'fas fa-download', 'Reports'
                WHERE NOT EXISTS (SELECT 1 FROM device_portal.screen WHERE path = '/download-reports')
            """);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void logReportActivity(String username, String reportName, String actionType, String filters) {
        try {
            jdbc.getJdbcTemplate().update(
                "INSERT INTO device_portal.report_log (username, report_name, action_type, filters, created_date) VALUES (?, ?, ?, ?, NOW())",
                username, reportName, actionType, filters
            );
        } catch (Exception e) {
            e.printStackTrace();
        }
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
                l.disbursed_date AS `disbursed_date`,
                l.closed_date AS `closed_date`,
                COALESCE(dl1.device_id, dl2.device_id) AS `device_id`,
                COALESCE(dl1.device_status, dl2.device_status) AS `device_status`,
                COALESCE(dl1.external_id, dl2.external_id) AS `external_id`,
                COALESCE(dl1.platform, dl2.platform) AS `platform`
            FROM cbs.loan l
            LEFT JOIN cbs.portfolio p ON p.account_no = l.account_no AND p.series = l.account_series 
            LEFT JOIN cbs.branch br ON CAST(l.branch AS UNSIGNED) = br.branch_code 
            LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val 
            LEFT JOIN cbs.device_loan dl1 ON dl1.account_no = l.account_no
            LEFT JOIN cbs.device_loan dl2 ON dl2.account_no = l.legacy_account_no
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
                subQuery += " AND l.disbursed_date <= :asAt";
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
                t.disbursed_date,
                t.closed_date,
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

    public DataTableResponse fetchReport4(DataTableRequest request) {
        Map<String, Object> params = new HashMap<>();
        String sql = buildReport4Query(request.getData(), params);
        return datatableRepo.dataTable(request, sql, params);
    }

    public List<Map<String, Object>> getReport4Data(String branch, List<String> products, String fromDate, String toDate) {
        Map<String, Object> filterMap = new HashMap<>();
        filterMap.put("branch", branch);
        filterMap.put("products", products);
        filterMap.put("fromDate", fromDate);
        filterMap.put("toDate", toDate);

        Map<String, Object> params = new HashMap<>();
        String sql = buildReport4Query(filterMap, params);
        return jdbc.queryForList(sql, params);
    }

    private String buildReport4Query(Object rawFilter, Map<String, Object> params) {
        String subQuery = """
            SELECT 
                l.account_no, 
                l.account_series AS `series`, 
                l.legacy_account_no, 
                l.client AS `client_code`,
                c.full_name AS `client_name`,
                c.id_no AS `id_no`,
                COALESCE(br.branch_name, l.branch) AS `branch_name`, 
                COALESCE(pr.product_name, l.product) AS `product_name`, 
                l.loan_amount, 
                l.period,
                l.rental, 
                l.rate, 
                l.disbursed_date AS `disbursed_date`,
                l.closed_date AS `closed_date`
            FROM cbs.loan l
            LEFT JOIN cbs.client c ON l.client = c.client_code
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
                subQuery += " AND DATE(l.disbursed_date) >= :fromDate";
                params.put("fromDate", fromDate.trim());
            }
            if (toDate != null && !toDate.trim().isEmpty()) {
                subQuery += " AND DATE(l.disbursed_date) <= :toDate";
                params.put("toDate", toDate.trim());
            }
        }

        return """
            SELECT 
                t.account_no, 
                t.series, 
                t.legacy_account_no, 
                t.client_code,
                t.client_name,
                t.id_no,
                t.branch_name, 
                t.product_name, 
                t.loan_amount, 
                t.period,
                t.rental, 
                t.rate, 
                t.disbursed_date,
                t.closed_date 
            FROM (""" + subQuery + ") t WHERE TRUE";
    }

    public DataTableResponse fetchReportLogs(DataTableRequest request) {
        Map<String, Object> params = new HashMap<>();
        String sql = buildReportLogsQuery(request.getData(), params);
        return datatableRepo.dataTable(request, sql, params);
    }

    private String buildReportLogsQuery(Object rawFilter, Map<String, Object> params) {
        String subQuery = """
            SELECT 
                id, 
                username, 
                report_name, 
                action_type, 
                filters, 
                created_date 
            FROM device_portal.report_log
            WHERE 1=1""";

        return """
            SELECT 
                t.id, 
                t.username, 
                t.report_name, 
                t.action_type, 
                t.filters, 
                t.created_date 
            FROM (""" + subQuery + ") t WHERE TRUE";
    }
}
