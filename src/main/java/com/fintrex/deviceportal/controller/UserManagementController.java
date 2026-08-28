package com.fintrex.deviceportal.controller;

import com.fintrex.deviceportal.dto.User;
import com.fintrex.deviceportal.dto.UserType;
import com.fintrex.deviceportal.dto.Screen;
import com.fintrex.deviceportal.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import jakarta.servlet.http.HttpSession;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/user-management")
public class UserManagementController {

    private final UserService userService;

    public UserManagementController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping
    public String index(Model model) {
        model.addAttribute("users", userService.getAllUsers());
        model.addAttribute("userTypes", userService.getAllUserTypes());
        model.addAttribute("screens", userService.getAllScreens());
        return "user_management";
    }

    @GetMapping("/api/users")
    @ResponseBody
    public ResponseEntity<List<User>> getUsers() {
        return ResponseEntity.ok(userService.getAllUsers());
    }

    @GetMapping("/api/user-types")
    @ResponseBody
    public ResponseEntity<List<UserType>> getUserTypes() {
        return ResponseEntity.ok(userService.getAllUserTypes());
    }

    @GetMapping("/api/screens")
    @ResponseBody
    public ResponseEntity<List<Screen>> getScreens() {
        return ResponseEntity.ok(userService.getAllScreens());
    }

    @GetMapping("/api/permissions")
    @ResponseBody
    public ResponseEntity<List<Integer>> getPermissions(@RequestParam("userTypeId") int userTypeId) {
        List<Integer> screenIds = userService.getPermittedScreens(userTypeId)
                .stream()
                .map(Screen::getId)
                .collect(Collectors.toList());
        return ResponseEntity.ok(screenIds);
    }

    @PostMapping("/api/users")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> createUser(
            @RequestParam("username") String username,
            @RequestParam("password") String password,
            @RequestParam("fullName") String fullName,
            @RequestParam("email") String email,
            @RequestParam("userTypeId") int userTypeId) {

        Map<String, Object> response = new HashMap<>();
        
        // Simple validation
        if (username.trim().isEmpty() || password.trim().isEmpty() || fullName.trim().isEmpty() || email.trim().isEmpty()) {
            response.put("success", false);
            response.put("message", "All fields are required.");
            return ResponseEntity.badRequest().body(response);
        }

        boolean success = userService.createUser(username, password, fullName, email, userTypeId);
        if (success) {
            response.put("success", true);
            response.put("message", "User created successfully!");
            return ResponseEntity.ok(response);
        } else {
            response.put("success", false);
            response.put("message", "Failed to create user (username may already exist).");
            return ResponseEntity.badRequest().body(response);
        }
    }

    @PostMapping("/api/user-types")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> createUserType(
            @RequestParam("name") String name,
            @RequestParam("description") String description) {

        Map<String, Object> response = new HashMap<>();
        if (name.trim().isEmpty()) {
            response.put("success", false);
            response.put("message", "Role name is required.");
            return ResponseEntity.badRequest().body(response);
        }

        boolean success = userService.createUserType(name.toUpperCase(), description);
        if (success) {
            response.put("success", true);
            response.put("message", "Role created successfully!");
            return ResponseEntity.ok(response);
        } else {
            response.put("success", false);
            response.put("message", "Failed to create role.");
            return ResponseEntity.badRequest().body(response);
        }
    }

    @PostMapping("/api/permissions")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updatePermissions(
            @RequestParam("userTypeId") int userTypeId,
            @RequestParam(value = "screenIds", required = false) List<Integer> screenIds,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();
        userService.updateUserTypePermissions(userTypeId, screenIds);

        // Log the change
        User currentUser = (User) session.getAttribute("currentUser");
        String changedBy = currentUser != null ? currentUser.getUsername() : "system";

        String userTypeName = "ID " + userTypeId;
        List<UserType> allUserTypes = userService.getAllUserTypes();
        if (allUserTypes != null) {
            for (UserType ut : allUserTypes) {
                if (ut.getId() != null && ut.getId() == userTypeId) {
                    userTypeName = ut.getName();
                    break;
                }
            }
        }

        List<String> screenNames = new java.util.ArrayList<>();
        if (screenIds != null && !screenIds.isEmpty()) {
            List<Screen> allScreens = userService.getAllScreens();
            if (allScreens != null) {
                for (Integer sid : screenIds) {
                    for (Screen sc : allScreens) {
                        if (sc.getId() != null && sc.getId().equals(sid)) {
                            screenNames.add(sc.getName());
                            break;
                        }
                    }
                }
            }
        }

        String actionDetails = "Updated permissions for " + userTypeName + " to screens: " + screenNames.toString();
        userService.logPermissionChange(changedBy, userTypeId, actionDetails);

        response.put("success", true);
        response.put("message", "Permissions updated successfully!");
        return ResponseEntity.ok(response);
    }

    @PostMapping("/api/users/update")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateUser(
            @RequestParam("id") int id,
            @RequestParam("fullName") String fullName,
            @RequestParam("email") String email,
            @RequestParam("userTypeId") int userTypeId,
            @RequestParam(value = "password", required = false) String password) {

        Map<String, Object> response = new HashMap<>();
        if (fullName.trim().isEmpty() || email.trim().isEmpty()) {
            response.put("success", false);
            response.put("message", "Full name and email are required.");
            return ResponseEntity.badRequest().body(response);
        }

        boolean success = userService.updateUser(id, fullName, email, userTypeId, password);
        if (success) {
            response.put("success", true);
            response.put("message", "User updated successfully!");
            return ResponseEntity.ok(response);
        } else {
            response.put("success", false);
            response.put("message", "Failed to update user.");
            return ResponseEntity.badRequest().body(response);
        }
    }
}
