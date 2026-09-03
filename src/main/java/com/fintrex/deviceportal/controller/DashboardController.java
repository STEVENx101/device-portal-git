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
    public ResponseEntity<Map<String, Object>> getDashboardStats(
            @RequestParam(value = "product", required = false) String product,
            @RequestParam(value = "month", required = false) String month) {
        return ResponseEntity.ok(dashboardService.getDashboardStats(product, month));
    }

    @GetMapping("/dpd-chart-data")
    public ResponseEntity<List<Map<String, Object>>> getDpdChartData(
            @RequestParam(value = "product", required = false) String product,
            @RequestParam(value = "dimension", defaultValue = "dealer") String dimension) {
        return ResponseEntity.ok(dashboardService.getDpdChartData(product, dimension));
    }

    @GetMapping("/business-chart")
    public ResponseEntity<List<Map<String, Object>>> getMonthWiseBusiness(@RequestParam(value = "product", required = false) String product) {
        return ResponseEntity.ok(dashboardService.getMonthWiseBusiness(product));
    }

    @GetMapping("/dpd-comparison-chart")
    public ResponseEntity<List<Map<String, Object>>> getMonthWiseDpdComparison(@RequestParam(value = "product", required = false) String product) {
        return ResponseEntity.ok(dashboardService.getMonthWiseDpdComparison(product));
    }

    @GetMapping("/vendor-payments-chart")
    public ResponseEntity<List<Map<String, Object>>> getVendorPaymentsChannelChart(
            @RequestParam(value = "product", required = false) String product,
            @RequestParam(value = "month", required = false) String month) {
        return ResponseEntity.ok(dashboardService.getVendorPaymentsChannelChart(product, month));
    }

    @GetMapping("/device-status-charts")
    public ResponseEntity<Map<String, Object>> getDeviceStatusCharts(
            @RequestParam(value = "product", required = false) String product,
            @RequestParam(value = "month", required = false) String month) {
        return ResponseEntity.ok(dashboardService.getDeviceStatusCharts(product, month));
    }

    @GetMapping("/dealer-current-month")
    public ResponseEntity<List<Map<String, Object>>> getDealerCurrentMonthBusiness(
            @RequestParam(value = "product", required = false) String product,
            @RequestParam(value = "month", required = false) String month) {
        return ResponseEntity.ok(dashboardService.getDealerCurrentMonthBusiness(product, month));
    }

    @GetMapping("/dealer-portfolio")
    public ResponseEntity<List<Map<String, Object>>> getDealerPortfolioBusiness(
            @RequestParam(value = "product", required = false) String product,
            @RequestParam(value = "month", required = false) String month) {
        return ResponseEntity.ok(dashboardService.getDealerPortfolioBusiness(product, month));
    }

    @GetMapping("/arrears-analysis")
    public ResponseEntity<List<Map<String, Object>>> getArrearsAnalysis(
            @RequestParam(value = "product", required = false) String product,
            @RequestParam(value = "month", required = false) String month) {
        return ResponseEntity.ok(dashboardService.getArrearsAnalysis(product, month));
    }


    @GetMapping("/collections-dealer-wise")
    public ResponseEntity<List<Map<String, Object>>> getCollectionsDealerWise(
            @RequestParam(value = "product", required = false) String product,
            @RequestParam(value = "startMonth", required = false) String startMonth,
            @RequestParam(value = "endMonth", required = false) String endMonth) {
        return ResponseEntity.ok(dashboardService.getCollectionsDealerWise(product, startMonth, endMonth));
    }

    @GetMapping("/product-business-chart")
    public ResponseEntity<List<Map<String, Object>>> getProductBusinessChart(
            @RequestParam(value = "product", required = false) String product,
            @RequestParam(value = "month", required = false) String month) {
        return ResponseEntity.ok(dashboardService.getProductBusinessChart(product, month));
    }

    @GetMapping("/mobile-lock-arrears")
    public ResponseEntity<Map<String, Object>> getMobileLockArrearsAnalysis() {
        return ResponseEntity.ok(dashboardService.getMobileLockArrearsAnalysis());
    }

    @GetMapping("/matured-nonperforming")
    public ResponseEntity<List<Map<String, Object>>> getMaturedNonPerformingAnalysis(
            @RequestParam(value = "product", required = false) String product,
            @RequestParam(value = "month", required = false) String month) {
        return ResponseEntity.ok(dashboardService.getMaturedNonPerformingAnalysis(product, month));
    }

    @GetMapping("/outstanding-analysis")
    public ResponseEntity<List<Map<String, Object>>> getOutstandingAnalysis(
            @RequestParam(value = "product", required = false) String product,
            @RequestParam(value = "month", required = false) String month) {
        return ResponseEntity.ok(dashboardService.getOutstandingAnalysis(product, month));
    }

    @GetMapping("/transaction-channel-chart")
    public ResponseEntity<List<Map<String, Object>>> getTransactionChannelChart(
            @RequestParam(value = "product", required = false) String product,
            @RequestParam(value = "month", required = false) String month) {
        return ResponseEntity.ok(dashboardService.getTransactionChannelChartData(product, month));
    }

    @GetMapping("/payments-status-chart")
    public ResponseEntity<List<Map<String, Object>>> getPaymentsStatusChart(@RequestParam(value = "product", required = false) String product) {
        return ResponseEntity.ok(dashboardService.getPaymentsStatusChart(product));
    }

    @GetMapping("/sync-info")
    public ResponseEntity<Map<String, Object>> getSyncInfo() {
        return ResponseEntity.ok(dashboardService.getSyncInfo());
    }

    @org.springframework.web.bind.annotation.PostMapping("/sync-now")
    public ResponseEntity<Map<String, Object>> triggerManualSync() {
        dashboardService.triggerManualSync();
        Map<String, Object> res = new java.util.HashMap<>();
        res.put("success", true);
        res.put("message", "Background sync triggered successfully.");
        return ResponseEntity.ok(res);
    }
}
