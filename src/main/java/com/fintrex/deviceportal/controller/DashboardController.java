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
    public ResponseEntity<Map<String, Object>> getDashboardStats(@RequestParam(value = "product", required = false) String product) {
        return ResponseEntity.ok(dashboardService.getDashboardStats(product));
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
    public ResponseEntity<List<Map<String, Object>>> getVendorPaymentsChannelChart(@RequestParam(value = "product", required = false) String product) {
        return ResponseEntity.ok(dashboardService.getVendorPaymentsChannelChart(product));
    }

    @GetMapping("/device-status-charts")
    public ResponseEntity<Map<String, Object>> getDeviceStatusCharts(@RequestParam(value = "product", required = false) String product) {
        return ResponseEntity.ok(dashboardService.getDeviceStatusCharts(product));
    }

    @GetMapping("/dealer-current-month")
    public ResponseEntity<List<Map<String, Object>>> getDealerCurrentMonthBusiness(@RequestParam(value = "product", required = false) String product) {
        return ResponseEntity.ok(dashboardService.getDealerCurrentMonthBusiness(product));
    }

    @GetMapping("/dealer-portfolio")
    public ResponseEntity<List<Map<String, Object>>> getDealerPortfolioBusiness(@RequestParam(value = "product", required = false) String product) {
        return ResponseEntity.ok(dashboardService.getDealerPortfolioBusiness(product));
    }

    @GetMapping("/arrears-analysis")
    public ResponseEntity<List<Map<String, Object>>> getArrearsAnalysis(@RequestParam(value = "product", required = false) String product) {
        return ResponseEntity.ok(dashboardService.getArrearsAnalysis(product));
    }

    @GetMapping("/highest-npl-model")
    public ResponseEntity<Map<String, Object>> getHighestNplModel(@RequestParam(value = "product", required = false) String product) {
        return ResponseEntity.ok(dashboardService.getHighestNplModel(product));
    }

    @GetMapping("/highest-npl-dealer")
    public ResponseEntity<Map<String, Object>> getHighestNplDealer(@RequestParam(value = "product", required = false) String product) {
        return ResponseEntity.ok(dashboardService.getHighestNplDealer(product));
    }

    @GetMapping("/collections-dealer-wise")
    public ResponseEntity<List<Map<String, Object>>> getCollectionsDealerWise(@RequestParam(value = "product", required = false) String product) {
        return ResponseEntity.ok(dashboardService.getCollectionsDealerWise(product));
    }

    @GetMapping("/product-business-chart")
    public ResponseEntity<List<Map<String, Object>>> getProductBusinessChart(@RequestParam(value = "product", required = false) String product) {
        return ResponseEntity.ok(dashboardService.getProductBusinessChart(product));
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
