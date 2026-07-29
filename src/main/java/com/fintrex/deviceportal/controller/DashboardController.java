package com.fintrex.deviceportal.controller;

import com.fintrex.deviceportal.service.DashboardService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import java.util.Map;
import java.util.List;

@RestController
@RequestMapping("/api/dashboard")
public class DashboardController {

    private final DashboardService dashboardService;

    public DashboardController(DashboardService dashboardService) {
        this.dashboardService = dashboardService;
    }

    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getDashboardStats() {
        return ResponseEntity.ok(dashboardService.getDashboardStats());
    }

    @GetMapping("/dpd-chart-data")
    public ResponseEntity<List<Map<String, Object>>> getDpdChartData(@RequestParam(value = "dimension", defaultValue = "dealer") String dimension) {
        return ResponseEntity.ok(dashboardService.getDpdChartData(dimension));
    }

    @GetMapping("/business-chart")
    public ResponseEntity<List<Map<String, Object>>> getMonthWiseBusiness() {
        return ResponseEntity.ok(dashboardService.getMonthWiseBusiness());
    }

    @GetMapping("/dpd-comparison-chart")
    public ResponseEntity<List<Map<String, Object>>> getMonthWiseDpdComparison() {
        return ResponseEntity.ok(dashboardService.getMonthWiseDpdComparison());
    }

    @GetMapping("/vendor-payments-chart")
    public ResponseEntity<List<Map<String, Object>>> getVendorPaymentsChannelChart() {
        return ResponseEntity.ok(dashboardService.getVendorPaymentsChannelChart());
    }

    @GetMapping("/device-status-charts")
    public ResponseEntity<Map<String, Object>> getDeviceStatusCharts() {
        return ResponseEntity.ok(dashboardService.getDeviceStatusCharts());
    }
}

