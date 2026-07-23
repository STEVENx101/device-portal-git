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
        <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,500,600,700%7cPoppins:300,400,500,600,700,800,900&amp;display=swap" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/vendors/simplebar/simplebar.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/theme-rtl.min.css" rel="stylesheet" id="style-rtl">
        <link href="${pageContext.request.contextPath}/assets/css/theme.min.css" rel="stylesheet" id="style-default">
        <link href="${pageContext.request.contextPath}/assets/css/user-rtl.min.css" rel="stylesheet" id="user-style-rtl">
        <link href="${pageContext.request.contextPath}/assets/css/user.min.css" rel="stylesheet" id="user-style-default">
        
        <!-- Chart.js for premium analytics rendering -->
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

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
            .card-title-sub {
                font-size: 0.8rem;
                opacity: 0.85;
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 0.05em;
            }
            .card-value {
                font-size: 2rem;
                font-weight: 800;
                margin-top: 0.5rem;
            }
            .card-detail-text {
                font-size: 0.78rem;
                opacity: 0.9;
                margin-top: 0.25rem;
            }
            .chart-container {
                position: relative;
                height: 280px;
                width: 100%;
            }
            .content {
                overflow-y: auto !important;
                height: calc(100vh - 20px) !important;
                padding-right: 15px !important;
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

                <div class="content">
                    <%@include file="../jspf/topbar.jspf" %>

                    <div class="d-flex mb-3 align-items-center justify-content-between mt-2">
                        <div>
                            <h4 class="mb-0 text-primary"><i class="fas fa-tachometer-alt me-2"></i>Device Finance Analytics Dashboard</h4>
                        </div>
                    </div>

                    <!-- KPI Cards Row -->
                    <div class="row g-3 mb-4">
                        <!-- Current Month Disbursements -->
                        <div class="col-md-3">
                            <div class="card glass-card kpi-card gradient-1 h-100 border-0">
                                <div class="card-body d-flex flex-column justify-content-between p-3">
                                    <div>
                                        <div class="card-title-sub"><i class="fas fa-hand-holding-usd me-2"></i>New Loans</div>
                                        <div class="card-value" id="kpi-current-month-loans">-</div>
                                    </div>
                                    <div class="card-detail-text">Disbursed this month</div>
                                </div>
                            </div>
                        </div>
                        <!-- Security Counts (Knox/Datacultr) -->
                        <div class="col-md-3">
                            <div class="card glass-card kpi-card gradient-2 h-100 border-0">
                                <div class="card-body d-flex flex-column justify-content-between p-3">
                                    <div>
                                        <div class="card-title-sub"><i class="fas fa-shield-alt me-2"></i>Platform Security</div>
                                        <div class="card-value" id="kpi-knox-count">-</div>
                                    </div>
                                    <div class="card-detail-text" id="kpi-security-details">Knox vs Datacultr</div>
                                </div>
                            </div>
                        </div>
                        <!-- Device Statuses -->
                        <div class="col-md-3">
                            <div class="card glass-card kpi-card gradient-3 h-100 border-0">
                                <div class="card-body d-flex flex-column justify-content-between p-3">
                                    <div>
                                        <div class="card-title-sub"><i class="fas fa-mobile-alt me-2"></i>Mobiles Locked</div>
                                        <div class="card-value" id="kpi-mobiles-locked">-</div>
                                    </div>
                                    <div class="card-detail-text" id="kpi-laptops-details">Laptops: - Locked</div>
                                </div>
                            </div>
                        </div>
                        <!-- Portfolio Status Counts -->
                        <div class="col-md-3">
                            <div class="card glass-card kpi-card gradient-4 h-100 border-0">
                                <div class="card-body d-flex flex-column justify-content-between p-3">
                                    <div>
                                        <div class="card-title-sub"><i class="fas fa-wallet me-2"></i>Portfolio Status</div>
                                        <div class="card-value" id="kpi-active-count">-</div>
                                    </div>
                                    <div class="card-detail-text" id="kpi-npl-arrears-details">Active / NPA / Arrears</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Charts Grid -->
                    <div class="row g-3 mb-4">
                        <!-- Arrears Analysis Chart -->
                        <div class="col-lg-6">
                            <div class="card glass-card h-100">
                                <div class="card-header py-2 d-flex align-items-center justify-content-between">
                                    <h6 class="mb-0 text-primary fw-bold"><i class="fas fa-chart-bar me-2"></i>Arrears Analysis by Product</h6>
                                </div>
                                <div class="card-body">
                                    <div class="chart-container">
                                        <canvas id="arrearsChart"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!-- DPD analysis -->
                        <div class="col-lg-6">
                            <div class="card glass-card h-100">
                                <div class="card-header py-2 d-flex align-items-center justify-content-between">
                                    <h6 class="mb-0 text-primary fw-bold"><i class="fas fa-chart-pie me-2"></i>DPD Analysis Distribution</h6>
                                </div>
                                <div class="card-body">
                                    <div class="chart-container">
                                        <canvas id="dpdChart"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Rankings and Dealer Statistics -->
                    <div class="row g-3 mb-4">
                        <!-- Dealer Current Month and Portfolio stats -->
                        <div class="col-lg-7">
                            <div class="card glass-card h-100">
                                <div class="card-header py-2">
                                    <h6 class="mb-0 text-primary fw-bold"><i class="fas fa-store me-2"></i>Dealer Business &amp; Collections Performance</h6>
                                </div>
                                <div class="card-body p-0">
                                    <div class="table-responsive">
                                        <table class="table table-striped align-middle mb-0 fs--1">
                                            <thead class="bg-200">
                                                <tr>
                                                    <th>Dealer Name</th>
                                                    <th class="text-end">Current Month Count</th>
                                                    <th class="text-end">Portfolio Count</th>
                                                    <th class="text-end">Collected (Month)</th>
                                                </tr>
                                            </thead>
                                            <tbody id="dealer-stats-tbody">
                                                <tr>
                                                    <td colspan="4" class="text-center text-500">Loading dealer stats...</td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Top NPL Rank tables -->
                        <div class="col-lg-5">
                            <div class="card glass-card h-100">
                                <div class="card-header py-2">
                                    <h6 class="mb-0 text-danger fw-bold"><i class="fas fa-exclamation-triangle me-2"></i>NPL Concentrations (Top 3)</h6>
                                </div>
                                <div class="card-body p-3">
                                    <div class="mb-3">
                                        <div class="fw-bold fs--1 mb-1 text-700">Highest NPL Models</div>
                                        <ul class="list-group list-group-flush fs--1" id="highest-npl-models-list">
                                            <li class="list-group-item text-center text-500 py-1">Loading...</li>
                                        </ul>
                                    </div>
                                    <div>
                                        <div class="fw-bold fs--1 mb-1 text-700">Highest NPL Dealers</div>
                                        <ul class="list-group list-group-flush fs--1" id="highest-npl-dealers-list">
                                            <li class="list-group-item text-center text-500 py-1">Loading...</li>
                                        </ul>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

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

        <script>
            let arrearsChart = null;
            let dpdChart = null;

            function formatNumber(num) {
                if (num == null) return "0.00";
                return parseFloat(num).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
            }

            // 1. Load Summary KPI Cards
            function loadSummaryKpis() {
                $.ajax({
                    url: '${pageContext.request.contextPath}/api/dashboard/summary-kpis',
                    type: 'GET',
                    success: function(data) {
                        $('#kpi-current-month-loans').text(data.currentMonthLoans != null ? data.currentMonthLoans : 0);
                        $('#kpi-knox-count').text(data.knoxCount != null ? data.knoxCount : 0);
                        $('#kpi-security-details').text('Knox: ' + (data.knoxCount || 0) + ' | Datacultr: ' + (data.dataculteCount || 0));

                        $('#kpi-mobiles-locked').text(data.mobileLocked != null ? data.mobileLocked : 0);
                        $('#kpi-laptops-details').text('Mobiles Unlocked: ' + (data.mobileUnlocked || 0) + ' | Laptops: ' + (data.laptopLocked || 0) + ' Locked / ' + (data.laptopUnlocked || 0) + ' Unlocked');

                        $('#kpi-active-count').text(data.activeCount != null ? data.activeCount : 0);
                        $('#kpi-npl-arrears-details').text('Active: ' + (data.activeCount || 0) + ' | NPA: ' + (data.nplCount || 0) + ' | Arrears: ' + (data.arrearsCount || 0));
                    },
                    error: function(err) {
                        console.error("Error loading KPI cards:", err);
                    }
                });
            }

            // 2. Load Arrears Chart
            function loadArrearsChart() {
                $.ajax({
                    url: '${pageContext.request.contextPath}/api/dashboard/arrears-analysis',
                    type: 'GET',
                    success: function(data) {
                        const arrearsLabels = [];
                        const arrearsVal = [];
                        const exposureVal = [];
                        if (data && Array.isArray(data)) {
                            data.forEach(item => {
                                arrearsLabels.push(item.label);
                                arrearsVal.push(item.arrears);
                                exposureVal.push(item.exposure);
                            });
                        }

                        const arrearsCtx = document.getElementById('arrearsChart').getContext('2d');
                        if (arrearsChart) arrearsChart.destroy();
                        arrearsChart = new Chart(arrearsCtx, {
                            type: 'bar',
                            data: {
                                labels: arrearsLabels,
                                datasets: [
                                    {
                                        label: 'Arrears Amount',
                                        data: arrearsVal,
                                        backgroundColor: 'rgba(99, 102, 241, 0.75)',
                                        borderColor: '#6366f1',
                                        borderWidth: 1
                                    },
                                    {
                                        label: 'Total Exposure',
                                        data: exposureVal,
                                        backgroundColor: 'rgba(168, 85, 247, 0.75)',
                                        borderColor: '#a855f7',
                                        borderWidth: 1
                                    }
                                ]
                            },
                            options: {
                                responsive: true,
                                maintainAspectRatio: false,
                                plugins: {
                                    legend: { position: 'bottom' }
                                }
                            }
                        });
                    },
                    error: function(err) {
                        console.error("Error loading Arrears chart:", err);
                    }
                });
            }

            // 3. Load DPD Analysis Chart
            function loadDpdChart() {
                $.ajax({
                    url: '${pageContext.request.contextPath}/api/dashboard/dpd-analysis',
                    type: 'GET',
                    success: function(data) {
                        const dpdLabels = [];
                        const dpdCounts = [];
                        if (data && Array.isArray(data)) {
                            data.forEach(item => {
                                dpdLabels.push(item.bucket);
                                dpdCounts.push(item.count);
                            });
                        }

                        const dpdCtx = document.getElementById('dpdChart').getContext('2d');
                        if (dpdChart) dpdChart.destroy();
                        dpdChart = new Chart(dpdCtx, {
                            type: 'pie',
                            data: {
                                labels: dpdLabels,
                                datasets: [{
                                    data: dpdCounts,
                                    backgroundColor: [
                                        '#10b981', // 0
                                        '#6366f1', // 1-30
                                        '#8b5cf6', // 31-60
                                        '#f59e0b', // 61-90
                                        '#ef4444', // 91-180
                                        '#b91c1c', // 181-270
                                        '#7f1d1d', // 271-360
                                        '#374151'  // Loss
                                    ]
                                }]
                            },
                            options: {
                                responsive: true,
                                maintainAspectRatio: false,
                                plugins: {
                                    legend: { position: 'right' }
                                }
                            }
                        });
                    },
                    error: function(err) {
                        console.error("Error loading DPD chart:", err);
                    }
                });
            }

            // 4. Load Dealer Performance Table
            function loadDealerPerformance() {
                $.ajax({
                    url: '${pageContext.request.contextPath}/api/dashboard/dealer-performance',
                    type: 'GET',
                    success: function(data) {
                        const dealerStatsTbody = $('#dealer-stats-tbody');
                        dealerStatsTbody.empty();

                        const dealerMap = {};
                        if (data.portfolioDealers) {
                            data.portfolioDealers.forEach(item => {
                                dealerMap[item.dealer_name] = {
                                    dealer_name: item.dealer_name,
                                    current_count: 0,
                                    portfolio_count: item.portfolio_count,
                                    collections: 0.0
                                };
                            });
                        }
                        if (data.currentMonthDealers) {
                            data.currentMonthDealers.forEach(item => {
                                if (!dealerMap[item.dealer_name]) {
                                    dealerMap[item.dealer_name] = { dealer_name: item.dealer_name, current_count: 0, portfolio_count: 0, collections: 0.0 };
                                }
                                dealerMap[item.dealer_name].current_count = item.business_count;
                            });
                        }
                        if (data.collectionsDealerWise) {
                            data.collectionsDealerWise.forEach(item => {
                                if (!dealerMap[item.dealer_name]) {
                                    dealerMap[item.dealer_name] = { dealer_name: item.dealer_name, current_count: 0, portfolio_count: 0, collections: 0.0 };
                                }
                                dealerMap[item.dealer_name].collections = item.total_collected;
                            });
                        }

                        const dealerList = Object.values(dealerMap);
                        if (dealerList.length === 0) {
                            dealerStatsTbody.append('<tr><td colspan="4" class="text-center text-500">No dealer data available</td></tr>');
                        } else {
                            dealerList.forEach(d => {
                                dealerStatsTbody.append(
                                    '<tr>' +
                                        '<td class="fw-bold">' + (d.dealer_name || '') + '</td>' +
                                        '<td class="text-end">' + (d.current_count || 0) + '</td>' +
                                        '<td class="text-end">' + (d.portfolio_count || 0) + '</td>' +
                                        '<td class="text-end text-success font-monospace fw-bold">LKR ' + formatNumber(d.collections) + '</td>' +
                                    '</tr>'
                                );
                            });
                        }
                    },
                    error: function(err) {
                        console.error("Error loading Dealer Performance:", err);
                        $('#dealer-stats-tbody').html('<tr><td colspan="4" class="text-center text-danger">Failed to load dealer data</td></tr>');
                    }
                });
            }

            // 5. Load Top NPL Concentrations
            function loadTopNpl() {
                $.ajax({
                    url: '${pageContext.request.contextPath}/api/dashboard/top-npl',
                    type: 'GET',
                    success: function(data) {
                        const nplModelsList = $('#highest-npl-models-list');
                        nplModelsList.empty();
                        if (data.highestNplModels && data.highestNplModels.length > 0) {
                            data.highestNplModels.slice(0, 3).forEach((m, idx) => {
                                nplModelsList.append('<li class="list-group-item d-flex justify-content-between align-items-center py-1"><span><span class="badge bg-soft-danger text-danger me-2">' + (idx + 1) + '</span>' + (m.model_name || '') + '</span><span class="badge bg-danger">' + (m.npl_count || 0) + ' NPLs</span></li>');
                            });
                        } else {
                            nplModelsList.append('<li class="list-group-item text-center text-500 py-1">No NPL model data</li>');
                        }

                        const nplDealersList = $('#highest-npl-dealers-list');
                        nplDealersList.empty();
                        if (data.highestNplDealers && data.highestNplDealers.length > 0) {
                            data.highestNplDealers.slice(0, 3).forEach((d, idx) => {
                                nplDealersList.append('<li class="list-group-item d-flex justify-content-between align-items-center py-1"><span><span class="badge bg-soft-danger text-danger me-2">' + (idx + 1) + '</span>' + (d.dealer_name || '') + '</span><span class="badge bg-danger">' + (d.npl_count || 0) + ' NPLs</span></li>');
                            });
                        } else {
                            nplDealersList.append('<li class="list-group-item text-center text-500 py-1">No NPL dealer data</li>');
                        }
                    },
                    error: function(err) {
                        console.error("Error loading Top NPL concentrations:", err);
                    }
                });
            }

            function initDashboard() {
                loadSummaryKpis();
                loadArrearsChart();
                loadDpdChart();
                loadDealerPerformance();
                loadTopNpl();
            }

            if (document.readyState === "complete" || document.readyState === "interactive") {
                initDashboard();
            } else {
                document.addEventListener('DOMContentLoaded', function() {
                    initDashboard();
                });
            }
        </script>

        <script src="${pageContext.request.contextPath}/assets/js/theme.js"></script>
    </body>
</html>