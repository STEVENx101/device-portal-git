package com.fintrex.deviceportal.service;

import com.fintrex.deviceportal.repository.DashboardRepository;
import jakarta.annotation.PostConstruct;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
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
    private String lastSyncedTime = "N/A";

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

            Map<String, Object> stats = dashboardRepository.getDashboardStats();
            cache.put("stats", stats != null ? stats : new HashMap<>());

            List<Map<String, Object>> biz = dashboardRepository.getMonthWiseBusiness();
            cache.put("business", biz != null ? biz : new ArrayList<>());

            List<Map<String, Object>> dpd = dashboardRepository.getMonthWiseDpdComparison();
            cache.put("dpdComparison", dpd != null ? dpd : new ArrayList<>());

            Map<String, Object> status = dashboardRepository.getDeviceStatusCharts();
            cache.put("deviceStatus", status != null ? status : new HashMap<>());

            Map<String, Object> nplModel = dashboardRepository.getHighestNplModel();
            cache.put("nplModel", nplModel != null ? nplModel : new HashMap<>());

            Map<String, Object> nplDealer = dashboardRepository.getHighestNplDealer();
            cache.put("nplDealer", nplDealer != null ? nplDealer : new HashMap<>());

            List<Map<String, Object>> payments = dashboardRepository.getVendorPaymentsChannelChart();
            cache.put("vendorPayments", payments != null ? payments : new ArrayList<>());

            List<Map<String, Object>> coll = dashboardRepository.getCollectionsDealerWise();
            cache.put("collections", coll != null ? coll : new ArrayList<>());

            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
            lastSyncedTime = LocalDateTime.now().format(formatter);
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

    @SuppressWarnings("unchecked")
    public Map<String, Object> getDashboardStats() {
        return (Map<String, Object>) cache.computeIfAbsent("stats", k -> dashboardRepository.getDashboardStats());
    }

    public List<Map<String, Object>> getDpdChartData(String dimension) {
        return dashboardRepository.getDpdChartData(dimension);
    }

    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> getMonthWiseBusiness() {
        return (List<Map<String, Object>>) cache.computeIfAbsent("business", k -> dashboardRepository.getMonthWiseBusiness());
    }

    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> getMonthWiseDpdComparison() {
        return (List<Map<String, Object>>) cache.computeIfAbsent("dpdComparison", k -> dashboardRepository.getMonthWiseDpdComparison());
    }

    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> getVendorPaymentsChannelChart() {
        return (List<Map<String, Object>>) cache.computeIfAbsent("vendorPayments", k -> dashboardRepository.getVendorPaymentsChannelChart());
    }

    @SuppressWarnings("unchecked")
    public Map<String, Object> getDeviceStatusCharts() {
        return (Map<String, Object>) cache.computeIfAbsent("deviceStatus", k -> dashboardRepository.getDeviceStatusCharts());
    }

    public List<Map<String, Object>> getDealerCurrentMonthBusiness() {
        return dashboardRepository.getDealerCurrentMonthBusiness();
    }

    public List<Map<String, Object>> getDealerPortfolioBusiness() {
        return dashboardRepository.getDealerPortfolioBusiness();
    }

    public List<Map<String, Object>> getArrearsAnalysis() {
        return dashboardRepository.getArrearsAnalysis();
    }

    @SuppressWarnings("unchecked")
    public Map<String, Object> getHighestNplModel() {
        return (Map<String, Object>) cache.computeIfAbsent("nplModel", k -> dashboardRepository.getHighestNplModel());
    }

    @SuppressWarnings("unchecked")
    public Map<String, Object> getHighestNplDealer() {
        return (Map<String, Object>) cache.computeIfAbsent("nplDealer", k -> dashboardRepository.getHighestNplDealer());
    }

    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> getCollectionsDealerWise() {
        return (List<Map<String, Object>>) cache.computeIfAbsent("collections", k -> dashboardRepository.getCollectionsDealerWise());
    }
}
