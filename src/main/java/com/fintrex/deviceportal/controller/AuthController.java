package com.fintrex.deviceportal.controller;

import com.fintrex.deviceportal.dto.User;
import com.fintrex.deviceportal.service.UserService;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.RequestBody;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@Controller
public class AuthController {

    private final UserService userService;

    @Value("${app.auth.server:https://auth.fintrexfinance.com:2083}")
    private String authServer;

    public AuthController(UserService userService) {
        this.userService = userService;
    }

    private String absoluteUrl(jakarta.servlet.http.HttpServletRequest req, String pathAndQuery) {
        String scheme = req.getScheme();
        String host = req.getServerName();
        int port = req.getServerPort();
        String ctx = req.getContextPath();
        boolean isStd = ("http".equalsIgnoreCase(scheme) && port == 80)
                || ("https".equalsIgnoreCase(scheme) && port == 443);
        if (!pathAndQuery.startsWith("/")) {
            pathAndQuery = "/" + pathAndQuery;
        }
        return scheme + "://" + host + (isStd ? "" : ":" + port) + ctx + pathAndQuery;
    }
    

    private String urlEncode(String v) {
        try {
            return URLEncoder.encode(v, StandardCharsets.UTF_8.name());
        } catch (Exception e) {
            return v;
        }
    }

    @PostMapping("/login")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> login(
            @RequestParam("username") String username,
            @RequestParam("password") String password,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();
        User user = userService.validateUser(username, password);

        if (user != null) {
            session.removeAttribute("loggedOut"); // Clear logged out flag if set
            session.setAttribute("currentUser", user);
            session.setAttribute("permittedScreens", userService.getPermittedScreens(user.getUserTypeId()));
            
            response.put("success", true);
            response.put("message", "Login successful!");
            return ResponseEntity.ok(response);
            
        } else {
            
            response.put("success", false);
            response.put("message", "Invalid username or password.");
            return ResponseEntity.badRequest().body(response);
        }
    }

    @PostMapping("/api/login-callback")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> loginCallback(@RequestBody Map<String, Object> payload, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        String email = payload.get("email") != null ? String.valueOf(payload.get("email")) : "";
        String name = payload.get("name") != null ? String.valueOf(payload.get("name")) : "";
        
        email = email.trim();
        
        User user = null;
        if (!email.isEmpty()) {
            user = userService.getUserByEmail(email);
        }
        
        if (user == null) {
            // Try deriving username (e.g. janudav from janudav@fintrex.lk)
            String derivedUsername = email;
            int at = email.indexOf('@');
            if (at > 0) {
                derivedUsername = email.substring(0, at);
            }
            derivedUsername = derivedUsername.toLowerCase().trim();
            if (!derivedUsername.isEmpty()) {
                user = userService.getUserByUsername(derivedUsername);
            }
        }

        if (user != null) {
            session.removeAttribute("loggedOut");
            session.setAttribute("currentUser", user);
            session.setAttribute("permittedScreens", userService.getPermittedScreens(user.getUserTypeId()));
            
            response.put("success", true);
            response.put("message", "SSO Login successful!");
            return ResponseEntity.ok(response);
        } else {
            response.put("success", false);
            response.put("message", "User with email " + email + " is not authorized for this application.");
            return ResponseEntity.status(401).body(response);
        }
    }
    

    @GetMapping("/sso-logout")
    public String ssoLogout(jakarta.servlet.http.HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        HttpSession newSession = request.getSession(true);
        newSession.setAttribute("loggedOut", true);
        
        String backToLogin = absoluteUrl(request, "/login");
        
        return "redirect:" + authServer + "/auth/sso-logout?client_redirect_uri=" + urlEncode(backToLogin);
    }

    @GetMapping("/logout")
    public String logout(jakarta.servlet.http.HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
        // Set loggedOut flag in a new session to prevent immediate auto-login
        HttpSession newSession = request.getSession(true);
        newSession.setAttribute("loggedOut", true);
        return "redirect:/login?logout=true";
    }

    @GetMapping("/api/sso-me")
    @ResponseBody
    public ResponseEntity<?> ssoMe(
            jakarta.servlet.http.HttpServletRequest request,
            @org.springframework.web.bind.annotation.RequestParam(value = "token", required = false) String paramToken) {

        String token = paramToken;
        if (token == null || token.isEmpty()) {
            if (request.getCookies() != null) {
                for (jakarta.servlet.http.Cookie cookie : request.getCookies()) {
                    if ("session_token".equals(cookie.getName())) {
                        token = cookie.getValue();
                        break;
                    }
                }
            }
        }

        if (token == null || token.isEmpty()) {
            return ResponseEntity.status(401).body(Map.of("error", "No session token found"));
        }

        try {
            javax.net.ssl.SSLContext sslContext = javax.net.ssl.SSLContext.getInstance("TLS");
            sslContext.init(null, new javax.net.ssl.TrustManager[]{new javax.net.ssl.X509TrustManager() {
                public void checkClientTrusted(java.security.cert.X509Certificate[] chain, String authType) {}
                public void checkServerTrusted(java.security.cert.X509Certificate[] chain, String authType) {}
                public java.security.cert.X509Certificate[] getAcceptedIssuers() { return new java.security.cert.X509Certificate[0]; }
            }}, new java.security.SecureRandom());

            java.net.http.HttpClient client = java.net.http.HttpClient.newBuilder()
                    .connectTimeout(java.time.Duration.ofSeconds(10))
                    .sslContext(sslContext)
                    .build();

            java.net.http.HttpRequest.Builder reqBuilder = java.net.http.HttpRequest.newBuilder()
                    .uri(new java.net.URI(authServer + "/me"))
                    .timeout(java.time.Duration.ofSeconds(10))
                    .GET();

            reqBuilder.header("Cookie", "session_token=" + token);
            reqBuilder.header("Authorization", "Bearer " + token);

            java.net.http.HttpResponse<String> response = client.send(reqBuilder.build(), java.net.http.HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() == 200) {
                return ResponseEntity.ok()
                        .header("Content-Type", "application/json")
                        .body(response.body());
            } else {
                return ResponseEntity.status(response.statusCode()).body(response.body());
            }
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of("error", "SSO backend call failed: " + e.getMessage()));
        }
    }
}
