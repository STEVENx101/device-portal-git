package com.fintrex.deviceportal.config;

import com.fintrex.deviceportal.dto.User;
import com.fintrex.deviceportal.dto.Screen;
import com.fintrex.deviceportal.service.UserService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component
public class SecurityInterceptor implements HandlerInterceptor {

    private final UserService userService;

    // Mapping API endpoint path prefixes to required screen paths
    private static final Map<String, String> API_SCREEN_MAP = new HashMap<>();

    static {
        API_SCREEN_MAP.put("/api/cbs/report1", "/portfolio");
        API_SCREEN_MAP.put("/api/cbs/report2", "/client");
        API_SCREEN_MAP.put("/api/cbs/report3", "/transaction");
        API_SCREEN_MAP.put("/api/cbs/report4", "/agreement");
        API_SCREEN_MAP.put("/api/cbs/arrears", "/arrears-report");
        API_SCREEN_MAP.put("/api/cbs/npa", "/npa-report");
        API_SCREEN_MAP.put("/api/cbs/nearing-npa", "/nearing-npa-report");
        API_SCREEN_MAP.put("/api/cbs/duplicate-loans", "/duplicate-loans-report");
        API_SCREEN_MAP.put("/api/cbs/unlock-arrears", "/unlock-arrears-report");
        API_SCREEN_MAP.put("/api/cbs/lock-no-arrears", "/lock-no-arrears-report");
        API_SCREEN_MAP.put("/api/cbs/one-rental", "/one-rental-report");
        API_SCREEN_MAP.put("/api/cbs/settled-report", "/settled-report");
        API_SCREEN_MAP.put("/api/cbs/matured-low-balance", "/matured-low-balance-report");
        API_SCREEN_MAP.put("/api/cbs/low-balance", "/low-balance-report");
        API_SCREEN_MAP.put("/api/cbs/multiple-payments-report", "/multiple-payments-report");
        API_SCREEN_MAP.put("/api/cbs/dpd-bucket", "/dpd-bucket-report");
        API_SCREEN_MAP.put("/api/cbs/vendor-payments", "/vendor-payments");
        API_SCREEN_MAP.put("/api/cbs/vendor-payments-exception", "/vendor-payments-exception");
        API_SCREEN_MAP.put("/api/cbs/report-logs", "/report-logs");
        API_SCREEN_MAP.put("/api/cbs/access-logs", "/access-logs");
        API_SCREEN_MAP.put("/api/cbs/permission-logs", "/permission-logs");
        API_SCREEN_MAP.put("/api/payments/upload", "/payments/upload");
        API_SCREEN_MAP.put("/api/payments/approve", "/payments/approve");
    }

    public SecurityInterceptor(UserService userService) {
        this.userService = userService;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        String uri = request.getRequestURI();
        String contextPath = request.getContextPath();
        String path = uri.substring(contextPath.length());

        // Clean path (strip matrix parameters and query string if present)
        int semicolonIndex = path.indexOf(';');
        if (semicolonIndex != -1) {
            path = path.substring(0, semicolonIndex);
        }
        int queryIndex = path.indexOf('?');
        if (queryIndex != -1) {
            path = path.substring(0, queryIndex);
        }

        // Strip trailing slash if present (unless root "/")
        if (path.length() > 1 && path.endsWith("/")) {
            path = path.substring(0, path.length() - 1);
        }

        // Bypass static assets, login/logout, and public resource requests
        if (path.startsWith("/assets/") || path.startsWith("/vendors/") || 
            path.equals("/login") || path.equals("/logout") || path.equals("/sso-logout") ||
            path.contains(".")) {
            return true;
        }

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            if (path.startsWith("/api/")) {
                response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Session expired or unauthorized");
            } else {
                response.sendRedirect(contextPath + "/login");
            }
            return false;
        }

        // Fetch latest screen permissions for current user role
        List<Screen> permittedScreens = userService.getPermittedScreens(currentUser.getUserTypeId());
        if (session != null) {
            session.setAttribute("permittedScreens", permittedScreens);
        }

        // Handle API endpoints permission validation
        if (path.startsWith("/api/")) {
            return checkApiPermission(path, permittedScreens, currentUser, request, response);
        }

        // If visiting root or home page, redirect to first permitted screen
        if (path.equals("/") || path.equals("/index.html")) {
            if (permittedScreens != null && !permittedScreens.isEmpty()) {
                response.sendRedirect(contextPath + permittedScreens.get(0).getPath());
            } else {
                response.sendRedirect(contextPath + "/dashboard");
            }
            return false;
        }

        // Page-level permission verification (Fail-Closed approach)
        List<Screen> allScreens = userService.getAllScreens();
        final String targetPath = path;
        boolean isRegisteredScreen = allScreens.stream().anyMatch(s -> s.getPath().equalsIgnoreCase(targetPath));

        if (isRegisteredScreen) {
            boolean isPermitted = permittedScreens != null && permittedScreens.stream()
                    .anyMatch(s -> s.getPath().equalsIgnoreCase(targetPath));
            if (!isPermitted) {
                userService.logAccess(currentUser.getUsername(), targetPath, request.getRemoteAddr(), "DENIED");
                if (permittedScreens != null && !permittedScreens.isEmpty()) {
                    response.sendRedirect(contextPath + permittedScreens.get(0).getPath() + "?error=unauthorized");
                } else {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
                }
                return false;
            } else {
                userService.logAccess(currentUser.getUsername(), targetPath, request.getRemoteAddr(), "ALLOWED");
            }
        } else {
            // Fail-closed for unregistered application page routes: deny access if not in permittedScreens
            boolean isPermitted = permittedScreens != null && permittedScreens.stream()
                    .anyMatch(s -> s.getPath().equalsIgnoreCase(targetPath));
            if (!isPermitted && !path.equals("/cbs-reports") && !path.equals("/test")) {
                userService.logAccess(currentUser.getUsername(), targetPath, request.getRemoteAddr(), "DENIED_UNREGISTERED");
                if (permittedScreens != null && !permittedScreens.isEmpty()) {
                    response.sendRedirect(contextPath + permittedScreens.get(0).getPath() + "?error=unauthorized");
                } else {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
                }
                return false;
            }
        }

        return true;
    }

    private boolean checkApiPermission(String path, List<Screen> permittedScreens, User currentUser, HttpServletRequest request, HttpServletResponse response) throws Exception {
        // Find if this API route requires a specific screen permission
        for (Map.Entry<String, String> entry : API_SCREEN_MAP.entrySet()) {
            if (path.startsWith(entry.getKey())) {
                String requiredScreen = entry.getValue();
                boolean isPermitted = permittedScreens != null && permittedScreens.stream()
                        .anyMatch(s -> s.getPath().equalsIgnoreCase(requiredScreen));
                if (!isPermitted) {
                    userService.logAccess(currentUser.getUsername(), path, request.getRemoteAddr(), "API_DENIED");
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Missing screen permission for " + requiredScreen);
                    return false;
                }
                break;
            }
        }
        return true;
    }
}

