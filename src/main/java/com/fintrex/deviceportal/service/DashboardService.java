package com.fintrex.deviceportal.service;

import com.fintrex.deviceportal.repository.DashboardRepository;
import org.springframework.stereotype.Service;
import java.util.Map;

@Service
public class DashboardService {

    private final DashboardRepository dashboardRepository;

    public DashboardService(DashboardRepository dashboardRepository) {
        this.dashboardRepository = dashboardRepository;
    }

    public Map<String, Object> getDashboardStats() {
        return dashboardRepository.getDashboardStats();
    }
}
