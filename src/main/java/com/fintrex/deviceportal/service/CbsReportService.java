package com.fintrex.deviceportal.service;

import com.fintrex.deviceportal.config.DataTableRequest;
import com.fintrex.deviceportal.config.DataTableResponse;
import com.fintrex.deviceportal.config.DataTableRepo;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class CbsReportService {

    private static final Logger log = LoggerFactory.getLogger(CbsReportService.class);
    private static final long PORTFOLIO_CACHE_TTL_MS = 60_000L;
    private static final long METADATA_CACHE_TTL_MS = 300_000L;

    private final NamedParameterJdbcTemplate jdbc;
    private final DataTableRepo datatableRepo;

    private final Object portfolioCacheLock = new Object();
    private final Object metadataCacheLock = new Object();

    private volatile Map<String, Object> latestPortfolioCache = Collections.emptyMap();
    private volatile long latestPortfolioCacheLoadedAt;

    private volatile Map<String, Object> metadataCache = Collections.emptyMap();
    private volatile long metadataCacheLoadedAt;

    public CbsReportService(NamedParameterJdbcTemplate jdbc, DataTableRepo datatableRepo) {
        this.jdbc = jdbc;
        this.datatableRepo = datatableRepo;
    }

    @PostConstruct
    public void initializeReportConfiguration() {
        initReportLogTable();
        initDownloadScreen();
        initAgreementScreen();
        initRecoveryScreens();

        try {
            jdbc.getJdbcTemplate()
                    .execute("UPDATE device_portal.screen SET name = 'Facility Information' WHERE path = '/mobile'");
        } catch (Exception e) {
            log.warn("Unable to update the Facility Information screen name", e);
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
            log.error("Report configuration database operation failed", e);
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

            Integer filtersColumnCount = jdbc.queryForObject("""
                        SELECT COUNT(*)
                        FROM information_schema.columns
                        WHERE table_schema = 'device_portal'
                          AND table_name = 'report_log'
                          AND column_name = 'filters'
                    """, Map.of(), Integer.class);

            if (filtersColumnCount != null && filtersColumnCount == 0) {
                jdbc.getJdbcTemplate().execute(
                        "ALTER TABLE device_portal.report_log ADD COLUMN filters TEXT");
            }
        } catch (Exception e) {
            log.error("Unable to initialize device_portal.report_log", e);
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
            log.error("Report configuration database operation failed", e);
        }
    }

    public void logReportActivity(String username, String reportName, String actionType, String filters) {
        try {
            jdbc.getJdbcTemplate().update(
                    "INSERT INTO device_portal.report_log (username, report_name, action_type, filters, created_date) VALUES (?, ?, ?, ?, NOW())",
                    username, reportName, actionType, filters);
        } catch (Exception e) {
            log.error("Unable to write report activity log for report {}", reportName, e);
        }
    }

    public Map<String, Object> getMetadata() {
        long now = System.currentTimeMillis();
        Map<String, Object> current = metadataCache;

        if (metadataCacheLoadedAt > 0L && now - metadataCacheLoadedAt < METADATA_CACHE_TTL_MS) {
            return new HashMap<>(current);
        }

        synchronized (metadataCacheLock) {
            now = System.currentTimeMillis();
            current = metadataCache;

            if (metadataCacheLoadedAt > 0L && now - metadataCacheLoadedAt < METADATA_CACHE_TTL_MS) {
                return new HashMap<>(current);
            }

            List<Map<String, Object>> branches = jdbc.queryForList(
                    "SELECT legacy_branch_code, branch_code, branch_name " +
                            "FROM cbs.branch ORDER BY branch_name ASC",
                    Map.of());
            List<Map<String, Object>> products = jdbc.queryForList(
                    "SELECT product_name, product_code, code_val " +
                            "FROM cbs.product ORDER BY product_name ASC",
                    Map.of());

            Map<String, Object> loaded = new HashMap<>();
            loaded.put("branches", List.copyOf(branches));
            loaded.put("products", List.copyOf(products));

            metadataCache = Collections.unmodifiableMap(loaded);
            metadataCacheLoadedAt = now;
            return new HashMap<>(metadataCache);
        }
    }

    public void clearReportCaches() {
        synchronized (portfolioCacheLock) {
            latestPortfolioCache = Collections.emptyMap();
            latestPortfolioCacheLoadedAt = 0L;
        }

        synchronized (metadataCacheLock) {
            metadataCache = Collections.emptyMap();
            metadataCacheLoadedAt = 0L;
        }
    }

    private DataTableResponse executePagedReport(
            DataTableRequest request,
            String sql,
            Map<String, Object> params) {
        return datatableRepo.dataTable(request, sql, params);
    }

    private List<Map<String, Object>> executeDownloadReport(
            String sql,
            Map<String, Object> params) {
        return jdbc.queryForList(sql, params);
    }

    public DataTableResponse fetchReport1(DataTableRequest request) {
        Map<String, Object> params = new HashMap<>();
        String sql = buildReport1Query(request.getData(), params);
        return executePagedReport(request, sql, params);
    }

    public List<Map<String, Object>> getReport1Data(String branch, List<String> products, String asAt) {
        Map<String, Object> filterMap = new HashMap<>();
        filterMap.put("branch", branch);
        filterMap.put("products", products);
        filterMap.put("asAt", asAt);

        Map<String, Object> params = new HashMap<>();
        String sql = buildReport1Query(filterMap, params);
        return executeDownloadReport(sql, params);
    }

    public DataTableResponse fetchReport2(DataTableRequest request) {
        Map<String, Object> params = new HashMap<>();
        String sql = buildReport2Query(request.getData(), params);
        return executePagedReport(request, sql, params);
    }

    public List<Map<String, Object>> getReport2Data(String branch, String fromDate, String toDate) {
        Map<String, Object> filterMap = new HashMap<>();
        filterMap.put("branch", branch);
        filterMap.put("fromDate", fromDate);
        filterMap.put("toDate", toDate);

        Map<String, Object> params = new HashMap<>();
        String sql = buildReport2Query(filterMap, params);
        return executeDownloadReport(sql, params);
    }

    public DataTableResponse fetchReport3(DataTableRequest request) {
        Map<String, Object> params = new HashMap<>();
        String sql = buildReport3Query(request.getData(), params);
        return executePagedReport(request, sql, params);
    }

    public List<Map<String, Object>> getReport3Data(String branch, List<String> products, String fromDate,
            String toDate) {
        Map<String, Object> filterMap = new HashMap<>();
        filterMap.put("branch", branch);
        filterMap.put("products", products);
        filterMap.put("fromDate", fromDate);
        filterMap.put("toDate", toDate);

        Map<String, Object> params = new HashMap<>();
        String sql = buildReport3Query(filterMap, params);
        return executeDownloadReport(sql, params);
    }

    private void addLatestPortfolioParams(Map<String, Object> params) {
        Map<String, Object> latest = getLatestPortfolioBatch();
        params.put("latestPortfolioDate", latest.get("latestPortfolioDate"));
    }

    private Map<String, Object> getLatestPortfolioBatch() {
        long now = System.currentTimeMillis();
        Map<String, Object> current = latestPortfolioCache;

        if (latestPortfolioCacheLoadedAt > 0L && now - latestPortfolioCacheLoadedAt < PORTFOLIO_CACHE_TTL_MS) {
            return current;
        }

        synchronized (portfolioCacheLock) {
            now = System.currentTimeMillis();
            current = latestPortfolioCache;

            if (latestPortfolioCacheLoadedAt > 0L && now - latestPortfolioCacheLoadedAt < PORTFOLIO_CACHE_TTL_MS) {
                return current;
            }

            String sql = """
                        SELECT portfolio_date
                        FROM cbs.portfolio
                        WHERE portfolio_date IS NOT NULL
                        ORDER BY portfolio_date DESC
                        LIMIT 1
                    """;

            Map<String, Object> loaded = jdbc.query(sql, Map.of(), resultSet -> {
                if (!resultSet.next()) {
                    return Collections.emptyMap();
                }

                Map<String, Object> row = new HashMap<>();
                row.put("latestPortfolioDate", resultSet.getObject("portfolio_date"));
                return Collections.unmodifiableMap(row);
            });

            latestPortfolioCache = loaded;
            latestPortfolioCacheLoadedAt = now;

            if (loaded.isEmpty()) {
                log.warn("No portfolio batch was found in cbs.portfolio");
            }

            return loaded;
        }
    }

    private String buildReport1Query(Object rawFilter, Map<String, Object> params) {
        addLatestPortfolioParams(params);
        String subQuery = """
                SELECT
                    DATE_FORMAT(p1.portfolio_date, '%Y-%m-%d') AS portfolio_date,
                    l.account_no,
                    l.account_series AS `series`,
                    p1.loan_status AS `portfolio_loan_status`,
                    p1.total_due AS total_due,
                    p1.exposure AS exposure,
                    p1.dpd AS dpd,
                    p1.performing_status AS performing_status,
                    l.legacy_account_no,
                    COALESCE(pr.product_name, l.product) AS `product_name`,
                    COALESCE(br.branch_name, l.branch) AS `branch_name`,
                    l.client AS `client_code`,
                    l.loan_amount,
                    l.rental,
                    l.rate,
                    l.period,
                    DATE_FORMAT(l.disbursed_date, '%Y-%m-%d') AS `disbursed_date`,
                    DATE_FORMAT(l.closed_date, '%Y-%m-%d') AS `closed_date`,
                    COALESCE(dl1.device_id, dl2.device_id) AS `device_id`,
                    COALESCE(dl1.device_status, dl2.device_status) AS `device_status`,
                    COALESCE(dl1.external_id, dl2.external_id) AS `external_id`,
                    COALESCE(dl1.platform, dl2.platform) AS `platform`
                FROM cbs.loan l
                JOIN cbs.portfolio p1
                    ON p1.account_no = l.account_no
                    AND p1.series = l.account_series
                    AND p1.portfolio_date = :latestPortfolioDate
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
                subQuery += " AND l.disbursed_date < DATE_ADD(:asAt, INTERVAL 1 DAY)";
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
                    DATE_FORMAT(c.entered_date, '%Y-%m-%d') AS `entered_date`
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
                subQuery += " AND c.entered_date >= :fromDate";
                params.put("fromDate", fromDate.trim());
            }
            if (toDate != null && !toDate.trim().isEmpty()) {
                subQuery += " AND c.entered_date < DATE_ADD(:toDate, INTERVAL 1 DAY)";
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
                    COALESCE(l1.legacy_account_no, l2.legacy_account_no) AS legacy_account_no,
                    t.amount,
                    DATE_FORMAT(t.date, '%Y-%m-%d') AS `date`,
                    t.user,
                    t.narration,
                    t.channel,
                    COALESCE(br.branch_name, l1.branch, l2.branch) AS `branch_name`,
                    COALESCE(pr.product_name, l1.product, l2.product) AS `product_name`
                FROM cbs.transaction t
                LEFT JOIN cbs.loan l1 ON t.account_no = l1.account_no
                LEFT JOIN cbs.loan l2 ON t.account_no = l2.legacy_account_no
                LEFT JOIN cbs.branch br ON CAST(COALESCE(l1.branch, l2.branch) AS UNSIGNED) = br.branch_code
                LEFT JOIN cbs.product pr ON CAST(COALESCE(l1.product, l2.product) AS UNSIGNED) = pr.code_val
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
                subQuery += " AND t.date >= :fromDate";
                params.put("fromDate", fromDate.trim());
            }
            if (toDate != null && !toDate.trim().isEmpty()) {
                subQuery += " AND t.date < DATE_ADD(:toDate, INTERVAL 1 DAY)";
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
                    t.channel,
                    t.branch_name AS `branch_name`,
                    t.product_name AS `product_name`
                FROM (""" + subQuery + ") t WHERE TRUE";
    }

    public DataTableResponse fetchReport4(DataTableRequest request) {
        Map<String, Object> params = new HashMap<>();
        String sql = buildReport4Query(request.getData(), params);
        return executePagedReport(request, sql, params);
    }

    public List<Map<String, Object>> getReport4Data(String branch, List<String> products, String fromDate,
            String toDate) {
        Map<String, Object> filterMap = new HashMap<>();
        filterMap.put("branch", branch);
        filterMap.put("products", products);
        filterMap.put("fromDate", fromDate);
        filterMap.put("toDate", toDate);

        Map<String, Object> params = new HashMap<>();
        String sql = buildReport4Query(filterMap, params);
        return executeDownloadReport(sql, params);
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
                    DATE_FORMAT(l.disbursed_date, '%Y-%m-%d') AS `disbursed_date`,
                    DATE_FORMAT(l.closed_date, '%Y-%m-%d') AS `closed_date`
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
                subQuery += " AND l.disbursed_date >= :fromDate";
                params.put("fromDate", fromDate.trim());
            }
            if (toDate != null && !toDate.trim().isEmpty()) {
                subQuery += " AND l.disbursed_date < DATE_ADD(:toDate, INTERVAL 1 DAY)";
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
        return executePagedReport(request, sql, params);
    }

    private String buildReportLogsQuery(Object rawFilter, Map<String, Object> params) {
        String subQuery = """
                SELECT
                    id,
                    username,
                    report_name,
                    action_type,
                    filters,
                    DATE_FORMAT(created_date, '%Y-%m-%d') AS `created_date`
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

    private void initRecoveryScreens() {
        try {
            // Arrears Report
            jdbc.getJdbcTemplate().execute("""
                        INSERT INTO device_portal.screen (name, path, icon, group_name)
                        SELECT 'Arrears Report', '/arrears-report', 'fas fa-clock', 'Reports'
                        WHERE NOT EXISTS (SELECT 1 FROM device_portal.screen WHERE path = '/arrears-report')
                    """);
            jdbc.getJdbcTemplate().execute("""
                        INSERT INTO device_portal.user_type_screen (user_type_id, screen_id)
                        SELECT ut.id, s.id
                        FROM device_portal.user_type ut, device_portal.screen s
                        WHERE s.path = '/arrears-report'
                        AND NOT EXISTS (
                            SELECT 1 FROM device_portal.user_type_screen uts
                            WHERE uts.user_type_id = ut.id AND uts.screen_id = s.id
                        )
                    """);

            // NPA Report
            jdbc.getJdbcTemplate().execute("""
                        INSERT INTO device_portal.screen (name, path, icon, group_name)
                        SELECT 'NPA Report', '/npa-report', 'fas fa-exclamation-triangle', 'Reports'
                        WHERE NOT EXISTS (SELECT 1 FROM device_portal.screen WHERE path = '/npa-report')
                    """);
            jdbc.getJdbcTemplate().execute("""
                        INSERT INTO device_portal.user_type_screen (user_type_id, screen_id)
                        SELECT ut.id, s.id
                        FROM device_portal.user_type ut, device_portal.screen s
                        WHERE s.path = '/npa-report'
                        AND NOT EXISTS (
                            SELECT 1 FROM device_portal.user_type_screen uts
                            WHERE uts.user_type_id = ut.id AND uts.screen_id = s.id
                        )
                    """);

            // Nearing NPA Report
            jdbc.getJdbcTemplate().execute("""
                        INSERT INTO device_portal.screen (name, path, icon, group_name)
                        SELECT 'Nearing NPA Report', '/nearing-npa-report', 'fas fa-hourglass-half', 'Reports'
                        WHERE NOT EXISTS (SELECT 1 FROM device_portal.screen WHERE path = '/nearing-npa-report')
                    """);
            jdbc.getJdbcTemplate().execute("""
                        INSERT INTO device_portal.user_type_screen (user_type_id, screen_id)
                        SELECT ut.id, s.id
                        FROM device_portal.user_type ut, device_portal.screen s
                        WHERE s.path = '/nearing-npa-report'
                        AND NOT EXISTS (
                            SELECT 1 FROM device_portal.user_type_screen uts
                            WHERE uts.user_type_id = ut.id AND uts.screen_id = s.id
                        )
                    """);

            // Duplicate Loans Report (Exception Reports)
            jdbc.getJdbcTemplate().execute("""
                        INSERT INTO device_portal.screen (name, path, icon, group_name)
                        SELECT 'Duplicate Loans', '/duplicate-loans-report', 'fas fa-copy', 'Reports'
                        WHERE NOT EXISTS (SELECT 1 FROM device_portal.screen WHERE path = '/duplicate-loans-report')
                    """);
            jdbc.getJdbcTemplate().execute("""
                        INSERT INTO device_portal.user_type_screen (user_type_id, screen_id)
                        SELECT ut.id, s.id
                        FROM device_portal.user_type ut, device_portal.screen s
                        WHERE s.path = '/duplicate-loans-report'
                        AND NOT EXISTS (
                            SELECT 1 FROM device_portal.user_type_screen uts
                            WHERE uts.user_type_id = ut.id AND uts.screen_id = s.id
                        )
                    """);

            // Unlock with Arrears Report
            jdbc.getJdbcTemplate().execute("""
                        INSERT INTO device_portal.screen (name, path, icon, group_name)
                        SELECT 'Unlock with Arrears', '/unlock-arrears-report', 'fas fa-lock-open', 'Reports'
                        WHERE NOT EXISTS (SELECT 1 FROM device_portal.screen WHERE path = '/unlock-arrears-report')
                    """);
            jdbc.getJdbcTemplate().execute("""
                        INSERT INTO device_portal.user_type_screen (user_type_id, screen_id)
                        SELECT ut.id, s.id
                        FROM device_portal.user_type ut, device_portal.screen s
                        WHERE s.path = '/unlock-arrears-report'
                        AND NOT EXISTS (
                            SELECT 1 FROM device_portal.user_type_screen uts
                            WHERE uts.user_type_id = ut.id AND uts.screen_id = s.id
                        )
                    """);

            // Lock with No Arrears Report
            jdbc.getJdbcTemplate().execute("""
                        INSERT INTO device_portal.screen (name, path, icon, group_name)
                        SELECT 'Lock with No Arrears', '/lock-no-arrears-report', 'fas fa-lock', 'Reports'
                        WHERE NOT EXISTS (SELECT 1 FROM device_portal.screen WHERE path = '/lock-no-arrears-report')
                    """);
            jdbc.getJdbcTemplate().execute("""
                        INSERT INTO device_portal.user_type_screen (user_type_id, screen_id)
                        SELECT ut.id, s.id
                        FROM device_portal.user_type ut, device_portal.screen s
                        WHERE s.path = '/lock-no-arrears-report'
                        AND NOT EXISTS (
                            SELECT 1 FROM device_portal.user_type_screen uts
                            WHERE uts.user_type_id = ut.id AND uts.screen_id = s.id
                        )
                    """);

            // Last Rental Remaining Report
            jdbc.getJdbcTemplate().execute("""
                        INSERT INTO device_portal.screen (name, path, icon, group_name)
                        SELECT 'Last Rental Remaining', '/one-rental-report', 'fas fa-calculator', 'Reports'
                        WHERE NOT EXISTS (SELECT 1 FROM device_portal.screen WHERE path = '/one-rental-report')
                    """);
            jdbc.getJdbcTemplate().execute("""
                        UPDATE device_portal.screen
                        SET name = 'Last Rental Remaining'
                        WHERE path = '/one-rental-report' AND name = 'One Rental Left'
                    """);
            jdbc.getJdbcTemplate().execute("""
                        INSERT INTO device_portal.user_type_screen (user_type_id, screen_id)
                        SELECT ut.id, s.id
                        FROM device_portal.user_type ut, device_portal.screen s
                        WHERE s.path = '/one-rental-report'
                        AND NOT EXISTS (
                            SELECT 1 FROM device_portal.user_type_screen uts
                            WHERE uts.user_type_id = ut.id AND uts.screen_id = s.id
                        )
                    """);

            // Matured Low Balance Report
            jdbc.getJdbcTemplate().execute("""
                        INSERT INTO device_portal.screen (name, path, icon, group_name)
                        SELECT 'Matured Low Balance', '/matured-low-balance-report', 'fas fa-calendar-check', 'Reports'
                        WHERE NOT EXISTS (SELECT 1 FROM device_portal.screen WHERE path = '/matured-low-balance-report')
                    """);
            jdbc.getJdbcTemplate().execute("""
                        INSERT INTO device_portal.user_type_screen (user_type_id, screen_id)
                        SELECT ut.id, s.id
                        FROM device_portal.user_type ut, device_portal.screen s
                        WHERE s.path = '/matured-low-balance-report'
                        AND NOT EXISTS (
                            SELECT 1 FROM device_portal.user_type_screen uts
                            WHERE uts.user_type_id = ut.id AND uts.screen_id = s.id
                        )
                    """);

            // DPD Bucket Report
            jdbc.getJdbcTemplate().execute("""
                        INSERT INTO device_portal.screen (name, path, icon, group_name)
                        SELECT 'DPD Bucket Report', '/dpd-bucket-report', 'fas fa-chart-bar', 'Reports'
                        WHERE NOT EXISTS (SELECT 1 FROM device_portal.screen WHERE path = '/dpd-bucket-report')
                    """);
            jdbc.getJdbcTemplate().execute("""
                        INSERT INTO device_portal.user_type_screen (user_type_id, screen_id)
                        SELECT ut.id, s.id
                        FROM device_portal.user_type ut, device_portal.screen s
                        WHERE s.path = '/dpd-bucket-report'
                        AND NOT EXISTS (
                            SELECT 1 FROM device_portal.user_type_screen uts
                            WHERE uts.user_type_id = ut.id AND uts.screen_id = s.id
                        )
                    """);

            // Settled & Early Settled Report
            jdbc.getJdbcTemplate().execute("""
                        INSERT INTO device_portal.screen (name, path, icon, group_name)
                        SELECT 'Settled & Early Settled', '/settled-report', 'fas fa-check-circle', 'Reports'
                        WHERE NOT EXISTS (SELECT 1 FROM device_portal.screen WHERE path = '/settled-report')
                    """);
            jdbc.getJdbcTemplate().execute("""
                        INSERT INTO device_portal.user_type_screen (user_type_id, screen_id)
                        SELECT ut.id, s.id
                        FROM device_portal.user_type ut, device_portal.screen s
                        WHERE s.path = '/settled-report'
                        AND NOT EXISTS (
                            SELECT 1 FROM device_portal.user_type_screen uts
                            WHERE uts.user_type_id = ut.id AND uts.screen_id = s.id
                        )
                    """);

            // Multiple Payments Report
            jdbc.getJdbcTemplate().execute("""
                        INSERT INTO device_portal.screen (name, path, icon, group_name)
                        SELECT 'Multiple Payments', '/multiple-payments-report', 'fas fa-history', 'Reports'
                        WHERE NOT EXISTS (SELECT 1 FROM device_portal.screen WHERE path = '/multiple-payments-report')
                    """);
            jdbc.getJdbcTemplate().execute("""
                        INSERT INTO device_portal.user_type_screen (user_type_id, screen_id)
                        SELECT ut.id, s.id
                        FROM device_portal.user_type ut, device_portal.screen s
                        WHERE s.path = '/multiple-payments-report'
                        AND NOT EXISTS (
                            SELECT 1 FROM device_portal.user_type_screen uts
                            WHERE uts.user_type_id = ut.id AND uts.screen_id = s.id
                        )
                    """);
        } catch (Exception e) {
            log.error("Report configuration database operation failed", e);
        }
    }

    public DataTableResponse fetchArrearsReport(DataTableRequest request) {
        Map<String, Object> params = new HashMap<>();
        String sql = buildArrearsReportQuery(request.getData(), params);
        return executePagedReport(request, sql, params);
    }

    public List<Map<String, Object>> getArrearsReportData(String asAt) {
        Map<String, Object> filterMap = new HashMap<>();
        filterMap.put("asAt", asAt);
        Map<String, Object> params = new HashMap<>();
        String sql = buildArrearsReportQuery(filterMap, params);
        return executeDownloadReport(sql, params);
    }

    public DataTableResponse fetchNpaReport(DataTableRequest request) {
        Map<String, Object> params = new HashMap<>();
        String sql = buildNpaReportQuery(request.getData(), params);
        return executePagedReport(request, sql, params);
    }

    public List<Map<String, Object>> getNpaReportData(String asAt) {
        Map<String, Object> filterMap = new HashMap<>();
        filterMap.put("asAt", asAt);
        Map<String, Object> params = new HashMap<>();
        String sql = buildNpaReportQuery(filterMap, params);
        return executeDownloadReport(sql, params);
    }

    public DataTableResponse fetchNearingNpaReport(DataTableRequest request) {
        Map<String, Object> params = new HashMap<>();
        String sql = buildNearingNpaReportQuery(request.getData(), params);
        return executePagedReport(request, sql, params);
    }

    public List<Map<String, Object>> getNearingNpaReportData(String asAt) {
        Map<String, Object> filterMap = new HashMap<>();
        filterMap.put("asAt", asAt);
        Map<String, Object> params = new HashMap<>();
        String sql = buildNearingNpaReportQuery(filterMap, params);
        return executeDownloadReport(sql, params);
    }

    public DataTableResponse fetchDuplicateLoansReport(DataTableRequest request) {
        Map<String, Object> params = new HashMap<>();
        String sql = buildDuplicateLoansQuery(params);
        return executePagedReport(request, sql, params);
    }

    public List<Map<String, Object>> getDuplicateLoansReportData() {
        Map<String, Object> params = new HashMap<>();
        String sql = buildDuplicateLoansQuery(params);
        return executeDownloadReport(sql, params);
    }

    private String buildDuplicateLoansQuery(Map<String, Object> params) {
        return """
                    SELECT
                        dl.device_id AS imei_no,
                        COALESCE(l1.account_no, l2.account_no) AS account_no,
                        COALESCE(l1.account_series, l2.account_series) AS series,
                        COALESCE(l1.legacy_account_no, l2.legacy_account_no) AS legacy_account_no,
                        COALESCE(c1.full_name, c2.full_name) AS client_name,
                        COALESCE(c1.id_no, c2.id_no) AS client_nic,
                        COALESCE(l1.loan_amount, l2.loan_amount) AS loan_amount,
                        COALESCE(v1.name, v2.name) AS vendor_name
                    FROM cbs.device_loan dl
                    INNER JOIN (
                        SELECT device_id
                        FROM cbs.device_loan
                        WHERE device_id IS NOT NULL
                          AND device_id != ''
                        GROUP BY device_id
                        HAVING COUNT(*) > 1
                    ) duplicates ON duplicates.device_id = dl.device_id
                    LEFT JOIN cbs.loan l1 ON dl.account_no = l1.account_no
                    LEFT JOIN cbs.loan l2 ON dl.account_no = l2.legacy_account_no
                    LEFT JOIN cbs.client c1 ON l1.client = c1.client_code
                    LEFT JOIN cbs.client c2 ON l2.client = c2.client_code
                    LEFT JOIN cbs.vendor v1 ON l1.vendor = v1.code
                    LEFT JOIN cbs.vendor v2 ON l2.vendor = v2.code
                    ORDER BY dl.device_id ASC
                """;
    }

    private String buildArrearsReportQuery(Object rawFilter, Map<String, Object> params) {
        addLatestPortfolioParams(params);
        String subQuery = """
                SELECT
                    l.account_no,
                    l.account_series AS `series`,
                    l.legacy_account_no,
                    c.full_name AS `client_name`,
                    c.id_no AS `client_nic`,
                    c.mobile AS `client_mobile`,
                    c.address AS `client_address`,
                    l.loan_amount,
                    l.rental,
                    p1.total_due AS `total_due`,
                    p1.exposure AS `exposure`,
                    p1.dpd AS `dpd`,
                    p1.loan_status AS `loan_status`,
                    p1.performing_status AS `performing_status`,
                    p1.npl_status AS `npl_status`,
                    p1.recovery_officer AS `recovery_officer`,
                    DATE_FORMAT(p1.last_payment_date, '%Y-%m-%d') AS `last_payment_date`,
                    p1.last_payment_amount AS `last_payment_amount`
                FROM cbs.loan l
                JOIN cbs.portfolio p1
                    ON p1.account_no = l.account_no
                    AND p1.series = l.account_series
                    AND p1.portfolio_date = :latestPortfolioDate
                LEFT JOIN cbs.client c ON l.client = c.client_code
                WHERE 1=1 AND p1.dpd > 0""";

        if (rawFilter instanceof Map) {
            Map<?, ?> filter = (Map<?, ?>) rawFilter;
            String asAt = (String) filter.get("asAt");
            if (asAt != null && !asAt.trim().isEmpty()) {
                subQuery += " AND l.disbursed_date < DATE_ADD(:asAt, INTERVAL 1 DAY)";
                params.put("asAt", asAt.trim());
            }
        }

        return """
                SELECT
                    t.account_no,
                    t.series,
                    t.legacy_account_no,
                    t.client_name,
                    t.client_nic,
                    t.client_mobile,
                    t.client_address,
                    t.loan_amount,
                    t.rental,
                    t.total_due,
                    t.exposure,
                    t.dpd,
                    CASE
                        WHEN t.loan_status = 'A' THEN 'Active Loan'
                        WHEN t.loan_status = 'F' THEN 'Fully Paid'
                        WHEN t.loan_status = 'N' THEN 'NPA (DPD over 90 days)'
                        WHEN t.loan_status = 'P' THEN 'Paid Off'
                        ELSE t.loan_status
                    END AS `loan_status`,
                    t.performing_status,
                    t.npl_status,
                    t.recovery_officer,
                    t.last_payment_date,
                    t.last_payment_amount
                FROM (""" + subQuery + ") t WHERE TRUE";
    }

    private String buildNpaReportQuery(Object rawFilter, Map<String, Object> params) {
        addLatestPortfolioParams(params);
        String subQuery = """
                SELECT
                    l.account_no,
                    l.account_series AS `series`,
                    l.legacy_account_no,
                    c.full_name AS `client_name`,
                    c.id_no AS `client_nic`,
                    c.mobile AS `client_mobile`,
                    c.address AS `client_address`,
                    l.loan_amount,
                    l.rental,
                    p1.total_due AS `total_due`,
                    p1.exposure AS `exposure`,
                    p1.dpd AS `dpd`,
                    p1.loan_status AS `loan_status`,
                    p1.performing_status AS `performing_status`,
                    p1.npl_status AS `npl_status`,
                    p1.recovery_officer AS `recovery_officer`,
                    DATE_FORMAT(p1.last_payment_date, '%Y-%m-%d') AS `last_payment_date`,
                    p1.last_payment_amount AS `last_payment_amount`
                FROM cbs.loan l
                JOIN cbs.portfolio p1
                    ON p1.account_no = l.account_no
                    AND p1.series = l.account_series
                    AND p1.portfolio_date = :latestPortfolioDate
                LEFT JOIN cbs.client c ON l.client = c.client_code
                WHERE 1=1 AND p1.performing_status = 'Non-Performing'""";

        if (rawFilter instanceof Map) {
            Map<?, ?> filter = (Map<?, ?>) rawFilter;
            String asAt = (String) filter.get("asAt");
            if (asAt != null && !asAt.trim().isEmpty()) {
                subQuery += " AND l.disbursed_date < DATE_ADD(:asAt, INTERVAL 1 DAY)";
                params.put("asAt", asAt.trim());
            }
        }

        return """
                SELECT
                    t.account_no,
                    t.series,
                    t.legacy_account_no,
                    t.client_name,
                    t.client_nic,
                    t.client_mobile,
                    t.client_address,
                    t.loan_amount,
                    t.rental,
                    t.total_due,
                    t.exposure,
                    t.dpd,
                    CASE
                        WHEN t.loan_status = 'A' THEN 'Active Loan'
                        WHEN t.loan_status = 'F' THEN 'Fully Paid'
                        WHEN t.loan_status = 'N' THEN 'NPA (DPD over 90 days)'
                        WHEN t.loan_status = 'P' THEN 'Paid Off'
                        ELSE t.loan_status
                    END AS `loan_status`,
                    t.performing_status,
                    t.npl_status,
                    t.recovery_officer,
                    t.last_payment_date,
                    t.last_payment_amount
                FROM (""" + subQuery + ") t WHERE TRUE";
    }

    private String buildNearingNpaReportQuery(Object rawFilter, Map<String, Object> params) {
        addLatestPortfolioParams(params);
        String subQuery = """
                SELECT
                    l.account_no,
                    l.account_series AS `series`,
                    l.legacy_account_no,
                    c.full_name AS `client_name`,
                    c.id_no AS `client_nic`,
                    c.mobile AS `client_mobile`,
                    c.address AS `client_address`,
                    l.loan_amount,
                    l.rental,
                    p1.total_due AS `total_due`,
                    p1.exposure AS `exposure`,
                    p1.dpd AS `dpd`,
                    p1.loan_status AS `loan_status`,
                    p1.performing_status AS `performing_status`,
                    p1.npl_status AS `npl_status`,
                    p1.recovery_officer AS `recovery_officer`,
                    DATE_FORMAT(p1.last_payment_date, '%Y-%m-%d') AS `last_payment_date`,
                    p1.last_payment_amount AS `last_payment_amount`
                FROM cbs.loan l
                JOIN cbs.portfolio p1
                    ON p1.account_no = l.account_no
                    AND p1.series = l.account_series
                    AND p1.portfolio_date = :latestPortfolioDate
                LEFT JOIN cbs.client c ON l.client = c.client_code
                WHERE 1=1 AND p1.dpd BETWEEN 60 AND 90""";

        if (rawFilter instanceof Map) {
            Map<?, ?> filter = (Map<?, ?>) rawFilter;
            String asAt = (String) filter.get("asAt");
            if (asAt != null && !asAt.trim().isEmpty()) {
                subQuery += " AND l.disbursed_date < DATE_ADD(:asAt, INTERVAL 1 DAY)";
                params.put("asAt", asAt.trim());
            }
        }

        return """
                SELECT
                    t.account_no,
                    t.series,
                    t.legacy_account_no,
                    t.client_name,
                    t.client_nic,
                    t.client_mobile,
                    t.client_address,
                    t.loan_amount,
                    t.rental,
                    t.total_due,
                    t.exposure,
                    t.dpd,
                    CASE
                        WHEN t.loan_status = 'A' THEN 'Active Loan'
                        WHEN t.loan_status = 'F' THEN 'Fully Paid'
                        WHEN t.loan_status = 'N' THEN 'NPA (DPD over 90 days)'
                        WHEN t.loan_status = 'P' THEN 'Paid Off'
                        ELSE t.loan_status
                    END AS `loan_status`,
                    t.performing_status,
                    t.npl_status,
                    t.recovery_officer,
                    t.last_payment_date,
                    t.last_payment_amount
                FROM (""" + subQuery + ") t WHERE TRUE";
    }

    public DataTableResponse fetchUnlockArrearsReport(DataTableRequest request) {
        Map<String, Object> params = new HashMap<>();
        String sql = buildUnlockArrearsReportQuery(request.getData(), params);
        return executePagedReport(request, sql, params);
    }

    public List<Map<String, Object>> getUnlockArrearsReportData(String asAt) {
        Map<String, Object> filterMap = new HashMap<>();
        filterMap.put("asAt", asAt);
        Map<String, Object> params = new HashMap<>();
        String sql = buildUnlockArrearsReportQuery(filterMap, params);
        return executeDownloadReport(sql, params);
    }

    public DataTableResponse fetchLockNoArrearsReport(DataTableRequest request) {
        Map<String, Object> params = new HashMap<>();
        String sql = buildLockNoArrearsReportQuery(request.getData(), params);
        return executePagedReport(request, sql, params);
    }

    public List<Map<String, Object>> getLockNoArrearsReportData(String asAt) {
        Map<String, Object> filterMap = new HashMap<>();
        filterMap.put("asAt", asAt);
        Map<String, Object> params = new HashMap<>();
        String sql = buildLockNoArrearsReportQuery(filterMap, params);
        return executeDownloadReport(sql, params);
    }

    private String buildUnlockArrearsReportQuery(Object rawFilter, Map<String, Object> params) {
        addLatestPortfolioParams(params);
        String subQuery = """
                SELECT
                    l.account_no,
                    l.account_series AS `series`,
                    l.legacy_account_no,
                    c.full_name AS `client_name`,
                    c.id_no AS `client_nic`,
                    c.mobile AS `client_mobile`,
                    c.address AS `client_address`,
                    l.loan_amount,
                    l.rental,
                    p.total_due AS `total_due`,
                    p.exposure AS `exposure`,
                    p.dpd AS `dpd`,
                    CASE
                        WHEN COALESCE(lm1.locked, 0) = 1 OR COALESCE(lm2.locked, 0) = 1 OR COALESCE(dl1.locked, 0) = 1 OR COALESCE(dl2.locked, 0) = 1 THEN 'Locked'
                        ELSE 'Unlocked'
                    END AS `lock_status`,
                    p.recovery_officer AS `recovery_officer`
                FROM cbs.portfolio p
                INNER JOIN cbs.loan l
                    ON (l.account_no = p.account_no OR l.legacy_account_no = p.account_no)
                    AND l.account_series = p.series
                LEFT JOIN cbs.client c ON l.client = c.client_code
                LEFT JOIN loan.mobileloan lm1 ON lm1.finance_no = l.account_no
                LEFT JOIN loan.mobileloan lm2 ON lm2.finance_no = l.legacy_account_no
                LEFT JOIN loan.device_loan dl1 ON dl1.finance_no = l.account_no
                LEFT JOIN loan.device_loan dl2 ON dl2.finance_no = l.legacy_account_no
                WHERE p.portfolio_date = :latestPortfolioDate
                  AND p.total_due >= 200
                  AND NOT (COALESCE(lm1.locked, 0) = 1 OR COALESCE(lm2.locked, 0) = 1 OR COALESCE(dl1.locked, 0) = 1 OR COALESCE(dl2.locked, 0) = 1)""";

        if (rawFilter instanceof Map) {
            Map<?, ?> filter = (Map<?, ?>) rawFilter;
            String asAt = (String) filter.get("asAt");
            if (asAt != null && !asAt.trim().isEmpty()) {
                subQuery += " AND l.disbursed_date < DATE_ADD(:asAt, INTERVAL 1 DAY)";
                params.put("asAt", asAt.trim());
            }
        }

        return """
                SELECT
                    t.account_no,
                    t.series,
                    t.legacy_account_no,
                    t.client_name,
                    t.client_nic,
                    t.client_mobile,
                    t.client_address,
                    t.loan_amount,
                    t.rental,
                    t.total_due,
                    t.exposure,
                    t.dpd,
                    t.lock_status,
                    t.recovery_officer
                FROM (""" + subQuery + ") t WHERE TRUE";
    }

    private String buildLockNoArrearsReportQuery(Object rawFilter, Map<String, Object> params) {
        addLatestPortfolioParams(params);
        String subQuery = """
                SELECT
                    l.account_no,
                    l.account_series AS `series`,
                    l.legacy_account_no,
                    c.full_name AS `client_name`,
                    c.id_no AS `client_nic`,
                    c.mobile AS `client_mobile`,
                    c.address AS `client_address`,
                    l.loan_amount,
                    l.rental,
                    p.total_due AS `total_due`,
                    p.exposure AS `exposure`,
                    p.dpd AS `dpd`,
                    'Locked' AS `lock_status`,
                    p.recovery_officer AS `recovery_officer`
                FROM cbs.portfolio p
                INNER JOIN cbs.loan l
                    ON (l.account_no = p.account_no OR l.legacy_account_no = p.account_no)
                    AND l.account_series = p.series
                LEFT JOIN cbs.client c ON l.client = c.client_code
                LEFT JOIN loan.mobileloan lm1 ON lm1.finance_no = l.account_no
                LEFT JOIN loan.mobileloan lm2 ON lm2.finance_no = l.legacy_account_no
                LEFT JOIN loan.device_loan dl1 ON dl1.finance_no = l.account_no
                LEFT JOIN loan.device_loan dl2 ON dl2.finance_no = l.legacy_account_no
                WHERE p.portfolio_date = :latestPortfolioDate
                  AND (p.total_due < 200 OR p.total_due IS NULL)
                  AND (COALESCE(lm1.locked, 0) = 1 OR COALESCE(lm2.locked, 0) = 1 OR COALESCE(dl1.locked, 0) = 1 OR COALESCE(dl2.locked, 0) = 1)""";

        if (rawFilter instanceof Map) {
            Map<?, ?> filter = (Map<?, ?>) rawFilter;
            String asAt = (String) filter.get("asAt");
            if (asAt != null && !asAt.trim().isEmpty()) {
                subQuery += " AND l.disbursed_date < DATE_ADD(:asAt, INTERVAL 1 DAY)";
                params.put("asAt", asAt.trim());
            }
        }

        return """
                SELECT
                    t.account_no,
                    t.series,
                    t.legacy_account_no,
                    t.client_name,
                    t.client_nic,
                    t.client_mobile,
                    t.client_address,
                    t.loan_amount,
                    t.rental,
                    t.total_due,
                    t.exposure,
                    t.dpd,
                    t.lock_status,
                    t.recovery_officer
                FROM (""" + subQuery + ") t WHERE TRUE";
    }

    public DataTableResponse fetchOneRentalReport(DataTableRequest request) {
        Map<String, Object> params = new HashMap<>();
        String sql = buildOneRentalReportQuery(request.getData(), params);
        return executePagedReport(request, sql, params);
    }

    public List<Map<String, Object>> getOneRentalReportData(String asAt, String arrearsFilter) {
        Map<String, Object> filterMap = new HashMap<>();
        filterMap.put("asAt", asAt);
        filterMap.put("arrearsFilter", arrearsFilter);
        Map<String, Object> params = new HashMap<>();
        String sql = buildOneRentalReportQuery(filterMap, params);
        return executeDownloadReport(sql, params);
    }

    public DataTableResponse fetchSettledReport(DataTableRequest request) {
        Map<String, Object> params = new HashMap<>();
        String sql = buildSettledReportQuery(request.getData(), params);
        return executePagedReport(request, sql, params);
    }

    public List<Map<String, Object>> getSettledReportData(String fromDate, String toDate) {
        Map<String, Object> filterMap = new HashMap<>();
        filterMap.put("fromDate", fromDate);
        filterMap.put("toDate", toDate);
        Map<String, Object> params = new HashMap<>();
        String sql = buildSettledReportQuery(filterMap, params);
        return executeDownloadReport(sql, params);
    }

    public DataTableResponse fetchMaturedLowBalanceReport(DataTableRequest request) {
        Map<String, Object> params = new HashMap<>();
        String sql = buildMaturedLowBalanceReportQuery(request.getData(), params);
        return executePagedReport(request, sql, params);
    }

    public List<Map<String, Object>> getMaturedLowBalanceReportData(String asAt, Double lowAmount) {
        Map<String, Object> filterMap = new HashMap<>();
        filterMap.put("asAt", asAt);
        if (lowAmount != null) {
            filterMap.put("lowAmount", lowAmount);
        }
        Map<String, Object> params = new HashMap<>();
        String sql = buildMaturedLowBalanceReportQuery(filterMap, params);
        return executeDownloadReport(sql, params);
    }

    private String buildOneRentalReportQuery(Object rawFilter, Map<String, Object> params) {
        addLatestPortfolioParams(params);
        String subQuery = """
                SELECT
                    l.account_no,
                    l.account_series AS `series`,
                    l.legacy_account_no,
                    c.full_name AS `client_name`,
                    c.id_no AS `client_nic`,
                    c.mobile AS `client_mobile`,
                    c.address AS `client_address`,
                    l.loan_amount,
                    l.rental,
                    p1.total_due AS `total_due`,
                    p1.exposure AS `exposure`,
                    p1.dpd AS `dpd`,
                    CASE
                        WHEN COALESCE(lm1.locked, lm2.locked) = 1 THEN 'Locked'
                        ELSE 'Unlocked'
                    END AS `lock_status`,
                    p1.recovery_officer AS `recovery_officer`
                FROM cbs.loan l
                JOIN cbs.portfolio p1
                    ON p1.account_no = l.account_no
                    AND p1.series = l.account_series
                    AND p1.portfolio_date = :latestPortfolioDate
                LEFT JOIN cbs.client c ON l.client = c.client_code
                LEFT JOIN loan.mobileloan lm1 ON lm1.finance_no = l.account_no
                LEFT JOIN loan.mobileloan lm2 ON lm2.finance_no = l.legacy_account_no
                WHERE 1=1
                  AND p1.exposure > 0
                  AND p1.exposure <= l.rental""";

        if (rawFilter instanceof Map) {
            Map<?, ?> filter = (Map<?, ?>) rawFilter;
            String asAt = (String) filter.get("asAt");
            if (asAt != null && !asAt.trim().isEmpty()) {
                subQuery += " AND l.disbursed_date < DATE_ADD(:asAt, INTERVAL 1 DAY)";
                params.put("asAt", asAt.trim());
            }

            String arrearsFilter = (String) filter.get("arrearsFilter");
            if (arrearsFilter != null && !arrearsFilter.trim().isEmpty()) {
                if ("WITH_ARREARS".equalsIgnoreCase(arrearsFilter.trim())) {
                    subQuery += " AND p1.dpd > 0";
                } else if ("WITHOUT_ARREARS".equalsIgnoreCase(arrearsFilter.trim())) {
                    subQuery += " AND (p1.dpd <= 0 OR p1.dpd IS NULL)";
                }
            }
        }

        return """
                SELECT
                    t.account_no,
                    t.series,
                    t.legacy_account_no,
                    t.client_name,
                    t.client_nic,
                    t.client_mobile,
                    t.client_address,
                    t.loan_amount,
                    t.rental,
                    t.total_due,
                    t.exposure,
                    t.dpd,
                    t.lock_status,
                    t.recovery_officer
                FROM (""" + subQuery + ") t WHERE TRUE";
    }

    private String buildSettledReportQuery(Object rawFilter, Map<String, Object> params) {
        String subQuery = """
                SELECT
                    l.account_no,
                    l.account_series AS `series`,
                    l.legacy_account_no,
                    c.full_name AS `client_name`,
                    c.id_no AS `client_nic`,
                    c.mobile AS `client_mobile`,
                    c.address AS `client_address`,
                    l.loan_amount,
                    l.rental,
                    DATE_FORMAT(l.disbursed_date, '%Y-%m-%d') AS `disbursed_date`,
                    DATE_FORMAT(l.closed_date, '%Y-%m-%d') AS `closed_date`,
                    CASE l.account_status
                        WHEN 'P' THEN 'Paid Off (early sett)'
                        WHEN 'F' THEN 'Fully Paid (settled)'
                        ELSE l.account_status
                    END AS `account_status`
                FROM cbs.loan l
                LEFT JOIN cbs.client c ON l.client = c.client_code
                WHERE l.account_status IN ('P', 'F')""";

        if (rawFilter instanceof Map) {
            Map<?, ?> filter = (Map<?, ?>) rawFilter;
            String fromDate = (String) filter.get("fromDate");
            String toDate = (String) filter.get("toDate");
            if (fromDate != null && !fromDate.trim().isEmpty()) {
                subQuery += " AND l.closed_date >= :fromDate";
                params.put("fromDate", fromDate.trim());
            }
            if (toDate != null && !toDate.trim().isEmpty()) {
                subQuery += " AND l.closed_date < DATE_ADD(:toDate, INTERVAL 1 DAY)";
                params.put("toDate", toDate.trim());
            }
        }

        return """
                SELECT
                    t.account_no,
                    t.series,
                    t.legacy_account_no,
                    t.client_name,
                    t.client_nic,
                    t.client_mobile,
                    t.client_address,
                    t.loan_amount,
                    t.rental,
                    t.disbursed_date,
                    t.closed_date,
                    t.account_status
                FROM (""" + subQuery + ") t WHERE TRUE";
    }

    private String buildMaturedLowBalanceReportQuery(Object rawFilter, Map<String, Object> params) {
        addLatestPortfolioParams(params);
        double lowAmount = 1000.0;
        if (rawFilter instanceof Map) {
            Map<?, ?> filter = (Map<?, ?>) rawFilter;
            Object lowAmtObj = filter.get("lowAmount");
            if (lowAmtObj != null) {
                try {
                    lowAmount = Double.parseDouble(lowAmtObj.toString().trim());
                } catch (NumberFormatException ignored) {
                }
            }
        }
        params.put("lowAmountThreshold", lowAmount);

        String subQuery = """
                SELECT
                    l.account_no,
                    l.account_series AS `series`,
                    l.legacy_account_no,
                    c.full_name AS `client_name`,
                    c.id_no AS `client_nic`,
                    c.mobile AS `client_mobile`,
                    DATE_FORMAT(l.maturity_date, '%Y-%m-%d') AS `mature_date`,
                    l.loan_amount,
                    l.rental,
                    p1.total_due AS `total_due`,
                    p1.exposure AS `exposure`,
                    p1.dpd AS `dpd`,
                    CASE
                        WHEN COALESCE(lm1.locked, lm2.locked) = 1 THEN 'Locked'
                        ELSE 'Unlocked'
                    END AS `lock_status`,
                    p1.recovery_officer AS `recovery_officer`,
                    COALESCE(lmc1.charge_amount, lmc2.charge_amount) AS `charge_amount`
                FROM cbs.loan l
                JOIN cbs.portfolio p1
                    ON p1.account_no = l.account_no
                    AND p1.series = l.account_series
                    AND p1.portfolio_date = :latestPortfolioDate
                LEFT JOIN cbs.client c ON l.client = c.client_code
                LEFT JOIN loan.mobileloan lm1 ON lm1.finance_no = l.account_no
                LEFT JOIN loan.mobileloan lm2 ON lm2.finance_no = l.legacy_account_no
                LEFT JOIN loan.mobileloan_charges lmc1 ON lmc1.id = lm1.id
                LEFT JOIN loan.mobileloan_charges lmc2 ON lmc2.id = lm2.id
                WHERE 1=1
                  AND l.maturity_date < CURDATE()
                  AND p1.exposure > 0
                  AND p1.exposure < :lowAmountThreshold""";

        if (rawFilter instanceof Map) {
            Map<?, ?> filter = (Map<?, ?>) rawFilter;
            String asAt = (String) filter.get("asAt");
            if (asAt != null && !asAt.trim().isEmpty()) {
                subQuery += " AND l.disbursed_date < DATE_ADD(:asAt, INTERVAL 1 DAY)";
                params.put("asAt", asAt.trim());
            }
        }

        return """
                SELECT
                    t.account_no,
                    t.series,
                    t.legacy_account_no,
                    t.client_name,
                    t.client_nic,
                    t.client_mobile,
                    t.mature_date,
                    t.loan_amount,
                    t.rental,
                    t.total_due,
                    t.exposure,
                    t.dpd,
                    t.lock_status,
                    t.recovery_officer,
                    t.charge_amount
                FROM (""" + subQuery + ") t WHERE TRUE";
    }

    public Map<String, Object> fetchDpdBucketReport(Map<String, Object> filters) {
        Map<String, Object> params = new HashMap<>();
        addLatestPortfolioParams(params);

        String dimension = filters != null && filters.get("dimension") != null
                ? filters.get("dimension").toString().toLowerCase()
                : "dealer";

        String categoryExpr;
        String dimensionJoin = "";

        if ("security".equals(dimension)) {
            categoryExpr = """
                        CASE
                            WHEN pr.product_code IN ('LF', 'laptop') THEN 'ABSOLUTE'
                            WHEN pr.product_code = 'MF' AND COALESCE(lm1.knox_compatibility, lm2.knox_compatibility) = 'yes' THEN 'KNOX'
                            WHEN pr.product_code = 'MF' AND (COALESCE(lm1.knox_compatibility, lm2.knox_compatibility) = 'no' OR COALESCE(lm1.knox_compatibility, lm2.knox_compatibility) IS NULL) THEN 'DATACULTR'
                            ELSE 'OTHER'
                        END
                    """;
            dimensionJoin = """
                        LEFT JOIN loan.mobileloan lm1 ON lm1.finance_no = l.account_no
                        LEFT JOIN loan.mobileloan lm2 ON lm2.finance_no = l.legacy_account_no
                    """;
        } else if ("model".equals(dimension)) {
            categoryExpr = "COALESCE(lmm.name, 'Unknown Model')";
            dimensionJoin = """
                        LEFT JOIN loan.mobileloan lm1 ON lm1.finance_no = l.account_no
                        LEFT JOIN loan.mobileloan lm2 ON lm2.finance_no = l.legacy_account_no
                        LEFT JOIN loan.device_loan dl2_1 ON dl2_1.finance_no = l.account_no
                        LEFT JOIN loan.device_loan dl2_2 ON dl2_2.finance_no = l.legacy_account_no
                        LEFT JOIN loan.mobileloan_model lmm ON lmm.id = COALESCE(lm1.model, lm2.model, dl2_1.model, dl2_2.model)
                    """;
        } else {
            categoryExpr = "COALESCE(v.name, 'Unknown Dealer')";
            dimensionJoin = "LEFT JOIN cbs.vendor v ON l.vendor = v.code";
        }

        StringBuilder whereClause = new StringBuilder(" WHERE 1=1 ");

        if (filters != null) {
            String branch = (String) filters.get("branch");
            if (branch != null && !branch.trim().isEmpty()) {
                whereClause.append(" AND (l.branch = :branch OR br.branch_name = :branch)");
                params.put("branch", branch.trim());
            }

            Object productsObj = filters.get("products");
            if (productsObj instanceof List && !((List<?>) productsObj).isEmpty()) {
                whereClause.append(
                        " AND (l.product IN (:products) OR pr.product_code IN (:products) OR pr.product_name IN (:products))");
                params.put("products", productsObj);
            } else if (productsObj instanceof String && !((String) productsObj).trim().isEmpty()) {
                whereClause.append(
                        " AND (l.product = :product OR pr.product_code = :product OR pr.product_name = :product)");
                params.put("product", ((String) productsObj).trim());
            }

            String asAt = (String) filters.get("asAt");
            if (asAt != null && !asAt.trim().isEmpty()) {
                whereClause.append(" AND l.disbursed_date < DATE_ADD(:asAt, INTERVAL 1 DAY)");
                params.put("asAt", asAt.trim());
            }

            String dealer = (String) filters.get("dealer");
            if (dealer != null && !dealer.trim().isEmpty() && !"ALL".equalsIgnoreCase(dealer.trim())) {
                whereClause.append(" AND l.vendor = :dealer ");
                params.put("dealer", dealer.trim());
            }

            Object modelObj = filters.get("model");
            if ("model".equals(dimension) && modelObj != null && !modelObj.toString().trim().isEmpty()
                    && !"ALL".equalsIgnoreCase(modelObj.toString().trim())) {
                whereClause.append(" AND COALESCE(lm1.model, lm2.model, dl2_1.model, dl2_2.model) = :model ");
                params.put("model", modelObj.toString().trim());
            }
        }

        String sql = String.format(
                """
                            SELECT
                                %s AS category_name,
                                COUNT(CASE WHEN COALESCE(p1.dpd, 0) = 0 THEN 1 END) AS dpd0_count,
                                SUM(CASE WHEN COALESCE(p1.dpd, 0) = 0 THEN COALESCE(p1.exposure, l.loan_amount, 0) ELSE 0 END) AS dpd0_val,
                                COUNT(CASE WHEN COALESCE(p1.dpd, 0) BETWEEN 1 AND 30 THEN 1 END) AS dpd1_30_count,
                                SUM(CASE WHEN COALESCE(p1.dpd, 0) BETWEEN 1 AND 30 THEN COALESCE(p1.exposure, l.loan_amount, 0) ELSE 0 END) AS dpd1_30_val,
                                COUNT(CASE WHEN COALESCE(p1.dpd, 0) BETWEEN 31 AND 60 THEN 1 END) AS dpd31_60_count,
                                SUM(CASE WHEN COALESCE(p1.dpd, 0) BETWEEN 31 AND 60 THEN COALESCE(p1.exposure, l.loan_amount, 0) ELSE 0 END) AS dpd31_60_val,
                                COUNT(CASE WHEN COALESCE(p1.dpd, 0) BETWEEN 61 AND 90 THEN 1 END) AS dpd61_90_count,
                                SUM(CASE WHEN COALESCE(p1.dpd, 0) BETWEEN 61 AND 90 THEN COALESCE(p1.exposure, l.loan_amount, 0) ELSE 0 END) AS dpd61_90_val,
                                COUNT(CASE WHEN COALESCE(p1.dpd, 0) > 90 OR p1.loan_status = 'N' THEN 1 END) AS dpdAbove90_count,
                                SUM(CASE WHEN COALESCE(p1.dpd, 0) > 90 OR p1.loan_status = 'N' THEN COALESCE(p1.exposure, l.loan_amount, 0) ELSE 0 END) AS dpdAbove90_val,
                                COUNT(*) AS total_count,
                                SUM(COALESCE(p1.exposure, l.loan_amount, 0)) AS total_val
                            FROM cbs.loan l
                            JOIN cbs.portfolio p1
                                ON p1.account_no = l.account_no
                                AND p1.series = l.account_series
                                AND p1.portfolio_date = :latestPortfolioDate
                            LEFT JOIN cbs.branch br ON CAST(l.branch AS UNSIGNED) = br.branch_code
                            LEFT JOIN cbs.product pr ON CAST(l.product AS UNSIGNED) = pr.code_val
                            %s
                            %s
                            GROUP BY category_name
                            ORDER BY total_val DESC
                        """,
                categoryExpr, dimensionJoin, whereClause.toString());

        List<Map<String, Object>> rawRows = jdbc.queryForList(sql, params);

        double grandTotalVal = 0.0;
        for (Map<String, Object> row : rawRows) {
            Number totalVal = (Number) row.get("total_val");
            if (totalVal != null) {
                grandTotalVal += totalVal.doubleValue();
            }
        }

        List<Map<String, Object>> formattedRows = new ArrayList<>();
        long gDpd0Count = 0, gDpd1_30Count = 0, gDpd31_60Count = 0, gDpd61_90Count = 0, gDpdAbove90Count = 0,
                gTotalCount = 0;
        double gDpd0Val = 0.0, gDpd1_30Val = 0.0, gDpd31_60Val = 0.0, gDpd61_90Val = 0.0, gDpdAbove90Val = 0.0;

        for (Map<String, Object> raw : rawRows) {
            String category = raw.get("category_name") != null ? raw.get("category_name").toString() : "Unknown";
            long dpd0Count = raw.get("dpd0_count") != null ? ((Number) raw.get("dpd0_count")).longValue() : 0L;
            double dpd0Val = raw.get("dpd0_val") != null ? ((Number) raw.get("dpd0_val")).doubleValue() : 0.0;

            long dpd1_30Count = raw.get("dpd1_30_count") != null ? ((Number) raw.get("dpd1_30_count")).longValue() : 0L;
            double dpd1_30Val = raw.get("dpd1_30_val") != null ? ((Number) raw.get("dpd1_30_val")).doubleValue() : 0.0;

            long dpd31_60Count = raw.get("dpd31_60_count") != null ? ((Number) raw.get("dpd31_60_count")).longValue()
                    : 0L;
            double dpd31_60Val = raw.get("dpd31_60_val") != null ? ((Number) raw.get("dpd31_60_val")).doubleValue()
                    : 0.0;

            long dpd61_90Count = raw.get("dpd61_90_count") != null ? ((Number) raw.get("dpd61_90_count")).longValue()
                    : 0L;
            double dpd61_90Val = raw.get("dpd61_90_val") != null ? ((Number) raw.get("dpd61_90_val")).doubleValue()
                    : 0.0;

            long dpdAbove90Count = raw.get("dpdAbove90_count") != null
                    ? ((Number) raw.get("dpdAbove90_count")).longValue()
                    : 0L;
            double dpdAbove90Val = raw.get("dpdAbove90_val") != null
                    ? ((Number) raw.get("dpdAbove90_val")).doubleValue()
                    : 0.0;

            long totalCount = raw.get("total_count") != null ? ((Number) raw.get("total_count")).longValue() : 0L;
            double totalVal = raw.get("total_val") != null ? ((Number) raw.get("total_val")).doubleValue() : 0.0;

            gDpd0Count += dpd0Count;
            gDpd0Val += dpd0Val;
            gDpd1_30Count += dpd1_30Count;
            gDpd1_30Val += dpd1_30Val;
            gDpd31_60Count += dpd31_60Count;
            gDpd31_60Val += dpd31_60Val;
            gDpd61_90Count += dpd61_90Count;
            gDpd61_90Val += dpd61_90Val;
            gDpdAbove90Count += dpdAbove90Count;
            gDpdAbove90Val += dpdAbove90Val;
            gTotalCount += totalCount;

            Map<String, Object> item = new HashMap<>();
            item.put("category", category);
            item.put("dpd0Count", dpd0Count);
            item.put("dpd0ValMn", round(dpd0Val / 1_000_000.0, 2));
            item.put("dpd0Pct", grandTotalVal > 0 ? round((dpd0Val / grandTotalVal) * 100.0, 2) : 0.0);

            item.put("dpd1_30Count", dpd1_30Count);
            item.put("dpd1_30ValMn", round(dpd1_30Val / 1_000_000.0, 2));
            item.put("dpd1_30Pct", grandTotalVal > 0 ? round((dpd1_30Val / grandTotalVal) * 100.0, 2) : 0.0);

            item.put("dpd31_60Count", dpd31_60Count);
            item.put("dpd31_60ValMn", round(dpd31_60Val / 1_000_000.0, 2));
            item.put("dpd31_60Pct", grandTotalVal > 0 ? round((dpd31_60Val / grandTotalVal) * 100.0, 2) : 0.0);

            item.put("dpd61_90Count", dpd61_90Count);
            item.put("dpd61_90ValMn", round(dpd61_90Val / 1_000_000.0, 2));
            item.put("dpd61_90Pct", grandTotalVal > 0 ? round((dpd61_90Val / grandTotalVal) * 100.0, 2) : 0.0);

            item.put("dpdAbove90Count", dpdAbove90Count);
            item.put("dpdAbove90ValMn", round(dpdAbove90Val / 1_000_000.0, 2));
            item.put("dpdAbove90Pct", grandTotalVal > 0 ? round((dpdAbove90Val / grandTotalVal) * 100.0, 2) : 0.0);

            item.put("totalCount", totalCount);
            item.put("totalValMn", round(totalVal / 1_000_000.0, 2));
            item.put("totalPct", grandTotalVal > 0 ? round((totalVal / grandTotalVal) * 100.0, 2) : 0.0);

            formattedRows.add(item);
        }

        Map<String, Object> totals = new HashMap<>();
        totals.put("category", "Total");
        totals.put("dpd0Count", gDpd0Count);
        totals.put("dpd0ValMn", round(gDpd0Val / 1_000_000.0, 2));
        totals.put("dpd0Pct", grandTotalVal > 0 ? round((gDpd0Val / grandTotalVal) * 100.0, 2) : 0.0);

        totals.put("dpd1_30Count", gDpd1_30Count);
        totals.put("dpd1_30ValMn", round(gDpd1_30Val / 1_000_000.0, 2));
        totals.put("dpd1_30Pct", grandTotalVal > 0 ? round((gDpd1_30Val / grandTotalVal) * 100.0, 2) : 0.0);

        totals.put("dpd31_60Count", gDpd31_60Count);
        totals.put("dpd31_60ValMn", round(gDpd31_60Val / 1_000_000.0, 2));
        totals.put("dpd31_60Pct", grandTotalVal > 0 ? round((gDpd31_60Val / grandTotalVal) * 100.0, 2) : 0.0);

        totals.put("dpd61_90Count", gDpd61_90Count);
        totals.put("dpd61_90ValMn", round(gDpd61_90Val / 1_000_000.0, 2));
        totals.put("dpd61_90Pct", grandTotalVal > 0 ? round((gDpd61_90Val / grandTotalVal) * 100.0, 2) : 0.0);

        totals.put("above90Count", gDpdAbove90Count);
        totals.put("above90ValMn", round(gDpdAbove90Val / 1_000_000.0, 2));
        totals.put("above90Pct", grandTotalVal > 0 ? round((gDpdAbove90Val / grandTotalVal) * 100.0, 2) : 0.0);

        totals.put("totalCount", gTotalCount);
        totals.put("totalValMn", round(grandTotalVal / 1_000_000.0, 2));
        totals.put("totalPct", grandTotalVal > 0 ? 100.0 : 0.0);

        Map<String, Object> result = new HashMap<>();
        result.put("rows", formattedRows);
        result.put("totals", totals);
        result.put("dimension", dimension);
        return result;
    }

    public Map<String, Object> fetchVendorPaymentsReport(Map<String, Object> filters, boolean isExceptionMode) {
        Map<String, Object> params = new HashMap<>();
        StringBuilder whereClause = new StringBuilder(" WHERE 1=1 ");

        if (isExceptionMode) {
            whereClause.append(" AND status IN ('Pending', 'Failed') ");
        }

        if (filters != null) {
            String status = (String) filters.get("status");
            if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status.trim())) {
                whereClause.append(" AND status = :status ");
                params.put("status", status.trim());
            }

            String search = (String) filters.get("search");
            if (search != null && !search.trim().isEmpty()) {
                whereClause.append(
                        " AND (vendor_name LIKE :search OR vendor_code LIKE :search OR account_id LIKE :search OR consumer_tran_id LIKE :search OR ref LIKE :search) ");
                params.put("search", "%" + search.trim() + "%");
            }

            String dateMode = (String) filters.get("dateMode");
            if ("today".equalsIgnoreCase(dateMode)) {
                whereClause.append(
                        " AND trx_date >= CURRENT_DATE() AND trx_date < DATE_ADD(CURRENT_DATE(), INTERVAL 1 DAY) ");
            } else if ("monthly".equalsIgnoreCase(dateMode)) {
                Object yearObj = filters.get("year");
                Object monthObj = filters.get("month");
                if (yearObj != null && monthObj != null && !yearObj.toString().isEmpty()
                        && !monthObj.toString().isEmpty()) {
                    String startStr = String.format("%s-%02d-01", yearObj.toString().trim(),
                            Integer.parseInt(monthObj.toString().trim()));
                    whereClause.append(
                            " AND trx_date >= STR_TO_DATE(:monthStart, '%Y-%m-%d') AND trx_date < DATE_ADD(STR_TO_DATE(:monthStart, '%Y-%m-%d'), INTERVAL 1 MONTH) ");
                    params.put("monthStart", startStr);
                }
            } else if ("accumulating".equalsIgnoreCase(dateMode)) {
                String fromDate = (String) filters.get("fromDate");
                String toDate = (String) filters.get("toDate");
                if (fromDate != null && !fromDate.trim().isEmpty()) {
                    whereClause.append(" AND trx_date >= :fromDate ");
                    params.put("fromDate", fromDate.trim());
                }
                if (toDate != null && !toDate.trim().isEmpty()) {
                    whereClause.append(" AND trx_date < DATE_ADD(:toDate, INTERVAL 1 DAY) ");
                    params.put("toDate", toDate.trim());
                }
            } else if ("last3years".equalsIgnoreCase(dateMode)) {
                Object selectedYearObj = filters.get("year");
                if (selectedYearObj != null && !selectedYearObj.toString().trim().isEmpty()
                        && !"ALL".equalsIgnoreCase(selectedYearObj.toString().trim())) {
                    whereClause.append(" AND YEAR(trx_date) = :selectedYear ");
                    params.put("selectedYear", Integer.parseInt(selectedYearObj.toString().trim()));
                } else {
                    whereClause.append(" AND trx_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 3 YEAR) ");
                }
            }
        }

        String sql = String.format("""
                    SELECT
                        COALESCE(ceft_id, '') AS ceft_id,
                        COALESCE(consumer_tran_id, '') AS consumer_tran_id,
                        COALESCE(account_id, '') AS account_id,
                        COALESCE(vendor_code, '') AS vendor_code,
                        COALESCE(vendor_name, '') AS vendor_name,
                        COALESCE(destination_account, '') AS destination_account,
                        COALESCE(destination_account_name, '') AS destination_account_name,
                        COALESCE(bank_code, '') AS bank_code,
                        COALESCE(bank_name, '') AS bank_name,
                        COALESCE(branch_code, '') AS branch_code,
                        COALESCE(amount, 0.0) AS amount,
                        DATE_FORMAT(trx_date, '%%Y-%%m-%%d %%H:%%i:%%s') AS trx_date,
                        COALESCE(ref, '') AS ref,
                        COALESCE(sp_number, '') AS sp_number,
                        COALESCE(status, '') AS status
                    FROM cbs.vendor_payments
                    %s
                    ORDER BY trx_date DESC
                """, whereClause.toString());

        List<Map<String, Object>> rows = jdbc.queryForList(sql, params);

        long totalCount = rows.size();
        double totalAmount = 0.0;
        long completedCount = 0;
        double completedAmount = 0.0;
        long pendingCount = 0;
        double pendingAmount = 0.0;
        long failedCount = 0;
        double failedAmount = 0.0;

        for (Map<String, Object> r : rows) {
            double amt = r.get("amount") != null ? ((Number) r.get("amount")).doubleValue() : 0.0;
            String st = r.get("status") != null ? r.get("status").toString() : "";
            totalAmount += amt;
            if ("Completed".equalsIgnoreCase(st)) {
                completedCount++;
                completedAmount += amt;
            } else if ("Pending".equalsIgnoreCase(st)) {
                pendingCount++;
                pendingAmount += amt;
            } else if ("Failed".equalsIgnoreCase(st)) {
                failedCount++;
                failedAmount += amt;
            }
        }

        Map<String, Object> totals = new HashMap<>();
        totals.put("totalCount", totalCount);
        totals.put("totalAmount", round(totalAmount, 2));
        totals.put("completedCount", completedCount);
        totals.put("completedAmount", round(completedAmount, 2));
        totals.put("pendingCount", pendingCount);
        totals.put("pendingAmount", round(pendingAmount, 2));
        totals.put("failedCount", failedCount);
        totals.put("failedAmount", round(failedAmount, 2));

        Map<String, Object> result = new HashMap<>();
        result.put("rows", rows);
        result.put("totals", totals);
        return result;
    }

    public List<Map<String, Object>> fetchDistinctVendors() {
        try {
            return jdbc.queryForList("""
                        SELECT DISTINCT
                            COALESCE(vendor_code, '') AS vendor_code,
                            COALESCE(vendor_name, 'Unknown') AS vendor_name
                        FROM cbs.vendor_payments
                        WHERE vendor_code IS NOT NULL AND vendor_code <> ''
                        ORDER BY vendor_name ASC
                    """, Map.of());
        } catch (Exception e) {
            log.error("Failed to fetch distinct vendors", e);
            return Collections.emptyList();
        }
    }

    public List<Map<String, Object>> fetchDistinctDealers() {
        try {
            return jdbc.queryForList("""
                        SELECT
                            code AS code,
                            name AS name
                        FROM cbs.vendor
                        WHERE code IS NOT NULL AND code <> ''
                        ORDER BY name ASC
                    """, Map.of());
        } catch (Exception e) {
            log.error("Failed to fetch distinct dealers", e);
            return Collections.emptyList();
        }
    }

    public List<Map<String, Object>> fetchDistinctModels() {
        try {
            return jdbc.queryForList("""
                        SELECT
                            id AS id,
                            name AS name
                        FROM loan.mobileloan_model
                        WHERE id IS NOT NULL
                        ORDER BY name ASC
                    """, Map.of());
        } catch (Exception e) {
            log.error("Failed to fetch distinct models", e);
            return Collections.emptyList();
        }
    }

    public DataTableResponse fetchMultiplePaymentsReport(DataTableRequest request) {
        Map<String, Object> params = new HashMap<>();
        String sql = buildMultiplePaymentsReportQuery(request.getData(), params);
        return executePagedReport(request, sql, params);
    }

    public List<Map<String, Object>> getMultiplePaymentsReportData(String fromDate, String toDate) {
        Map<String, Object> filterMap = new HashMap<>();
        filterMap.put("fromDate", fromDate);
        filterMap.put("toDate", toDate);
        Map<String, Object> params = new HashMap<>();
        String sql = buildMultiplePaymentsReportQuery(filterMap, params);
        return executeDownloadReport(sql, params);
    }

    private String buildMultiplePaymentsReportQuery(Object rawFilter, Map<String, Object> params) {
        String subQuery = """
                SELECT
                    t.tran_id,
                    t.account_no,
                    COALESCE(l1.legacy_account_no, l2.legacy_account_no) AS legacy_account_no,
                    t.amount,
                    DATE_FORMAT(t.date, '%Y-%m-%d') AS `date`,
                    t.user,
                    t.narration,
                    t.channel,
                    CASE
                        WHEN d.same_amount_count > 1 THEN 'Yes'
                        ELSE 'No'
                    END AS same_amount_duplicate
                FROM cbs.transaction t
                INNER JOIN (
                    SELECT
                        account_no,
                        DATE(date) tx_date
                    FROM cbs.transaction
                    GROUP BY account_no, DATE(date)
                    HAVING COUNT(*) > 1
                ) dup
                    ON dup.account_no = t.account_no
                   AND dup.tx_date = DATE(t.date)
                LEFT JOIN (
                    SELECT
                        account_no,
                        DATE(date) tx_date,
                        amount,
                        COUNT(*) same_amount_count
                    FROM cbs.transaction
                    GROUP BY account_no, DATE(date), amount
                ) d
                    ON d.account_no = t.account_no
                   AND d.tx_date = DATE(t.date)
                   AND d.amount = t.amount
                LEFT JOIN cbs.loan l1
                    ON l1.account_no = t.account_no
                LEFT JOIN cbs.loan l2
                    ON l2.legacy_account_no = t.account_no
                WHERE 1=1""";

        if (rawFilter instanceof Map) {
            Map<?, ?> filter = (Map<?, ?>) rawFilter;
            String fromDate = (String) filter.get("fromDate");
            String toDate = (String) filter.get("toDate");
            if (fromDate != null && !fromDate.trim().isEmpty()) {
                subQuery += " AND t.date >= :fromDate";
                params.put("fromDate", fromDate.trim());
            }
            if (toDate != null && !toDate.trim().isEmpty()) {
                subQuery += " AND t.date < DATE_ADD(:toDate, INTERVAL 1 DAY)";
                params.put("toDate", toDate.trim());
            }
        }

        return """
                SELECT
                    t.tran_id,
                    t.account_no,
                    t.legacy_account_no,
                    t.amount,
                    t.date,
                    t.user,
                    t.narration,
                    t.channel,
                    t.same_amount_duplicate
                FROM (""" + subQuery + ") t WHERE TRUE ORDER BY t.account_no ASC, t.date ASC";
    }

    private double round(double val, int places) {
        if (places < 0)
            return val;
        long factor = (long) Math.pow(10, places);
        val = val * factor;
        long tmp = Math.round(val);
        return (double) tmp / factor;
    }
}
