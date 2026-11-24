package com.fintrex.deviceportal.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Component;

/**
 * Manages the dedicated read-only HikariCP pool and NamedParameterJdbcTemplate
 * for the My Fintrex Mobile App MySQL database.
 *
 * Intentionally NOT exposing DataSource / JdbcTemplate / NamedParameterJdbcTemplate
 * as Spring @Beans so Spring Boot's primary auto-configured DataSource and
 * NamedParameterJdbcTemplate (used by CbsReportService, DataTableRepo, etc.)
 * are completely unaffected.
 */
@Component
public class MobileAppDataSourceConfig {

    @Value("${mobileapp.datasource.url:jdbc:mysql://10.16.2.38:3306/fintrex_live_app_backend?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Colombo}")
    private String url;

    @Value("${mobileapp.datasource.username:fintrex_read_only}")
    private String username;

    @Value("${mobileapp.datasource.password:}")
    private String password;

    @Value("${mobileapp.datasource.driver-class-name:com.mysql.cj.jdbc.Driver}")
    private String driverClassName;

    private HikariDataSource mobileAppDataSource;
    private NamedParameterJdbcTemplate mobileAppJdbcTemplate;

    @PostConstruct
    public void init() {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(url);
        config.setUsername(username);
        config.setPassword(password);
        config.setDriverClassName(driverClassName);
        config.setPoolName("MobileAppReadOnlyPool");
        config.setReadOnly(true);
        config.setMaximumPoolSize(4);
        config.setMinimumIdle(0);
        config.setConnectionTimeout(10000);
        config.setIdleTimeout(60000);
        config.setInitializationFailTimeout(-1);

        this.mobileAppDataSource = new HikariDataSource(config);
        this.mobileAppJdbcTemplate = new NamedParameterJdbcTemplate(this.mobileAppDataSource);
    }

    public NamedParameterJdbcTemplate getJdbcTemplate() {
        return this.mobileAppJdbcTemplate;
    }

    @PreDestroy
    public void close() {
        if (this.mobileAppDataSource != null && !this.mobileAppDataSource.isClosed()) {
            this.mobileAppDataSource.close();
        }
    }
}
