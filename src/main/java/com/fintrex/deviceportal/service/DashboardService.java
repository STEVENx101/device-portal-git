package com.fintrex.deviceportal.service;

import com.fintrex.deviceportal.repository.DashboardRepository;
import jakarta.annotation.PostConstruct;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.time.ZonedDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.Map;
import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;

@Service
public class DashboardService {

    private final DashboardRepository dashboardRepository;
    private final ConcurrentHashMap<String, Object> cache = new ConcurrentHashMap<>();
    private final AtomicBoolean isSyncing = new AtomicBoolean(false);
    private String lastSyncedTime = ZonedDateTime.now(ZoneId.of("Asia/Colombo")).format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

    public DashboardService(DashboardRepository dashboardRepository) {
        this.dashboardRepository = dashboardRepository;
    }

    @PostConstruct
    public void init() {
        // Trigger initial cache population in a separate background thread on startup to prevent blocking boot
        new Thread(this::refreshCache, "dashboard-cache-warmup-thread").start();
    }

    // Refresh dashboard snapshot data cache (scheduled to run every 30 minutes: 1800000 ms)
    @Scheduled(fixedRate = 1800000)
    public void scheduledRefresh() {
        if (!isSyncing.get()) {
            refreshCache();
        }
    }

    public synchronized void refreshCache() {
        if (isSyncing.getAndSet(true)) {
            return;
        }
        try {
            System.out.println("WARMING UP/REFRESHING DASHBOARD SNAPSHOT STORE DATA...");

            String[] products = { "MF", "LF" };
            for (String product : products) {
                String suffix = "_" + product.toUpperCase();

                Map<String, Object> stats = dashboardRepository.getDashboardStats(product);
                cache.put("stats" + suffix, stats != null ? stats : new HashMap<>());

                List<Map<String, Object>> biz = dashboardRepository.getMonthWiseBusiness(product);
                cache.put("business" + suffix, biz != null ? biz : new ArrayList<>());

                List<Map<String, Object>> dpd = dashboardRepository.getMonthWiseDpdComparison(product);
                cache.put("dpdComparison" + suffix, dpd != null ? dpd : new ArrayList<>());

                Map<String, Object> status = dashboardRepository.getDeviceStatusCharts(product);
                cache.put("deviceStatus" + suffix, status != null ? status : new HashMap<>());


                 List<Map<String, Object>> payments = dashboardRepository.getVendorPaymentsChannelChart(product);
                cache.put("vendorPayments" + suffix, payments != null ? payments : new ArrayList<>());

                List<Map<String, Object>> coll = dashboardRepository.getCollectionsDealerWise(product);
                cache.put("collections" + suffix, coll != null ? coll : new ArrayList<>());

                List<Map<String, Object>> prodBiz = dashboardRepository.getProductBusinessChart(product);
                cache.put("productBusiness" + suffix, prodBiz != null ? prodBiz : new ArrayList<>());

                // New analysis cache
                List<Map<String, Object>> maturedNp = dashboardRepository.getMaturedNonPerformingAnalysis(product);
                cache.put("maturedNp" + suffix, maturedNp != null ? maturedNp : new ArrayList<>());

                List<Map<String, Object>> outstanding = dashboardRepository.getOutstandingAnalysis(product);
                cache.put("outstanding" + suffix, outstanding != null ? outstanding : new ArrayList<>());

                List<Map<String, Object>> txnChannel = dashboardRepository.getTransactionChannelChartData(product);
                cache.put("txnChannel" + suffix, txnChannel != null ? txnChannel : new ArrayList<>());

                List<Map<String, Object>> pmtsStatus = dashboardRepository.getPaymentsStatusChart(product);
                cache.put("paymentsStatus" + suffix, pmtsStatus != null ? pmtsStatus : new ArrayList<>());
            }

            // Mobile lock arrears is specific to MF, but cached standalone or with suffix
            Map<String, Object> mobileLockArrears = dashboardRepository.getMobileLockArrearsAnalysis();
            cache.put("mobileLockArrears", mobileLockArrears != null ? mobileLockArrears : new HashMap<>());

            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
            lastSyncedTime = ZonedDateTime.now(ZoneId.of("Asia/Colombo")).format(formatter);
            System.out.println("DASHBOARD SNAPSHOT STORE DATA SUCCESSFULLY SYNCED AT: " + lastSyncedTime);
        } catch (Exception e) {
            System.err.println("Error while updating dashboard cache store: " + e.getMessage());
            e.printStackTrace();
        } finally {
            isSyncing.set(false);
        }
    }

    public void triggerManualSync() {
        if (!isSyncing.get()) {
            new Thread(this::refreshCache, "dashboard-manual-sync-thread").start();
        }
    }

    public Map<String, Object> getSyncInfo() {
        Map<String, Object> info = new HashMap<>();
        info.put("lastSynced", lastSyncedTime);
        info.put("isSyncing", isSyncing.get());
        return info;
    }

    private String getSuffix(String product) {
        if (product == null || product.trim().isEmpty()) {
            return "_MF"; // Default fallback to MF as requested
        }
        return "_" + product.toUpperCase();
    }

    @SuppressWarnings("unchecked")
    public Map<String, Object> getDashboardStats(String product) {
        String suffix = getSuffix(product);
        return (Map<String, Object>) cache.computeIfAbsent("stats" + suffix, k -> dashboardRepository.getDashboardStats(product));
    }

    public List<Map<String, Object>> getDpdChartData(String product, String dimension) {
        return dashboardRepository.getDpdChartData(product, dimension);
    }

    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> getMonthWiseBusiness(String product) {
        String suffix = getSuffix(product);
        return (List<Map<String, Object>>) cache.computeIfAbsent("business" + suffix, k -> dashboardRepository.getMonthWiseBusiness(product));
    }

    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> getMonthWiseDpdComparison(String product) {
        String suffix = getSuffix(product);
        return (List<Map<String, Object>>) cache.computeIfAbsent("dpdComparison" + suffix, k -> dashboardRepository.getMonthWiseDpdComparison(product));
    }

    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> getVendorPaymentsChannelChart(String product) {
        String suffix = getSuffix(product);
        return (List<Map<String, Object>>) cache.computeIfAbsent("vendorPayments" + suffix, k -> dashboardRepository.getVendorPaymentsChannelChart(product));
    }

    @SuppressWarnings("unchecked")
    public Map<String, Object> getDeviceStatusCharts(String product) {
        String suffix = getSuffix(product);
        return (Map<String, Object>) cache.computeIfAbsent("deviceStatus" + suffix, k -> dashboardRepository.getDeviceStatusCharts(product));
    }

    public List<Map<String, Object>> getDealerCurrentMonthBusiness(String product) {
        return dashboardRepository.getDealerCurrentMonthBusiness(product);
    }

    public List<Map<String, Object>> getDealerPortfolioBusiness(String product) {
        return dashboardRepository.getDealerPortfolioBusiness(product);
    }

    public List<Map<String, Object>> getArrearsAnalysis(String product) {
        return dashboardRepository.getArrearsAnalysis(product);
    }

    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> getCollectionsDealerWise(String product) {
        return getCollectionsDealerWise(product, null, null);
    }

    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> getCollectionsDealerWise(String product, String startMonth, String endMonth) {
        if ((startMonth != null && !startMonth.trim().isEmpty()) || (endMonth != null && !endMonth.trim().isEmpty())) {
            return dashboardRepository.getCollectionsDealerWise(product, startMonth, endMonth);
        }
        String suffix = getSuffix(product);
        return (List<Map<String, Object>>) cache.computeIfAbsent("collections" + suffix, k -> dashboardRepository.getCollectionsDealerWise(product, null, null));
    }

    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> getProductBusinessChart(String product) {
        String suffix = getSuffix(product);
        return (List<Map<String, Object>>) cache.computeIfAbsent("productBusiness" + suffix, k -> dashboardRepository.getProductBusinessChart(product));
    }

    @SuppressWarnings("unchecked")
    public Map<String, Object> getMobileLockArrearsAnalysis() {
        return (Map<String, Object>) cache.computeIfAbsent("mobileLockArrears", k -> dashboardRepository.getMobileLockArrearsAnalysis());
    }

    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> getMaturedNonPerformingAnalysis(String product) {
        String suffix = getSuffix(product);
        return (List<Map<String, Object>>) cache.computeIfAbsent("maturedNp" + suffix, k -> dashboardRepository.getMaturedNonPerformingAnalysis(product));
    }

    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> getOutstandingAnalysis(String product) {
        String suffix = getSuffix(product);
        return (List<Map<String, Object>>) cache.computeIfAbsent("outstanding" + suffix, k -> dashboardRepository.getOutstandingAnalysis(product));
    }

    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> getTransactionChannelChartData(String product) {
        String suffix = getSuffix(product);
        return (List<Map<String, Object>>) cache.computeIfAbsent("txnChannel" + suffix, k -> dashboardRepository.getTransactionChannelChartData(product));
    }

    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> getPaymentsStatusChart(String product) {
        String suffix = getSuffix(product);
        return (List<Map<String, Object>>) cache.computeIfAbsent("paymentsStatus" + suffix, k -> dashboardRepository.getPaymentsStatusChart(product));
    }
}
