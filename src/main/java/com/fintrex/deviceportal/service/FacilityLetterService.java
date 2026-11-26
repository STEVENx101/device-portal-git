package com.fintrex.deviceportal.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fintrex.deviceportal.config.CmsDataSourceConfig;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.NumberFormat;
import java.time.LocalDate;
import java.util.*;

@Service
public class FacilityLetterService {

    private static final Logger log = LoggerFactory.getLogger(FacilityLetterService.class);
    private static final ObjectMapper MAPPER = new ObjectMapper();

    private static final List<LetterSeed> DEFAULT_LETTERS = List.of(
            new LetterSeed("Acceptance Receipt", "Acceptance Receipt", "ALL", 10),
            new LetterSeed("Acceptance Receipt Joint", "Acceptance Receipt Joint", "ALL", 10),
            new LetterSeed("Affidavit", "Affidavit", "ALL", 10),
            new LetterSeed("Cash Back Loan Terms & Conditions", "Cash Back Loan Terms and Conditions", "ALL", 10),
            new LetterSeed("Direct Insurance Consent Letter", "Direct Insurance Consent letter", "ALL", 10),
            new LetterSeed("Duplicate Key Letter", "Duplicate Key Letter", "ALL", 10),
            new LetterSeed("Invoice", "Invoice", "ALL", 10),
            new LetterSeed("Leasing Agreement 2025", "Leasing Agreement 2025", "ALL", 9),
            new LetterSeed("Lien Consent", "Lien Consent", "ALL", 10),
            new LetterSeed("Offer Letter", "Offer Letter", "ALL", 9),
            new LetterSeed("Offer Letter Joint", "Offer Letter Joint", "ALL", 9),
            new LetterSeed("Part Payment Request Letter", "Part Payment Request Letter", "ALL", 10),
            new LetterSeed("PG 2 Guarantors", "PG 2 Gurantors", "ALL", 10),
            new LetterSeed("PG 2 Guarantors Joint", "PG 2 Gurantors Joint", "ALL", 10),
            new LetterSeed("PG 2 Guarantors Joint 3G", "PG 2 Gurantors Joint 3G", "ALL", 10),
            new LetterSeed("Pledge Letter", "Pledge Letter", "ALL", 10),
            new LetterSeed("Refinance Consent Letter", "Refinance Consent Letter", "ALL", 10),
            new LetterSeed("RMV No Objection Letter", "RMV No Objection Letter", "ALL", 10),
            new LetterSeed("RMV No Objection Letter Joint", "RMV No Objection Letter Joint", "ALL", 10),
            new LetterSeed("RO TO RO Letter", "RO TO RO LETTER", "ALL", 10),
            new LetterSeed("Sale of Vehicle (RO to RO - One Asset)", "Sale of Vehicle for RO to RO-one asset", "ALL", 10),
            new LetterSeed("Schedule Last Page", "shedule last page", "ALL", 9),
            new LetterSeed("Stamp Duty Letter", "Stamp Duty Letter", "ALL", 10),
            new LetterSeed("Stamp Duty Letter Joint", "Stamp Duty Letter Joint", "ALL", 10),
            new LetterSeed("Vehicle Colour Change Letter", "Vehicle Colour Change Letter", "ALL", 10)
    );

    private record LetterSeed(String displayName, String fileName, String category, int fontSize) {}

    public record GeneratedLetter(byte[] bytes, String downloadFileName, String contentType) {}

    @Value("${letters.templates-dir:${catalina.base:.}/letters}")
    private String templatesDirConfig;

    @Value("${letters.cms-schema:cms}")
    private String cmsSchema;

    private final JdbcTemplate primaryJdbc;
    private final NamedParameterJdbcTemplate primaryNamedJdbc;
    private final CmsDataSourceConfig cmsDataSourceConfig;
    private final LetterDocumentEngine documentEngine;

    public FacilityLetterService(
            JdbcTemplate primaryJdbc,
            NamedParameterJdbcTemplate primaryNamedJdbc,
            CmsDataSourceConfig cmsDataSourceConfig,
            LetterDocumentEngine documentEngine) {
        this.primaryJdbc = primaryJdbc;
        this.primaryNamedJdbc = primaryNamedJdbc;
        this.cmsDataSourceConfig = cmsDataSourceConfig;
        this.documentEngine = documentEngine;
    }

    private String cms(String table) {
        String schema = (cmsSchema == null || cmsSchema.isBlank()) ? "cms" : cmsSchema.trim();
        return schema + "." + table;
    }

    @PostConstruct
    public void initialize() {
        ensureTemplatesDirectoryAndSyncDefaults();
        ensureDatabaseTablesAndSeed();
        ensureScreenRegistered();
        resolveCmsSchema();
    }

    private void resolveCmsSchema() {
        try {
            String configured = (cmsSchema == null || cmsSchema.isBlank()) ? "cms" : cmsSchema.trim();
            Integer exists = primaryJdbc.queryForObject(
                    "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = ? AND TABLE_NAME = 'lease'",
                    Integer.class, configured);
            if (exists != null && exists > 0) {
                this.cmsSchema = configured;
                return;
            }
            List<String> matches = primaryJdbc.queryForList(
                    "SELECT TABLE_SCHEMA FROM information_schema.TABLES WHERE TABLE_NAME = 'lease' LIMIT 1",
                    String.class);
            if (!matches.isEmpty()) {
                this.cmsSchema = matches.get(0);
                log.info("Auto-detected CMS schema on primary DB: '{}'", this.cmsSchema);
            }
        } catch (Exception e) {
            log.warn("Could not auto-detect CMS schema (using '{}'): {}", cmsSchema, e.getMessage());
        }
    }

    public Path getTemplatesDirectory() {
        return Paths.get(templatesDirConfig).toAbsolutePath().normalize();
    }

    private void ensureTemplatesDirectoryAndSyncDefaults() {
        try {
            Path dir = getTemplatesDirectory();
            Files.createDirectories(dir);

            PathMatchingResourcePatternResolver resolver = new PathMatchingResourcePatternResolver();
            Resource[] resources = resolver.getResources("classpath:letters/*.docx");
            int copied = 0;
            for (Resource res : resources) {
                String filename = res.getFilename();
                if (filename == null) continue;
                Path target = dir.resolve(filename);
                if (!Files.exists(target)) {
                    try (InputStream in = res.getInputStream()) {
                        Files.copy(in, target);
                        copied++;
                    }
                }
            }
            log.info("Facility letters directory ready at {} (copied {} bundled templates).", dir, copied);
        } catch (IOException e) {
            log.warn("Unable to initialize letters directory {}: {}", templatesDirConfig, e.getMessage());
        }
    }

    private void ensureDatabaseTablesAndSeed() {
        try {
            primaryJdbc.execute("""
                    CREATE TABLE IF NOT EXISTS device_portal.letter_template (
                        id INT AUTO_INCREMENT PRIMARY KEY,
                        letter_name VARCHAR(150) NOT NULL,
                        file_name VARCHAR(200) NOT NULL UNIQUE,
                        product_category VARCHAR(30) NOT NULL DEFAULT 'ALL',
                        font_size INT NOT NULL DEFAULT 10,
                        is_active TINYINT(1) NOT NULL DEFAULT 1,
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                    )
                    """);

            primaryJdbc.execute("""
                    CREATE TABLE IF NOT EXISTS device_portal.letter_print_log (
                        id BIGINT AUTO_INCREMENT PRIMARY KEY,
                        product_category VARCHAR(30),
                        product_id VARCHAR(60),
                        product_name VARCHAR(150),
                        letter_name VARCHAR(150) NOT NULL,
                        lease_id VARCHAR(60),
                        agreement_no VARCHAR(100),
                        customer_name VARCHAR(255),
                        letter_type VARCHAR(50) NOT NULL,
                        output_format VARCHAR(10) NOT NULL DEFAULT 'PDF',
                        generated_by VARCHAR(100),
                        generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                    )
                    """);

            for (LetterSeed seed : DEFAULT_LETTERS) {
                primaryJdbc.update("""
                        INSERT IGNORE INTO device_portal.letter_template
                            (letter_name, file_name, product_category, font_size, is_active)
                        VALUES (?, ?, ?, ?, 1)
                        """, seed.displayName(), seed.fileName(), seed.category(), seed.fontSize());
            }
        } catch (Exception e) {
            log.warn("Unable to initialize letter_template / letter_print_log tables: {}", e.getMessage());
        }
    }

    private void ensureScreenRegistered() {
        try {
            Integer count = primaryJdbc.queryForObject(
                    "SELECT COUNT(*) FROM device_portal.screen WHERE path = '/facility-letters'",
                    Integer.class);
            if (count != null && count == 0) {
                primaryJdbc.update(
                        "INSERT INTO device_portal.screen (name, path, icon, group_name) VALUES (?, ?, ?, ?)",
                        "Facility Letters", "/facility-letters", "fas fa-file-signature", "General");
                Integer screenId = primaryJdbc.queryForObject(
                        "SELECT id FROM device_portal.screen WHERE path = '/facility-letters' LIMIT 1",
                        Integer.class);
                if (screenId != null) {
                    primaryJdbc.update(
                            "INSERT IGNORE INTO device_portal.user_type_screen (user_type_id, screen_id) VALUES (1, ?)",
                            screenId);
                }
                log.info("Registered '/facility-letters' screen and granted access to Admin role.");
            }
        } catch (Exception e) {
            log.warn("Unable to auto-register '/facility-letters' screen: {}", e.getMessage());
        }
    }

    public List<Map<String, Object>> getLetterTemplates(String category) {
        if (category != null && !category.isBlank() && !"ALL".equalsIgnoreCase(category)) {
            return primaryJdbc.queryForList("""
                    SELECT id, letter_name, file_name, product_category, font_size
                    FROM device_portal.letter_template
                    WHERE is_active = 1 AND (product_category = 'ALL' OR product_category = ?)
                    ORDER BY letter_name ASC
                    """, category.trim());
        }
        return primaryJdbc.queryForList("""
                SELECT id, letter_name, file_name, product_category, font_size
                FROM device_portal.letter_template
                WHERE is_active = 1
                ORDER BY letter_name ASC
                """);
    }

    public List<Map<String, Object>> searchProducts(String category, String query) {
        String sql = "SELECT `id` AS `value`, `description` AS `text` FROM " + cms("`product`") + " " +
                "WHERE `status` LIKE '%active%' " +
                "  AND (:category = '' OR `sub_product` = :category) " +
                "  AND (:q = '' OR `description` LIKE :qLike) " +
                "ORDER BY `description` ASC LIMIT 100";
        String q = query == null ? "" : query.trim();
        MapSqlParameterSource params = new MapSqlParameterSource()
                .addValue("category", category == null ? "" : category.trim())
                .addValue("q", q)
                .addValue("qLike", "%" + q + "%");
        return primaryNamedJdbc.queryForList(sql, params);
    }

    public List<Map<String, Object>> searchLeases(String productId, String productName, String query) {
        String q = query == null ? "" : query.trim();
        MapSqlParameterSource params = new MapSqlParameterSource()
                .addValue("product", productId == null ? "" : productId.trim())
                .addValue("q", q)
                .addValue("qLike", "%" + q + "%");

        if ("Cash Backed Loan".equalsIgnoreCase(productName != null ? productName.trim() : "")) {
            String sql = "SELECT `id` AS `value`, `code` AS `text` FROM " + cms("`cashback`") + " " +
                    "WHERE `status` IN ('active', 'Credit Approval') " +
                    "  AND (:q = '' OR `code` LIKE :qLike) " +
                    "ORDER BY `code` DESC LIMIT 100";
            return primaryNamedJdbc.queryForList(sql, params);
        }

        String sql = "SELECT `id` AS `value`, `code` AS `text` FROM " + cms("`lease`") + " " +
                "WHERE `product` = :product " +
                "  AND `status` IN ('Pending Verification', 'active', 'Document Pending') " +
                "  AND (:q = '' OR `code` LIKE :qLike OR `finance_no` LIKE :qLike) " +
                "ORDER BY `code` DESC LIMIT 100";
        return primaryNamedJdbc.queryForList(sql, params);
    }

    public List<Map<String, Object>> getRecentPrintLogs() {
        return primaryJdbc.queryForList("""
                SELECT id, product_category, product_name, letter_name, agreement_no,
                       customer_name, letter_type, output_format, generated_by,
                       DATE_FORMAT(generated_at, '%Y-%m-%d %H:%i') AS generated_at
                FROM device_portal.letter_print_log
                ORDER BY id DESC
                LIMIT 30
                """);
    }

    public GeneratedLetter generateLetter(
            String leaseId,
            String productCategory,
            String productId,
            String productName,
            String letterFileName,
            String letterType,
            String outputFormat,
            String username) {

        Map<String, Object> templateMeta = primaryJdbc.queryForList("""
                SELECT letter_name, file_name, font_size
                FROM device_portal.letter_template
                WHERE file_name = ? AND is_active = 1
                LIMIT 1
                """, letterFileName).stream().findFirst()
                .orElseThrow(() -> new IllegalArgumentException("Letter template not found: " + letterFileName));

        String displayName = String.valueOf(templateMeta.get("letter_name"));
        String resolvedFileName = String.valueOf(templateMeta.get("file_name"));
        int fontSize = ((Number) templateMeta.get("font_size")).intValue();

        Path templatePath = getTemplatesDirectory().resolve(resolvedFileName + ".docx").normalize();
        if (!templatePath.startsWith(getTemplatesDirectory()) || !Files.exists(templatePath)) {
            throw new IllegalArgumentException("Template file missing in Tomcat letters directory: " + resolvedFileName + ".docx");
        }

        LetterDocumentEngine.RenderMode mode = LetterDocumentEngine.RenderMode.fromString(letterType);
        boolean isDocFormatBlank = (leaseId == null || leaseId.isBlank()) && mode == LetterDocumentEngine.RenderMode.DOC_FORMAT;

        Map<String, String> placeholders = new HashMap<>();
        String cusFullName = "Document Template";
        String agreementNo = "-";

        if (isDocFormatBlank) {
            placeholders = buildBlankPlaceholders();
        } else {
            if (leaseId == null || leaseId.isBlank()) {
                throw new IllegalArgumentException("Please select an Agreement No.");
            }
            PlaceholderResult loaded = loadLeasePlaceholders(leaseId.trim(), displayName);
            placeholders = loaded.placeholders();
            cusFullName = loaded.cusFullName().isBlank() ? "Customer" : loaded.cusFullName();
            agreementNo = loaded.agreementNo();
        }

        boolean isDocx = "DOCX".equalsIgnoreCase(outputFormat);
        byte[] bytes = isDocx
                ? documentEngine.generateDocx(templatePath, placeholders, mode)
                : documentEngine.generatePdf(templatePath, placeholders, mode, fontSize);

        String safeFileBase = (displayName + " - " + cusFullName).replaceAll("[\\\\/:*?\"<>|]", "_");
        String downloadName = safeFileBase + (isDocx ? ".docx" : ".pdf");
        String contentType = isDocx
                ? "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                : "application/pdf";

        // Audit log in device_portal
        try {
            primaryJdbc.update("""
                    INSERT INTO device_portal.letter_print_log
                        (product_category, product_id, product_name, letter_name, lease_id,
                         agreement_no, customer_name, letter_type, output_format, generated_by)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                    productCategory, productId, productName, displayName, leaseId,
                    agreementNo, cusFullName, mode.name(), isDocx ? "DOCX" : "PDF", username);
        } catch (Exception e) {
            log.warn("Unable to write letter_print_log: {}", e.getMessage());
        }

        return new GeneratedLetter(bytes, downloadName, contentType);
    }

    private record PlaceholderResult(Map<String, String> placeholders, String cusFullName, String agreementNo) {}

    private PlaceholderResult loadLeasePlaceholders(String leaseId, String letterDisplayName) {
        MapSqlParameterSource params = new MapSqlParameterSource().addValue("leaseId", leaseId);
        String s = (cmsSchema == null || cmsSchema.isBlank()) ? "cms" : cmsSchema.trim();

        String qr = ("""
                SELECT
                    IFNULL((SELECT IFNULL(INITIALS, FULL_NAME) FROM __S__.customer WHERE CUSTOMER_CODE = l.customer), '') AS cusName,
                    IFNULL((SELECT IFNULL(FULL_NAME, '') FROM __S__.customer WHERE CUSTOMER_CODE = l.customer), '') AS cusFullName,
                    IFNULL((SELECT CONCAT(IFNULL(R_ADDRESS_L1, ''), ' ', IFNULL(R_ADDRESS_L2, ''), ' ', IFNULL(R_ADDRESS_L3, ''), ' ',
                                          IFNULL((SELECT name_en FROM __S__.geo_cities WHERE id = RESIDENTIAL_CITY), ''))
                            FROM __S__.customer WHERE CUSTOMER_CODE = l.customer), '') AS addres,
                    IFNULL((SELECT IFNULL(RPAD(LEFT(COALESCE(NIC_BR, ''), 13), 13, ' '), '') FROM __S__.customer WHERE CUSTOMER_CODE = l.customer), '') AS cus_nic,
                    IFNULL((SELECT IFNULL(registration_no, IFNULL(chassis_no, '')) FROM __S__.asset WHERE id = (SELECT asset FROM __S__.lease_assets WHERE lease = l.id LIMIT 1)), '') AS vehiNo,
                    IFNULL((SELECT IFNULL(chassis_no, '') FROM __S__.asset WHERE id = (SELECT asset FROM __S__.lease_assets WHERE lease = l.id LIMIT 1)), '') AS chasisNo,
                    IFNULL((SELECT IFNULL(name, '') FROM __S__.vendor WHERE id = (SELECT vendor FROM __S__.lease_assets WHERE lease = l.id LIMIT 1)), '') AS vendorName,
                    IFNULL(CONCAT((SELECT IFNULL(address, '') FROM __S__.vendor WHERE id = (SELECT vendor FROM __S__.lease_assets WHERE lease = l.id LIMIT 1)), ' ',
                                  IFNULL((SELECT name_en FROM __S__.geo_cities WHERE id = (SELECT IFNULL(city, '') FROM __S__.vendor WHERE id = (SELECT vendor FROM __S__.lease_assets WHERE lease = l.id LIMIT 1))), '')), '') AS vendorAddress,
                    IFNULL((SELECT CONCAT((SELECT name FROM __S__.asset_make WHERE id = make), ' ', IFNULL((SELECT name FROM __S__.asset_model WHERE id = model), '-'))
                            FROM __S__.asset WHERE id = (SELECT asset FROM __S__.lease_assets WHERE lease = l.id LIMIT 1)), '') AS makeModel,
                    IFNULL((SELECT IFNULL(engine_no, '') FROM __S__.asset WHERE id = (SELECT asset FROM __S__.lease_assets WHERE lease = l.id LIMIT 1)), '') AS engineNo,
                    IFNULL((SELECT IFNULL(yom, '') FROM __S__.asset WHERE id = (SELECT asset FROM __S__.lease_assets WHERE lease = l.id LIMIT 1)), '') AS yom,
                    IFNULL(FORMAT(l.finance_amount, 2), '') AS facilityAmount,
                    IFNULL((SELECT IFNULL(nic, '') FROM __S__.vendor WHERE id = (SELECT vendor FROM __S__.lease_assets WHERE lease = l.id LIMIT 1)), '') AS vendorNic,
                    IFNULL(l.finance_no, '') AS agreementNo,
                    IFNULL((SELECT IFNULL(DATE(date), '') FROM __S__.lease_recommendation WHERE lease = l.id AND action = 'activated' ORDER BY date DESC LIMIT 1), '') AS facilityActivationDate,
                    IFNULL((SELECT CONCAT(
                            DAY(IFNULL(DATE(date), '')),
                            CASE
                                WHEN DAY(IFNULL(DATE(date), '')) IN (1, 21, 31) THEN 'st'
                                WHEN DAY(IFNULL(DATE(date), '')) IN (2, 22) THEN 'nd'
                                WHEN DAY(IFNULL(DATE(date), '')) IN (3, 23) THEN 'rd'
                                ELSE 'th'
                            END,
                            ' Day Of ',
                            DATE_FORMAT(IFNULL(DATE(date), ''), '%M %Y'))
                            FROM __S__.lease_recommendation WHERE lease = l.id AND action = 'activated' ORDER BY date DESC LIMIT 1), '') AS facilityActivateDateWord,
                    IFNULL(l.tenor, '') AS tenor,
                    IFNULL(l.interest_rate, '') AS interestRate,
                    IFNULL((SELECT FORMAT(SUM(charge_amount), 2) FROM __S__.lease_charges WHERE lease = l.id AND method = 'Upfront'), '') AS totalUpfrontCharges,
                    IFNULL(l.appNo, '') AS applicationNo,
                    IFNULL((WITH payment_data AS (
                                SELECT net, MIN(installment) AS min_installment, MAX(installment) AS max_installment
                                FROM __S__.lease, JSON_TABLE(payment_schedule, '$[*]' COLUMNS (installment INT PATH '$.installment', net INT PATH '$.net')) AS jt
                                WHERE id = :leaseId
                                GROUP BY net
                            )
                            SELECT JSON_ARRAYAGG(JSON_OBJECT('nbr',
                                CASE WHEN min_installment = max_installment THEN CAST(min_installment AS CHAR)
                                     ELSE CONCAT(min_installment, ' - ', max_installment) END,
                                'net', net))
                            FROM payment_data), '') AS installmentJson,
                    IFNULL((SELECT IFNULL(registration_no, '') FROM __S__.asset WHERE id = (SELECT asset FROM __S__.lease_assets WHERE lease = l.id LIMIT 1)), '') AS vehiNoOnly,
                    IFNULL((SELECT c.INITIALS FROM __S__.lease_co_borrowers cb LEFT JOIN __S__.customer c ON cb.co_borrower = c.CUSTOMER_CODE WHERE cb.lease = l.id LIMIT 1), '') AS name2,
                    IFNULL((SELECT CONCAT(IFNULL(c.R_ADDRESS_L1, ''), ' ', IFNULL(c.R_ADDRESS_L2, ''), ' ', IFNULL(c.R_ADDRESS_L3, ''), ' ',
                                          IFNULL((SELECT name_en FROM __S__.geo_cities WHERE id = c.RESIDENTIAL_CITY), ''))
                            FROM __S__.lease_co_borrowers cb LEFT JOIN __S__.customer c ON cb.co_borrower = c.CUSTOMER_CODE WHERE cb.lease = l.id LIMIT 1), '') AS adrs2,
                    IFNULL((SELECT RPAD(LEFT(COALESCE(c.NIC_BR, ''), 13), 13, ' ')
                            FROM __S__.lease_co_borrowers cb LEFT JOIN __S__.customer c ON cb.co_borrower = c.CUSTOMER_CODE WHERE cb.lease = l.id LIMIT 1), '') AS nic2,
                    IFNULL((SELECT c.FULL_NAME FROM __S__.lease_co_borrowers cb LEFT JOIN __S__.customer c ON cb.co_borrower = c.CUSTOMER_CODE WHERE cb.lease = l.id LIMIT 1), '') AS coFullname,
                    IFNULL((SELECT (SELECT name FROM __S__.payee WHERE id = insurance_company) FROM __S__.asset_insurance WHERE finance_no = l.finance_no LIMIT 1), '') AS insuName,
                    IFNULL((SELECT policy_no FROM __S__.asset_insurance WHERE finance_no = l.finance_no LIMIT 1), '') AS insupolicyno,
                    IFNULL((SELECT (SELECT name FROM __S__.asset_make WHERE id = make) FROM __S__.asset WHERE id = (SELECT asset FROM __S__.lease_assets WHERE lease = l.id LIMIT 1)), '') AS make,
                    IFNULL((SELECT IFNULL((SELECT name FROM __S__.asset_model WHERE id = model), '-') FROM __S__.asset WHERE id = (SELECT asset FROM __S__.lease_assets WHERE lease = l.id LIMIT 1)), '') AS model,
                    IFNULL((SELECT IFNULL(R_ADDRESS_L1, '') FROM __S__.customer WHERE CUSTOMER_CODE = l.customer), '') AS cusL1,
                    IFNULL((SELECT CONCAT(IFNULL(R_ADDRESS_L2, ''), ' ', IFNULL(R_ADDRESS_L3, '')) FROM __S__.customer WHERE CUSTOMER_CODE = l.customer), '') AS cusL2,
                    IFNULL((SELECT IFNULL((SELECT name_en FROM __S__.geo_cities WHERE id = RESIDENTIAL_CITY), '') FROM __S__.customer WHERE CUSTOMER_CODE = l.customer), '') AS cusL3,
                    IFNULL((SELECT IFNULL(c.R_ADDRESS_L1, '') FROM __S__.lease_co_borrowers cb LEFT JOIN __S__.customer c ON cb.co_borrower = c.CUSTOMER_CODE WHERE cb.lease = l.id LIMIT 1), '') AS coL1,
                    IFNULL((SELECT CONCAT(IFNULL(c.R_ADDRESS_L2, ''), ' ', IFNULL(c.R_ADDRESS_L3, '')) FROM __S__.lease_co_borrowers cb LEFT JOIN __S__.customer c ON cb.co_borrower = c.CUSTOMER_CODE WHERE cb.lease = l.id LIMIT 1), '') AS coL2,
                    IFNULL((SELECT IFNULL((SELECT name_en FROM __S__.geo_cities WHERE id = c.RESIDENTIAL_CITY), '') FROM __S__.lease_co_borrowers cb LEFT JOIN __S__.customer c ON cb.co_borrower = c.CUSTOMER_CODE WHERE cb.lease = l.id LIMIT 1), '') AS coL3
                FROM __S__.lease l
                WHERE l.id = :leaseId
                """).replace("__S__", s);

        List<Map<String, Object>> rows = primaryNamedJdbc.queryForList(qr, params);
        if (rows.isEmpty()) {
            throw new IllegalArgumentException("No lease record found for ID: " + leaseId);
        }
        Map<String, Object> r = rows.get(0);

        // Guarantors (up to 3)
        String[] gNames = {"", "", ""};
        String[] gNics = {"", "", ""};
        String[] gAddrs = {"", "", ""};
        try {
            String guarSql = "SELECT g.details FROM " + cms("lease_guarantors") + " g " +
                    "WHERE g.lease = :leaseId AND g.guarantor IS NOT NULL AND g.details IS NOT NULL LIMIT 3";
            List<Map<String, Object>> gRows = primaryNamedJdbc.queryForList(guarSql, params);
            for (int i = 0; i < gRows.size() && i < 3; i++) {
                String json = str(gRows.get(i).get("details"));
                if (!json.isBlank()) {
                    JsonNode node = MAPPER.readTree(json);
                    gNames[i] = node.path("name").asText("");
                    gNics[i] = node.path("nic").asText("");
                    gAddrs[i] = node.path("address").asText("");
                }
            }
        } catch (Exception e) {
            log.warn("Could not parse guarantor details for lease {}: {}", leaseId, e.getMessage());
        }

        // Optional Oracle rental dates
        String rentalStartDate = "";
        String rentalEndDate = "";
        String dueDate = "";
        String appNo = str(r.get("applicationNo"));
        if (!appNo.isBlank() && cmsDataSourceConfig.isOracleAvailable()) {
            try {
                String oraSql = """
                        SELECT NVL(TO_CHAR(MIN(A.RENTAL_DATE), 'yyyy-mm-dd'), '') AS start_dt,
                               NVL(TO_CHAR(MAX(A.RENTAL_DATE), 'yyyy-mm-dd'), '') AS end_dt
                        FROM MRFL.AF_CO_PRO_APP_INSTALLMENT A
                        WHERE A.APPLICATION_NO = :appNo
                        """;
                List<Map<String, Object>> oraRows = cmsDataSourceConfig.getOracleJdbcTemplate()
                        .queryForList(oraSql, new MapSqlParameterSource().addValue("appNo", appNo));
                if (!oraRows.isEmpty()) {
                    rentalStartDate = str(oraRows.get(0).get("START_DT"));
                    rentalEndDate = str(oraRows.get(0).get("END_DT"));
                    if (!rentalStartDate.isBlank()) {
                        dueDate = dayWithSuffix(LocalDate.parse(rentalStartDate).getDayOfMonth());
                    }
                }
            } catch (Exception e) {
                log.warn("Oracle installment lookup failed for appNo {}: {}", appNo, e.getMessage());
            }
        }

        // Format payment schedule table data
        String tblData = formatInstallmentSchedule(str(r.get("installmentJson")));
        String leaseAmount = str(r.get("facilityAmount"));
        String interestRate = str(r.get("interestRate"));
        String cusFullName = str(r.get("cusFullName"));
        String agreementNo = str(r.get("agreementNo"));

        Map<String, String> p = new HashMap<>();
        p.put("cShortName", str(r.get("cusName")));
        p.put("cFullName", cusFullName);
        p.put("cAddress", str(r.get("addres")));
        p.put("nicNo", str(r.get("cus_nic")));

        boolean isRmv = "RMV No Objection Letter".equalsIgnoreCase(letterDisplayName);
        p.put("regNo", isRmv ? str(r.get("vehiNoOnly")) : str(r.get("vehiNo")));
        p.put("chassisNo", str(r.get("chasisNo")));
        p.put("vendorName", str(r.get("vendorName")));
        p.put("vendorAddress", str(r.get("vendorAddress")));
        p.put("vendorNic", str(r.get("vendorNic")));
        p.put("makeModel", str(r.get("makeModel")));
        p.put("astMake", nonBlankOrSpace(r.get("make")));
        p.put("mdel", nonBlankOrSpace(r.get("model")));
        p.put("engineNo", str(r.get("engineNo")));
        p.put("makeYear", str(r.get("yom")));
        p.put("leaseAmount", leaseAmount);
        p.put("amountInWord", NumberToWordsConverter.convert(leaseAmount));
        p.put("agreementNo", agreementNo.isBlank() ? "                                 " : agreementNo);

        String actDate = str(r.get("facilityActivationDate"));
        p.put("facilityActivateDate", actDate.isBlank() ? "                                 " : actDate);
        p.put("facilityActiveDateWord", str(r.get("facilityActivateDateWord")));

        String tenor = str(r.get("tenor"));
        p.put("tenorMonth", tenor.isBlank() ? "     " : tenor);
        p.put("lRate", interestRate);
        p.put("leaseRate", NumberToWordsConverter.convert(interestRate));
        p.put("cvgfh", str(r.get("totalUpfrontCharges")));
        p.put("tblData", tblData);

        // Co-applicant & address lines
        p.put("ApNm", nonBlankOrSpace(r.get("name2")));
        p.put("nnia", nonBlankOrSpace(r.get("nic2")));
        p.put("JcNm", nonBlankOrSpace(r.get("coFullname")));
        p.put("colpadrs", nonBlankOrSpace(r.get("adrs2")));
        p.put("jansm", nonBlankOrSpace(r.get("cusL1")));
        p.put("Dgadr2", nonBlankOrSpace(r.get("cusL2")));
        p.put("Ghafg3", nonBlankOrSpace(r.get("cusL3")));
        p.put("coAdrs", nonBlankOrSpace(r.get("coL1")));
        p.put("vbhyu", nonBlankOrSpace(r.get("coL2")));
        p.put("tyhjk", nonBlankOrSpace(r.get("coL3")));

        // Insurance
        p.put("comn", nonBlankOrSpace(r.get("insuName")));
        p.put("polno", nonBlankOrSpace(r.get("insupolicyno")));

        // Guarantors 1, 2, 3
        p.put("ghname", gNames[0]);
        p.put("ghnic", gNics[0]);
        p.put("adrsth", gAddrs[0]);
        p.put("ghnames", gNames[1]);
        p.put("g2Nic", gNics[1]);
        p.put("g2Address", gAddrs[1]);
        p.put("gcnm", gNames[2].isBlank() ? " " : gNames[2]);
        p.put("ganc", gNics[2].isBlank() ? " " : gNics[2]);
        p.put("gdars", gAddrs[2].isBlank() ? " " : gAddrs[2]);

        // Rental dates
        p.put("rentalStartDate", rentalStartDate.isBlank() ? "                            " : rentalStartDate);
        p.put("rentalEndDate", rentalEndDate.isBlank() ? "                            " : rentalEndDate);
        p.put("dfg", dueDate);
        p.put("dueDate", dueDate);

        return new PlaceholderResult(p, cusFullName, agreementNo);
    }

    private Map<String, String> buildBlankPlaceholders() {
        String[] keys = {
                "cShortName", "cFullName", "cAddress", "nicNo", "regNo", "chassisNo",
                "vendorName", "vendorAddress", "vendorNic", "makeModel", "astMake", "mdel",
                "engineNo", "makeYear", "leaseAmount", "amountInWord", "agreementNo",
                "facilityActivateDate", "facilityActiveDateWord", "tenorMonth", "lRate", "leaseRate",
                "cvgfh", "tblData", "ApNm", "nnia", "JcNm", "colpadrs", "jansm", "Dgadr2", "Ghafg3",
                "coAdrs", "vbhyu", "tyhjk", "comn", "polno", "ghname", "ghnic", "adrsth",
                "ghnames", "g2Nic", "g2Address", "gcnm", "ganc", "gdars",
                "rentalStartDate", "rentalEndDate", "dfg", "dueDate"
        };
        Map<String, String> map = new HashMap<>();
        for (String k : keys) {
            map.put(k, "                    ");
        }
        return map;
    }

    private String formatInstallmentSchedule(String json) {
        if (json == null || json.isBlank() || "null".equalsIgnoreCase(json)) {
            return "";
        }
        try {
            JsonNode arr = MAPPER.readTree(json);
            if (!arr.isArray()) return "";
            NumberFormat nf = NumberFormat.getNumberInstance(Locale.US);
            List<String> lines = new ArrayList<>();
            for (JsonNode node : arr) {
                String nbr = node.path("nbr").asText("");
                long net = node.path("net").asLong(0);
                String spacer = nbr.contains("-")
                        ? "                                 "
                        : "                                      ";
                lines.add(nbr + spacer + nf.format(net));
            }
            return String.join("\n ", lines);
        } catch (Exception e) {
            return "";
        }
    }

    private static String dayWithSuffix(int day) {
        String suffix = (day >= 11 && day <= 13) ? "th"
                : (day % 10 == 1) ? "st"
                : (day % 10 == 2) ? "nd"
                : (day % 10 == 3) ? "rd" : "th";
        return day + suffix;
    }

    private static String str(Object obj) {
        return obj == null ? "" : String.valueOf(obj).trim();
    }

    private static String nonBlankOrSpace(Object obj) {
        String s = str(obj);
        return s.isEmpty() ? " " : s;
    }
}
