<%-- 
    Document   : empty_dashboard
    Created on : Jul 6, 2026, 5:01:29 PM
    Author     : poornap
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en-US" dir="ltr">

    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title>Fintrex | Dashboard &amp; Device Finance Portal</title>

        <link rel="apple-touch-icon" sizes="180x180" href="../assets/img/favicons/apple-touch-icon.png">
        <link rel="icon" type="image/png" sizes="32x32" href="../assets/img/favicons/favicon-32x32.png">
        <link rel="icon" type="image/png" sizes="16x16" href="../assets/img/favicons/favicon-16x16.png">
        <link rel="shortcut icon" type="image/x-icon" href="../assets/img/favicons/favicon.ico">
        <link rel="manifest" href="../assets/img/favicons/manifest.json">
        <meta name="msapplication-TileImage" content="../assets/img/favicons/mstile-150x150.png">
        <meta name="theme-color" content="#ffffff">
        <script src="assets/js/config.js"></script>
        <script src="vendors/simplebar/simplebar.min.js"></script>

        <link rel="preconnect" href="https://fonts.gstatic.com/">
        <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,500,600,700%7cPoppins:300,400,500,600,700,800,900&amp;display=swap" rel="stylesheet">
        <link href="vendors/simplebar/simplebar.min.css" rel="stylesheet">
        <link href="assets/css/theme-rtl.min.css" rel="stylesheet" id="style-rtl">
        <link href="assets/css/theme.min.css" rel="stylesheet" id="style-default">
        <link href="assets/css/user-rtl.min.css" rel="stylesheet" id="user-style-rtl">
        <link href="assets/css/user.min.css" rel="stylesheet" id="user-style-default">
        <script>
            var linkRTL = document.getElementById('style-rtl');
            var userLinkRTL = document.getElementById('user-style-rtl');
            linkRTL.setAttribute('disabled', true);
            userLinkRTL.setAttribute('disabled', true);
        </script>
    </head>

    <body>

        <main class="main" id="top">
            <div class="container" data-layout="container">
                <script>

                    var container = document.querySelector('[data-layout]');
                    container.classList.remove('container');
                    container.classList.add('container-fluid');

                </script>

                <%@include file="../jspf/navbar.jspf" %>

                <nav class="navbar navbar-light navbar-glass navbar-top navbar-expand-lg" style="display: none;">
                    <button class="btn navbar-toggler-humburger-icon navbar-toggler me-1 me-sm-3" type="button" data-bs-toggle="collapse" data-bs-target="#navbarStandard" aria-controls="navbarStandard" aria-expanded="false" aria-label="Toggle Navigation"><span class="navbar-toggle-icon"><span class="toggle-line"></span></span></button>
                    <a class="navbar-brand me-1 me-sm-3" href="../index.html">
                        <div class="d-flex align-items-center"><img class="me-2" src="../assets/img/icons/spot-illustrations/falcon.png" alt="" width="40" /><span class="font-sans-serif">falcon</span></div>
                    </a>                    
                </nav>

                <div class="content">
                    <%@include file="../jspf/topbar.jspf" %>

                    <script>
                        var navbarPosition = localStorage.getItem('navbarPosition');
                        var navbarVertical = document.querySelector('.navbar-vertical');
                        var navbarTopVertical = document.querySelector('.content .navbar-top');
                        var navbarTop = document.querySelector('[data-layout] .navbar-top:not([data-double-top-nav');

                        navbarVertical.removeAttribute('style');
                        navbarTopVertical.removeAttribute('style');
                        navbarTop.remove(navbarTop);
                    </script>

                    <div class="d-flex mb-3 align-items-center justify-content-between mt-2">
                        <div>
                            <h4 class="mb-0 text-primary"><i class="fas fa-chart-pie me-2"></i>Device Finance Overview Dashboard</h4>
                        </div>
                    </div>

                    <!-- KPI Cards Row -->
                    <div class="row g-3 mb-3">
                        <div class="col-sm-6 col-md-3">
                            <div class="card glass-card overflow-hidden">
                                <div class="card-body p-3">
                                    <div class="d-flex align-items-center justify-content-between">
                                        <div>
                                            <p class="fs--2 text-600 mb-0 fw-semi-bold">TOTAL ACCOUNTS</p>
                                            <h3 class="fw-bold mb-0 text-primary font-sans-serif" id="stat-total-accounts">0</h3>
                                        </div>
                                        <div class="avatar avatar-3xl bg-soft-primary rounded-circle">
                                            <span class="fas fa-file-invoice-dollar fs-1"></span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-sm-6 col-md-3">
                            <div class="card glass-card overflow-hidden">
                                <div class="card-body p-3">
                                    <div class="d-flex align-items-center justify-content-between">
                                        <div>
                                            <p class="fs--2 text-600 mb-0 fw-semi-bold">OUTSTANDING DUES</p>
                                            <h3 class="fw-bold mb-0 text-success font-sans-serif" id="stat-outstanding">LKR 0.00</h3>
                                        </div>
                                        <div class="avatar avatar-3xl bg-soft-success rounded-circle">
                                            <span class="fas fa-hand-holding-usd fs-1"></span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-sm-6 col-md-3">
                            <div class="card glass-card overflow-hidden">
                                <div class="card-body p-3">
                                    <div class="d-flex align-items-center justify-content-between">
                                        <div>
                                            <p class="fs--2 text-600 mb-0 fw-semi-bold">LOCKED DEVICES</p>
                                            <h3 class="fw-bold mb-0 text-danger font-sans-serif" id="stat-locked">0</h3>
                                        </div>
                                        <div class="avatar avatar-3xl bg-soft-danger rounded-circle">
                                            <span class="fas fa-lock fs-1"></span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-sm-6 col-md-3">
                            <div class="card glass-card overflow-hidden">
                                <div class="card-body p-3">
                                    <div class="d-flex align-items-center justify-content-between">
                                        <div>
                                            <p class="fs--2 text-600 mb-0 fw-semi-bold">KNOX DEVICES</p>
                                            <h3 class="fw-bold mb-0 text-info font-sans-serif" id="stat-knox">0</h3>
                                        </div>
                                        <div class="avatar avatar-3xl bg-soft-info rounded-circle">
                                            <span class="fas fa-shield-alt fs-1"></span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Charts & Recent Actions row -->
                    <div class="row g-3 mb-3">
                        <div class="col-md-5">
                            <div class="card h-100">
                                <div class="card-header bg-light d-flex align-items-center justify-content-between py-2">
                                    <h6 class="mb-0 text-800 fw-semi-bold"><span class="fas fa-shield-alt me-2 text-primary"></span>Device Security Model Breakdown</h6>
                                </div>
                                <div class="card-body d-flex align-items-center justify-content-center">
                                    <div style="max-height: 220px; width: 100%;">
                                        <canvas id="securityChart"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-7">
                            <div class="card h-100">
                                <div class="card-header bg-light d-flex align-items-center justify-content-between py-2">
                                    <h6 class="mb-0 text-800 fw-semi-bold"><span class="fas fa-history me-2 text-primary"></span>Recent Device Lock / Unlock logs</h6>
                                </div>
                                <div class="card-body p-0">
                                    <div class="table-responsive scrollbar">
                                        <table class="table table-hover table-striped align-middle mb-0 fs--1">
                                            <thead class="bg-200 text-900">
                                                <tr>
                                                    <th>Finance No</th>
                                                    <th>Action</th>
                                                    <th>Date</th>
                                                    <th>User</th>
                                                    <th>Reason</th>
                                                </tr>
                                            </thead>
                                            <tbody id="recent-locks-list">
                                                <tr>
                                                    <td colspan="5" class="text-center py-4 text-muted">Loading logs...</td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Include Chart.js and jQuery -->
                    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
                    <script src="vendors/jquery/jquery.min.js"></script>
                    <script>
                        $(document).ready(function() {
                            // Load KPI stats and chart data
                            fetch('<%= request.getContextPath() %>/api/contracts/dashboard-stats')
                                .then(res => res.json())
                                .then(data => {
                                    $('#stat-total-accounts').text(data.totalAccounts);
                                    $('#stat-outstanding').text('LKR ' + data.totalOutstanding.toLocaleString(undefined, {minimumFractionDigits: 2, maximumFractionDigits: 2}));
                                    $('#stat-locked').text(data.totalLocked);
                                    $('#stat-knox').text(data.knoxCount);

                                    // Render Security distribution chart
                                    const ctx = document.getElementById('securityChart').getContext('2d');
                                    new Chart(ctx, {
                                        type: 'doughnut',
                                        data: {
                                            labels: ['KNOX', 'DATACULTE', 'ABSOLUTE (Laptop)'],
                                            datasets: [{
                                                data: [data.knoxCount, data.dataculteCount, data.laptopCount],
                                                backgroundColor: ['#2b4eff', '#a855f7', '#10b981'],
                                                borderWidth: 0
                                            }]
                                        },
                                        options: {
                                            responsive: true,
                                            maintainAspectRatio: false,
                                            plugins: {
                                                legend: {
                                                    position: 'bottom'
                                                }
                                            }
                                        }
                                    });
                                })
                                .catch(err => console.error("Error loading dashboard statistics:", err));

                            // Load Recent lock actions
                            fetch('<%= request.getContextPath() %>/api/contracts/recent-locks')
                                .then(res => res.json())
                                .then(logs => {
                                    const tbody = $('#recent-locks-list');
                                    tbody.empty();
                                    if (logs.length === 0) {
                                        tbody.append('<tr><td colspan="5" class="text-center py-3 text-muted">No locking events found.</td></tr>');
                                        return;
                                    }
                                    logs.forEach(log => {
                                        const badgeClass = log.status === 'LOCKED' ? 'bg-danger' : 'bg-success';
                                        tbody.append(`
                                            <tr>
                                                <td class="fw-bold"><a href="<%= request.getContextPath() %>/mobile?financeNo=${log.finance_no}">${log.finance_no}</a></td>
                                                <td><span class="badge rounded-pill ${badgeClass}">${log.status}</span></td>
                                                <td>${log.date}</td>
                                                <td>${log.changed_by}</td>
                                                <td class="text-truncate" style="max-width: 200px;" title="${log.reason}">${log.reason}</td>
                                            </tr>
                                        `);
                                    });
                                })
                                .catch(err => console.error("Error loading lock actions:", err));
                        });
                    </script>
                    
                   
                </div>

            </div>
        </main>


        <script src="vendors/popper/popper.min.js"></script>
        <script src="vendors/bootstrap/bootstrap.min.js"></script>
        <script src="vendors/anchorjs/anchor.min.js"></script>
        <script src="vendors/is/is.min.js"></script>
        <script src="vendors/fontawesome/all.min.js"></script>
        <script src="vendors/lodash/lodash.min.js"></script>
        <script src="../../../../polyfill.io/v3/polyfill.min58be.js?features=window.scroll"></script>
        <script src="vendors/list.js/list.min.js"></script>
        <script src="assets/js/theme.js"></script>
    </body>

</html>
<%-- Touch JSP for JSPF compile v8 --%>
