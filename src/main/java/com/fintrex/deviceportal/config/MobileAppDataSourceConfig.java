package com.fintrex.deviceportal.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import jakarta.annotation.PreDestroy;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;

@Configuration
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

    /**
     * Dedicated read-only NamedParameterJdbcTemplate for the My Fintrex Mobile App MySQL DB.
     * Kept private as a DataSource so Spring Boot's primary DataSource and JPA auto-configuration
     * remain unaffected.
     */
    @Bean(name = "mobileAppJdbcTemplate")
    public NamedParameterJdbcTemplate mobileAppJdbcTemplate() {
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
        // Do not fail application startup if credentials are not yet configured or DB is unreachable
        config.setInitializationFailTimeout(-1);

        this.mobileAppDataSource = new HikariDataSource(config);
        return new NamedParameterJdbcTemplate(this.mobileAppDataSource);
    }

    @PreDestroy
    public void close() {
        if (this.mobileAppDataSource != null && !this.mobileAppDataSource.isClosed()) {
            this.mobileAppDataSource.close();
        }
    }
}
