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

                    <!-- N-Status Metrics Card Row -->
                    <div class="row g-3 mb-4">
                        <div class="col-md-3">
                            <div class="card kpi-card gradient-1 shadow-sm h-100">
                                <div class="card-body p-3">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <span class="card-title-sub">Current Month Business</span>
                                            <div class="card-value" id="n-month-amount">LKR 0.00</div>
                                            <div class="card-detail-text" id="n-month-count">0 Accounts</div>
                                        </div>
                                        <div class="bg-white bg-opacity-20 rounded p-2 text-white">
                                            <i class="fas fa-calendar-day fa-lg"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="card kpi-card gradient-2 shadow-sm h-100">
                                <div class="card-body p-3">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <span class="card-title-sub">Year to Date (YTD)</span>
                                            <div class="card-value" id="n-ytd-amount">LKR 0.00</div>
                                            <div class="card-detail-text" id="n-ytd-count">0 Accounts</div>
                                        </div>
                                        <div class="bg-white bg-opacity-20 rounded p-2 text-white">
                                            <i class="fas fa-calendar-alt fa-lg"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="card kpi-card gradient-3 shadow-sm h-100">
                                <div class="card-body p-3">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <span class="card-title-sub">Portfolio</span>
                                            <div class="card-value" id="n-portfolio-amount">LKR 0.00</div>
                                            <div class="card-detail-text" id="n-portfolio-count">0 Accounts</div>
                                        </div>
                                        <div class="bg-white bg-opacity-20 rounded p-2 text-white">
                                            <i class="fas fa-briefcase fa-lg"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="card kpi-card gradient-4 shadow-sm h-100">
                                <div class="card-body p-3">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <span class="card-title-sub">NPL</span>
                                            <div class="card-value" id="n-npl-exposure">LKR 0.00</div>
                                            <div class="card-detail-text" id="n-npl-count">0 Accounts (Arrears: LKR 0)</div>
                                        </div>
                                        <div class="bg-white bg-opacity-20 rounded p-2 text-white">
                                            <i class="fas fa-exclamation-triangle fa-lg"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Interactive Analytics Charts Row -->
                    <div class="row g-3 mb-4">
                        <!-- Chart 1: DPD Bucket Analysis (LKR Millions) -->
                        <div class="col-lg-7">
                            <div class="card shadow-sm h-100">
                                <div class="card-header bg-light d-flex justify-content-between align-items-center py-2">
                                    <h6 class="mb-0 text-primary fw-bold"><i class="fas fa-chart-bar me-2"></i>DPD Bucket Analysis (LKR Millions)</h6>
                                    <div class="d-flex gap-2">
                                        <select class="form-select form-select-sm py-0" id="chartDimensionSelect" style="width: auto; height: 30px; font-size: 0.75rem;">
                                            <option value="dealer">Dealer Wise</option>
                                            <option value="security">Security Type</option>
                                            <option value="model">Model Wise</option>
                                        </select>
                                        <select class="form-select form-select-sm py-0" id="chartItemSelect" style="width: auto; min-width: 140px; height: 30px; font-size: 0.75rem;">
                                            <option value="all">All Items</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="card-body p-3 d-flex flex-column justify-content-center">
                                    <div class="chart-container" style="height: 320px; position: relative; width: 100%;">
                                        <canvas id="dpdBarChart"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Chart 2: Security locked/unlocked stats -->
                        <div class="col-lg-5">
                            <div class="card shadow-sm h-100">
                                <div class="card-header bg-light py-2">
                                    <h6 class="mb-0 text-primary fw-bold"><i class="fas fa-lock me-2"></i>Lock Status by Security Type</h6>
                                </div>
                                <div class="card-body p-3 d-flex flex-column justify-content-center">
                                    <div class="chart-container" style="height: 320px; position: relative; width: 100%;">
                                        <canvas id="securityChart"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Fetch and Render Script -->
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

                            // API statistics fetching
                            fetch('${pageContext.request.contextPath}/api/dashboard/stats')
                                .then(response => {
                                    if (!response.ok) {
                                        throw new Error("HTTP error " + response.status);
                                    }
                                    return response.json();
                                })
                                .then(data => {
                                    console.log("Dashboard Stats:", data);
                                    
                                    // Set N-Status Kpis (in Millions)
                                    document.getElementById("n-month-amount").innerText = formatLKR(data.nMonthAmount);
                                    document.getElementById("n-month-count").innerText = formatNum(data.nMonthCount) + " Accounts";
                                    
                                    document.getElementById("n-ytd-amount").innerText = formatLKR(data.nYtdAmount);
                                    document.getElementById("n-ytd-count").innerText = formatNum(data.nYtdCount) + " Accounts";
                                    
                                    document.getElementById("n-portfolio-amount").innerText = formatLKR(data.nPortfolioAmount);
                                    document.getElementById("n-portfolio-count").innerText = formatNum(data.nPortfolioCount) + " Accounts";
                                    
                                    document.getElementById("n-npl-exposure").innerText = formatLKR(data.nNplExposure);
                                    document.getElementById("n-npl-count").innerText = formatNum(data.nNplCount) + " Accounts (Arrears: " + formatLKR(data.nNplArrears) + ")";

                                    // Render Security Lock Chart
                                    if (data.securityStats) {
                                        renderSecurityChart(data.securityStats);
                                    }
                                })
                                .catch(err => {
                                    console.error("Error fetching dashboard statistics:", err);
                                });

                            // Chart.js: DPD Bar Chart Config & Handling
                            let dpdChart = null;
                            let rawDpdData = [];

                            const updateDpdChart = (labels, datasetData) => {
                                const ctx = document.getElementById('dpdBarChart').getContext('2d');
                                if (dpdChart) {
                                    dpdChart.destroy();
                                }
                                dpdChart = new Chart(ctx, {
                                    type: 'bar',
                                    data: {
                                        labels: labels,
                                        datasets: [{
                                            label: 'Exposure (LKR Mn)',
                                            data: datasetData,
                                            backgroundColor: [
                                                'rgba(16, 185, 129, 0.75)',  // DPD 0
                                                'rgba(245, 158, 11, 0.75)',  // DPD 1-30
                                                'rgba(249, 115, 22, 0.75)',  // DPD 31-60
                                                'rgba(239, 68, 68, 0.75)',   // DPD 61-90
                                                'rgba(30, 41, 59, 0.75)'     // Over 90
                                            ],
                                            borderColor: [
                                                '#10b981',
                                                '#f59e0b',
                                                '#f97316',
                                                '#ef4444',
                                                '#1e293b'
                                            ],
                                            borderWidth: 1.5,
                                            borderRadius: 6
                                        }]
                                    },
                                    options: {
                                        responsive: true,
                                        maintainAspectRatio: false,
                                        plugins: {
                                            legend: { display: false }
                                        },
                                        scales: {
                                            y: {
                                                beginAtZero: true,
                                                ticks: {
                                                    callback: function(value) { return 'LKR ' + value + 'M'; }
                                                }
                                            }
                                        }
                                    }
                                });
                            };

                            const loadDpdChartData = () => {
                                const dim = document.getElementById('chartDimensionSelect').value;
                                fetch('${pageContext.request.contextPath}/api/dashboard/dpd-chart-data?dimension=' + dim)
                                .then(res => res.json())
                                .then(resData => {
                                    rawDpdData = resData || [];
                                    const itemSelect = document.getElementById('chartItemSelect');
                                    itemSelect.innerHTML = '<option value="all">All Items</option>';
                                    rawDpdData.forEach(item => {
                                        const cat = item.category_name || 'Unknown';
                                        const opt = document.createElement('option');
                                        opt.value = cat;
                                        opt.innerText = cat;
                                        itemSelect.appendChild(opt);
                                    });
                                    renderFilteredDpdData();
                                })
                                .catch(err => console.error("Error loading DPD data for chart:", err));
                            };

                            const renderFilteredDpdData = () => {
                                const selectedItem = document.getElementById('chartItemSelect').value;
                                const labels = ['DPD 0', 'DPD 1-30', 'DPD 31-60', 'DPD 61-90', 'Over 90 DPD'];
                                let values = [0, 0, 0, 0, 0];

                                if (selectedItem === 'all') {
                                    rawDpdData.forEach(item => {
                                        values[0] += item.dpd0_val || 0;
                                        values[1] += item.dpd1_30_val || 0;
                                        values[2] += item.dpd31_60_val || 0;
                                        values[3] += item.dpd61_90_val || 0;
                                        values[4] += item.dpdAbove90_val || 0;
                                    });
                                } else {
                                    const found = rawDpdData.find(item => item.category_name === selectedItem);
                                    if (found) {
                                        values[0] = found.dpd0_val || 0;
                                        values[1] = found.dpd1_30_val || 0;
                                        values[2] = found.dpd31_60_val || 0;
                                        values[3] = found.dpd61_90_val || 0;
                                        values[4] = found.dpdAbove90_val || 0;
                                    }
                                }
                                // Convert raw values to Millions
                                values = values.map(v => Math.round((v / 1000000) * 100) / 100);
                                updateDpdChart(labels, values);
                            };

                            document.getElementById('chartDimensionSelect').addEventListener('change', loadDpdChartData);
                            document.getElementById('chartItemSelect').addEventListener('change', renderFilteredDpdData);

                            // Initial DPD chart load
                            loadDpdChartData();

                            // Chart.js: Security Lock Chart Config & Handling
                            let securityChart = null;
                            const renderSecurityChart = (securityStats) => {
                                const ctx = document.getElementById('securityChart').getContext('2d');
                                const labels = [];
                                const lockedData = [];
                                const unlockedData = [];

                                securityStats.forEach(item => {
                                    labels.push(item.security_type || 'Unknown');
                                    lockedData.push(item.locked_count || 0);
                                    unlockedData.push(item.unlocked_count || 0);
                                });

                                if (securityChart) {
                                    securityChart.destroy();
                                }

                                securityChart = new Chart(ctx, {
                                    type: 'bar',
                                    data: {
                                        labels: labels,
                                        datasets: [
                                            {
                                                label: 'Locked',
                                                data: lockedData,
                                                backgroundColor: 'rgba(239, 68, 68, 0.75)',
                                                borderColor: '#ef4444',
                                                borderWidth: 1.5,
                                                borderRadius: 4
                                            },
                                            {
                                                label: 'Unlocked',
                                                data: unlockedData,
                                                backgroundColor: 'rgba(16, 185, 129, 0.75)',
                                                borderColor: '#10b981',
                                                borderWidth: 1.5,
                                                borderRadius: 4
                                            }
                                        ]
                                    },
                                    options: {
                                        responsive: true,
                                        maintainAspectRatio: false,
                                        scales: {
                                            x: { stacked: true },
                                            y: { stacked: true, beginAtZero: true }
                                        },
                                        plugins: {
                                            legend: { position: 'bottom' }
                                        }
                                    }
                                });
                            };
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