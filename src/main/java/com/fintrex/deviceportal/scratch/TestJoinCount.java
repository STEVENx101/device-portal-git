package com.fintrex.deviceportal.scratch;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;

public class TestJoinCount {
    public static void main(String[] args) {
        String url = "jdbc:mysql://intdb.fintrex.lk:3306/device_portal";
        String user = "cbs";
        String password = "hatxGap260";
        try (Connection conn = DriverManager.getConnection(url, user, password)) {
            System.out.println("Connected successfully!");

            // 1. Show Indexes of cbs.portfolio
            System.out.println("\n--- Indexes on cbs.portfolio ---");
            try (PreparedStatement stmt = conn.prepareStatement("SHOW INDEX FROM cbs.portfolio")) {
                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next()) {
                        System.out.println("Table: " + rs.getString("Table") +
                                           " | Key_name: " + rs.getString("Key_name") +
                                           " | Seq_in_index: " + rs.getInt("Seq_in_index") +
                                           " | Column_name: " + rs.getString("Column_name"));
                    }
                }
            }

            // 2. Test execution time of original Unlock Arrears query
            System.out.println("\n--- Testing Original Unlock Arrears Query ---");
            String originalSql = """
                SELECT COUNT(*) FROM cbs.loan l
                LEFT JOIN cbs.portfolio p1
                    ON p1.account_no = l.account_no
                    AND p1.series = l.account_series
                    AND p1.portfolio_date = '2026-07-28'
                    AND p1.sync_time = '09:00:00'
                LEFT JOIN cbs.portfolio p2
                    ON p2.account_no = l.legacy_account_no
                    AND p2.series = l.account_series
                    AND p2.portfolio_date = '2026-07-28'
                    AND p2.sync_time = '09:00:00'
                LEFT JOIN loan.mobileloan lm1 ON lm1.finance_no = l.account_no
                LEFT JOIN loan.mobileloan lm2 ON lm2.finance_no = l.legacy_account_no
                WHERE 1=1 AND COALESCE(lm1.locked, lm2.locked) = 0 AND COALESCE(p1.dpd, p2.dpd) > 0
            """;
            long start = System.currentTimeMillis();
            try (PreparedStatement stmt = conn.prepareStatement(originalSql)) {
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        System.out.println("Count: " + rs.getInt(1));
                    }
                }
            }
            System.out.println("Original query took: " + (System.currentTimeMillis() - start) + " ms");

            // 3. Test execution time of optimized Unlock Arrears query (using subqueries / CTE)
            System.out.println("\n--- Testing Optimized Unlock Arrears Query ---");
            String optimizedSql = """
                SELECT COUNT(*) FROM cbs.loan l
                LEFT JOIN (
                    SELECT account_no, series, dpd FROM cbs.portfolio
                    WHERE portfolio_date = '2026-07-28' AND sync_time = '09:00:00'
                ) p1 ON p1.account_no = l.account_no AND p1.series = l.account_series
                LEFT JOIN (
                    SELECT account_no, series, dpd FROM cbs.portfolio
                    WHERE portfolio_date = '2026-07-28' AND sync_time = '09:00:00'
                ) p2 ON p2.account_no = l.legacy_account_no AND p2.series = l.account_series
                LEFT JOIN loan.mobileloan lm1 ON lm1.finance_no = l.account_no
                LEFT JOIN loan.mobileloan lm2 ON lm2.finance_no = l.legacy_account_no
                WHERE 1=1 AND COALESCE(lm1.locked, lm2.locked) = 0 AND COALESCE(p1.dpd, p2.dpd) > 0
            """;
            start = System.currentTimeMillis();
            try (PreparedStatement stmt = conn.prepareStatement(optimizedSql)) {
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        System.out.println("Count: " + rs.getInt(1));
                    }
                }
            }
            System.out.println("Optimized query took: " + (System.currentTimeMillis() - start) + " ms");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
