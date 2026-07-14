package com.fintrex.deviceportal.config;

import com.fintrex.deviceportal.dto.User;
import com.fintrex.deviceportal.dto.Screen;
import com.fintrex.deviceportal.service.UserService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import java.util.List;

@Component
public class SecurityInterceptor implements HandlerInterceptor {

    private final UserService userService;

    public SecurityInterceptor(UserService userService) {
        this.userService = userService;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        String uri = request.getRequestURI();
        String contextPath = request.getContextPath();
        String path = uri.substring(contextPath.length());

        // Bypass static assets, API calls, and authentication endpoints
        if (path.startsWith("/assets/") || path.startsWith("/vendors/") || 
            path.equals("/login") || path.equals("/logout") || 
            path.contains(".") || path.startsWith("/api/")) {
            return true;
        }

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        // Development Auto-login: If not logged in and not explicitly logged out
        if (currentUser == null && session.getAttribute("loggedOut") == null) {
            User adminUser = userService.getUserByUsername("admin");
            if (adminUser != null) {
                session.setAttribute("currentUser", adminUser);
                List<Screen> screens = userService.getPermittedScreens(adminUser.getUserTypeId());
                session.setAttribute("permittedScreens", screens);
                currentUser = adminUser;
                System.out.println("Dev Mode: Automatically logged in as 'admin'");
            }
        }

        if (currentUser == null) {
            response.sendRedirect(contextPath + "/login");
            return false;
        }

        // Screen-level permission verification
        List<Screen> permittedScreens = userService.getPermittedScreens(currentUser.getUserTypeId());
        session.setAttribute("permittedScreens", permittedScreens);
        
        // If visiting standard home or default route, redirect to the first permitted page
        if (path.equals("/") || path.equals("/index.html")) {
            if (permittedScreens != null && !permittedScreens.isEmpty()) {
                response.sendRedirect(contextPath + permittedScreens.get(0).getPath());
            } else {
                response.sendRedirect(contextPath + "/dashboard");
            }
            return false;
        }

        // Check if the current requested page is a registered screen
        List<Screen> allScreens = userService.getAllScreens();
        boolean isRegisteredScreen = allScreens.stream().anyMatch(s -> s.getPath().equalsIgnoreCase(path));

        if (isRegisteredScreen) {
            boolean isPermitted = permittedScreens != null && permittedScreens.stream()
                    .anyMatch(s -> s.getPath().equalsIgnoreCase(path));
            if (!isPermitted) {
                // Not permitted: Redirect to the first permitted screen or access denied
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
}
