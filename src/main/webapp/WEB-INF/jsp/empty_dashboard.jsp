<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html lang="en-US" dir="ltr">

    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title>Fintrex | Device Finance Analytics Dashboard</title>

        <link rel="apple-touch-icon" sizes="180x180"
            href="${pageContext.request.contextPath}/assets/img/favicons/apple-touch-icon.png">
        <link rel="icon" type="image/png" sizes="32x32"
            href="${pageContext.request.contextPath}/assets/img/favicons/favicon-32x32.png">
        <link rel="icon" type="image/png" sizes="16x16"
            href="${pageContext.request.contextPath}/assets/img/favicons/favicon-16x16.png">
        <link rel="shortcut icon" type="image/x-icon"
            href="${pageContext.request.contextPath}/assets/img/favicons/favicon.ico">
        <link rel="manifest" href="${pageContext.request.contextPath}/assets/img/favicons/manifest.json">
        <meta name="msapplication-TileImage"
            content="${pageContext.request.contextPath}/assets/img/favicons/mstile-150x150.png">
        <meta name="theme-color" content="#ffffff">
        <script src="${pageContext.request.contextPath}/assets/js/config.js"></script>
        <script src="${pageContext.request.contextPath}/vendors/simplebar/simplebar.min.js"></script>

        <link rel="preconnect" href="https://fonts.gstatic.com/">
        <link
            href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap"
            rel="stylesheet">
        <link href="${pageContext.request.contextPath}/vendors/simplebar/simplebar.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/theme-rtl.min.css" rel="stylesheet" id="style-rtl">
        <link href="${pageContext.request.contextPath}/assets/css/theme.min.css" rel="stylesheet" id="style-default">
        <link href="${pageContext.request.contextPath}/assets/css/user-rtl.min.css" rel="stylesheet"
            id="user-style-rtl">
        <link href="${pageContext.request.contextPath}/assets/css/user.min.css" rel="stylesheet"
            id="user-style-default">

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
            body,
            .main,
            p,
            div,
            span,
            select,
            input,
            button,
            textarea,
            .card-value,
            .card-detail-text,
            h4,
            h3,
            h5,
            .fs--1,
            .fs--2 {
                font-family: 'Plus Jakarta Sans', sans-serif !important;
            }

            h1,
            h2,
            h3,
            h4,
            h5,
            h6,
            .fw-bold,
            .fw-extrabold,
            .card-title-sub,
            .section-title,
            .navbar-brand {
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

            .glass-card {
                background: rgba(255, 255, 255, 0.75) !important;
                backdrop-filter: blur(12px) !important;
                -webkit-backdrop-filter: blur(12px) !important;
                border: 1px solid rgba(226, 232, 240, 0.8) !important;
                box-shadow: 0 4px 15px rgba(0, 0, 0, 0.03) !important;
                transition: transform 0.25s ease, box-shadow 0.25s ease, border-color 0.25s ease !important;
                cursor: pointer;
            }

            html.dark .glass-card {
                background: rgba(15, 23, 42, 0.45) !important;
                border: 1px solid rgba(255, 255, 255, 0.08) !important;
                box-shadow: 0 10px 30px rgba(0, 0, 0, 0.25) !important;
            }

            .glass-card:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 24px rgba(99, 102, 241, 0.12) !important;
                border-color: rgba(99, 102, 241, 0.3) !important;
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
                                    <h4 class="mb-0 text-primary fw-bold" style="font-size: 1.25rem;">Device Finance
                                        Analytics Dashboard</h4>
                                </div>
                                <div class="d-flex align-items-center gap-3">
                                    <div class="d-flex align-items-center gap-2"
                                        style="border-right: 1px solid rgba(226, 232, 240, 0.8); padding-right: 10px;">
                                        <span class="text-muted fs--2 fw-semi-bold"><i
                                                class="fas fa-filter me-1"></i>Product:</span>
                                        <select class="form-select form-select-sm fw-bold text-primary"
                                            id="productFilterSelect" onchange="onProductChange()"
                                            style="font-size: 0.75rem; padding: 2px 25px 2px 10px; width: auto; border-radius: 4px; border: 1px solid #cbd5e1; cursor: pointer;">
                                            <option value="MF" selected>Mobile Finance (MF)</option>
                                            <option value="LF">Laptop Finance (LF)</option>
                                        </select>
                                    </div>
                                    <div class="text-muted fs--2 fw-semi-bold" id="sync-time-badge"
                                        style="border-right: 1px solid rgba(226, 232, 240, 0.8); padding-right: 10px;">
                                        Last Synced: <span class="fw-bold text-dark dark__text-white"
                                            id="last-sync-timestamp">Loading...</span>
                                    </div>
                                    <button class="btn btn-sm btn-primary d-flex align-items-center gap-1 fw-bold"
                                        id="btn-sync-now" onclick="triggerManualSync()"
                                        style="font-size: 0.68rem; padding: 4px 10px; border-radius: 4px;">
                                        <i class="fas fa-sync-alt" id="sync-icon"></i> <span id="sync-btn-text">Sync
                                            Now</span>
                                    </button>
                                </div>
                            </div>

                             <!-- Row 1: KPI Cards (6 Cards) -->
                             <div class="row g-2 mb-2">
                                 <!-- 1. Month Disbursement -->
                                   <div class="col-lg col-md-3 col-sm-6">
                                       <div class="card kpi-card shadow-sm h-100"
                                           style="border-left: 3px solid #6366f1 !important; cursor: pointer; transition: all 0.2s ease-in-out;">
                                           <div class="card-body p-2 d-flex flex-column justify-content-between">
                                               <div>
                                                   <span class="card-title-sub text-muted">MONTH DISBURSEMENT</span>
                                                   <div class="card-value text-primary" id="kpi-month-amount">0.00 Mn</div>
                                                   <div class="card-detail-text text-muted" id="kpi-month-count">0 Accounts</div>
                                               </div>
                                           </div>
                                       </div>
                                   </div>
                                   <!-- Empty KPI Card 1 -->
                                   <div class="col-lg col-md-3 col-sm-6">
                                       <div class="card kpi-card shadow-sm h-100"
                                           style="border-left: 3px solid #cbd5e1 !important; cursor: default; transition: all 0.2s ease-in-out; opacity: 0.7;">
                                           <div class="card-body p-2 d-flex flex-column justify-content-between">
                                               <div>
                                                   <span class="card-title-sub text-muted">INFO</span>
                                                   <div class="card-value text-muted">-</div>
                                                   <div class="card-detail-text text-muted">-</div>
                                               </div>
                                           </div>
                                       </div>
                                   </div>
                                   <!-- Empty KPI Card 2 -->
                                   <div class="col-lg col-md-3 col-sm-6">
                                       <div class="card kpi-card shadow-sm h-100"
                                           style="border-left: 3px solid #cbd5e1 !important; cursor: default; transition: all 0.2s ease-in-out; opacity: 0.7;">
                                           <div class="card-body p-2 d-flex flex-column justify-content-between">
                                               <div>
                                                   <span class="card-title-sub text-muted">INFO</span>
                                                   <div class="card-value text-muted">-</div>
                                                   <div class="card-detail-text text-muted">-</div>
                                               </div>
                                           </div>
                                       </div>
                                   </div>
                                  <!-- 2. Active Portfolio -->
                                  <div class="col-lg col-md-3 col-sm-6">
                                      <div class="card kpi-card shadow-sm h-100"
                                          style="border-left: 3px solid #10b981 !important; cursor: pointer; transition: all 0.2s ease-in-out;">
                                          <div class="card-body p-2 d-flex flex-column justify-content-between">
                                              <div>
                                                  <span class="card-title-sub text-muted">ACTIVE PORTFOLIO</span>
                                                  <div class="card-value text-success" id="kpi-portfolio-amount">0.00 Mn</div>
                                                  <div class="card-detail-text text-muted" id="kpi-portfolio-count">0 Accounts</div>
                                              </div>
                                          </div>
                                      </div>
                                  </div>
                                  <!-- 3. DPD 0 Portfolio -->
                                  <div class="col-lg col-md-3 col-sm-6">
                                      <div class="card kpi-card shadow-sm h-100"
                                          style="border-left: 3px solid #2563eb !important; cursor: pointer; transition: all 0.2s ease-in-out;">
                                          <div class="card-body p-2 d-flex flex-column justify-content-between">
                                              <div>
                                                  <span class="card-title-sub text-muted">DPD 0 PORTFOLIO</span>
                                                  <div class="card-value text-primary" id="kpi-dpd-zero-amount">0.00 Mn</div>
                                                  <div class="card-detail-text text-muted" id="kpi-dpd-zero-count">0 Accounts</div>
                                              </div>
                                          </div>
                                      </div>
                                  </div>
                                  <!-- 4. Arrears Portfolio (was DPD Arrears) -->
                                  <div class="col-lg col-md-3 col-sm-6">
                                      <div class="card kpi-card shadow-sm h-100"
                                          style="border-left: 3px solid #dc2626 !important; cursor: pointer; transition: all 0.2s ease-in-out;">
                                          <div class="card-body p-2 d-flex flex-column justify-content-between">
                                              <div>
                                                  <span class="card-title-sub text-muted">Arrears Portfolio</span>
                                                  <div class="card-value text-danger" id="kpi-perf-arrears-amount">0.00 Mn</div>
                                                  <div class="card-detail-text text-muted" id="kpi-perf-arrears-count">0 Accounts</div>
                                              </div>
                                          </div>
                                      </div>
                                  </div>
                                  <!-- 5. NPL Exposure -->
                                  <div class="col-lg col-md-3 col-sm-6">
                                      <div class="card kpi-card shadow-sm h-100"
                                          style="border-left: 3px solid #ef4444 !important; cursor: pointer; transition: all 0.2s ease-in-out;">
                                          <div class="card-body p-2 d-flex flex-column justify-content-between">
                                              <div>
                                                  <span class="card-title-sub text-muted">NPL PORTFOLIO</span>
                                                  <div class="card-value text-danger" id="kpi-npl-exposure">0.00 Mn</div>
                                                  <div class="card-detail-text text-muted" id="kpi-npl-count">0 Accounts</div>
                                              </div>
                                          </div>
                                      </div>
                                  </div>
                                  <!-- 6. Settled Month -->
                                  <div class="col-lg col-md-3 col-sm-6">
                                      <div class="card kpi-card shadow-sm h-100"
                                          style="border-left: 3px solid #f59e0b !important; cursor: pointer; transition: all 0.2s ease-in-out;">
                                          <div class="card-body p-2 d-flex flex-column justify-content-between">
                                              <div>
                                                  <span class="card-title-sub text-muted">SETTLED MONTH</span>
                                                  <div class="card-value text-warning" id="kpi-settled-amount">0.00 Mn</div>
                                                  <div class="card-detail-text text-muted" id="kpi-settled-count">0 Accounts</div>
                                              </div>
                                          </div>
                                      </div>
                                  </div>
                             </div>


                            <!-- Row 2: Charts (Disbursements, DPD Status, and Daily Disbursements) -->
                            <div class="row g-2 mb-2">
                                <!-- Left: Month-Wise Disbursements (1/3 width) -->
                                <div class="col-lg-4 col-12">
                                    <div class="card shadow-sm h-100">
                                        <div class="card-body p-2">
                                            <div class="fs--2 fw-semi-bold text-muted mb-1"><i
                                                    class="fas fa-chart-line me-1"></i>Month-Wise Disbursements</div>
                                            <div style="height: 155px; position: relative; width: 100%;">
                                                <canvas id="businessChart"></canvas>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Middle: Daily Disbursements (Past 7 Days) (1/3 width) -->
                                <div class="col-lg-4 col-12">
                                    <div class="card shadow-sm h-100">
                                        <div class="card-body p-2">
                                            <div class="fs--2 fw-semi-bold text-muted mb-2"><i
                                                    class="fas fa-money-check-alt me-1"></i>Daily Disbursements (Past 7
                                                Days)</div>
                                            <div style="height: 155px; position: relative; width: 100%;">
                                                <canvas id="vendorPaymentsChart"></canvas>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Right: DPD Status (Overdue Portfolio) (1/3 width) -->
                                <div class="col-lg-4 col-12">
                                    <div class="card shadow-sm h-100">
                                        <div class="card-body p-2">
                                            <div class="fs--2 fw-semi-bold text-muted mb-1"><i
                                                    class="fas fa-chart-bar me-1"></i>DPD Status (Overdue Portfolio)
                                            </div>
                                            <div style="height: 155px; position: relative; width: 100%;">
                                                <canvas id="dpdComparisonChart"></canvas>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>



                            <!-- Row 3: Risk & Performance Charts (All 5 cards side-by-side, vertical content orientation) -->
                            <div class="row g-2 mb-2" style="margin-top: 4px;">
                                <!-- Card 1: Mobile Arrears: Lock vs Unlock -->
                                <div class="col-lg-2 col-md-4 col-sm-6 col-12" id="mobile-lock-arrears-card">
                                    <div class="card glass-card h-100">
                                        <div class="card-body p-2">
                                            <div class="fs--2 fw-semi-bold text-muted mb-2 text-truncate"><i
                                                    class="fas fa-lock me-1"></i>Mobile Arrears: Lock vs Unlock</div>
                                            <div style="height: 260px; position: relative; width: 100%;">
                                                <canvas id="mobileLockArrearsChart"></canvas>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Card 2: Transaction Channels -->
                                <div class="col-lg-3 col-md-4 col-sm-6 col-12" id="transaction-channels-card">
                                    <div class="card glass-card h-100">
                                        <div class="card-body p-2">
                                            <div class="fs--2 fw-semi-bold text-muted mb-2 text-truncate"><i
                                                    class="fas fa-chart-pie me-1"></i>Transaction Channels</div>
                                            <div style="height: 260px; position: relative; width: 100%;">
                                                <canvas id="transactionChannelChart"></canvas>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Card 3: Matured vs Non-Matured -->
                                <div class="col-lg-2 col-md-4 col-sm-6 col-12" id="matured-np-card">
                                    <div class="card glass-card h-100">
                                        <div class="card-body p-2">
                                            <div class="fs--2 fw-semi-bold text-muted mb-2 text-truncate"><i
                                                    class="fas fa-history me-1"></i>Matured vs Non-Matured</div>
                                            <div style="height: 260px; position: relative; width: 100%;">
                                                <canvas id="maturedNpChart"></canvas>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Card 4: Device Security Status (Stacked vertically inside) -->
                                <div class="col-lg-2 col-md-4 col-sm-6 col-12" id="device-security-status-card">
                                    <div class="card glass-card h-100">
                                        <div class="card-body p-2 d-flex flex-column justify-content-between">
                                            <div>
                                                <div class="fs--2 fw-semi-bold text-muted mb-2"><i
                                                        class="fas fa-hdd me-1"></i>Device Security Status</div>
                                                <div class="row g-1 align-items-center text-center">
                                                    <div class="col-12 mobile-sec-col mb-2">
                                                        <div class="fw-semi-bold text-muted"
                                                            style="font-size: 0.55rem; margin-bottom: 2px;">Mobiles
                                                            Performing</div>
                                                        <div style="height: 100px; position: relative; width: 100%;">
                                                            <canvas id="mobilePerformingChart"></canvas>
                                                        </div>
                                                    </div>
                                                    <div class="col-12 mobile-sec-col">
                                                        <div class="fw-semi-bold text-muted"
                                                            style="font-size: 0.55rem; margin-bottom: 2px;">Mobiles Lock
                                                        </div>
                                                        <div style="height: 100px; position: relative; width: 100%;">
                                                            <canvas id="mobileLockChart"></canvas>
                                                        </div>
                                                    </div>
                                                    <div class="col-12 laptop-sec-col mb-2" style="display: none;">
                                                        <div class="fw-semi-bold text-muted"
                                                            style="font-size: 0.55rem; margin-bottom: 2px;">Laptops
                                                            Performing</div>
                                                        <div style="height: 100px; position: relative; width: 100%;">
                                                            <canvas id="laptopPerformingChart"></canvas>
                                                        </div>
                                                    </div>
                                                    <div class="col-12 laptop-sec-col" style="display: none;">
                                                        <div class="fw-semi-bold text-muted"
                                                            style="font-size: 0.55rem; margin-bottom: 2px;">Laptops Lock
                                                        </div>
                                                        <div style="height: 100px; position: relative; width: 100%;">
                                                            <canvas id="laptopLockChart"></canvas>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="text-center text-muted mt-2 border-top pt-1"
                                                id="device-sec-text" style="font-size: 0.65rem; line-height: 1.1;">
                                                Device locks summary &bull; Active: <span id="sec-mobile-locked-val"
                                                    class="fw-bold text-danger">0</span> Mobiles
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Card 5: Payments Status-Wise -->
                                <div class="col-lg-3 col-md-4 col-sm-6 col-12" id="payments-status-wise-card">
                                    <div class="card glass-card h-100">
                                        <div class="card-body p-2 d-flex flex-column justify-content-between">
                                            <div>
                                                <div class="d-flex justify-content-between align-items-center mb-2">
                                                    <div class="fs--2 fw-semi-bold text-muted"><i
                                                            class="fas fa-hand-holding-usd me-1"></i>Payments
                                                        Status-Wise</div>
                                                </div>
                                                <div style="height: 260px; position: relative; width: 100%;">
                                                    <canvas id="collectionsDealerChart"></canvas>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- ======================== SCRIPTS ======================== -->
                            <script>
                                // Global chart instances to allow clean redrawing without hover issues
                                const activeCharts = {};
                                let selectedProduct = 'MF';

                                const formatLKR = (val) => {
                                    const millions = val / 1000000;
                                    return new Intl.NumberFormat('en-US', {
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
                                                backgroundColor: function (context) {
                                                    const chart = context.chart;
                                                    const { ctx: canvasCtx, chartArea } = chart;
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

                                function onProductChange() {
                                    selectedProduct = document.getElementById('productFilterSelect').value;
                                    loadDashboardData();
                                }

                                function destroyChart(canvasId) {
                                    if (activeCharts[canvasId]) {
                                        activeCharts[canvasId].destroy();
                                        delete activeCharts[canvasId];
                                    }
                                }

                                 const drawSparkline = (canvasId, dataPoints, strokeColor, fillColor) => {
                                     destroyChart(canvasId);
                                     const ctx = document.getElementById(canvasId).getContext('2d');
                                     
                                     let gradient = null;
                                     if (fillColor) {
                                         gradient = ctx.createLinearGradient(0, 0, 0, 30);
                                         gradient.addColorStop(0, fillColor);
                                         gradient.addColorStop(1, 'rgba(255, 255, 255, 0)');
                                     }

                                     activeCharts[canvasId] = new Chart(ctx, {
                                         type: 'line',
                                         data: {
                                             labels: dataPoints.map((_, i) => i),
                                             datasets: [{
                                                 data: dataPoints,
                                                 borderColor: strokeColor,
                                                 borderWidth: 1.5,
                                                 fill: !!gradient,
                                                 backgroundColor: gradient,
                                                 tension: 0.4,
                                                 pointRadius: 0,
                                                 pointHoverRadius: 2
                                             }]
                                         },
                                         options: {
                                             plugins: {
                                                 legend: { display: false },
                                                 tooltip: { enabled: false },
                                                 datalabels: { display: false }
                                             },
                                             scales: {
                                                 x: { display: false },
                                                 y: { display: false }
                                             },
                                             maintainAspectRatio: false,
                                             responsive: true
                                         }
                                     });
                                 };

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
                                    const productParam = selectedProduct ? '?product=' + encodeURIComponent(selectedProduct) : '';

                                    // ============ 1. Dashboard Stats (KPI Cards) ============
                                    fetch('${pageContext.request.contextPath}/api/dashboard/stats' + productParam)
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

                                            document.getElementById("kpi-perf-arrears-amount").innerText = formatLKR(data.perfArrearsAmount || 0);
                                            document.getElementById("kpi-perf-arrears-count").innerText = formatNum(data.perfArrearsCount || 0) + " Accounts";

                                            document.getElementById("kpi-dpd-zero-amount").innerText = formatLKR(data.dpdZeroPortfolioAmount || 0);
                                            document.getElementById("kpi-dpd-zero-count").innerText = formatNum(data.dpdZeroPortfolioCount || 0) + " Accounts";

                                        })
                                        .catch(err => console.error("Error fetching dashboard statistics:", err));

                                    // ============ 2. Month Wise Business Chart ============
                                    fetch('${pageContext.request.contextPath}/api/dashboard/business-chart' + productParam)
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
                                    fetch('${pageContext.request.contextPath}/api/dashboard/dpd-comparison-chart' + productParam)
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
                                                type: 'line',
                                                data: {
                                                    labels: labels,
                                                    datasets: [
                                                        {
                                                            label: 'DPD 0',
                                                            data: dpd0,
                                                            borderColor: '#10b981',
                                                            backgroundColor: 'rgba(16, 185, 129, 0.05)',
                                                            borderWidth: 2,
                                                            tension: 0.2,
                                                            pointRadius: 3,
                                                            fill: false
                                                        },
                                                        {
                                                            label: 'DPD 1-30',
                                                            data: dpd1_30,
                                                            borderColor: '#f59e0b',
                                                            backgroundColor: 'rgba(245, 158, 11, 0.05)',
                                                            borderWidth: 2,
                                                            tension: 0.2,
                                                            pointRadius: 3,
                                                            fill: false
                                                        },
                                                        {
                                                            label: 'DPD 31-60',
                                                            data: dpd31_60,
                                                            borderColor: '#f97316',
                                                            backgroundColor: 'rgba(249, 115, 22, 0.05)',
                                                            borderWidth: 2,
                                                            tension: 0.2,
                                                            pointRadius: 3,
                                                            fill: false
                                                        },
                                                        {
                                                            label: 'DPD 61-90',
                                                            data: dpd61_90,
                                                            borderColor: '#ef4444',
                                                            backgroundColor: 'rgba(239, 68, 68, 0.05)',
                                                            borderWidth: 2,
                                                            tension: 0.2,
                                                            pointRadius: 3,
                                                            fill: false
                                                        },
                                                        {
                                                            label: 'Over 90 DPD',
                                                            data: dpdAbove90,
                                                            borderColor: isDark ? '#a78bfa' : '#1e293b',
                                                            backgroundColor: isDark ? 'rgba(167, 139, 250, 0.05)' : 'rgba(30, 41, 59, 0.05)',
                                                            borderWidth: 2,
                                                            tension: 0.2,
                                                            pointRadius: 3,
                                                            fill: false
                                                        }
                                                    ]
                                                },
                                                options: {
                                                    responsive: true,
                                                    maintainAspectRatio: false,
                                                    scales: {
                                                        x: {
                                                            stacked: false,
                                                            grid: { display: false },
                                                            ticks: { color: isDark ? '#94a3b8' : '#475569', font: { size: 9, weight: 'bold' } }
                                                        },
                                                        y: {
                                                            stacked: false,
                                                            beginAtZero: true,
                                                            grid: { color: isDark ? 'rgba(255,255,255,0.05)' : 'rgba(0,0,0,0.05)' },
                                                            ticks: {
                                                                color: isDark ? '#94a3b8' : '#475569',
                                                                font: { size: 9 },
                                                                callback: function (value) {
                                                                    return value + ' Mn';
                                                                }
                                                            }
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


                                    // ============ 6. Device Status Charts ============
                                    fetch('${pageContext.request.contextPath}/api/dashboard/device-status-charts' + productParam)
                                        .then(res => res.json())
                                        .then(data => {
                                            // Helper function for small doughnut charts
                                             const buildDoughnut = (canvasId, dataset, labelsList, colorsList) => {
                                                 destroyChart(canvasId);
                                                 const labels = dataset.map(item => item.state_name);
                                                 const counts = dataset.map(item => item.count_val);
 
                                                 let finalColors = colorsList;
                                                 if (labels.length) {
                                                     finalColors = labels.map(label => {
                                                         const lowerLabel = label.toLowerCase();
                                                         if (lowerLabel === 'performing' || lowerLabel === 'unlocked' || lowerLabel === 'active' || lowerLabel === 'un-locked') {
                                                             return 'rgba(16, 185, 129, 0.85)'; // Green
                                                         }
                                                         if (lowerLabel === 'non-performing' || lowerLabel === 'locked') {
                                                             return 'rgba(239, 68, 68, 0.85)'; // Red
                                                         }
                                                         return 'rgba(156, 163, 175, 0.85)'; // Gray fallback
                                                     });
                                                 }

                                                 const centerTextPlugin = {
                                                     id: 'centerTextPlugin',
                                                     beforeDraw: function (chart) {
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
                                                             backgroundColor: finalColors,
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
                                                                formatter: (value, context) => {
                                                                    let sum = context.chart.data.datasets[0].data.reduce((a, b) => a + b, 0);
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

                                            if (selectedProduct === 'MF') {
                                                document.querySelectorAll('.mobile-sec-col').forEach(el => el.style.display = '');
                                                document.querySelectorAll('.laptop-sec-col').forEach(el => el.style.display = 'none');

                                                let mobileLocked = 0;
                                                if (data.mobileLock) {
                                                    data.mobileLock.forEach(item => {
                                                        if (item.state_name === 'Locked') mobileLocked = item.count_val || 0;
                                                    });
                                                }
                                                document.getElementById("device-sec-text").innerHTML = 'Device locks summary &bull; Active: <span class="fw-bold text-danger">' + formatNum(mobileLocked) + '</span> Mobiles';

                                                buildDoughnut('mobilePerformingChart', data.mobilePerforming || [], ['Performing', 'Non-Performing'], ['rgba(16, 185, 129, 0.85)', 'rgba(244, 63, 94, 0.85)']);
                                                buildDoughnut('mobileLockChart', data.mobileLock || [], ['Active', 'Locked'], ['rgba(99, 102, 241, 0.85)', 'rgba(245, 158, 11, 0.85)']);
                                            } else {
                                                document.querySelectorAll('.mobile-sec-col').forEach(el => el.style.display = 'none');
                                                document.querySelectorAll('.laptop-sec-col').forEach(el => el.style.display = '');

                                                let laptopLocked = 0;
                                                if (data.laptopLock) {
                                                    data.laptopLock.forEach(item => {
                                                        if (item.state_name === 'Locked') laptopLocked = item.count_val || 0;
                                                    });
                                                }
                                                document.getElementById("device-sec-text").innerHTML = 'Device locks summary &bull; Active: <span class="fw-bold text-danger">' + formatNum(laptopLocked) + '</span> Laptops';

                                                buildDoughnut('laptopPerformingChart', data.laptopPerforming || [], ['Performing', 'Non-Performing'], ['rgba(16, 185, 129, 0.85)', 'rgba(244, 63, 94, 0.85)']);
                                                buildDoughnut('laptopLockChart', data.laptopLock || [], ['Active', 'Locked'], ['rgba(99, 102, 241, 0.85)', 'rgba(245, 158, 11, 0.85)']);
                                            }
                                        })
                                        .catch(err => console.error("Error loading security doughnut status:", err));

                                    // ============ 7. Daily Disbursements (Past 7 Days) ============
                                    fetch('${pageContext.request.contextPath}/api/dashboard/vendor-payments-chart' + productParam)
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

                                    // ============ 8. Payments Status-Wise Chart ============
                                    loadPaymentsStatusChart();



                                    // ============ 9. Mobile Arrears Lock vs Unlock ============
                                    const arrearsCard = document.getElementById('mobile-lock-arrears-card');
                                    if (selectedProduct === 'LF') {
                                        if (arrearsCard) arrearsCard.style.display = 'none';
                                    } else {
                                        if (arrearsCard) arrearsCard.style.display = '';
                                    }

                                    if (selectedProduct !== 'LF') {
                                        fetch('${pageContext.request.contextPath}/api/dashboard/mobile-lock-arrears')
                                            .then(res => res.json())
                                            .then(data => {
                                                // 1. Mobile Lock vs Unlock Chart
                                                destroyChart('mobileLockArrearsChart');
                                                const ctx1 = document.getElementById('mobileLockArrearsChart').getContext('2d');
                                                activeCharts['mobileLockArrearsChart'] = new Chart(ctx1, {
                                                    type: 'bar',
                                                    data: {
                                                        labels: ['Lock (<200)', 'Unlock (>=200)'],
                                                        datasets: [{
                                                            data: [
                                                                data.lock_but_less_200 || 0,
                                                                data.unlock_but_more_200 || 0
                                                            ],
                                                            backgroundColor: [
                                                                'rgba(239, 68, 68, 0.85)',
                                                                'rgba(16, 185, 129, 0.85)'
                                                            ],
                                                            borderWidth: 0,
                                                            borderRadius: 4,
                                                            barThickness: 36
                                                        }]
                                                    },
                                                    options: {
                                                        responsive: true,
                                                        maintainAspectRatio: false,
                                                        layout: { padding: { top: 20 } },
                                                        plugins: {
                                                            legend: { display: false },
                                                            tooltip: { enabled: true },
                                                            datalabels: {
                                                                display: true,
                                                                anchor: 'end',
                                                                align: 'top',
                                                                color: isDark ? '#cbd5e1' : '#1e293b',
                                                                font: { weight: 'bold', size: 9 },
                                                                formatter: (val) => val > 0 ? formatNum(val) : '0'
                                                            }
                                                        },
                                                        scales: {
                                                            x: { grid: { display: false }, ticks: { color: isDark ? '#94a3b8' : '#475569', font: { size: 9, weight: 'bold' } } },
                                                            y: { display: false, grid: { display: false } }
                                                        }
                                                    }
                                                });
                                            })
                                            .catch(err => console.error("Error loading Mobile lock arrears analysis:", err));
                                    }

                                    // ============ 9.1 Transaction Channels Pie Chart ============
                                    fetch('${pageContext.request.contextPath}/api/dashboard/transaction-channel-chart' + productParam)
                                        .then(res => res.json())
                                        .then(data => {
                                            destroyChart('transactionChannelChart');
                                            const labels = data.map(i => i.channel_name);
                                            const amounts = data.map(i => i.total_amount);
                                            const ctx2 = document.getElementById('transactionChannelChart').getContext('2d');
                                            activeCharts['transactionChannelChart'] = new Chart(ctx2, {
                                                type: 'pie',
                                                data: {
                                                    labels: labels,
                                                    datasets: [{
                                                        data: amounts,
                                                        backgroundColor: [
                                                            'rgba(16, 185, 129, 0.85)',
                                                            'rgba(59, 130, 246, 0.85)',
                                                            'rgba(245, 158, 11, 0.85)',
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
                                                            display: true,
                                                            position: 'bottom',
                                                            labels: {
                                                                boxWidth: 8,
                                                                padding: 4,
                                                                color: isDark ? '#94a3b8' : '#475569',
                                                                font: { size: 8, weight: 'bold' }
                                                            }
                                                        },
                                                        tooltip: { enabled: true },
                                                        datalabels: {
                                                            display: true,
                                                            color: isDark ? '#cbd5e1' : '#1e293b',
                                                            font: { weight: 'bold', size: 9 },
                                                            formatter: (val) => val > 0 ? formatLKR(val) : ''
                                                        }
                                                    }
                                                }
                                            });
                                        })
                                        .catch(err => console.error("Error loading transaction channels pie chart:", err));

                                    // ============ 10. Matured vs Non-Matured Contracts Performance ============
                                    fetch('${pageContext.request.contextPath}/api/dashboard/matured-nonperforming' + productParam)
                                        .then(res => res.json())
                                        .then(data => {
                                            let maturedPerf = 0, maturedNp = 0, nonMaturedPerf = 0, nonMaturedNp = 0;
                                            data.forEach(item => {
                                                const isMatured = item.maturity_status === 'Matured';
                                                const isNp = item.performing_status === 'Non-Performing';
                                                if (isMatured) {
                                                    if (isNp) maturedNp = item.contract_count || 0;
                                                    else maturedPerf = item.contract_count || 0;
                                                } else {
                                                    if (isNp) nonMaturedNp = item.contract_count || 0;
                                                    else nonMaturedPerf = item.contract_count || 0;
                                                }
                                            });

                                            destroyChart('maturedNpChart');
                                            const ctx = document.getElementById('maturedNpChart').getContext('2d');
                                            activeCharts['maturedNpChart'] = new Chart(ctx, {
                                                type: 'bar',
                                                data: {
                                                    labels: ['Mat Perf', 'Mat NP', 'Non-Mat Perf', 'Non-Mat NP'],
                                                    datasets: [
                                                        {
                                                            data: [maturedPerf, maturedNp, nonMaturedPerf, nonMaturedNp],
                                                            backgroundColor: [
                                                                'rgba(16, 185, 129, 0.85)',
                                                                'rgba(239, 68, 68, 0.85)',
                                                                'rgba(16, 185, 129, 0.85)',
                                                                'rgba(239, 68, 68, 0.85)'
                                                            ],
                                                            borderWidth: 0,
                                                            borderRadius: 4,
                                                            barThickness: 28
                                                        }
                                                    ]
                                                },
                                                options: {
                                                    responsive: true,
                                                    maintainAspectRatio: false,
                                                    plugins: {
                                                        legend: {
                                                            display: false
                                                        },
                                                        tooltip: { enabled: true },
                                                        datalabels: {
                                                            display: true,
                                                            anchor: 'end',
                                                            align: 'top',
                                                            color: isDark ? '#cbd5e1' : '#1e293b',
                                                            font: { weight: 'bold', size: 8 },
                                                            formatter: (val) => val > 0 ? formatNum(val) : '',
                                                            overflow: 'allow',
                                                            clip: false
                                                        }
                                                    },
                                                    scales: {
                                                        x: {
                                                            grid: { display: false },
                                                            ticks: { color: isDark ? '#94a3b8' : '#475569', font: { size: 7, weight: 'bold' } }
                                                        },
                                                        y: {
                                                            display: false,
                                                            grid: { display: false }
                                                        }
                                                    }
                                                }
                                            });
                                        })
                                        .catch(err => console.error("Error loading matured contract performance analysis:", err));
                                }


                                 function loadPaymentsStatusChart() {
                                     const productParam = selectedProduct ? '?product=' + encodeURIComponent(selectedProduct) : '';
                                     fetch('${pageContext.request.contextPath}/api/dashboard/payments-status-chart' + productParam)
                                         .then(res => res.json())
                                         .then(data => {
                                             const months = [...new Set(data.map(i => i.month_name))];
                                             
                                             const completedData = months.map(m => {
                                                 const found = data.find(i => i.month_name === m && i.status_name.toLowerCase() === 'completed');
                                                 return found ? found.count_val : 0;
                                             });
                                             const pendingData = months.map(m => {
                                                 const found = data.find(i => i.month_name === m && i.status_name.toLowerCase() === 'pending');
                                                 return found ? found.count_val : 0;
                                             });
                                             const failedData = months.map(m => {
                                                 const found = data.find(i => i.month_name === m && i.status_name.toLowerCase() === 'failed');
                                                 return found ? found.count_val : 0;
                                             });

                                             destroyChart('collectionsDealerChart');
                                             const ctx = document.getElementById('collectionsDealerChart').getContext('2d');
                                             activeCharts['collectionsDealerChart'] = new Chart(ctx, {
                                                 type: 'bar',
                                                 data: {
                                                     labels: months,
                                                     datasets: [
                                                         {
                                                             label: 'Completed',
                                                             data: completedData,
                                                             backgroundColor: 'rgba(16, 185, 129, 0.85)',
                                                             borderRadius: 4,
                                                             barThickness: 28
                                                         },
                                                         {
                                                             label: 'Pending',
                                                             data: pendingData,
                                                             backgroundColor: 'rgba(245, 158, 11, 0.85)',
                                                             borderRadius: 4,
                                                             barThickness: 28
                                                         },
                                                         {
                                                             label: 'Failed',
                                                             data: failedData,
                                                             backgroundColor: 'rgba(239, 68, 68, 0.85)',
                                                             borderRadius: 4,
                                                             barThickness: 28
                                                         }
                                                     ]
                                                 },
                                                 options: {
                                                     responsive: true,
                                                     maintainAspectRatio: false,
                                                     plugins: {
                                                         legend: {
                                                             display: true,
                                                             position: 'top',
                                                             labels: { boxWidth: 8, padding: 6, color: isDark ? '#94a3b8' : '#475569', font: { size: 8, weight: 'bold' } }
                                                         },
                                                         tooltip: { enabled: true },
                                                         datalabels: {
                                                             display: true,
                                                             color: isDark ? '#cbd5e1' : '#1e293b',
                                                             anchor: 'end',
                                                             align: 'top',
                                                             font: { weight: 'bold', size: 8 },
                                                             formatter: (val) => val > 0 ? formatNum(val) : '',
                                                             overflow: 'allow',
                                                             clip: false
                                                         }
                                                     },
                                                     scales: {
                                                         x: {
                                                             grid: { display: false },
                                                             ticks: { color: isDark ? '#94a3b8' : '#475569', font: { size: 8, weight: 'bold' } }
                                                         },
                                                         y: {
                                                             display: false,
                                                             grid: { display: false }
                                                         }
                                                     }
                                                 }
                                             });
                                         })
                                         .catch(err => console.error("Error loading payments status:", err));
                                 }

                                 document.addEventListener("DOMContentLoaded", function () {
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