package com.fintrex.deviceportal.controller;

import com.fintrex.deviceportal.service.DashboardService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/dashboard")
public class DashboardController {

    private final DashboardService dashboardService;

    public DashboardController(DashboardService dashboardService) {
        this.dashboardService = dashboardService;
    }

    @GetMapping("/summary-kpis")
    public ResponseEntity<Map<String, Object>> getSummaryKpis() {
        return ResponseEntity.ok(dashboardService.getSummaryKpis());
    }

    @GetMapping("/arrears-analysis")
    public ResponseEntity<List<Map<String, Object>>> getArrearsAnalysis() {
        return ResponseEntity.ok(dashboardService.getArrearsAnalysis());
    }

    @GetMapping("/dpd-analysis")
    public ResponseEntity<List<Map<String, Object>>> getDpdAnalysis() {
        return ResponseEntity.ok(dashboardService.getDpdAnalysis());
    }

    @GetMapping("/dealer-performance")
    public ResponseEntity<Map<String, Object>> getDealerPerformance() {
        return ResponseEntity.ok(dashboardService.getDealerPerformance());
    }

    @GetMapping("/top-npl")
    public ResponseEntity<Map<String, Object>> getTopNplConcentrations() {
        return ResponseEntity.ok(dashboardService.getTopNplConcentrations());
    }

    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getDashboardStats() {
        return ResponseEntity.ok(dashboardService.getDashboardStats());
    }
}

