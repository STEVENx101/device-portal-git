<%@page contentType="text/html" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en-US" dir="ltr">

    <head>
        <script>
            window.addEventListener('error', function(e) {
                console.error("GLOBAL ERROR DETECTED:", e);
                var div = document.createElement('div');
                div.style.position = 'fixed';
                div.style.top = '0';
                div.style.left = '0';
                div.style.width = '100%';
                div.style.backgroundColor = '#f8d7da';
                div.style.color = '#721c24';
                div.style.padding = '10px';
                div.style.zIndex = '9999';
                div.style.borderBottom = '2px solid #f5c6cb';
                div.style.fontFamily = 'monospace';
                div.innerText = "JS ERROR: " + e.message + " in " + e.filename + ":" + e.lineno;
                document.body.appendChild(div);
            });
        </script>
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
            // Set premium global defaults for Chart.js dynamically supporting dark mode
            const isDark = document.documentElement.classList.contains('dark');
            Chart.defaults.font.family = "'Plus Jakarta Sans', 'Poppins', sans-serif";
            Chart.defaults.font.weight = '500';
            Chart.defaults.color = isDark ? "#94a3b8" : "#64748b";

            // Register and disable datalabels plugin globally so we only enable it on specific doughnut charts
            Chart.register(ChartDataLabels);
            Chart.defaults.plugins.datalabels.display = false;
            
            // Tooltip styling
            Chart.defaults.plugins.tooltip.backgroundColor = isDark ? "rgba(15, 23, 42, 0.96)" : "rgba(255, 255, 255, 0.96)";
            Chart.defaults.plugins.tooltip.titleColor = isDark ? "#f8fafc" : "#1e293b";
            Chart.defaults.plugins.tooltip.titleFont = { size: 13, weight: 'bold' };
            Chart.defaults.plugins.tooltip.bodyColor = isDark ? "#cbd5e1" : "#475569";
            Chart.defaults.plugins.tooltip.bodyFont = { size: 12 };
            Chart.defaults.plugins.tooltip.borderColor = isDark ? "rgba(255, 255, 255, 0.1)" : "#e2e8f0";
            Chart.defaults.plugins.tooltip.borderWidth = 1;
            Chart.defaults.plugins.tooltip.cornerRadius = 10;
            Chart.defaults.plugins.tooltip.padding = 12;
            Chart.defaults.plugins.tooltip.boxPadding = 6;
            Chart.defaults.plugins.tooltip.usePointStyle = true;
            
            // Legend styling
            Chart.defaults.plugins.legend.labels.usePointStyle = true;
            Chart.defaults.plugins.legend.labels.padding = 15;
            Chart.defaults.plugins.legend.labels.font = { size: 12, weight: '600' };
            Chart.defaults.plugins.legend.labels.color = isDark ? "#94a3b8" : "#64748b";
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
            }
            .kpi-card:hover {
                transform: translateY(-3px);
                box-shadow: 0 12px 24px rgba(99, 102, 241, 0.15) !important;
            }
            .gradient-1 {
                background: linear-gradient(135deg, #6366f1 0%, #a855f7 100%) !important;
                color: #ffffff !important;
            }
            .gradient-2 {
                background: linear-gradient(135deg, #0ea5e9 0%, #2563eb 100%) !important;
                color: #ffffff !important;
            }
            .gradient-3 {
                background: linear-gradient(135deg, #10b981 0%, #059669 100%) !important;
                color: #ffffff !important;
            }
            .gradient-4 {
                background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%) !important;
                color: #ffffff !important;
            }
            .gradient-5 {
                background: linear-gradient(135deg, #f43f5e 0%, #e11d48 100%) !important;
                color: #ffffff !important;
            }
            .gradient-6 {
                background: linear-gradient(135deg, #14b8a6 0%, #0d9488 100%) !important;
                color: #ffffff !important;
            }
            .gradient-7 {
                background: linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%) !important;
                color: #ffffff !important;
            }
            .gradient-8 {
                background: linear-gradient(135deg, #64748b 0%, #475569 100%) !important;
                color: #ffffff !important;
            }
            /* Dark mode overrides for dashboard cards */
            html.dark .kpi-card {
                background: rgba(15, 23, 42, 0.65) !important;
                backdrop-filter: blur(16px) !important;
                border: 1px solid rgba(255, 255, 255, 0.08) !important;
                color: #f8fafc !important;
                box-shadow: 0 10px 30px -10px rgba(0, 0, 0, 0.5) !important;
            }
            html.dark .kpi-card .card-title-sub {
                color: #94a3b8 !important;
            }
            html.dark .kpi-card .card-value {
                color: #f8fafc !important;
            }
            html.dark .kpi-card .card-detail-text {
                color: #cbd5e1 !important;
            }
            .card-title-sub {
                font-size: 0.7rem;
                opacity: 0.85;
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 0.05em;
            }
            .card-value {
                font-size: 1.4rem;
                font-weight: 800;
                margin-top: 0.3rem;
            }
            .card-detail-text {
                font-size: 0.68rem;
                opacity: 0.9;
                margin-top: 0.2rem;
            }
            .chart-container {
                position: relative;
                height: 280px;
                width: 100%;
            }
            /* Dashboard content must scroll */
            .dashboard-content {
                overflow-y: auto !important;
                height: calc(100vh - 20px) !important;
                padding-right: 15px !important;
                padding-bottom: 30px !important;
            }
            
            /* Modern Futuristic Card & Header Styles */
            .card {
                border-radius: 12px !important;
                border: 1px solid rgba(226, 232, 240, 0.8) !important;
                box-shadow: 0 4px 15px -1px rgba(0, 0, 0, 0.03) !important;
                transition: transform 0.25s cubic-bezier(0.4, 0, 0.2, 1), box-shadow 0.25s cubic-bezier(0.4, 0, 0.2, 1) !important;
            }
            html.dark .card {
                background: rgba(15, 23, 42, 0.6) !important;
                backdrop-filter: blur(20px) !important;
                -webkit-backdrop-filter: blur(20px) !important;
                border: 1px solid rgba(255, 255, 255, 0.08) !important;
                box-shadow: 0 10px 30px rgba(0, 0, 0, 0.25) !important;
            }
            .card:hover {
                transform: translateY(-2px);
                box-shadow: 0 12px 28px -4px rgba(99, 102, 241, 0.12) !important;
            }
            html.dark .card:hover {
                box-shadow: 0 12px 30px -4px rgba(245, 158, 11, 0.15) !important;
            }
            .card-header {
                background: transparent !important;
                border-bottom: 1px solid rgba(99, 102, 241, 0.12) !important;
                padding: 14px 20px !important;
                border-left: 4px solid #6366f1 !important;
                border-top-left-radius: 12px !important;
                border-top-right-radius: 12px !important;
            }
            html.dark .card-header {
                border-bottom: 1px solid rgba(245, 158, 11, 0.15) !important;
                border-left: 4px solid #f59e0b !important;
            }
            .card-header h6.text-primary {
                font-family: 'Plus Jakarta Sans', 'Poppins', sans-serif !important;
                text-transform: uppercase !important;
                letter-spacing: 0.8px !important;
                font-size: 0.82rem !important;
                font-weight: 700 !important;
                background: linear-gradient(90deg, #6366f1, #a855f7) !important;
                -webkit-background-clip: text !important;
                -webkit-text-fill-color: transparent !important;
                display: inline-flex !important;
                align-items: center !important;
            }
            html.dark .card-header h6.text-primary {
                background: linear-gradient(90deg, #f59e0b, #fbbf24) !important;
                -webkit-background-clip: text !important;
                -webkit-text-fill-color: transparent !important;
            }
            .card-header h6.text-primary i {
                -webkit-text-fill-color: #6366f1 !important;
                margin-right: 8px !important;
            }
            html.dark .card-header h6.text-primary i {
                -webkit-text-fill-color: #f59e0b !important;
            }

            /* Security strip mini cards */
            .security-mini-card {
                border-radius: 10px !important;
                padding: 12px 16px !important;
                transition: transform 0.2s, box-shadow 0.2s;
                cursor: default;
            }
            .security-mini-card:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 20px rgba(99, 102, 241, 0.12) !important;
            }
            .security-mini-card .mini-label {
                font-size: 0.65rem;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 0.06em;
                opacity: 0.9;
            }
            .security-mini-card .mini-value {
                font-size: 1.1rem;
                font-weight: 800;
            }
            .security-mini-card .mini-detail {
                font-size: 0.62rem;
                opacity: 0.85;
                font-weight: 600;
            }

            /* NPL Highlight cards */
            .npl-highlight-card {
                border-radius: 12px !important;
                padding: 20px !important;
                position: relative;
                overflow: hidden;
            }
            .npl-highlight-card::before {
                content: '';
                position: absolute;
                top: -50%;
                right: -50%;
                width: 100%;
                height: 100%;
                background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 70%);
                pointer-events: none;
            }
            .npl-highlight-card .highlight-icon {
                width: 44px;
                height: 44px;
                border-radius: 10px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 1.2rem;
                background: rgba(255,255,255,0.2);
                margin-bottom: 12px;
            }
            .npl-highlight-card .highlight-label {
                font-size: 0.7rem;
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 0.05em;
                opacity: 0.85;
            }
            .npl-highlight-card .highlight-name {
                font-size: 1.05rem;
                font-weight: 800;
                margin: 4px 0;
                line-height: 1.3;
            }
            .npl-highlight-card .highlight-stat {
                font-size: 0.72rem;
                font-weight: 600;
                opacity: 0.9;
            }

            /* Section dividers */
            .section-title {
                font-family: 'Plus Jakarta Sans', sans-serif;
                font-size: 0.78rem;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 0.08em;
                color: #6366f1;
                margin-bottom: 12px;
                display: flex;
                align-items: center;
                gap: 8px;
            }
            html.dark .section-title {
                color: #f59e0b;
            }
            .section-title::after {
                content: '';
                flex: 1;
                height: 1px;
                background: linear-gradient(90deg, rgba(99, 102, 241, 0.3), transparent);
            }
            html.dark .section-title::after {
                background: linear-gradient(90deg, rgba(245, 158, 11, 0.3), transparent);
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

                    <div class="d-flex mb-3 align-items-center justify-content-between mt-2">
                        <div>
                            <h4 class="mb-0 text-primary"><i class="fas fa-tachometer-alt me-2"></i>Device Finance Analytics Dashboard</h4>
                        </div>
                    </div>

                    <!-- ======================== ROW 1: Primary KPI Cards ======================== -->
                    <div class="section-title"><i class="fas fa-chart-pie"></i> Key Performance Indicators</div>
                    <div class="row g-2 mb-3">
                        <!-- Current Month Loans -->
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <div class="card kpi-card gradient-1 shadow-sm h-100">
                                <div class="card-body p-2">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <span class="card-title-sub">Current Month Loans</span>
                                            <div class="card-value" id="kpi-month-count">0</div>
                                            <div class="card-detail-text" id="kpi-month-amount">LKR 0.00 Mn</div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!-- Active Loans -->
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <div class="card kpi-card gradient-3 shadow-sm h-100">
                                <div class="card-body p-2">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <span class="card-title-sub">Active Loans</span>
                                            <div class="card-value" id="kpi-active-count">0</div>
                                            <div class="card-detail-text">Active status</div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!-- NPL Card (Merged Count & Arrears) -->
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <div class="card kpi-card gradient-4 shadow-sm h-100">
                                <div class="card-body p-2">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <span class="card-title-sub">NPL</span>
                                            <div class="card-value" id="kpi-npl-count">0 Accounts</div>
                                            <div class="card-detail-text" id="kpi-npl-exposure">Exp: LKR 0.00 Mn</div>
                                            <div class="card-detail-text" id="kpi-npl-arrears" style="font-size: 0.65rem; opacity: 0.85;">Arr: LKR 0.00 Mn</div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!-- Arrears -->
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <div class="card kpi-card gradient-5 shadow-sm h-100">
                                <div class="card-body p-2">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <span class="card-title-sub">Arrears</span>
                                            <div class="card-value" id="kpi-arrears-count">0</div>
                                            <div class="card-detail-text" id="kpi-arrears-amount">LKR 0.00 Mn</div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!-- Portfolio -->
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <div class="card kpi-card gradient-2 shadow-sm h-100">
                                <div class="card-body p-2">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <span class="card-title-sub">Portfolio</span>
                                            <div class="card-value" id="kpi-portfolio-amount">LKR 0.00 Mn</div>
                                            <div class="card-detail-text" id="kpi-portfolio-count">0 Accounts</div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!-- YTD -->
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <div class="card kpi-card gradient-7 shadow-sm h-100">
                                <div class="card-body p-2">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <span class="card-title-sub">YTD (Fin Year)</span>
                                            <div class="card-value" id="kpi-ytd-amount">LKR 0.00 Mn</div>
                                            <div class="card-detail-text" id="kpi-ytd-count">0 Accounts</div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- ======================== ROW 3: Charts - Business & DPD ======================== -->
                    <div class="section-title"><i class="fas fa-chart-bar"></i> Business & DPD Analytics</div>
                    <div class="row g-3 mb-4">
                        <!-- Chart 1: Month-wise Business -->
                        <div class="col-lg-6">
                            <div class="card shadow-sm h-100">
                                <div class="card-header bg-light d-flex justify-content-between align-items-center py-2">
                                    <h6 class="mb-0 text-primary fw-bold"><i class="fas fa-chart-line me-2"></i>Month Wise Business (Financial Year)</h6>
                                </div>
                                <div class="card-body p-3 d-flex flex-column justify-content-center">
                                    <div class="chart-container" style="height: 280px; position: relative; width: 100%;">
                                        <canvas id="businessChart"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Chart 2: DPD Comparison Chart Month-wise -->
                        <div class="col-lg-6">
                            <div class="card shadow-sm h-100">
                                <div class="card-header bg-light d-flex justify-content-between align-items-center py-2">
                                    <h6 class="mb-0 text-primary fw-bold"><i class="fas fa-chart-bar me-2"></i>DPD Comparison Month Wise (Financial Year)</h6>
                                </div>
                                <div class="card-body p-3 d-flex flex-column justify-content-center">
                                    <div class="chart-container" style="height: 280px; position: relative; width: 100%;">
                                        <canvas id="dpdComparisonChart"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- ======================== ROW 4: Highest NPL Model & Dealer ======================== -->
                    <div class="section-title"><i class="fas fa-exclamation-circle"></i> NPL Highlight Statistics</div>
                    <div class="row g-3 mb-4">
                        <!-- Highest NPL Model -->
                        <div class="col-md-6">
                            <div class="card npl-highlight-card gradient-5 shadow-sm h-100">
                                <div class="highlight-icon">
                                    <i class="fas fa-mobile-alt"></i>
                                </div>
                                <div class="highlight-label">Highest NPL Model</div>
                                <div class="highlight-name" id="npl-model-name">Loading...</div>
                                <div class="highlight-stat" id="npl-model-count">0 Accounts</div>
                                <div class="highlight-stat" id="npl-model-exposure">Exposure: LKR 0.00 Mn</div>
                            </div>
                        </div>
                        <!-- Highest NPL Dealer -->
                        <div class="col-md-6">
                            <div class="card npl-highlight-card gradient-4 shadow-sm h-100">
                                <div class="highlight-icon">
                                    <i class="fas fa-store"></i>
                                </div>
                                <div class="highlight-label">Highest NPL Dealer</div>
                                <div class="highlight-name" id="npl-dealer-name">Loading...</div>
                                <div class="highlight-stat" id="npl-dealer-count">0 Accounts</div>
                                <div class="highlight-stat" id="npl-dealer-exposure">Exposure: LKR 0.00 Mn</div>
                            </div>
                        </div>
                    </div>

                    <!-- ======================== ROW 5: Device Status Charts ======================== -->
                    <div class="section-title"><i class="fas fa-hdd"></i> Device Status Analytics</div>
                    <div class="row g-3 mb-4">
                        <!-- Mobile Device Status -->
                        <div class="col-lg-6">
                            <div class="card shadow-sm h-100">
                                <div class="card-header bg-light d-flex justify-content-between align-items-center py-2">
                                    <h6 class="mb-0 text-primary fw-bold"><i class="fas fa-mobile-alt me-2"></i>Mobile Device Status (MF)</h6>
                                </div>
                                <div class="card-body p-3">
                                    <div class="row g-2">
                                        <div class="col-6">
                                            <div class="text-center fw-semi-bold fs--2 text-muted mb-2">Performance</div>
                                            <div style="height: 220px; position: relative; width: 100%;">
                                                <canvas id="mobilePerformingChart"></canvas>
                                            </div>
                                        </div>
                                        <div class="col-6">
                                            <div class="text-center fw-semi-bold fs--2 text-muted mb-2">Lock Status</div>
                                            <div style="height: 220px; position: relative; width: 100%;">
                                                <canvas id="mobileLockChart"></canvas>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Laptop Device Status -->
                        <div class="col-lg-6">
                            <div class="card shadow-sm h-100">
                                <div class="card-header bg-light d-flex justify-content-between align-items-center py-2">
                                    <h6 class="mb-0 text-primary fw-bold"><i class="fas fa-laptop me-2"></i>Laptop Device Status (LF)</h6>
                                </div>
                                <div class="card-body p-3">
                                    <div class="row g-2">
                                        <div class="col-6">
                                            <div class="text-center fw-semi-bold fs--2 text-muted mb-2">Performance</div>
                                            <div style="height: 220px; position: relative; width: 100%;">
                                                <canvas id="laptopPerformingChart"></canvas>
                                            </div>
                                        </div>
                                        <div class="col-6">
                                            <div class="text-center fw-semi-bold fs--2 text-muted mb-2">Lock Status</div>
                                            <div style="height: 220px; position: relative; width: 100%;">
                                                <canvas id="laptopLockChart"></canvas>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- ======================== ROW 6: Collections & Vendor Payments ======================== -->
                    <div class="section-title"><i class="fas fa-hand-holding-usd"></i> Collections & Payments</div>
                    <div class="row g-3 mb-4">
                        <!-- Collections Dealer Wise -->
                        <div class="col-lg-6">
                            <div class="card shadow-sm h-100">
                                <div class="card-header bg-light d-flex justify-content-between align-items-center py-2">
                                    <h6 class="mb-0 text-primary fw-bold"><i class="fas fa-hand-holding-usd me-2"></i>Collections Dealer Wise (Current Month)</h6>
                                </div>
                                <div class="card-body p-3 d-flex flex-column justify-content-center">
                                    <div class="chart-container" style="height: 320px; position: relative; width: 100%;">
                                        <canvas id="collectionsDealerChart"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Vendor Payments -->
                        <div class="col-lg-6">
                            <div class="card shadow-sm h-100">
                                <div class="card-header bg-light d-flex justify-content-between align-items-center py-2">
                                    <h6 class="mb-0 text-primary fw-bold"><i class="fas fa-money-check-alt me-2"></i>Vendor Payments (Current Month)</h6>
                                </div>
                                <div class="card-body p-3 d-flex flex-column justify-content-center">
                                    <div class="chart-container" style="height: 320px; position: relative; width: 100%;">
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

                            // Helper function to create canvas gradients dynamically
                            function getGradient(ctx, chartArea, startColor, endColor) {
                                if (!chartArea) return startColor;
                                const gradient = ctx.createLinearGradient(0, chartArea.bottom, 0, chartArea.top);
                                gradient.addColorStop(0, startColor);
                                gradient.addColorStop(1, endColor);
                                return gradient;
                            }

                            // Helper: build horizontal bar chart (reusable)
                            function buildHorizontalBar(canvasId, labels, amounts, gradientStart, gradientEnd, borderColor, tooltipPrefix) {
                                const ctx = document.getElementById(canvasId).getContext('2d');
                                new Chart(ctx, {
                                    type: 'bar',
                                    data: {
                                        labels: labels,
                                        datasets: [{
                                            label: tooltipPrefix || 'Amount (LKR)',
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
                                            borderRadius: { topRight: 6, bottomRight: 6, topLeft: 0, bottomLeft: 0 },
                                            barThickness: 16
                                        }]
                                    },
                                    options: {
                                        indexAxis: 'y',
                                        responsive: true,
                                        maintainAspectRatio: false,
                                        plugins: {
                                            legend: { display: false },
                                            tooltip: {
                                                callbacks: {
                                                    label: function(context) {
                                                        return ' LKR ' + Number(context.raw).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 });
                                                    }
                                                }
                                            }
                                        },
                                        scales: {
                                            x: {
                                                grid: { display: false },
                                                ticks: {
                                                    color: isDark ? '#94a3b8' : '#64748b',
                                                    callback: function(value) {
                                                        if (value >= 1000000) return (value / 1000000).toFixed(1) + 'M';
                                                        if (value >= 1000) return (value / 1000).toFixed(0) + 'K';
                                                        return value;
                                                    }
                                                }
                                            },
                                            y: {
                                                grid: { display: false },
                                                ticks: { color: isDark ? '#94a3b8' : '#64748b' }
                                            }
                                        }
                                    }
                                });
                            }

                            // ============ 1. Dashboard Stats (KPI Cards) ============
                            fetch('${pageContext.request.contextPath}/api/dashboard/stats')
                                .then(response => {
                                    if (!response.ok) {
                                        throw new Error("HTTP error " + response.status);
                                    }
                                    return response.json();
                                    })
                                .then(data => {
                                    console.log("Dashboard Stats:", data);
                                    
                                    // Primary KPIs
                                    document.getElementById("kpi-month-count").innerText = formatNum(data.nMonthCount);
                                    document.getElementById("kpi-month-amount").innerText = formatLKR(data.nMonthAmount);
                                    
                                    document.getElementById("kpi-active-count").innerText = formatNum(data.activeCount);
                                    
                                    document.getElementById("kpi-npl-count").innerText = formatNum(data.nNplCount) + " A/Cs";
                                    document.getElementById("kpi-npl-exposure").innerText = "Exp: " + formatLKR(data.nNplExposure);
                                    document.getElementById("kpi-npl-arrears").innerText = "Arr: " + formatLKR(data.nNplArrears);
                                    
                                    document.getElementById("kpi-arrears-count").innerText = formatNum(data.arrearsCount);
                                    document.getElementById("kpi-arrears-amount").innerText = formatLKR(data.arrearsAmount);
                                    
                                    document.getElementById("kpi-portfolio-amount").innerText = formatLKR(data.nPortfolioAmount);
                                    document.getElementById("kpi-portfolio-count").innerText = formatNum(data.nPortfolioCount) + " Accounts";
                                    
                                    document.getElementById("kpi-ytd-amount").innerText = formatLKR(data.nYtdAmount);
                                    document.getElementById("kpi-ytd-count").innerText = formatNum(data.nYtdCount) + " Accounts";
                                })
                                .catch(err => {
                                    console.error("Error fetching dashboard statistics:", err);
                                });

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
                                            datasets: [
                                                {
                                                    label: 'Disbursed Amount (LKR Mn)',
                                                    data: amounts,
                                                    backgroundColor: function(context) {
                                                        const chart = context.chart;
                                                        const {ctx: canvasCtx, chartArea} = chart;
                                                        if (!chartArea) return isDark ? 'rgba(139, 92, 246, 0.85)' : 'rgba(99, 102, 241, 0.85)';
                                                        const gradient = canvasCtx.createLinearGradient(chartArea.left, 0, chartArea.right, 0);
                                                        gradient.addColorStop(0, isDark ? 'rgba(139, 92, 246, 0.15)' : 'rgba(99, 102, 241, 0.15)');
                                                        gradient.addColorStop(1, isDark ? 'rgba(139, 92, 246, 0.85)' : 'rgba(99, 102, 241, 0.85)');
                                                        return gradient;
                                                    },
                                                    borderColor: isDark ? '#8b5cf6' : '#6366f1',
                                                    borderWidth: 2,
                                                    borderRadius: { topRight: 8, bottomRight: 8, topLeft: 0, bottomLeft: 0 },
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
                                                    type: 'linear',
                                                    beginAtZero: true,
                                                    grid: { 
                                                        borderDash: [4, 4], 
                                                        color: isDark ? 'rgba(255, 255, 255, 0.05)' : 'rgba(226, 232, 240, 0.4)' 
                                                    },
                                                    title: { display: true, text: 'LKR Millions', font: { weight: 'bold' }, color: isDark ? '#94a3b8' : '#475569' }
                                                },
                                                y: {
                                                    grid: { display: false }
                                                }
                                            },
                                            plugins: {
                                                legend: { position: 'bottom' }
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
                                    const dpd0 = data.map(item => Math.round((item.dpd0_val / 1000000) * 100) / 100);
                                    const dpd1_30 = data.map(item => Math.round((item.dpd1_30_val / 1000000) * 100) / 100);
                                    const dpd31_60 = data.map(item => Math.round((item.dpd31_60_val / 1000000) * 100) / 100);
                                    const dpd61_90 = data.map(item => Math.round((item.dpd61_90_val / 1000000) * 100) / 100);
                                    const dpdAbove90 = data.map(item => Math.round((item.dpdAbove90_val / 1000000) * 100) / 100);

                                    const ctx = document.getElementById('dpdComparisonChart').getContext('2d');
                                    new Chart(ctx, {
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
                                                     title: { display: true, text: 'LKR Millions', font: { weight: 'bold' }, color: isDark ? '#94a3b8' : '#475569' }
                                                 },
                                                 y: {
                                                     stacked: true,
                                                     grid: { display: false }
                                                 }
                                             },
                                             plugins: {
                                                 legend: { position: 'bottom' }
                                             }
                                         }
                                    });
                                })
                                .catch(err => console.error("Error loading DPD comparison chart:", err));

                            // ============ 4. Vendor Payments ============
                            fetch('${pageContext.request.contextPath}/api/dashboard/vendor-payments-chart')
                                .then(res => res.json())
                                .then(data => {
                                    let chartData = [];
                                    if (data.length > 10) {
                                        chartData = data.slice(0, 10);
                                        const othersSum = data.slice(10).reduce((sum, item) => sum + (item.total_amount || 0), 0);
                                        chartData.push({ channel_name: 'Others', total_amount: othersSum });
                                    } else {
                                        chartData = data;
                                    }
                                    chartData.reverse();
                                    const labels = chartData.map(item => item.channel_name);
                                    const amounts = chartData.map(item => item.total_amount);
                                    
                                    buildHorizontalBar(
                                        'vendorPaymentsChart', labels, amounts,
                                        isDark ? 'rgba(167, 139, 250, 0.15)' : 'rgba(79, 70, 229, 0.15)',
                                        isDark ? 'rgba(167, 139, 250, 0.85)' : 'rgba(79, 70, 229, 0.85)',
                                        isDark ? '#a78bfa' : 'rgba(79, 70, 229, 1)',
                                        'Payment Amount (LKR)'
                                    );
                                })
                                .catch(err => console.error("Error loading vendor payments chart:", err));

                            // ============ 5. Device Status Charts ============
                            fetch('${pageContext.request.contextPath}/api/dashboard/device-status-charts')
                                .then(res => res.json())
                                .then(data => {
                                    // Helper function to build status doughnut chart
                                    function buildDoughnut(canvasId, dataset, labelsList, colorsList) {
                                        const labels = dataset.map(item => item.state_name);
                                        const counts = dataset.map(item => item.count_val);
                                        
                                        // Custom center text plugin for this chart instance
                                        const centerTextPlugin = {
                                            id: 'centerTextPlugin',
                                            beforeDraw: function(chart) {
                                                const width = chart.width,
                                                      height = chart.height,
                                                      ctx = chart.ctx;
                                                ctx.restore();
                                                
                                                const total = chart.data.datasets[0].data.reduce((a, b) => a + b, 0);
                                                
                                                // Responsive font size
                                                const fontSize = (chart.innerRadius / 35).toFixed(2);
                                                ctx.font = "bold " + fontSize + "em 'Plus Jakarta Sans', sans-serif";
                                                ctx.textBaseline = "middle";
                                                ctx.fillStyle = isDark ? "#f8fafc" : "#0f172a";
                                                
                                                const text = total.toLocaleString(),
                                                      textX = Math.round((width - ctx.measureText(text).width) / 2),
                                                      textY = chart.chartArea.top + (chart.chartArea.bottom - chart.chartArea.top) / 2 - 6;
                                                
                                                ctx.fillText(text, textX, textY);
                                                
                                                // Subtitle below center count
                                                ctx.font = "600 0.7em 'Plus Jakarta Sans', sans-serif";
                                                ctx.fillStyle = isDark ? "#64748b" : "#94a3b8";
                                                const labelText = "Total",
                                                      labelX = Math.round((width - ctx.measureText(labelText).width) / 2),
                                                      labelY = textY + 14;
                                                      
                                                ctx.fillText(labelText, labelX, labelY);
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
                                                    borderWidth: 2.5,
                                                    hoverOffset: 4,
                                                    spacing: 3
                                                }]
                                            },
                                            plugins: [centerTextPlugin],
                                            options: {
                                                responsive: true,
                                                maintainAspectRatio: false,
                                                cutout: '72%',
                                                plugins: {
                                                    datalabels: {
                                                        display: true,
                                                        color: '#ffffff',
                                                        font: {
                                                            family: "'Plus Jakarta Sans', sans-serif",
                                                            weight: 'bold',
                                                            size: 10
                                                        },
                                                        formatter: (value, ctx) => {
                                                            let sum = 0;
                                                            let dataArr = ctx.chart.data.datasets[0].data;
                                                            dataArr.map(data => {
                                                                sum += data;
                                                            });
                                                            if (sum === 0) return '';
                                                            let percentage = (value * 100 / sum).toFixed(0);
                                                            if (percentage === "0" || value === 0) return '';
                                                            return percentage + "%";
                                                        },
                                                        anchor: 'center',
                                                        align: 'center',
                                                        textShadowColor: 'rgba(0, 0, 0, 0.6)',
                                                        textShadowBlur: 4
                                                    },
                                                    legend: { 
                                                        position: 'bottom', 
                                                        labels: { 
                                                            boxWidth: 8, 
                                                            padding: 8, 
                                                            font: { size: 10, weight: '600' },
                                                            color: isDark ? '#94a3b8' : '#64748b'
                                                        } 
                                                     }
                                                }
                                            }
                                        });
                                    }

                                    // Mobile Performing
                                    buildDoughnut(
                                        'mobilePerformingChart',
                                        data.mobilePerforming,
                                        ['Performing', 'Non-Performing'],
                                        ['rgba(16, 185, 129, 0.85)', 'rgba(244, 63, 94, 0.85)']
                                    );
                                    
                                    // Mobile Locked
                                    buildDoughnut(
                                        'mobileLockChart',
                                        data.mobileLock,
                                        ['Active', 'Locked'],
                                        ['rgba(99, 102, 241, 0.85)', 'rgba(245, 158, 11, 0.85)']
                                    );

                                    // Laptop Performing
                                    buildDoughnut(
                                        'laptopPerformingChart',
                                        data.laptopPerforming,
                                        ['Performing', 'Non-Performing'],
                                        ['rgba(16, 185, 129, 0.85)', 'rgba(244, 63, 94, 0.85)']
                                    );

                                    // Laptop Locked
                                    buildDoughnut(
                                        'laptopLockChart',
                                        data.laptopLock,
                                        ['Active', 'Locked'],
                                        ['rgba(99, 102, 241, 0.85)', 'rgba(245, 158, 11, 0.85)']
                                    );

                                    // Populate lock strip counts from device status data
                                    let mobileLocked = 0, mobileUnlocked = 0;
                                    if (data.mobileLock) {
                                        data.mobileLock.forEach(item => {
                                            if (item.state_name === 'Locked') mobileLocked = item.count_val;
                                            else mobileUnlocked = item.count_val;
                                        });
                                    }
                                    document.getElementById("sec-mobile-locked-val").innerText = formatNum(mobileLocked);
                                    document.getElementById("sec-mobile-unlocked-val").innerText = formatNum(mobileUnlocked);

                                    let laptopLocked = 0, laptopUnlocked = 0;
                                    if (data.laptopLock) {
                                        data.laptopLock.forEach(item => {
                                            if (item.state_name === 'Locked') laptopLocked = item.count_val;
                                            else laptopUnlocked = item.count_val;
                                        });
                                    }
                                    document.getElementById("sec-laptop-locked-val").innerText = formatNum(laptopLocked);
                                    document.getElementById("sec-laptop-unlocked-val").innerText = formatNum(laptopUnlocked);
                                })
                                .catch(err => console.error("Error loading device status charts:", err));

                            // ============ 9. Highest NPL Model ============
                            fetch('${pageContext.request.contextPath}/api/dashboard/highest-npl-model')
                                .then(res => res.json())
                                .then(data => {
                                    document.getElementById("npl-model-name").innerText = data.model_name || 'N/A';
                                    document.getElementById("npl-model-count").innerText = formatNum(data.npl_count || 0) + ' Accounts';
                                    document.getElementById("npl-model-exposure").innerText = 'Exposure: ' + formatLKR(data.npl_exposure || 0);
                                })
                                .catch(err => console.error("Error loading highest NPL model:", err));

                            // ============ 10. Highest NPL Dealer ============
                            fetch('${pageContext.request.contextPath}/api/dashboard/highest-npl-dealer')
                                .then(res => res.json())
                                .then(data => {
                                    document.getElementById("npl-dealer-name").innerText = data.dealer_name || 'N/A';
                                    document.getElementById("npl-dealer-count").innerText = formatNum(data.npl_count || 0) + ' Accounts';
                                    document.getElementById("npl-dealer-exposure").innerText = 'Exposure: ' + formatLKR(data.npl_exposure || 0);
                                })
                                .catch(err => console.error("Error loading highest NPL dealer:", err));

                            // ============ 11. Collections Dealer Wise ============
                            fetch('${pageContext.request.contextPath}/api/dashboard/collections-dealer-wise')
                                .then(res => res.json())
                                .then(data => {
                                    let chartData = data.length > 10 ? data.slice(0, 10) : data;
                                    if (data.length > 10) {
                                        const othersAmt = data.slice(10).reduce((s, i) => s + (i.total_collected || 0), 0);
                                        chartData.push({ dealer_name: 'Others', total_collected: othersAmt });
                                    }
                                    chartData.reverse();
                                    buildHorizontalBar(
                                        'collectionsDealerChart',
                                        chartData.map(i => i.dealer_name),
                                        chartData.map(i => i.total_collected),
                                        isDark ? 'rgba(245, 158, 11, 0.15)' : 'rgba(245, 158, 11, 0.15)',
                                        isDark ? 'rgba(245, 158, 11, 0.85)' : 'rgba(245, 158, 11, 0.85)',
                                        '#f59e0b',
                                        'Collected (LKR)'
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