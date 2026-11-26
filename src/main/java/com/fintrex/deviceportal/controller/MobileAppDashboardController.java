package com.fintrex.deviceportal.controller;

import com.fintrex.deviceportal.service.MobileAppDashboardService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/mobile-app-dashboard")
public class MobileAppDashboardController {

    private static final Logger log = LoggerFactory.getLogger(MobileAppDashboardController.class);

    private final MobileAppDashboardService mobileAppDashboardService;

    public MobileAppDashboardController(MobileAppDashboardService mobileAppDashboardService) {
        this.mobileAppDashboardService = mobileAppDashboardService;
    }

    @GetMapping("/summary")
    public ResponseEntity<Map<String, Object>> getSummary(
            @RequestParam(value = "fromDate", required = false) String fromDate,
            @RequestParam(value = "toDate", required = false) String toDate,
            @RequestParam(value = "asAt", required = false) String asAt,
            @RequestParam(value = "compareMode", required = false, defaultValue = "DAY") String compareMode) {
        try {
            String effectiveToDate = (toDate != null && !toDate.isBlank()) ? toDate : asAt;
            return ResponseEntity.ok(mobileAppDashboardService.getDashboardSummary(fromDate, effectiveToDate, compareMode));
        } catch (Exception e) {
            log.error("Failed to fetch Mobile App dashboard summary", e);
            Map<String, Object> err = new LinkedHashMap<>();
            err.put("error", true);
            err.put("message", "Unable to query Mobile App database: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(err);
        }
    }
}
