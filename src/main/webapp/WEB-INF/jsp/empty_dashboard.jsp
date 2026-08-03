<%@page contentType="text/html" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en-US" dir="ltr">

    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title>Fintrex | Device Finance Analytics Dashboard</title>

        <link rel="apple-touch-icon" sizes="180x180" href="${pageContext.request.contextPath}/assets/img/favicons/apple-touch-icon.png">
        <link rel="icon" type="image/png" sizes="32x32" href="${pageContext.request.contextPath}/assets/img/favicons/favicon-32x32.png">
        <link rel="icon" type="image/png" sizes="16x16" href="${pageContext.request.contextPath}/assets/img/favicons/favicon-16x16.png">
        <link rel="shortcut icon" type="image/x-icon" href="${pageContext.request.contextPath}/assets/img/favicons/favicon.ico">
        <link rel="manifest" href="${pageContext.request.contextPath}/assets/img/favicons/manifest.json">
        <meta name="msapplication-TileImage" content="${pageContext.request.contextPath}/assets/img/favicons/mstile-150x150.png">
        <meta name="theme-color" content="#ffffff">
        <script src="${pageContext.request.contextPath}/assets/js/config.js"></script>
        <script src="${pageContext.request.contextPath}/vendors/simplebar/simplebar.min.js"></script>

        <link rel="preconnect" href="https://fonts.gstatic.com/">
        <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=Poppins:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/vendors/simplebar/simplebar.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/theme-rtl.min.css" rel="stylesheet" id="style-rtl">
        <link href="${pageContext.request.contextPath}/assets/css/theme.min.css" rel="stylesheet" id="style-default">
        <link href="${pageContext.request.contextPath}/assets/css/user-rtl.min.css" rel="stylesheet" id="user-style-rtl">
        <link href="${pageContext.request.contextPath}/assets/css/user.min.css" rel="stylesheet" id="user-style-default">
        
        <!-- Chart.js and Datalabels for premium analytics rendering -->
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2"></script>
        <script>
            const isDark = document.documentElement.classList.contains('dark');
            Chart.defaults.font.family = "'Plus Jakarta Sans', 'Poppins', sans-serif";
            Chart.defaults.font.weight = '600';
            Chart.defaults.color = isDark ? "#94a3b8" : "#475569";

            // Register ChartDataLabels globally
            Chart.register(ChartDataLabels);
            
            // Set global datalabels default values to display directly on charts
            Chart.defaults.plugins.datalabels.color = isDark ? "#f8fafc" : "#1e293b";
            Chart.defaults.plugins.datalabels.display = true;
            Chart.defaults.plugins.datalabels.anchor = 'end';
            Chart.defaults.plugins.datalabels.align = 'end';
            Chart.defaults.plugins.datalabels.offset = 4;
            Chart.defaults.plugins.datalabels.font = {
                family: "'Plus Jakarta Sans', sans-serif",
                weight: 'bold',
                size: 9
            };
        </script>

        <script>
            var linkRTL = document.getElementById('style-rtl');
            var userLinkRTL = document.getElementById('user-style-rtl');
            linkRTL.setAttribute('disabled', true);
            userLinkRTL.setAttribute('disabled', true);
        </script>

        <style>
            .kpi-card {
                transition: transform 0.2s, box-shadow 0.2s;
                border: 1px solid rgba(226, 232, 240, 0.8) !important;
                background: #ffffff !important;
            }
            html.dark .kpi-card {
                background: rgba(15, 23, 42, 0.6) !important;
                border: 1px solid rgba(255, 255, 255, 0.08) !important;
            }
            .kpi-card:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 20px rgba(99, 102, 241, 0.12) !important;
            }
            .card-title-sub {
                font-size: 0.65rem;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 0.05em;
            }
            .card-value {
                font-size: 1.15rem;
                font-weight: 800;
                margin-top: 0.2rem;
            }
            .card-detail-text {
                font-size: 0.65rem;
                font-weight: 600;
                margin-top: 0.1rem;
            }
            .chart-container {
                position: relative;
                width: 100%;
            }
            .dashboard-content {
                overflow-y: auto !important;
                overflow-x: hidden !important;
                height: auto !important;
                max-height: none !important;
                padding: 10px !important;
                padding-bottom: 60px !important;
            }
            .card {
                border-radius: 8px !important;
                border: 1px solid rgba(226, 232, 240, 0.8) !important;
            }
            html.dark .card {
                background: rgba(15, 23, 42, 0.6) !important;
                border: 1px solid rgba(255, 255, 255, 0.08) !important;
            }
            .card-header {
                background: transparent !important;
                border-bottom: 1px solid rgba(99, 102, 241, 0.12) !important;
                padding: 6px 12px !important;
            }
            .npl-highlight-card {
                border-radius: 8px !important;
                padding: 10px 14px !important;
            }
            .highlight-label {
                font-size: 0.62rem;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 0.05em;
            }
            .highlight-name {
                font-size: 0.95rem;
                font-weight: 800;
                margin: 2px 0;
            }
            .highlight-stat {
                font-size: 0.65rem;
                font-weight: 600;
            }
            .section-title {
                font-family: 'Plus Jakarta Sans', sans-serif;
                font-size: 0.72rem;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 0.08em;
                color: #6366f1;
                margin-bottom: 6px;
                display: flex;
                align-items: center;
                gap: 6px;
            }
            html.dark .section-title {
                color: #f59e0b;
            }
            .section-title::after {
                content: '';
                flex: 1;
                height: 1px;
                background: linear-gradient(90deg, rgba(99, 102, 241, 0.2), transparent);
            }
        </style>
    </head>

    <body>
        <main class="main" id="top">
            <div class="container-fluid" data-layout="container">
                <script>
                    var container = document.querySelector('[data-layout]');
                    if (container) {
                        container.classList.remove('container');
                        container.classList.add('container-fluid');
                    }
                </script>
                <%@include file="../jspf/navbar.jspf" %>

                <div class="content dashboard-content">
                    <%@include file="../jspf/topbar.jspf" %>

                    <!-- Header Area -->
                    <div class="d-flex align-items-center justify-content-between mb-2 pb-1 border-bottom">
                        <div class="d-flex align-items-center gap-3">
                            <h4 class="mb-0 text-primary fw-bold" style="font-size: 1.25rem;"><i class="fas fa-chart-line me-2"></i>Device Finance Analytics Dashboard</h4>
                            <span class="badge bg-soft-primary text-primary fw-semi-bold">Fintrex Snapshot</span>
                            <span class="badge bg-soft-success text-success fw-semi-bold"><i class="fas fa-calendar-alt me-1"></i>Current Month</span>
                        </div>
                        <div class="text-muted fs--2 fw-semi-bold">
                            Only tracked active device contracts
                        </div>
                    </div>

                    <!-- Row 1: KPI Cards (6 Cards) -->
                    <div class="row g-2 mb-2">
                        <!-- Current Month Business -->
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <div class="card kpi-card shadow-sm h-100" style="border-left: 4px solid #6366f1 !important;">
                                <div class="card-body p-2 d-flex flex-column justify-content-between">
                                    <div>
                                        <span class="card-title-sub text-muted">MONTH DISBURSEMENT</span>
                                        <div class="card-value text-primary" id="kpi-month-amount">LKR 0.00 Mn</div>
                                        <div class="card-detail-text text-muted" id="kpi-month-count">0 Accounts</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!-- Active Loans -->
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <div class="card kpi-card shadow-sm h-100" style="border-left: 4px solid #10b981 !important;">
                                <div class="card-body p-2 d-flex flex-column justify-content-between">
                                    <div>
                                        <span class="card-title-sub text-muted">ACTIVE PORTFOLIO</span>
                                        <div class="card-value text-success" id="kpi-portfolio-amount">LKR 0.00 Mn</div>
                                        <div class="card-detail-text text-muted" id="kpi-portfolio-count">0 Accounts</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!-- NPL Card -->
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <div class="card kpi-card shadow-sm h-100" style="border-left: 4px solid #ef4444 !important;">
                                <div class="card-body p-2 d-flex flex-column justify-content-between">
                                    <div>
                                        <span class="card-title-sub text-muted">NPL EXPOSURE</span>
                                        <div class="card-value text-danger" id="kpi-npl-exposure">LKR 0.00 Mn</div>
                                        <div class="card-detail-text text-muted" id="kpi-npl-count">0 Accounts</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!-- Arrears -->
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <div class="card kpi-card shadow-sm h-100" style="border-left: 4px solid #f59e0b !important;">
                                <div class="card-body p-2 d-flex flex-column justify-content-between">
                                    <div>
                                        <span class="card-title-sub text-muted">TOTAL ARREARS</span>
                                        <div class="card-value text-warning" id="kpi-arrears-amount">LKR 0.00 Mn</div>
                                        <div class="card-detail-text text-muted" id="kpi-arrears-count">0 Accounts</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!-- Collections Active -->
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <div class="card kpi-card shadow-sm h-100" style="border-left: 4px solid #3b82f6 !important;">
                                <div class="card-body p-2 d-flex flex-column justify-content-between">
                                    <div>
                                        <span class="card-title-sub text-muted">COLLECTIONS ACTIVE</span>
                                        <div class="card-value text-info" id="top-collection-amount">LKR 0.00</div>
                                        <div class="card-detail-text text-muted" id="top-collection-channel">Loading...</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!-- YTD summary -->
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <div class="card kpi-card shadow-sm h-100" style="border-left: 4px solid #8b5cf6 !important;">
                                <div class="card-body p-2 d-flex flex-column justify-content-between">
                                    <div>
                                        <span class="card-title-sub text-muted">YTD FINANCE ACCOUNTS</span>
                                        <div class="card-value text-secondary" id="kpi-ytd-count-val" style="font-size: 1.0rem;">0 Accounts</div>
                                        <div class="card-detail-text text-muted" id="kpi-active-count-val">0 Active contracts</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Row 2: Trend Chart and NPL model/dealer details side-by-side -->
                    <div class="row g-2 mb-2">
                        <!-- Left: Monthly trend charts (2/3 width) -->
                        <div class="col-lg-8 col-md-7">
                            <div class="card shadow-sm h-100">
                                <div class="card-header bg-light py-1 d-flex justify-content-between align-items-center">
                                    <span class="fw-bold fs--1 text-primary"><i class="fas fa-chart-line me-1"></i>Month-Wise Disbursements & DPD Status</span>
                                </div>
                                <div class="card-body p-2">
                                    <div class="row g-2">
                                        <div class="col-6">
                                            <div style="height: 180px; position: relative; width: 100%;">
                                                <canvas id="businessChart"></canvas>
                                            </div>
                                        </div>
                                        <div class="col-6">
                                            <div style="height: 180px; position: relative; width: 100%;">
                                                <canvas id="dpdComparisonChart"></canvas>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Right: Highest NPL Model and Dealer (1/3 width) -->
                        <div class="col-lg-4 col-md-5">
                            <div class="d-flex flex-column gap-2 h-100">
                                <!-- Highest NPL Model -->
                                <div class="card shadow-sm flex-fill" style="border-left: 4px solid #ef4444 !important;">
                                    <div class="card-body p-2">
                                        <span class="card-title-sub text-muted">HIGHEST NPL MODEL</span>
                                        <div class="card-value text-danger mt-1" id="npl-model-name" style="font-size: 1.1rem;">Loading...</div>
                                        <div class="card-detail-text text-muted" id="npl-model-count">0 Accounts</div>
                                    </div>
                                </div>
                                <!-- Highest NPL Dealer -->
                                <div class="card shadow-sm flex-fill" style="border-left: 4px solid #f59e0b !important;">
                                    <div class="card-body p-2">
                                        <span class="card-title-sub text-muted">HIGHEST NPL DEALER</span>
                                        <div class="card-value text-warning mt-1" id="npl-dealer-name" style="font-size: 1.1rem;">Loading...</div>
                                        <div class="card-detail-text text-muted" id="npl-dealer-count">0 Accounts</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Row 3: Device status & lock doughnuts (Performing & Lock status) -->
                    <div class="row g-2 mb-2">
                        <div class="col-12">
                            <div class="card shadow-sm">
                                <div class="card-header bg-light py-1">
                                    <span class="fw-bold fs--1 text-primary"><i class="fas fa-hdd me-1"></i>Device Performing & Security Status</span>
                                </div>
                                <div class="card-body p-2">
                                    <div class="row g-1 align-items-center text-center">
                                        <div class="col-3">
                                            <div class="fs--2 fw-semi-bold text-muted mb-1">Mobiles Performing</div>
                                            <div style="height: 120px; position: relative; width: 100%;">
                                                <canvas id="mobilePerformingChart"></canvas>
                                            </div>
                                        </div>
                                        <div class="col-3">
                                            <div class="fs--2 fw-semi-bold text-muted mb-1">Mobiles Lock</div>
                                            <div style="height: 120px; position: relative; width: 100%;">
                                                <canvas id="mobileLockChart"></canvas>
                                            </div>
                                        </div>
                                        <div class="col-3">
                                            <div class="fs--2 fw-semi-bold text-muted mb-1">Laptops Performing</div>
                                            <div style="height: 120px; position: relative; width: 100%;">
                                                <canvas id="laptopPerformingChart"></canvas>
                                            </div>
                                        </div>
                                        <div class="col-3">
                                            <div class="fs--2 fw-semi-bold text-muted mb-1">Laptops Lock</div>
                                            <div style="height: 120px; position: relative; width: 100%;">
                                                <canvas id="laptopLockChart"></canvas>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="text-center fs--2 text-muted mt-2 border-top pt-1">
                                        Device locks summary &bull; Active: <span id="sec-mobile-locked-val" class="fw-bold text-danger">0</span> Mobiles &bull; <span id="sec-laptop-locked-val" class="fw-bold text-danger">0</span> Laptops
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Row 4: Collections & Payments (Side-by-Side Horizontal Bars) -->
                    <div class="row g-2">
                        <div class="col-lg-6">
                            <div class="card shadow-sm">
                                <div class="card-header bg-light py-1">
                                    <span class="fw-bold fs--1 text-primary"><i class="fas fa-hand-holding-usd me-1"></i>Collections Dealer Wise (Current Month)</span>
                                </div>
                                <div class="card-body p-2">
                                    <div style="height: 140px; position: relative; width: 100%;">
                                        <canvas id="collectionsDealerChart"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <div class="card shadow-sm">
                                <div class="card-header bg-light py-1">
                                    <span class="fw-bold fs--1 text-primary"><i class="fas fa-money-check-alt me-1"></i>Vendor Payments Channel-Wise (Current Month)</span>
                                </div>
                                <div class="card-body p-2">
                                    <div style="height: 140px; position: relative; width: 100%;">
                                        <canvas id="vendorPaymentsChart"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- ======================== SCRIPTS ======================== -->
                    <script>
                        document.addEventListener("DOMContentLoaded", function() {
                            const formatLKR = (val) => {
                                const millions = val / 1000000;
                                return new Intl.NumberFormat('en-LK', {
                                    style: 'currency',
                                    currency: 'LKR',
                                    minimumFractionDigits: 2,
                                    maximumFractionDigits: 2
                                }).format(millions) + " Mn";
                            };

                            const formatNum = (val) => {
                                return new Intl.NumberFormat().format(val);
                            };

                            // Helper: build horizontal bar chart with direct data labels
                            function buildHorizontalBar(canvasId, labels, amounts, gradientStart, gradientEnd, borderColor, isCollected) {
                                const ctx = document.getElementById(canvasId).getContext('2d');
                                new Chart(ctx, {
                                    type: 'bar',
                                    data: {
                                        labels: labels,
                                        datasets: [{
                                            data: amounts,
                                            backgroundColor: function(context) {
                                                const chart = context.chart;
                                                const {ctx: canvasCtx, chartArea} = chart;
                                                if (!chartArea) return gradientEnd;
                                                const gradient = canvasCtx.createLinearGradient(chartArea.left, 0, chartArea.right, 0);
                                                gradient.addColorStop(0, gradientStart);
                                                gradient.addColorStop(1, gradientEnd);
                                                return gradient;
                                            },
                                            borderColor: borderColor,
                                            borderWidth: 1.5,
                                            borderRadius: { topRight: 4, bottomRight: 4, topLeft: 0, bottomLeft: 0 },
                                            barThickness: 12
                                        }]
                                    },
                                    options: {
                                        indexAxis: 'y',
                                        responsive: true,
                                        maintainAspectRatio: false,
                                        layout: {
                                            padding: { right: 40 }
                                        },
                                        plugins: {
                                            legend: { display: false },
                                            tooltip: { enabled: true },
                                            datalabels: {
                                                display: true,
                                                anchor: 'end',
                                                align: 'end',
                                                color: isDark ? '#cbd5e1' : '#1e293b',
                                                font: { weight: 'bold', size: 9 },
                                                formatter: (val) => formatLKR(val)
                                            }
                                        },
                                        scales: {
                                            x: {
                                                grid: { display: false },
                                                ticks: { display: false }
                                            },
                                            y: {
                                                grid: { display: false },
                                                ticks: { color: isDark ? '#94a3b8' : '#475569', font: { size: 9, weight: 'bold' } }
                                            }
                                        }
                                    }
                                });
                            }

                            // ============ 1. Dashboard Stats (KPI Cards) ============
                            fetch('${pageContext.request.contextPath}/api/dashboard/stats')
                                .then(response => {
                                    if (!response.ok) throw new Error("HTTP error " + response.status);
                                    return response.json();
                                })
                                .then(data => {
                                    // Primary KPIs
                                    document.getElementById("kpi-month-count").innerText = formatNum(data.nMonthCount) + " Accounts";
                                    document.getElementById("kpi-month-amount").innerText = formatLKR(data.nMonthAmount);
                                    
                                    document.getElementById("kpi-portfolio-amount").innerText = formatLKR(data.nPortfolioAmount);
                                    document.getElementById("kpi-portfolio-count").innerText = formatNum(data.nPortfolioCount) + " Accounts";
                                    
                                    document.getElementById("kpi-npl-exposure").innerText = formatLKR(data.nNplExposure);
                                    document.getElementById("kpi-npl-count").innerText = formatNum(data.nNplCount) + " Accounts";
                                    
                                    document.getElementById("kpi-arrears-amount").innerText = formatLKR(data.arrearsAmount);
                                    document.getElementById("kpi-arrears-count").innerText = formatNum(data.arrearsCount) + " Accounts";
                                    
                                    // Highlights / Analytics Row
                                    document.getElementById("kpi-ytd-count-val").innerText = formatNum(data.nYtdCount) + " Accounts";
                                    document.getElementById("kpi-active-count-val").innerText = formatNum(data.activeCount) + " Active contracts";
                                })
                                .catch(err => console.error("Error fetching dashboard statistics:", err));

                            // ============ 2. Month Wise Business Chart ============
                            fetch('${pageContext.request.contextPath}/api/dashboard/business-chart')
                                .then(res => res.json())
                                .then(data => {
                                    const labels = data.map(item => item.month_name);
                                    const amounts = data.map(item => Math.round((item.business_amount / 1000000) * 100) / 100);

                                    const ctx = document.getElementById('businessChart').getContext('2d');
                                    new Chart(ctx, {
                                        type: 'bar',
                                        data: {
                                            labels: labels,
                                            datasets: [{
                                                data: amounts,
                                                backgroundColor: isDark ? 'rgba(139, 92, 246, 0.85)' : 'rgba(99, 102, 241, 0.85)',
                                                borderColor: isDark ? '#8b5cf6' : '#6366f1',
                                                borderWidth: 1.5,
                                                borderRadius: { topRight: 4, bottomRight: 4, topLeft: 0, bottomLeft: 0 },
                                                barThickness: 12
                                            }]
                                        },
                                        options: {
                                            indexAxis: 'y',
                                            responsive: true,
                                            maintainAspectRatio: false,
                                            layout: { padding: { right: 30 } },
                                            plugins: {
                                                legend: { display: false },
                                                datalabels: {
                                                    display: true,
                                                    anchor: 'end',
                                                    align: 'end',
                                                    formatter: (val) => val.toFixed(1) + 'M'
                                                }
                                            },
                                            scales: {
                                                x: { grid: { display: false }, ticks: { display: false } },
                                                y: { grid: { display: false }, ticks: { color: isDark ? '#94a3b8' : '#475569', font: { size: 9, weight: 'bold' } } }
                                            }
                                        }
                                    });
                                })
                                .catch(err => console.error("Error loading business chart:", err));

                            // ============ 3. DPD Comparison Month Wise ============
                            fetch('${pageContext.request.contextPath}/api/dashboard/dpd-comparison-chart')
                                .then(res => res.json())
                                .then(data => {
                                    const labels = data.map(item => item.month_name);
                                    const dpdAbove90 = data.map(item => Math.round((item.dpdAbove90_val / 1000000) * 100) / 100);

                                    const ctx = document.getElementById('dpdComparisonChart').getContext('2d');
                                    new Chart(ctx, {
                                        type: 'bar',
                                        data: {
                                            labels: labels,
                                            datasets: [{
                                                label: 'Over 90 DPD',
                                                data: dpdAbove90,
                                                backgroundColor: 'rgba(239, 68, 68, 0.85)',
                                                borderColor: '#ef4444',
                                                borderWidth: 1.5,
                                                borderRadius: { topRight: 4, bottomRight: 4, topLeft: 0, bottomLeft: 0 },
                                                barThickness: 12
                                            }]
                                        },
                                        options: {
                                            indexAxis: 'y',
                                            responsive: true,
                                            maintainAspectRatio: false,
                                            layout: { padding: { right: 30 } },
                                            plugins: {
                                                legend: { display: false },
                                                datalabels: {
                                                    display: true,
                                                    anchor: 'end',
                                                    align: 'end',
                                                    formatter: (val) => val.toFixed(1) + 'M'
                                                }
                                            },
                                            scales: {
                                                x: { grid: { display: false }, ticks: { display: false } },
                                                y: { grid: { display: false }, ticks: { color: isDark ? '#94a3b8' : '#475569', font: { size: 9, weight: 'bold' } } }
                                            }
                                        }
                                    });
                                })
                                .catch(err => console.error("Error loading DPD comparison chart:", err));

                            // ============ 4. Device Status Charts ============
                            fetch('${pageContext.request.contextPath}/api/dashboard/device-status-charts')
                                .then(res => res.json())
                                .then(data => {
                                    function buildDoughnut(canvasId, dataset, labelsList, colorsList) {
                                        const labels = dataset.map(item => item.state_name);
                                        const counts = dataset.map(item => item.count_val);
                                        
                                        const centerTextPlugin = {
                                            id: 'centerTextPlugin',
                                            beforeDraw: function(chart) {
                                                const width = chart.width, height = chart.height, ctx = chart.ctx;
                                                ctx.restore();
                                                const total = chart.data.datasets[0].data.reduce((a, b) => a + b, 0);
                                                const fontSize = (chart.innerRadius / 26).toFixed(2);
                                                ctx.font = "bold " + fontSize + "em 'Plus Jakarta Sans', sans-serif";
                                                ctx.textBaseline = "middle";
                                                ctx.fillStyle = isDark ? "#f8fafc" : "#1e293b";
                                                const text = total.toLocaleString(),
                                                      textX = Math.round((width - ctx.measureText(text).width) / 2),
                                                      textY = chart.chartArea.top + (chart.chartArea.bottom - chart.chartArea.top) / 2;
                                                ctx.fillText(text, textX, textY);
                                                ctx.save();
                                            }
                                        };

                                        const ctx = document.getElementById(canvasId).getContext('2d');
                                        new Chart(ctx, {
                                            type: 'doughnut',
                                            data: {
                                                labels: labels.length ? labels : labelsList,
                                                datasets: [{
                                                    data: counts.length ? counts : [0, 0],
                                                    backgroundColor: colorsList,
                                                    borderColor: isDark ? 'rgba(15, 23, 42, 0.95)' : '#ffffff',
                                                    borderWidth: 2,
                                                    hoverOffset: 3,
                                                    spacing: 2
                                                }]
                                            },
                                            plugins: [centerTextPlugin],
                                            options: {
                                                responsive: true,
                                                maintainAspectRatio: false,
                                                cutout: '72%',
                                                plugins: {
                                                    legend: { display: false },
                                                    datalabels: {
                                                        display: true,
                                                        color: '#ffffff',
                                                        font: { weight: 'bold', size: 9 },
                                                        formatter: (value, ctx) => {
                                                            let sum = ctx.chart.data.datasets[0].data.reduce((a, b) => a + b, 0);
                                                            if (sum === 0) return '';
                                                            let percentage = (value * 100 / sum).toFixed(0);
                                                            return percentage > 0 ? percentage + "%" : '';
                                                        },
                                                        anchor: 'center',
                                                        align: 'center'
                                                    }
                                                }
                                            }
                                        });
                                    }

                                    buildDoughnut('mobilePerformingChart', data.mobilePerforming, ['Performing', 'Non-Performing'], ['rgba(16, 185, 129, 0.85)', 'rgba(244, 63, 94, 0.85)']);
                                    buildDoughnut('mobileLockChart', data.mobileLock, ['Active', 'Locked'], ['rgba(99, 102, 241, 0.85)', 'rgba(245, 158, 11, 0.85)']);
                                    buildDoughnut('laptopPerformingChart', data.laptopPerforming, ['Performing', 'Non-Performing'], ['rgba(16, 185, 129, 0.85)', 'rgba(244, 63, 94, 0.85)']);
                                    buildDoughnut('laptopLockChart', data.laptopLock, ['Active', 'Locked'], ['rgba(99, 102, 241, 0.85)', 'rgba(245, 158, 11, 0.85)']);

                                    let mobileLocked = 0, mobileUnlocked = 0;
                                    if (data.mobileLock) {
                                        data.mobileLock.forEach(item => {
                                            if (item.state_name === 'Locked') mobileLocked = item.count_val;
                                            else mobileUnlocked = item.count_val;
                                        });
                                    }
                                    document.getElementById("sec-mobile-locked-val").innerText = formatNum(mobileLocked);

                                    let laptopLocked = 0, laptopUnlocked = 0;
                                    if (data.laptopLock) {
                                        data.laptopLock.forEach(item => {
                                            if (item.state_name === 'Locked') laptopLocked = item.count_val;
                                            else laptopUnlocked = item.count_val;
                                        });
                                    }
                                    document.getElementById("sec-laptop-locked-val").innerText = formatNum(laptopLocked);
                                })
                                .catch(err => console.error("Error loading device status charts:", err));

                            // ============ 5. Highest NPL Model ============
                            fetch('${pageContext.request.contextPath}/api/dashboard/highest-npl-model')
                                .then(res => res.json())
                                .then(data => {
                                    document.getElementById("npl-model-name").innerText = data.model_name || 'N/A';
                                    document.getElementById("npl-model-count").innerText = formatNum(data.npl_count || 0) + ' Accounts';
                                })
                                .catch(err => console.error("Error loading highest NPL model:", err));

                            // ============ 6. Highest NPL Dealer ============
                            fetch('${pageContext.request.contextPath}/api/dashboard/highest-npl-dealer')
                                .then(res => res.json())
                                .then(data => {
                                    document.getElementById("npl-dealer-name").innerText = data.dealer_name || 'N/A';
                                    document.getElementById("npl-dealer-count").innerText = formatNum(data.npl_count || 0) + ' Accounts';
                                })
                                .catch(err => console.error("Error loading highest NPL dealer:", err));

                            // ============ 7. Vendor Payments ============
                            fetch('${pageContext.request.contextPath}/api/dashboard/vendor-payments-chart')
                                .then(res => res.json())
                                .then(data => {
                                    let chartData = data.length > 5 ? data.slice(0, 5) : data;
                                    chartData.reverse();
                                    buildHorizontalBar(
                                        'vendorPaymentsChart',
                                        chartData.map(item => item.channel_name),
                                        chartData.map(item => item.total_amount),
                                        isDark ? 'rgba(167, 139, 250, 0.15)' : 'rgba(79, 70, 229, 0.15)',
                                        isDark ? 'rgba(167, 139, 250, 0.85)' : 'rgba(79, 70, 229, 0.85)',
                                        isDark ? '#a78bfa' : 'rgba(79, 70, 229, 1)',
                                        false
                                    );
                                })
                                .catch(err => console.error("Error loading vendor payments chart:", err));

                            // ============ 8. Collections Dealer Wise ============
                            fetch('${pageContext.request.contextPath}/api/dashboard/collections-dealer-wise')
                                .then(res => res.json())
                                .then(data => {
                                    if (data && data.length > 0) {
                                        const top = data[0];
                                        document.getElementById("top-collection-channel").innerText = top.dealer_name || 'N/A';
                                        document.getElementById("top-collection-amount").innerText = formatLKR(top.total_collected || 0);
                                    } else {
                                        document.getElementById("top-collection-channel").innerText = 'N/A';
                                        document.getElementById("top-collection-amount").innerText = 'LKR 0.00';
                                    }

                                    let chartData = data.length > 5 ? data.slice(0, 5) : data;
                                    chartData.reverse();
                                    buildHorizontalBar(
                                        'collectionsDealerChart',
                                        chartData.map(i => i.dealer_name),
                                        chartData.map(i => i.total_collected),
                                        isDark ? 'rgba(245, 158, 11, 0.15)' : 'rgba(245, 158, 11, 0.15)',
                                        isDark ? 'rgba(245, 158, 11, 0.85)' : 'rgba(245, 158, 11, 0.85)',
                                        '#f59e0b',
                                        true
                                    );
                                })
                                .catch(err => console.error("Error loading collections dealer wise:", err));
                        });
                    </script>
                </div>
            </div>
        </main>

        <script src="${pageContext.request.contextPath}/vendors/jquery/jquery.min.js"></script>
        <script src="${pageContext.request.contextPath}/vendors/popper/popper.min.js"></script>
        <script src="${pageContext.request.contextPath}/vendors/bootstrap/bootstrap.min.js"></script>
        <script src="${pageContext.request.contextPath}/vendors/anchorjs/anchor.min.js"></script>
        <script src="${pageContext.request.contextPath}/vendors/is/is.min.js"></script>
        <script src="${pageContext.request.contextPath}/vendors/fontawesome/all.min.js"></script>
        <script src="${pageContext.request.contextPath}/vendors/lodash/lodash.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/theme.js"></script>
    </body>
</html>