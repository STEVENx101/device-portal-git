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
        params.put("latestSyncTime", latest.get("latestSyncTime"));
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
                        SELECT portfolio_date, sync_time
                        FROM cbs.portfolio
                        WHERE portfolio_date IS NOT NULL
                          AND sync_time IS NOT NULL
                        ORDER BY portfolio_date DESC, sync_time DESC
                        LIMIT 1
                    """;

            Map<String, Object> loaded = jdbc.query(sql, Map.of(), resultSet -> {
                if (!resultSet.next()) {
                    return Collections.emptyMap();
                }

                Map<String, Object> row = new HashMap<>();
                row.put("latestPortfolioDate", resultSet.getObject("portfolio_date"));
                row.put("latestSyncTime", resultSet.getObject("sync_time"));
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
                    DATE_FORMAT(COALESCE(p1.portfolio_date, p2.portfolio_date), '%Y-%m-%d') AS portfolio_date,
                    l.account_no,
                    l.account_series AS `series`,
                    COALESCE(p1.loan_status, p2.loan_status) AS `portfolio_loan_status`,
                    COALESCE(p1.total_due, p2.total_due) AS total_due,
                    COALESCE(p1.exposure, p2.exposure) AS exposure,
                    COALESCE(p1.dpd, p2.dpd) AS dpd,
                    COALESCE(p1.performing_status, p2.performing_status) AS performing_status,
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
                LEFT JOIN cbs.portfolio p1
                    ON p1.account_no = l.account_no
                    AND p1.series = l.account_series
                    AND p1.portfolio_date = :latestPortfolioDate
                    AND p1.sync_time = :latestSyncTime
                LEFT JOIN cbs.portfolio p2
                    ON p2.account_no = l.legacy_account_no
                    AND p2.series = l.account_series
                    AND p2.portfolio_date = :latestPortfolioDate
                    AND p2.sync_time = :latestSyncTime
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

            // One Rental Left Report
            jdbc.getJdbcTemplate().execute("""
                        INSERT INTO device_portal.screen (name, path, icon, group_name)
                        SELECT 'One Rental Left', '/one-rental-report', 'fas fa-calculator', 'Reports'
                        WHERE NOT EXISTS (SELECT 1 FROM device_portal.screen WHERE path = '/one-rental-report')
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
                    COALESCE(p1.total_due, p2.total_due) AS `total_due`,
                    COALESCE(p1.exposure, p2.exposure) AS `exposure`,
                    COALESCE(p1.dpd, p2.dpd) AS `dpd`,
                    COALESCE(p1.loan_status, p2.loan_status) AS `loan_status`,
                    COALESCE(p1.performing_status, p2.performing_status) AS `performing_status`,
                    COALESCE(p1.npl_status, p2.npl_status) AS `npl_status`,
                    COALESCE(p1.recovery_officer, p2.recovery_officer) AS `recovery_officer`,
                    DATE_FORMAT(COALESCE(p1.last_payment_date, p2.last_payment_date), '%Y-%m-%d') AS `last_payment_date`,
                    COALESCE(p1.last_payment_amount, p2.last_payment_amount) AS `last_payment_amount`
                FROM cbs.loan l
                LEFT JOIN cbs.portfolio p1
                    ON p1.account_no = l.account_no
                    AND p1.series = l.account_series
                    AND p1.portfolio_date = :latestPortfolioDate
                    AND p1.sync_time = :latestSyncTime
                LEFT JOIN cbs.portfolio p2
                    ON p2.account_no = l.legacy_account_no
                    AND p2.series = l.account_series
                    AND p2.portfolio_date = :latestPortfolioDate
                    AND p2.sync_time = :latestSyncTime
                LEFT JOIN cbs.client c ON l.client = c.client_code
                WHERE 1=1 AND COALESCE(p1.dpd, p2.dpd) > 0""";

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
                    COALESCE(p1.total_due, p2.total_due) AS `total_due`,
                    COALESCE(p1.exposure, p2.exposure) AS `exposure`,
                    COALESCE(p1.dpd, p2.dpd) AS `dpd`,
                    COALESCE(p1.loan_status, p2.loan_status) AS `loan_status`,
                    COALESCE(p1.performing_status, p2.performing_status) AS `performing_status`,
                    COALESCE(p1.npl_status, p2.npl_status) AS `npl_status`,
                    COALESCE(p1.recovery_officer, p2.recovery_officer) AS `recovery_officer`,
                    DATE_FORMAT(COALESCE(p1.last_payment_date, p2.last_payment_date), '%Y-%m-%d') AS `last_payment_date`,
                    COALESCE(p1.last_payment_amount, p2.last_payment_amount) AS `last_payment_amount`
                FROM cbs.loan l
                LEFT JOIN cbs.portfolio p1
                    ON p1.account_no = l.account_no
                    AND p1.series = l.account_series
                    AND p1.portfolio_date = :latestPortfolioDate
                    AND p1.sync_time = :latestSyncTime
                LEFT JOIN cbs.portfolio p2
                    ON p2.account_no = l.legacy_account_no
                    AND p2.series = l.account_series
                    AND p2.portfolio_date = :latestPortfolioDate
                    AND p2.sync_time = :latestSyncTime
                LEFT JOIN cbs.client c ON l.client = c.client_code
                WHERE 1=1 AND COALESCE(p1.performing_status, p2.performing_status) = 'Non-Performing'""";

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
                    COALESCE(p1.total_due, p2.total_due) AS `total_due`,
                    COALESCE(p1.exposure, p2.exposure) AS `exposure`,
                    COALESCE(p1.dpd, p2.dpd) AS `dpd`,
                    COALESCE(p1.loan_status, p2.loan_status) AS `loan_status`,
                    COALESCE(p1.performing_status, p2.performing_status) AS `performing_status`,
                    COALESCE(p1.npl_status, p2.npl_status) AS `npl_status`,
                    COALESCE(p1.recovery_officer, p2.recovery_officer) AS `recovery_officer`,
                    DATE_FORMAT(COALESCE(p1.last_payment_date, p2.last_payment_date), '%Y-%m-%d') AS `last_payment_date`,
                    COALESCE(p1.last_payment_amount, p2.last_payment_amount) AS `last_payment_amount`
                FROM cbs.loan l
                LEFT JOIN cbs.portfolio p1
                    ON p1.account_no = l.account_no
                    AND p1.series = l.account_series
                    AND p1.portfolio_date = :latestPortfolioDate
                    AND p1.sync_time = :latestSyncTime
                LEFT JOIN cbs.portfolio p2
                    ON p2.account_no = l.legacy_account_no
                    AND p2.series = l.account_series
                    AND p2.portfolio_date = :latestPortfolioDate
                    AND p2.sync_time = :latestSyncTime
                LEFT JOIN cbs.client c ON l.client = c.client_code
                WHERE 1=1 AND COALESCE(p1.dpd, p2.dpd) BETWEEN 60 AND 90""";

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
                    COALESCE(p1.total_due, p2.total_due) AS `total_due`,
                    COALESCE(p1.exposure, p2.exposure) AS `exposure`,
                    COALESCE(p1.dpd, p2.dpd) AS `dpd`,
                    CASE
                        WHEN COALESCE(lm1.locked, lm2.locked) = 1 THEN 'Locked'
                        ELSE 'Unlocked'
                    END AS `lock_status`,
                    COALESCE(p1.recovery_officer, p2.recovery_officer) AS `recovery_officer`
                FROM cbs.loan l
                LEFT JOIN cbs.portfolio p1
                    ON p1.account_no = l.account_no
                    AND p1.series = l.account_series
                    AND p1.portfolio_date = :latestPortfolioDate
                    AND p1.sync_time = :latestSyncTime
                LEFT JOIN cbs.portfolio p2
                    ON p2.account_no = l.legacy_account_no
                    AND p2.series = l.account_series
                    AND p2.portfolio_date = :latestPortfolioDate
                    AND p2.sync_time = :latestSyncTime
                LEFT JOIN cbs.client c ON l.client = c.client_code
                LEFT JOIN loan.mobileloan lm1 ON lm1.finance_no = l.account_no
                LEFT JOIN loan.mobileloan lm2 ON lm2.finance_no = l.legacy_account_no
                WHERE 1=1 AND COALESCE(lm1.locked, lm2.locked) = 0 AND COALESCE(p1.dpd, p2.dpd) > 0""";

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
                    COALESCE(p1.total_due, p2.total_due) AS `total_due`,
                    COALESCE(p1.exposure, p2.exposure) AS `exposure`,
                    COALESCE(p1.dpd, p2.dpd) AS `dpd`,
                    CASE
                        WHEN COALESCE(lm1.locked, lm2.locked) = 1 THEN 'Locked'
                        ELSE 'Unlocked'
                    END AS `lock_status`,
                    COALESCE(p1.recovery_officer, p2.recovery_officer) AS `recovery_officer`
                FROM cbs.loan l
                LEFT JOIN cbs.portfolio p1
                    ON p1.account_no = l.account_no
                    AND p1.series = l.account_series
                    AND p1.portfolio_date = :latestPortfolioDate
                    AND p1.sync_time = :latestSyncTime
                LEFT JOIN cbs.portfolio p2
                    ON p2.account_no = l.legacy_account_no
                    AND p2.series = l.account_series
                    AND p2.portfolio_date = :latestPortfolioDate
                    AND p2.sync_time = :latestSyncTime
                LEFT JOIN cbs.client c ON l.client = c.client_code
                LEFT JOIN loan.mobileloan lm1 ON lm1.finance_no = l.account_no
                LEFT JOIN loan.mobileloan lm2 ON lm2.finance_no = l.legacy_account_no
                WHERE 1=1 AND COALESCE(lm1.locked, lm2.locked) = 1 AND (COALESCE(p1.dpd, p2.dpd) <= 0 OR COALESCE(p1.dpd, p2.dpd) IS NULL)""";

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

    public List<Map<String, Object>> getOneRentalReportData(String asAt) {
        Map<String, Object> filterMap = new HashMap<>();
        filterMap.put("asAt", asAt);
        Map<String, Object> params = new HashMap<>();
        String sql = buildOneRentalReportQuery(filterMap, params);
        return executeDownloadReport(sql, params);
    }

    public DataTableResponse fetchMaturedLowBalanceReport(DataTableRequest request) {
        Map<String, Object> params = new HashMap<>();
        String sql = buildMaturedLowBalanceReportQuery(request.getData(), params);
        return executePagedReport(request, sql, params);
    }

    public List<Map<String, Object>> getMaturedLowBalanceReportData(String asAt) {
        Map<String, Object> filterMap = new HashMap<>();
        filterMap.put("asAt", asAt);
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
                    COALESCE(p1.total_due, p2.total_due) AS `total_due`,
                    COALESCE(p1.exposure, p2.exposure) AS `exposure`,
                    COALESCE(p1.dpd, p2.dpd) AS `dpd`,
                    CASE
                        WHEN COALESCE(lm1.locked, lm2.locked) = 1 THEN 'Locked'
                        ELSE 'Unlocked'
                    END AS `lock_status`,
                    COALESCE(p1.recovery_officer, p2.recovery_officer) AS `recovery_officer`
                FROM cbs.loan l
                LEFT JOIN cbs.portfolio p1
                    ON p1.account_no = l.account_no
                    AND p1.series = l.account_series
                    AND p1.portfolio_date = :latestPortfolioDate
                    AND p1.sync_time = :latestSyncTime
                LEFT JOIN cbs.portfolio p2
                    ON p2.account_no = l.legacy_account_no
                    AND p2.series = l.account_series
                    AND p2.portfolio_date = :latestPortfolioDate
                    AND p2.sync_time = :latestSyncTime
                LEFT JOIN cbs.client c ON l.client = c.client_code
                LEFT JOIN loan.mobileloan lm1 ON lm1.finance_no = l.account_no
                LEFT JOIN loan.mobileloan lm2 ON lm2.finance_no = l.legacy_account_no
                WHERE 1=1
                  AND COALESCE(p1.exposure, p2.exposure) > 0
                  AND COALESCE(p1.exposure, p2.exposure) <= l.rental""";

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

    private String buildMaturedLowBalanceReportQuery(Object rawFilter, Map<String, Object> params) {
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
                    COALESCE(p1.total_due, p2.total_due) AS `total_due`,
                    COALESCE(p1.exposure, p2.exposure) AS `exposure`,
                    COALESCE(p1.dpd, p2.dpd) AS `dpd`,
                    CASE
                        WHEN COALESCE(lm1.locked, lm2.locked) = 1 THEN 'Locked'
                        ELSE 'Unlocked'
                    END AS `lock_status`,
                    COALESCE(p1.recovery_officer, p2.recovery_officer) AS `recovery_officer`
                FROM cbs.loan l
                LEFT JOIN cbs.portfolio p1
                    ON p1.account_no = l.account_no
                    AND p1.series = l.account_series
                    AND p1.portfolio_date = :latestPortfolioDate
                    AND p1.sync_time = :latestSyncTime
                LEFT JOIN cbs.portfolio p2
                    ON p2.account_no = l.legacy_account_no
                    AND p2.series = l.account_series
                    AND p2.portfolio_date = :latestPortfolioDate
                    AND p2.sync_time = :latestSyncTime
                LEFT JOIN cbs.client c ON l.client = c.client_code
                LEFT JOIN loan.mobileloan lm1 ON lm1.finance_no = l.account_no
                LEFT JOIN loan.mobileloan lm2 ON lm2.finance_no = l.legacy_account_no
                WHERE 1=1
                  AND l.maturity_date < CURDATE()
                  AND COALESCE(p1.exposure, p2.exposure) > 0
                  AND COALESCE(p1.exposure, p2.exposure) < 1000""";

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
}
