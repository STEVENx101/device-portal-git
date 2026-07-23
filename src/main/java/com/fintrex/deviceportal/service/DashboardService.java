package com.fintrex.deviceportal.service;

import com.fintrex.deviceportal.repository.DashboardRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Map;

@Service
public class DashboardService {

    private static final long CACHE_TTL_MS = 60_000L; // 1 minute cache TTL

    private final DashboardRepository dashboardRepository;

    private volatile Map<String, Object> cachedSummaryKpis;
    private volatile long summaryKpisLoadedAt = 0L;

    private volatile List<Map<String, Object>> cachedArrearsAnalysis;
    private volatile long arrearsAnalysisLoadedAt = 0L;

    private volatile List<Map<String, Object>> cachedDpdAnalysis;
    private volatile long dpdAnalysisLoadedAt = 0L;

    private volatile Map<String, Object> cachedDealerPerformance;
    private volatile long dealerPerformanceLoadedAt = 0L;

    private volatile Map<String, Object> cachedTopNpl;
    private volatile long topNplLoadedAt = 0L;

    public DashboardService(DashboardRepository dashboardRepository) {
        this.dashboardRepository = dashboardRepository;
    }

    public Map<String, Object> getSummaryKpis() {
        long now = System.currentTimeMillis();
        if (cachedSummaryKpis != null && (now - summaryKpisLoadedAt < CACHE_TTL_MS)) {
            return cachedSummaryKpis;
        }
        synchronized (this) {
            if (cachedSummaryKpis == null || (now - summaryKpisLoadedAt >= CACHE_TTL_MS)) {
                cachedSummaryKpis = dashboardRepository.getSummaryKpis();
                summaryKpisLoadedAt = System.currentTimeMillis();
            }
            return cachedSummaryKpis;
        }
    }

    public List<Map<String, Object>> getArrearsAnalysis() {
        long now = System.currentTimeMillis();
        if (cachedArrearsAnalysis != null && (now - arrearsAnalysisLoadedAt < CACHE_TTL_MS)) {
            return cachedArrearsAnalysis;
        }
        synchronized (this) {
            if (cachedArrearsAnalysis == null || (now - arrearsAnalysisLoadedAt >= CACHE_TTL_MS)) {
                cachedArrearsAnalysis = dashboardRepository.getArrearsAnalysis();
                arrearsAnalysisLoadedAt = System.currentTimeMillis();
            }
            return cachedArrearsAnalysis;
        }
    }

    public List<Map<String, Object>> getDpdAnalysis() {
        long now = System.currentTimeMillis();
        if (cachedDpdAnalysis != null && (now - dpdAnalysisLoadedAt < CACHE_TTL_MS)) {
            return cachedDpdAnalysis;
        }
        synchronized (this) {
            if (cachedDpdAnalysis == null || (now - dpdAnalysisLoadedAt >= CACHE_TTL_MS)) {
                cachedDpdAnalysis = dashboardRepository.getDpdAnalysis();
                dpdAnalysisLoadedAt = System.currentTimeMillis();
            }
            return cachedDpdAnalysis;
        }
    }

    public Map<String, Object> getDealerPerformance() {
        long now = System.currentTimeMillis();
        if (cachedDealerPerformance != null && (now - dealerPerformanceLoadedAt < CACHE_TTL_MS)) {
            return cachedDealerPerformance;
        }
        synchronized (this) {
            if (cachedDealerPerformance == null || (now - dealerPerformanceLoadedAt >= CACHE_TTL_MS)) {
                cachedDealerPerformance = dashboardRepository.getDealerPerformance();
                dealerPerformanceLoadedAt = System.currentTimeMillis();
            }
            return cachedDealerPerformance;
        }
    }

    public Map<String, Object> getTopNplConcentrations() {
        long now = System.currentTimeMillis();
        if (cachedTopNpl != null && (now - topNplLoadedAt < CACHE_TTL_MS)) {
            return cachedTopNpl;
        }
        synchronized (this) {
            if (cachedTopNpl == null || (now - topNplLoadedAt >= CACHE_TTL_MS)) {
                cachedTopNpl = dashboardRepository.getTopNplConcentrations();
                topNplLoadedAt = System.currentTimeMillis();
            }
            return cachedTopNpl;
        }
    }

    public Map<String, Object> getDashboardStats() {
        return dashboardRepository.getDashboardStats();
    }
}

