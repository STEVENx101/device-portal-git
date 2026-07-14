package com.fintrex.deviceportal.repository;

import com.fintrex.deviceportal.dto.User;
import com.fintrex.deviceportal.dto.UserType;
import com.fintrex.deviceportal.dto.Screen;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class UserRepository {

    private final JdbcTemplate jdbcTemplate;

    public UserRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public User findByUsername(String username) {
        String sql = """
            SELECT u.id, u.username, u.password, u.full_name, u.email, u.user_type_id, ut.name AS user_type_name 
            FROM device_portal.user u 
            LEFT JOIN device_portal.user_type ut ON u.user_type_id = ut.id 
            WHERE u.username = ?""";
        List<User> users = jdbcTemplate.query(sql, (rs, rowNum) -> new User(
                rs.getInt("id"),
                rs.getString("username"),
                rs.getString("password"),
                rs.getString("full_name"),
                rs.getString("email"),
                rs.getInt("user_type_id"),
                rs.getString("user_type_name")
        ), username);
        return users.isEmpty() ? null : users.get(0);
    }

    public User findByEmail(String email) {
        String sql = """
            SELECT u.id, u.username, u.password, u.full_name, u.email, u.user_type_id, ut.name AS user_type_name 
            FROM device_portal.user u 
            LEFT JOIN device_portal.user_type ut ON u.user_type_id = ut.id 
            WHERE u.email = ?""";
        List<User> users = jdbcTemplate.query(sql, (rs, rowNum) -> new User(
                rs.getInt("id"),
                rs.getString("username"),
                rs.getString("password"),
                rs.getString("full_name"),
                rs.getString("email"),
                rs.getInt("user_type_id"),
                rs.getString("user_type_name")
        ), email);
        return users.isEmpty() ? null : users.get(0);
    }

    public List<User> findAllUsers() {
        String sql = """
            SELECT u.id, u.username, u.password, u.full_name, u.email, u.user_type_id, ut.name AS user_type_name 
            FROM device_portal.user u 
            LEFT JOIN device_portal.user_type ut ON u.user_type_id = ut.id 
            ORDER BY u.id DESC""";
        return jdbcTemplate.query(sql, (rs, rowNum) -> new User(
                rs.getInt("id"),
                rs.getString("username"),
                null, // don't return password
                rs.getString("full_name"),
                rs.getString("email"),
                rs.getInt("user_type_id"),
                rs.getString("user_type_name")
        ));
    }

    public List<UserType> findAllUserTypes() {
        String sql = """
            SELECT id, name, description FROM device_portal.user_type ORDER BY name ASC""";
        return jdbcTemplate.query(sql, (rs, rowNum) -> new UserType(
                rs.getInt("id"),
                rs.getString("name"),
                rs.getString("description")
        ));
    }

    public List<Screen> findAllScreens() {
        String sql = """
            SELECT id, name, path, icon, group_name FROM device_portal.screen ORDER BY id ASC""";
        return jdbcTemplate.query(sql, (rs, rowNum) -> new Screen(
                rs.getInt("id"),
                rs.getString("name"),
                rs.getString("path"),
                rs.getString("icon"),
                rs.getString("group_name")
        ));
    }

    public List<Screen> findPermittedScreens(int userTypeId) {
        String sql = """
            SELECT s.id, s.name, s.path, s.icon, s.group_name 
            FROM device_portal.screen s 
            JOIN device_portal.user_type_screen uts ON s.id = uts.screen_id 
            WHERE uts.user_type_id = ? 
            ORDER BY s.id ASC""";
        return jdbcTemplate.query(sql, (rs, rowNum) -> new Screen(
                rs.getInt("id"),
                rs.getString("name"),
                rs.getString("path"),
                rs.getString("icon"),
                rs.getString("group_name")
        ), userTypeId);
    }

    public int createUser(String username, String password, String fullName, String email, int userTypeId) {
        String sql = """
            INSERT INTO device_portal.user (username, password, full_name, email, user_type_id) VALUES (?, ?, ?, ?, ?)""";
        return jdbcTemplate.update(sql, username, password, fullName, email, userTypeId);
    }

    public int createUserType(String name, String description) {
        String sql = """
            INSERT INTO device_portal.user_type (name, description) VALUES (?, ?)""";
        return jdbcTemplate.update(sql, name, description);
    }

    public void updateUserTypePermissions(int userTypeId, List<Integer> screenIds) {
        // First delete existing permissions
        jdbcTemplate.update("DELETE FROM device_portal.user_type_screen WHERE user_type_id = ?", userTypeId);
        
        // Then insert new permissions
        if (screenIds != null && !screenIds.isEmpty()) {
            for (Integer screenId : screenIds) {
                jdbcTemplate.update("INSERT INTO device_portal.user_type_screen (user_type_id, screen_id) VALUES (?, ?)", userTypeId, screenId);
            }
        }
    }

    public int updateUser(int id, String fullName, String email, int userTypeId, String password) {
        if (password != null && !password.trim().isEmpty()) {
            String sql = """
                UPDATE device_portal.user SET full_name = ?, email = ?, user_type_id = ?, password = ? WHERE id = ?""";
            return jdbcTemplate.update(sql, fullName, email, userTypeId, password, id);
        } else {
            String sql = """
                UPDATE device_portal.user SET full_name = ?, email = ?, user_type_id = ? WHERE id = ?""";
            return jdbcTemplate.update(sql, fullName, email, userTypeId, id);
        }
    }
}
