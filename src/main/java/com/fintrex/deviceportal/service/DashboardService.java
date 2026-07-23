package com.fintrex.deviceportal.service;

import com.fintrex.deviceportal.repository.DashboardRepository;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Map;

@Service
public class DashboardService {

    private final DashboardRepository dashboardRepository;

    public DashboardService(DashboardRepository dashboardRepository) {
        this.dashboardRepository = dashboardRepository;
    }

    public Map<String, Object> getSummaryKpis() {
        return dashboardRepository.getSummaryKpis();
    }

    public List<Map<String, Object>> getArrearsAnalysis() {
        return dashboardRepository.getArrearsAnalysis();
    }

    public List<Map<String, Object>> getDpdAnalysis() {
        return dashboardRepository.getDpdAnalysis();
    }

    public Map<String, Object> getDealerPerformance() {
        return dashboardRepository.getDealerPerformance();
    }

    public Map<String, Object> getTopNplConcentrations() {
        return dashboardRepository.getTopNplConcentrations();
    }

    public Map<String, Object> getDashboardStats() {
        return dashboardRepository.getDashboardStats();
    }
}

