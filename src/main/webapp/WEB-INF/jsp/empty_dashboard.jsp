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
        <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
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
            Chart.defaults.font.family = "'Plus Jakarta Sans', sans-serif";
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
            body, .main, p, div, span, select, input, button, textarea, .card-value, .card-detail-text, h4, h3, h5, .fs--1, .fs--2 { 
                font-family: 'Plus Jakarta Sans', sans-serif !important; 
            }
            h1, h2, h3, h4, h5, h6, .fw-bold, .fw-extrabold, .card-title-sub, .section-title, .navbar-brand { 
                font-family: 'Plus Jakarta Sans', sans-serif !important; 
                letter-spacing: -0.02em;
            }
            .kpi-card {
                transition: transform 0.2s, box-shadow 0.2s;
                border: 1px solid rgba(226, 232, 240, 0.6) !important;
                background: #ffffff !important;
                border-radius: 6px !important;
            }
            html.dark .kpi-card {
                background: rgba(15, 23, 42, 0.4) !important;
                border: 1px solid rgba(255, 255, 255, 0.05) !important;
            }
            .kpi-card:hover {
                transform: translateY(-1px);
                box-shadow: 0 4px 12px rgba(99, 102, 241, 0.08) !important;
            }
            .card-title-sub {
                font-size: 0.62rem;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 0.06em;
                color: #64748b !important;
            }
            .card-value {
                font-size: 1.15rem;
                font-weight: 800;
                margin-top: 0.25rem;
                letter-spacing: -0.02em;
            }
            .card-detail-text {
                font-size: 0.62rem;
                font-weight: 600;
                margin-top: 0.15rem;
                color: #94a3b8 !important;
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
                border-radius: 6px !important;
                border: 1px solid rgba(226, 232, 240, 0.6) !important;
            }
            html.dark .card {
                background: rgba(15, 23, 42, 0.4) !important;
                border: 1px solid rgba(255, 255, 255, 0.05) !important;
            }
            .npl-highlight-card {
                border-radius: 6px !important;
                padding: 10px 14px !important;
            }
            .highlight-label {
                font-size: 0.6rem;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 0.05em;
            }
            .highlight-name {
                font-size: 0.9rem;
                font-weight: 800;
                margin: 2px 0;
            }
            .highlight-stat {
                font-size: 0.62rem;
                font-weight: 600;
            }
            .section-title {
                font-family: 'Outfit', sans-serif !important;
                font-size: 0.7rem;
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
                background: linear-gradient(90deg, rgba(99, 102, 241, 0.15), transparent);
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
                            <h4 class="mb-0 text-primary fw-bold" style="font-size: 1.25rem;">Device Finance Analytics Dashboard</h4>
                        </div>
                        <div class="d-flex align-items-center gap-3">
                            <div class="text-muted fs--2 fw-semi-bold" id="sync-time-badge" style="border-right: 1px solid rgba(226, 232, 240, 0.8); padding-right: 10px;">
                                Last Synced: <span class="fw-bold text-dark dark__text-white" id="last-sync-timestamp">Loading...</span>
                            </div>
                            <button class="btn btn-sm btn-primary d-flex align-items-center gap-1 fw-bold" id="btn-sync-now" onclick="triggerManualSync()" style="font-size: 0.68rem; padding: 4px 10px; border-radius: 4px;">
                                <i class="fas fa-sync-alt" id="sync-icon"></i> <span id="sync-btn-text">Sync Now</span>
                            </button>
                        </div>
                    </div>

                    <!-- Row 1: KPI Cards (6 Cards) -->
                    <div class="row g-2 mb-2">
                        <!-- Current Month Business -->
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <div class="card kpi-card shadow-sm h-100" style="border-left: 3px solid #6366f1 !important;">
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
                            <div class="card kpi-card shadow-sm h-100" style="border-left: 3px solid #10b981 !important;">
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
                            <div class="card kpi-card shadow-sm h-100" style="border-left: 3px solid #ef4444 !important;">
                                <div class="card-body p-2 d-flex flex-column justify-content-between">
                                    <div>
                                        <span class="card-title-sub text-muted">NPL EXPOSURE</span>
                                        <div class="card-value text-danger" id="kpi-npl-exposure">LKR 0.00 Mn</div>
                                        <div class="card-detail-text text-muted" id="kpi-npl-count">0 Accounts</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!-- Settled During Month -->
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <div class="card kpi-card shadow-sm h-100" style="border-left: 3px solid #f59e0b !important;">
                                <div class="card-body p-2 d-flex flex-column justify-content-between">
                                    <div>
                                        <span class="card-title-sub text-muted">SETTLED MONTH</span>
                                        <div class="card-value text-warning" id="kpi-settled-amount">LKR 0.00 Mn</div>
                                        <div class="card-detail-text text-muted" id="kpi-settled-count">0 Accounts</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!-- Highest NPL Model -->
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <div class="card kpi-card shadow-sm h-100" style="border-left: 3px solid #ef4444 !important;">
                                <div class="card-body p-2 d-flex flex-column justify-content-between">
                                    <div>
                                        <span class="card-title-sub text-muted">HIGHEST NPL MODEL</span>
                                        <div class="card-value text-danger" id="npl-model-name" style="font-size: 0.85rem;">Loading...</div>
                                        <div class="card-detail-text text-muted" id="npl-model-count">0 Accounts</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!-- Highest NPL Dealer -->
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <div class="card kpi-card shadow-sm h-100" style="border-left: 3px solid #f59e0b !important;">
                                <div class="card-body p-2 d-flex flex-column justify-content-between">
                                    <div>
                                        <span class="card-title-sub text-muted">HIGHEST NPL DEALER</span>
                                        <div class="card-value text-warning" id="npl-dealer-name" style="font-size: 0.85rem;">Loading...</div>
                                        <div class="card-detail-text text-muted" id="npl-dealer-count">0 Accounts</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Row 2: Charts (Month-Wise Disbursements & DPD Status on Left, Product Business Pie on Right) -->
                    <div class="row g-2 mb-2">
                        <!-- Left: Monthly trend charts -->
                        <div class="col-lg-9 col-md-8">
                            <div class="card shadow-sm h-100">
                                <div class="card-body p-3">
                                    <div class="row g-3">
                                        <div class="col-6">
                                            <div class="fs--2 fw-semi-bold text-muted mb-1"><i class="fas fa-chart-line me-1"></i>Month-Wise Disbursements</div>
                                            <div style="height: 200px; position: relative; width: 100%;">
                                                <canvas id="businessChart"></canvas>
                                            </div>
                                        </div>
                                        <div class="col-6">
                                            <div class="fs--2 fw-semi-bold text-muted mb-1"><i class="fas fa-chart-bar me-1"></i>DPD Status (Month-Wise)</div>
                                            <div style="height: 200px; position: relative; width: 100%;">
                                                <canvas id="dpdComparisonChart"></canvas>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Right: Product-Wise Business Distribution Column (Smaller Pie Chart) -->
                        <div class="col-lg-3 col-md-4">
                            <div class="card shadow-sm h-100">
                                <div class="card-body p-3 d-flex flex-column justify-content-between">
                                    <div class="fs--2 fw-semi-bold text-muted mb-2"><i class="fas fa-chart-pie me-1"></i>Product Business (Current Month)</div>
                                    <div style="height: 180px; position: relative; width: 100%;" class="d-flex align-items-center justify-content-center">
                                        <canvas id="productBusinessChart"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Row 3: Device status & lock doughnuts (4 horizontal pie charts) -->
                    <div class="row g-2 mb-2" style="margin-top: 4px;">
                        <div class="col-12">
                            <div class="card shadow-sm">
                                <div class="card-body p-3">
                                    <div class="fs--2 fw-semi-bold text-muted mb-2"><i class="fas fa-hdd me-1"></i>Device Performance & Security Status</div>
                                    <div class="row g-3 align-items-center text-center">
                                        <div class="col-3">
                                            <div class="fs--2 fw-semi-bold text-muted mb-2">Mobiles Performing</div>
                                            <div style="height: 130px; position: relative; width: 100%;">
                                                <canvas id="mobilePerformingChart"></canvas>
                                            </div>
                                        </div>
                                        <div class="col-3">
                                            <div class="fs--2 fw-semi-bold text-muted mb-2">Mobiles Lock</div>
                                            <div style="height: 130px; position: relative; width: 100%;">
                                                <canvas id="mobileLockChart"></canvas>
                                            </div>
                                        </div>
                                        <div class="col-3">
                                            <div class="fs--2 fw-semi-bold text-muted mb-2">Laptops Performing</div>
                                            <div style="height: 130px; position: relative; width: 100%;">
                                                <canvas id="laptopPerformingChart"></canvas>
                                            </div>
                                        </div>
                                        <div class="col-3">
                                            <div class="fs--2 fw-semi-bold text-muted mb-2">Laptops Lock</div>
                                            <div style="height: 130px; position: relative; width: 100%;">
                                                <canvas id="laptopLockChart"></canvas>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="text-center fs--2 text-muted mt-3 border-top pt-2">
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
                                <div class="card-body p-3">
                                    <div class="fs--2 fw-semi-bold text-muted mb-2"><i class="fas fa-hand-holding-usd me-1"></i>Vendor-Wise Payments (Current Month)</div>
                                    <div style="height: 140px; position: relative; width: 100%;">
                                        <canvas id="collectionsDealerChart"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-6">
                            <div class="card shadow-sm">
                                <div class="card-body p-3">
                                    <div class="fs--2 fw-semi-bold text-muted mb-2"><i class="fas fa-money-check-alt me-1"></i>Daily Disbursements (Past 7 Days)</div>
                                    <div style="height: 140px; position: relative; width: 100%;">
                                        <canvas id="vendorPaymentsChart"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- ======================== SCRIPTS ======================== -->
                    <script>
                        // Global chart instances to allow clean redrawing without hover issues
                        const activeCharts = {};

                        function destroyChart(canvasId) {
                            if (activeCharts[canvasId]) {
                                activeCharts[canvasId].destroy();
                                delete activeCharts[canvasId];
                            }
                        }

                        function checkSyncStatus() {
                            fetch('${pageContext.request.contextPath}/api/dashboard/sync-info')
                                .then(res => res.json())
                                .then(data => {
                                    document.getElementById("last-sync-timestamp").innerText = data.lastSynced || 'N/A';
                                    const btn = document.getElementById("btn-sync-now");
                                    const icon = document.getElementById("sync-icon");
                                    const text = document.getElementById("sync-btn-text");

                                    if (data.isSyncing) {
                                        btn.disabled = true;
                                        btn.classList.remove('btn-primary');
                                        btn.classList.add('btn-secondary');
                                        icon.classList.add('fa-spin');
                                        text.innerText = "Syncing...";
                                        // Poll status again in 3 seconds
                                        setTimeout(checkSyncStatus, 3000);
                                    } else {
                                        if (btn.disabled) {
                                            btn.disabled = false;
                                            btn.classList.remove('btn-secondary');
                                            btn.classList.add('btn-primary');
                                            icon.classList.remove('fa-spin');
                                            text.innerText = "Sync Now";
                                            loadDashboardData();
                                        }
                                    }
                                })
                                .catch(err => console.error("Error fetching sync status:", err));
                        }

                        function triggerManualSync() {
                            const btn = document.getElementById("btn-sync-now");
                            const icon = document.getElementById("sync-icon");
                            const text = document.getElementById("sync-btn-text");

                            btn.disabled = true;
                            btn.classList.remove('btn-primary');
                            btn.classList.add('btn-secondary');
                            icon.classList.add('fa-spin');
                            text.innerText = "Syncing...";

                            fetch('${pageContext.request.contextPath}/api/dashboard/sync-now', {
                                method: 'POST'
                            })
                            .then(res => res.json())
                            .then(data => {
                                // Wait 2 seconds and check status
                                setTimeout(checkSyncStatus, 2000);
                            })
                            .catch(err => {
                                console.error("Error triggering manual sync:", err);
                                btn.disabled = false;
                                btn.classList.remove('btn-secondary');
                                btn.classList.add('btn-primary');
                                icon.classList.remove('fa-spin');
                                text.innerText = "Sync Now";
                            });
                        }

                        function loadDashboardData() {
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
                                destroyChart(canvasId);
                                const ctx = document.getElementById(canvasId).getContext('2d');
                                activeCharts[canvasId] = new Chart(ctx, {
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
                                    document.getElementById("kpi-month-count").innerText = formatNum(data.nMonthCount || 0) + " Accounts";
                                    document.getElementById("kpi-month-amount").innerText = formatLKR(data.nMonthAmount || 0);
                                    
                                    document.getElementById("kpi-portfolio-amount").innerText = formatLKR(data.nPortfolioAmount || 0);
                                    document.getElementById("kpi-portfolio-count").innerText = formatNum(data.nPortfolioCount || 0) + " Accounts";
                                    
                                    document.getElementById("kpi-npl-exposure").innerText = formatLKR(data.nNplExposure || 0);
                                    document.getElementById("kpi-npl-count").innerText = formatNum(data.nNplCount || 0) + " Accounts";
                                    
                                    document.getElementById("kpi-settled-amount").innerText = formatLKR(data.settledAmount || 0);
                                    document.getElementById("kpi-settled-count").innerText = formatNum(data.settledCount || 0) + " Accounts";
                                    
                                 })
                                 .catch(err => console.error("Error fetching dashboard statistics:", err));

                            // ============ 2. Month Wise Business Chart ============
                            fetch('${pageContext.request.contextPath}/api/dashboard/business-chart')
                                .then(res => res.json())
                                .then(data => {
                                    const labels = data.map(i => i.month_name);
                                    const amounts = data.map(i => i.business_amount || 0);

                                     buildHorizontalBar(
                                         'businessChart',
                                         labels,
                                         amounts,
                                         isDark ? 'rgba(99, 102, 241, 0.15)' : 'rgba(99, 102, 241, 0.15)',
                                         isDark ? 'rgba(99, 102, 241, 0.85)' : 'rgba(99, 102, 241, 0.85)',
                                         '#6366f1',
                                         false
                                     );
                                 })
                                 .catch(err => console.error("Error loading month wise business:", err));

                            // ============ 3. DPD Range Wise Chart ============
                            fetch('${pageContext.request.contextPath}/api/dashboard/dpd-comparison-chart')
                                .then(res => res.json())
                                .then(data => {
                                    const labels = data.map(i => i.month_name);
                                    const dpd0 = data.map(item => Math.round((item.dpd0_val / 1000000) * 100) / 100);
                                    const dpd1_30 = data.map(item => Math.round((item.dpd1_30_val / 1000000) * 100) / 100);
                                    const dpd31_60 = data.map(item => Math.round((item.dpd31_60_val / 1000000) * 100) / 100);
                                    const dpd61_90 = data.map(item => Math.round((item.dpd61_90_val / 1000000) * 100) / 100);
                                    const dpdAbove90 = data.map(item => Math.round((item.dpdAbove90_val / 1000000) * 100) / 100);

                                    destroyChart('dpdComparisonChart');
                                    const ctx = document.getElementById("dpdComparisonChart").getContext('2d');
                                    activeCharts['dpdComparisonChart'] = new Chart(ctx, {
                                        type: 'bar',
                                        data: {
                                            labels: labels,
                                            datasets: [
                                                {
                                                    label: 'DPD 0',
                                                    data: dpd0,
                                                    backgroundColor: 'rgba(16, 185, 129, 0.75)',
                                                    borderColor: '#10b981',
                                                    borderWidth: 1.5,
                                                    borderRadius: 4,
                                                    barThickness: 16
                                                },
                                                {
                                                    label: 'DPD 1-30',
                                                    data: dpd1_30,
                                                    backgroundColor: 'rgba(245, 158, 11, 0.75)',
                                                    borderColor: '#f59e0b',
                                                    borderWidth: 1.5,
                                                    borderRadius: 4,
                                                    barThickness: 16
                                                },
                                                {
                                                    label: 'DPD 31-60',
                                                    data: dpd31_60,
                                                    backgroundColor: 'rgba(249, 115, 22, 0.75)',
                                                    borderColor: '#f97316',
                                                    borderWidth: 1.5,
                                                    borderRadius: 4,
                                                    barThickness: 16
                                                },
                                                {
                                                    label: 'DPD 61-90',
                                                    data: dpd61_90,
                                                    backgroundColor: 'rgba(239, 68, 68, 0.75)',
                                                    borderColor: '#ef4444',
                                                    borderWidth: 1.5,
                                                    borderRadius: 4,
                                                    barThickness: 16
                                                },
                                                {
                                                    label: 'Over 90 DPD',
                                                    data: dpdAbove90,
                                                    backgroundColor: isDark ? 'rgba(167, 139, 250, 0.75)' : 'rgba(30, 41, 59, 0.75)',
                                                    borderColor: isDark ? '#a78bfa' : '#1e293b',
                                                    borderWidth: 1.5,
                                                    borderRadius: 4,
                                                    barThickness: 16
                                                }
                                            ]
                                        },
                                        options: {
                                            indexAxis: 'y',
                                            responsive: true,
                                            maintainAspectRatio: false,
                                            scales: {
                                                x: {
                                                    stacked: true,
                                                    beginAtZero: true,
                                                    grid: {
                                                        borderDash: [4, 4],
                                                        color: isDark ? 'rgba(255, 255, 255, 0.05)' : 'rgba(226, 232, 240, 0.4)'
                                                    },
                                                    ticks: { display: false }
                                                },
                                                y: {
                                                    stacked: true,
                                                    grid: { display: false },
                                                    ticks: { color: isDark ? '#94a3b8' : '#475569', font: { size: 9, weight: 'bold' } }
                                                }
                                            },
                                            plugins: {
                                                legend: {
                                                    display: true,
                                                    position: 'top',
                                                    labels: { boxWidth: 10, padding: 8, font: { size: 9, weight: 'bold' } }
                                                },
                                                tooltip: { enabled: true },
                                                datalabels: { display: false }
                                            }
                                        }
                                    });
                                })
                                .catch(err => console.error("Error loading monthly DPD comparison:", err));

                            // ============ 4. Highest NPL Model Highlight ============
                            fetch('${pageContext.request.contextPath}/api/dashboard/highest-npl-model')
                                .then(res => res.json())
                                .then(data => {
                                    if (data && data.model_name) {
                                        document.getElementById("npl-model-name").innerText = data.model_name;
                                        document.getElementById("npl-model-count").innerText = formatNum(data.accounts_count || 0) + " Accounts \u2022 Exposure: " + formatLKR(data.exposure || 0);
                                    } else {
                                        document.getElementById("npl-model-name").innerText = 'Unknown Model';
                                        document.getElementById("npl-model-count").innerText = '0 Accounts';
                                    }
                                })
                                .catch(err => console.error("Error loading highest NPL model:", err));

                            // ============ 5. Highest NPL Dealer Highlight ============
                            fetch('${pageContext.request.contextPath}/api/dashboard/highest-npl-dealer')
                                .then(res => res.json())
                                .then(data => {
                                    if (data && data.dealer_name) {
                                        document.getElementById("npl-dealer-name").innerText = data.dealer_name;
                                        document.getElementById("npl-dealer-count").innerText = formatNum(data.accounts_count || 0) + " Accounts \u2022 Exposure: " + formatLKR(data.exposure || 0);
                                    } else {
                                        document.getElementById("npl-dealer-name").innerText = 'Unknown Dealer';
                                        document.getElementById("npl-dealer-count").innerText = '0 Accounts';
                                    }
                                })
                                .catch(err => console.error("Error loading highest NPL dealer:", err));

                            // ============ 6. Device Status Charts ============
                            fetch('${pageContext.request.contextPath}/api/dashboard/device-status-charts')
                                .then(res => res.json())
                                .then(data => {
                                    let mobileLocked = 0;
                                    if (data.mobileLock) {
                                        data.mobileLock.forEach(item => {
                                            if (item.state_name === 'Locked') mobileLocked = item.count_val || 0;
                                        });
                                    }
                                    document.getElementById("sec-mobile-locked-val").innerText = formatNum(mobileLocked);

                                    let laptopLocked = 0;
                                    if (data.laptopLock) {
                                        data.laptopLock.forEach(item => {
                                            if (item.state_name === 'Locked') laptopLocked = item.count_val || 0;
                                        });
                                    }
                                    document.getElementById("sec-laptop-locked-val").innerText = formatNum(laptopLocked);

                                    // Helper function for small doughnut charts
                                    const buildDoughnut = (canvasId, dataset, labelsList, colorsList) => {
                                        destroyChart(canvasId);
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
                                        activeCharts[canvasId] = new Chart(ctx, {
                                            type: 'doughnut',
                                            data: {
                                                labels: labels.length ? labels : labelsList,
                                                datasets: [{
                                                    data: counts.length ? counts : [0, 0],
                                                    backgroundColor: colorsList,
                                                    borderWidth: 0
                                                }]
                                            },
                                            plugins: [centerTextPlugin],
                                            options: {
                                                responsive: true,
                                                maintainAspectRatio: false,
                                                cutout: '72%',
                                                plugins: {
                                                    legend: { display: false },
                                                    tooltip: { enabled: true },
                                                    datalabels: {
                                                        display: true,
                                                        color: '#ffffff',
                                                        font: { weight: 'bold', size: 9 },
                                                        formatter: (value, ctx) => {
                                                            let sum = ctx.chart.data.datasets[0].data.reduce((a, b) => a + b, 0);
                                                            if (sum === 0) return '';
                                                            let percentage = Math.round(value * 100 / sum);
                                                            return percentage >= 5 ? percentage + "%" : '';
                                                        },
                                                        anchor: 'center',
                                                        align: 'center'
                                                    }
                                                }
                                            }
                                        });
                                    };

                                    buildDoughnut('mobilePerformingChart', data.mobilePerforming || [], ['Performing', 'Non-Performing'], ['rgba(16, 185, 129, 0.85)', 'rgba(244, 63, 94, 0.85)']);
                                    buildDoughnut('mobileLockChart', data.mobileLock || [], ['Active', 'Locked'], ['rgba(99, 102, 241, 0.85)', 'rgba(245, 158, 11, 0.85)']);
                                    buildDoughnut('laptopPerformingChart', data.laptopPerforming || [], ['Performing', 'Non-Performing'], ['rgba(16, 185, 129, 0.85)', 'rgba(244, 63, 94, 0.85)']);
                                    buildDoughnut('laptopLockChart', data.laptopLock || [], ['Active', 'Locked'], ['rgba(99, 102, 241, 0.85)', 'rgba(245, 158, 11, 0.85)']);
                                })
                                .catch(err => console.error("Error loading security doughnut status:", err));

                            // ============ 7. Daily Disbursements (Past 7 Days) ============
                            fetch('${pageContext.request.contextPath}/api/dashboard/vendor-payments-chart')
                                .then(res => res.json())
                                .then(data => {
                                    let chartData = data;
                                    buildHorizontalBar(
                                        'vendorPaymentsChart',
                                        chartData.map(i => i.channel_name),
                                        chartData.map(i => i.total_amount || 0),
                                        isDark ? 'rgba(99, 102, 241, 0.15)' : 'rgba(99, 102, 241, 0.15)',
                                        isDark ? 'rgba(99, 102, 241, 0.85)' : 'rgba(99, 102, 241, 0.85)',
                                        '#6366f1',
                                        false
                                    );
                                })
                                .catch(err => console.error("Error loading daily disbursements chart:", err));

                            // ============ 8. Collections Dealer Wise ============
                            fetch('${pageContext.request.contextPath}/api/dashboard/collections-dealer-wise')
                                .then(res => res.json())
                                .then(data => {
                                    // Collections details not displayed anymore on top cards but processed for chart

                                    let chartData = data.length > 5 ? data.slice(0, 5) : data;
                                    chartData.reverse();
                                    buildHorizontalBar(
                                        'collectionsDealerChart',
                                        chartData.map(i => i.dealer_name),
                                        chartData.map(i => i.total_collected || 0),
                                        isDark ? 'rgba(245, 158, 11, 0.15)' : 'rgba(245, 158, 11, 0.15)',
                                        isDark ? 'rgba(245, 158, 11, 0.85)' : 'rgba(245, 158, 11, 0.85)',
                                        '#f59e0b',
                                        true
                                    );
                                })
                                .catch(err => console.error("Error loading collections dealer wise:", err));

                            // ============ 9. Product-Wise Business Chart ============
                            fetch('${pageContext.request.contextPath}/api/dashboard/product-business-chart')
                                .then(res => res.json())
                                .then(data => {
                                    const total = data.reduce((sum, item) => sum + (item.business_amount || 0), 0);
                                    
                                    const labels = data.map(item => item.product_name);
                                    const amounts = data.map(item => item.business_amount || 0);
                                    const percentages = data.map(item => total > 0 ? Math.round((item.business_amount / total) * 100) : 0);

                                    destroyChart('productBusinessChart');
                                    const ctx = document.getElementById("productBusinessChart").getContext('2d');
                                    activeCharts['productBusinessChart'] = new Chart(ctx, {
                                        type: 'pie',
                                        data: {
                                            labels: labels,
                                            datasets: [{
                                                data: amounts,
                                                backgroundColor: [
                                                    'rgba(99, 102, 241, 0.85)',
                                                    'rgba(59, 130, 246, 0.85)',
                                                    'rgba(245, 158, 11, 0.85)',
                                                    'rgba(16, 185, 129, 0.85)',
                                                    'rgba(239, 68, 68, 0.85)',
                                                    'rgba(139, 92, 246, 0.85)'
                                                ],
                                                borderWidth: 1,
                                                borderColor: isDark ? '#1e293b' : '#ffffff'
                                            }]
                                        },
                                        options: {
                                            responsive: true,
                                            maintainAspectRatio: false,
                                            plugins: {
                                                legend: {
                                                    position: 'bottom',
                                                    labels: {
                                                        color: isDark ? '#94a3b8' : '#475569',
                                                        boxWidth: 8,
                                                        font: { size: 8, weight: 'bold' }
                                                    }
                                                },
                                                tooltip: {
                                                    callbacks: {
                                                        label: function(context) {
                                                            const label = context.label || '';
                                                            const val = context.raw || 0;
                                                            const pct = percentages[context.dataIndex];
                                                            return label + ': ' + formatLKR(val) + ' (' + pct + '%)';
                                                        }
                                                    }
                                                },
                                                datalabels: {
                                                    display: true,
                                                    color: '#ffffff',
                                                    font: { size: 9, weight: 'bold' },
                                                    formatter: (val, ctx) => {
                                                        const pct = percentages[ctx.dataIndex];
                                                        return pct >= 5 ? pct + '%' : '';
                                                    }
                                                }
                                            }
                                        }
                                    });
                                })
                                .catch(err => console.error("Error loading product business chart:", err));
                        }

                        document.addEventListener("DOMContentLoaded", function() {
                            checkSyncStatus();
                            loadDashboardData();
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