package com.fintrex.deviceportal.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Component;

/**
 * Optional read-only HikariCP pool for Oracle (MRFL.AF_CO_PRO_APP_INSTALLMENT)
 * used by Facility Letters when oracle.datasource.enabled=true.
 *
 * CMS tables live on the primary intdb.fintrex.lk MySQL server (cms.*),
 * so they are queried directly via Spring Boot's primary NamedParameterJdbcTemplate.
 */
@Component
public class CmsDataSourceConfig {

    private static final Logger log = LoggerFactory.getLogger(CmsDataSourceConfig.class);

    @Value("${oracle.datasource.enabled:false}")
    private boolean oracleEnabled;

    @Value("${oracle.datasource.url:}")
    private String oracleUrl;

    @Value("${oracle.datasource.username:}")
    private String oracleUsername;

    @Value("${oracle.datasource.password:}")
    private String oraclePassword;

    @Value("${oracle.datasource.driver-class-name:oracle.jdbc.OracleDriver}")
    private String oracleDriverClassName;

    private HikariDataSource oracleDataSource;
    private NamedParameterJdbcTemplate oracleJdbcTemplate;

    @PostConstruct
    public void init() {
        if (oracleEnabled && oracleUrl != null && !oracleUrl.isBlank()) {
            try {
                HikariConfig oCfg = new HikariConfig();
                oCfg.setJdbcUrl(oracleUrl);
                oCfg.setUsername(oracleUsername);
                oCfg.setPassword(oraclePassword);
                oCfg.setDriverClassName(oracleDriverClassName);
                oCfg.setPoolName("OracleReadOnlyPool");
                oCfg.setReadOnly(true);
                oCfg.setMaximumPoolSize(3);
                oCfg.setMinimumIdle(0);
                oCfg.setConnectionTimeout(10000);
                oCfg.setIdleTimeout(60000);
                oCfg.setInitializationFailTimeout(-1);

                this.oracleDataSource = new HikariDataSource(oCfg);
                this.oracleJdbcTemplate = new NamedParameterJdbcTemplate(this.oracleDataSource);
            } catch (Exception e) {
                log.warn("Oracle DataSource initialization deferred/failed: {}", e.getMessage());
            }
        }
    }

    public boolean isOracleAvailable() {
        return this.oracleJdbcTemplate != null;
    }

    public NamedParameterJdbcTemplate getOracleJdbcTemplate() {
        return this.oracleJdbcTemplate;
    }

    @PreDestroy
    public void close() {
        if (this.oracleDataSource != null && !this.oracleDataSource.isClosed()) {
            this.oracleDataSource.close();
        }
    }
}
