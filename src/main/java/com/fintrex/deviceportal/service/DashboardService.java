package com.fintrex.deviceportal.service;

import com.fintrex.deviceportal.repository.DashboardRepository;
import org.springframework.stereotype.Service;
import java.util.Map;
import java.util.List;

@Service
public class DashboardService {

    private final DashboardRepository dashboardRepository;

    public DashboardService(DashboardRepository dashboardRepository) {
        this.dashboardRepository = dashboardRepository;
    }

    public Map<String, Object> getDashboardStats() {
        return dashboardRepository.getDashboardStats();
    }

    public List<Map<String, Object>> getDpdChartData(String dimension) {
        return dashboardRepository.getDpdChartData(dimension);
    }

    public List<Map<String, Object>> getMonthWiseBusiness() {
        return dashboardRepository.getMonthWiseBusiness();
    }

    public List<Map<String, Object>> getMonthWiseDpdComparison() {
        return dashboardRepository.getMonthWiseDpdComparison();
    }
}

