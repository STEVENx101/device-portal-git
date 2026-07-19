package com.fintrex.deviceportal.scratch;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class TestJoinCount {
    public static void main(String[] args) {
        String url = "jdbc:mysql://localhost:3306/device_portal";
        String user = "root";
        String password = "password";
        try (Connection conn = DriverManager.getConnection(url, user, password)) {
            
            // Join 1: exact account_no and series match
            String sql1 = """
                SELECT COUNT(*) FROM cbs.loan l
                JOIN cbs.portfolio p ON p.account_no = l.account_no AND p.series = l.account_series
                WHERE p.dpd > 0
            """;
            try (PreparedStatement stmt = conn.prepareStatement(sql1)) {
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) System.out.println("Match by account_no AND series: " + rs.getInt(1));
                }
            }

            // Join 2: account_no OR legacy_account_no match (without series)
            String sql2 = """
                SELECT COUNT(*) FROM cbs.loan l
                JOIN cbs.portfolio p ON (p.account_no = l.account_no OR p.account_no = l.legacy_account_no)
                WHERE p.dpd > 0
            """;
            try (PreparedStatement stmt = conn.prepareStatement(sql2)) {
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) System.out.println("Match by account_no OR legacy_account_no (no series): " + rs.getInt(1));
                }
            }

            // Check details for account 5800125118999
            String sql3 = "SELECT account_no, account_series, legacy_account_no FROM cbs.loan WHERE account_no = '5800125118999' OR legacy_account_no = '5800125118999'";
            try (PreparedStatement stmt = conn.prepareStatement(sql3)) {
                try (ResultSet rs = stmt.executeQuery()) {
                    System.out.println("Details in cbs.loan:");
                    while (rs.next()) {
                        System.out.println("account_no: " + rs.getString("account_no") + " | series: " + rs.getInt("account_series") + " | legacy: " + rs.getString("legacy_account_no"));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
