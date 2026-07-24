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

                    <!-- N-Status (NPA/NPL) Metrics Section -->
                    <div class="mb-3">
                        <h5 class="text-700 fw-bold mb-2"><i class="fas fa-exclamation-circle me-2 text-warning"></i>N-Status Account Metrics (Status = N)</h5>
                    </div>
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
                                            <span class="card-title-sub">Total Portfolio</span>
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
                                            <span class="card-title-sub">NPL Exposure</span>
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

                    <!-- General Dashboard KPIs Section -->
                    <div class="mb-3">
                        <h5 class="text-700 fw-bold mb-2"><i class="fas fa-chart-pie me-2 text-primary"></i>General Portfolio Overview</h5>
                    </div>
                    <div class="row g-3 mb-4">
                        <div class="col-md-3">
                            <div class="card border-0 shadow-sm h-100 bg-white">
                                <div class="card-body p-3">
                                    <span class="text-500 card-title-sub text-muted">Total Accounts</span>
                                    <div class="fs-2 fw-bold text-dark mt-1" id="total-accounts">0</div>
                                    <div class="fs--1 text-muted" id="current-month-loans">New current month: 0</div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="card border-0 shadow-sm h-100 bg-white">
                                <div class="card-body p-3">
                                    <span class="text-500 card-title-sub text-muted">Active Portfolio</span>
                                    <div class="fs-2 fw-bold text-success mt-1" id="active-count">0</div>
                                    <div class="fs--1 text-muted">Status: Active</div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="card border-0 shadow-sm h-100 bg-white">
                                <div class="card-body p-3">
                                    <span class="text-500 card-title-sub text-muted">Total NPL Accounts</span>
                                    <div class="fs-2 fw-bold text-danger mt-1" id="total-npl-count">0</div>
                                    <div class="fs--1 text-muted">DPD > 90 or Status N</div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="card border-0 shadow-sm h-100 bg-white">
                                <div class="card-body p-3">
                                    <span class="text-500 card-title-sub text-muted">Arrears Count</span>
                                    <div class="fs-2 fw-bold text-warning mt-1" id="arrears-count">0</div>
                                    <div class="fs--1 text-muted">Active loans with DPD > 0</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Charts Section -->
                    <div class="row g-3 mb-4">
                        <div class="col-md-6">
                            <div class="card border-0 shadow-sm">
                                <div class="card-header bg-white border-0 py-3">
                                    <h6 class="mb-0 text-800 fw-bold">Arrears by Product</h6>
                                </div>
                                <div class="card-body pt-0">
                                    <div class="chart-container">
                                        <canvas id="arrearsChart"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="card border-0 shadow-sm">
                                <div class="card-header bg-white border-0 py-3">
                                    <h6 class="mb-0 text-800 fw-bold">DPD Bucket Distribution</h6>
                                </div>
                                <div class="card-body pt-0">
                                    <div class="chart-container">
                                        <canvas id="dpdChart"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Fetch and Render Script -->
                    <script>
                        document.addEventListener("DOMContentLoaded", function() {
                            const formatLKR = (val) => {
                                return new Intl.NumberFormat('en-LK', {
                                    style: 'currency',
                                    currency: 'LKR',
                                    minimumFractionDigits: 2,
                                    maximumFractionDigits: 2
                                }).format(val);
                            };

                            const formatNum = (val) => {
                                return new Intl.NumberFormat().format(val);
                            };

                            fetch('${pageContext.request.contextPath}/api/dashboard/stats')
                                .then(response => {
                                    if (!response.ok) {
                                        throw new Error("HTTP error " + response.status);
                                    }
                                    return response.json();
                                })
                                .then(data => {
                                    console.log("Dashboard Stats:", data);
                                    
                                    // 1. Set N-Status Kpis
                                    document.getElementById("n-month-amount").innerText = formatLKR(data.nMonthAmount);
                                    document.getElementById("n-month-count").innerText = formatNum(data.nMonthCount) + " Accounts";
                                    
                                    document.getElementById("n-ytd-amount").innerText = formatLKR(data.nYtdAmount);
                                    document.getElementById("n-ytd-count").innerText = formatNum(data.nYtdCount) + " Accounts";
                                    
                                    document.getElementById("n-portfolio-amount").innerText = formatLKR(data.nPortfolioAmount);
                                    document.getElementById("n-portfolio-count").innerText = formatNum(data.nPortfolioCount) + " Accounts";
                                    
                                    document.getElementById("n-npl-exposure").innerText = formatLKR(data.nNplExposure);
                                    document.getElementById("n-npl-count").innerText = formatNum(data.nNplCount) + " Accounts (Arrears: " + formatLKR(data.nNplArrears) + ")";

                                    // 2. Set General Portfolio Overview
                                    document.getElementById("total-accounts").innerText = formatNum(data.totalAccounts);
                                    document.getElementById("current-month-loans").innerText = "New current month: " + formatNum(data.currentMonthLoans);
                                    document.getElementById("active-count").innerText = formatNum(data.activeCount);
                                    document.getElementById("total-npl-count").innerText = formatNum(data.nplCount);
                                    document.getElementById("arrears-count").innerText = formatNum(data.arrearsCount);

                                    // 3. Render Arrears Chart
                                    if (data.arrearsAnalysis && data.arrearsAnalysis.length > 0) {
                                        const labels = data.arrearsAnalysis.map(x => x.label || "Unknown");
                                        const exposureData = data.arrearsAnalysis.map(x => x.exposure || 0);
                                        const arrearsData = data.arrearsAnalysis.map(x => x.arrears || 0);

                                        new Chart(document.getElementById('arrearsChart'), {
                                            type: 'bar',
                                            data: {
                                                labels: labels,
                                                datasets: [
                                                    {
                                                        label: 'Arrears (LKR)',
                                                        data: arrearsData,
                                                        backgroundColor: 'rgba(245, 158, 11, 0.75)',
                                                        borderColor: '#f59e0b',
                                                        borderWidth: 1
                                                    },
                                                    {
                                                        label: 'Exposure (LKR)',
                                                        data: exposureData,
                                                        backgroundColor: 'rgba(99, 102, 241, 0.75)',
                                                        borderColor: '#6366f1',
                                                        borderWidth: 1
                                                    }
                                                ]
                                            },
                                            options: {
                                                responsive: true,
                                                maintainAspectRatio: false,
                                                scales: {
                                                    y: {
                                                        beginAtZero: true
                                                    }
                                                }
                                            }
                                        });
                                    }

                                    // 4. Render DPD Chart
                                    if (data.dpdAnalysis && data.dpdAnalysis.length > 0) {
                                        const labels = data.dpdAnalysis.map(x => x.bucket);
                                        const counts = data.dpdAnalysis.map(x => x.count);

                                        new Chart(document.getElementById('dpdChart'), {
                                            type: 'pie',
                                            data: {
                                                labels: labels,
                                                datasets: [{
                                                    data: counts,
                                                    backgroundColor: [
                                                        '#10b981', '#3b82f6', '#f59e0b', '#ef4444', '#8b5cf6', '#ec4899', '#6b7280', '#000000'
                                                    ]
                                                }]
                                            },
                                            options: {
                                                responsive: true,
                                                maintainAspectRatio: false,
                                                plugins: {
                                                    legend: {
                                                        position: 'right'
                                                    }
                                                }
                                            }
                                        });
                                    }
                                })
                                .catch(err => {
                                    console.error("Error fetching dashboard statistics:", err);
                                });
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