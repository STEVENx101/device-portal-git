<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en-US" dir="ltr">

    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title>Fintrex | Arrears Report</title>

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

        <!-- Vendors for DataTables -->
        <link href="${pageContext.request.contextPath}/vendors/datatables.net-bs5/dataTables.bootstrap5.min.css" rel="stylesheet">

        <script>
            var linkRTL = document.getElementById('style-rtl');
            var userLinkRTL = document.getElementById('user-style-rtl');
            linkRTL.setAttribute('disabled', true);
            userLinkRTL.setAttribute('disabled', true);
        </script>

        <style>
            .btn-primary {
                background: linear-gradient(135deg, #6366f1 0%, #a855f7 100%) !important;
                border: none !important;
                box-shadow: 0 4px 12px rgba(99, 102, 241, 0.2) !important;
                color: #ffffff !important;
            }
            .btn-primary:hover, .btn-primary:focus, .btn-primary:active {
                background: linear-gradient(135deg, #4f46e5 0%, #9333ea 100%) !important;
                box-shadow: 0 4px 15px rgba(99, 102, 241, 0.3) !important;
                color: #ffffff !important;
            }
            .btn-success {
                background: linear-gradient(135deg, #10b981 0%, #059669 100%) !important;
                border: none !important;
                box-shadow: 0 4px 12px rgba(16, 185, 129, 0.2) !important;
                color: #ffffff !important;
            }
            .btn-success:hover {
                background: linear-gradient(135deg, #059669 0%, #047857 100%) !important;
                box-shadow: 0 4px 15px rgba(16, 185, 129, 0.3) !important;
                color: #ffffff !important;
            }
            .text-primary {
                color: #6366f1 !important;
            }
            .bg-soft-primary {
                background-color: rgba(99, 102, 241, 0.15) !important;
                color: #6366f1 !important;
            }
            .bg-primary {
                background: linear-gradient(135deg, #6366f1 0%, #a855f7 100%) !important;
            }
            .kpi-card {
                border-radius: 14px;
                padding: 1rem;
                background: rgba(255, 255, 255, 0.8);
                backdrop-filter: blur(10px);
                border: 1px solid rgba(226, 232, 240, 0.8);
                transition: transform 0.2s ease, box-shadow 0.2s ease;
            }
            .kpi-card:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 20px rgba(99, 102, 241, 0.12);
            }
            .kpi-title {
                font-size: 0.75rem;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 0.05em;
                color: #64748b;
            }
            .kpi-value {
                font-size: 1.35rem;
                font-weight: 800;
                color: #1e293b;
            }
        </style>
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

                <div class="content">
                    <%@include file="../jspf/topbar.jspf" %>

                    <div class="d-flex mb-2 align-items-center justify-content-between mt-2">
                        <div>
                            <h4 class="mb-0 text-primary"><i class="fas fa-clock me-2"></i>Recovery Reports - Arrears</h4>
                        </div>
                    </div>

                    <!-- Summary KPI Cards -->
                    <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-xl-5 g-3 mb-3">
                        <div class="col">
                            <div class="kpi-card border-start border-4 border-success">
                                <div class="kpi-title"><i class="fas fa-wallet me-1 text-success"></i>Total Exposure</div>
                                <div class="kpi-value text-success" id="kpiTotalExposure">-</div>
                                <div class="small text-muted mt-1" id="kpiTotalSub">-</div>
                            </div>
                        </div>
                        <div class="col">
                            <div class="kpi-card border-start border-4 border-warning">
                                <div class="kpi-title"><i class="fas fa-exclamation-circle me-1 text-warning"></i>DPD 1 - 30</div>
                                <div class="kpi-value text-warning" id="kpiDpd1_30Exposure">-</div>
                                <div class="small text-muted mt-1" id="kpiDpd1_30Sub">-</div>
                            </div>
                        </div>
                        <div class="col">
                            <div class="kpi-card border-start border-4 border-danger">
                                <div class="kpi-title"><i class="fas fa-exclamation-triangle me-1 text-danger"></i>DPD 31 - 60</div>
                                <div class="kpi-value text-danger" id="kpiDpd31_60Exposure">-</div>
                                <div class="small text-muted mt-1" id="kpiDpd31_60Sub">-</div>
                            </div>
                        </div>
                        <div class="col">
                            <div class="kpi-card border-start border-4 border-danger">
                                <div class="kpi-title"><i class="fas fa-times-circle me-1 text-danger"></i>DPD 61 - 90</div>
                                <div class="kpi-value text-danger" id="kpiDpd61_90Exposure">-</div>
                                <div class="small text-muted mt-1" id="kpiDpd61_90Sub">-</div>
                            </div>
                        </div>
                        <div class="col">
                            <div class="kpi-card border-start border-4 border-dark">
                                <div class="kpi-title"><i class="fas fa-ban me-1 text-dark"></i>Over 90 DPD</div>
                                <div class="kpi-value text-dark" id="kpiAbove90Exposure">-</div>
                                <div class="small text-muted mt-1" id="kpiAbove90Sub">-</div>
                            </div>
                        </div>
                    </div>

                    <!-- Filter panel -->
                    <div class="card glass-card mb-3" style="position: relative; z-index: 10;">
                        <div class="card-body">
                            <form id="filterForm">
                                <div class="row g-3 align-items-end">
                                    <div class="col-md-3">
                                        <label class="form-label text-700 fw-semi-bold" for="asAtDate">As at Portfolio Date</label>
                                        <input class="form-control" type="date" id="asAtDate" value="">
                                    </div>
                                    <div class="col-md-9 d-flex align-items-end justify-content-end gap-2">
                                        <button class="btn btn-primary btn-sm" type="button" id="applyFiltersBtn">
                                            <span class="fas fa-search me-1"></span> Load Data
                                        </button>
                                        <% if (canDownloadReports) { %>
                                        <button class="btn btn-success btn-sm" type="button" id="downloadExcelBtn">
                                            <span class="fas fa-file-excel me-1"></span> Download Excel
                                        </button>
                                        <% } %>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>

                    <!-- Table Card -->
                    <div class="card glass-card mb-3" style="position: relative; z-index: 1;">
                        <div class="card-body p-3">
                            <div class="table-responsive scrollbar">
                                <table class="table table-hover table-striped align-middle mb-0 fs--1 w-100" id="tableArrears">
                                    <thead class="bg-200 text-900">
                                        <tr>
                                            <th>Account No</th>
                                            <th>Series</th>
                                            <th>Legacy Account</th>
                                            <th>NIC/ID No</th>
                                            <th>Mobile No</th>
                                            <th>Address</th>
                                            <th>Loan Amount</th>
                                            <th>Rental</th>
                                            <th>Total Due</th>
                                            <th>Exposure</th>
                                            <th>DPD</th>
                                            <th>Status</th>
                                            <th>Performing Status</th>
                                            <th>NPL Status</th>
                                            <th>Recovery Officer</th>
                                            <th>Customer Name</th>
                                        </tr>
                                    </thead>
                                    <tbody></tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </main>

        <!-- Scripts -->
        <script src="${pageContext.request.contextPath}/vendors/jquery/jquery.min.js"></script>
        <script src="${pageContext.request.contextPath}/vendors/popper/popper.min.js"></script>
        <script src="${pageContext.request.contextPath}/vendors/bootstrap/bootstrap.min.js"></script>
        <script src="${pageContext.request.contextPath}/vendors/anchorjs/anchor.min.js"></script>
        <script src="${pageContext.request.contextPath}/vendors/is/is.min.js"></script>
        <script src="${pageContext.request.contextPath}/vendors/fontawesome/all.min.js"></script>
        <script src="${pageContext.request.contextPath}/vendors/lodash/lodash.min.js"></script>
        <script src="${pageContext.request.contextPath}/vendors/datatables.net/jquery.dataTables.min.js"></script>
        <script src="${pageContext.request.contextPath}/vendors/datatables.net-bs5/dataTables.bootstrap5.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/theme.js"></script>
        <script>
            let dtReport;
            let hasLoaded = false;

            function formatNumber(val, decimals = 2) {
                if (val === null || val === undefined || isNaN(val)) return '0.00';
                return Number(val).toLocaleString(undefined, { minimumFractionDigits: decimals, maximumFractionDigits: decimals });
            }

            webAppFormatNumber = formatNumber; // expose to global if needed

            function formatInt(val) {
                if (val === null || val === undefined || isNaN(val)) return '0';
                return Number(val).toLocaleString();
            }

            function getFilters() {
                return {
                    asAt: $('#asAtDate').val()
                };
            }

            function loadKpis() {
                const filters = getFilters();
                $.ajax({
                    url: '${pageContext.request.contextPath}/api/cbs/arrears/summary',
                    type: 'POST',
                    contentType: 'application/json',
                    data: JSON.stringify(filters),
                    success: function(totals) {
                        $('#kpiTotalExposure').text(formatNumber(totals.total_exposure / 1000000.0) + ' Mn');
                        $('#kpiTotalSub').text(formatInt(totals.total_count) + ' Contracts');
                        
                        $('#kpiTotalArrears').text(formatNumber(totals.total_due / 1000000.0) + ' Mn');
                        $('#kpiTotalArrearsSub').text('Arrears Value');
                        
                        $('#kpiDpd1_30Exposure').text(formatNumber(totals.dpd1_30_exposure / 1000000.0) + ' Mn');
                        $('#kpiDpd1_30Sub').text(formatInt(totals.dpd1_30_count) + ' Contracts');
                        
                        $('#kpiDpd31_60Exposure').text(formatNumber(totals.dpd31_60_exposure / 1000000.0) + ' Mn');
                        $('#kpiDpd31_60Sub').text(formatInt(totals.dpd31_60_count) + ' Contracts');
                        
                        $('#kpiDpd61_90Exposure').text(formatNumber(totals.dpd61_90_exposure / 1000000.0) + ' Mn');
                        $('#kpiDpd61_90Sub').text(formatInt(totals.dpd61_90_count) + ' Contracts');
                        
                        $('#kpiAbove90Exposure').text(formatNumber(totals.above90_exposure / 1000000.0) + ' Mn');
                        $('#kpiAbove90Sub').text(formatInt(totals.above90_count) + ' Contracts');
                    }
                });
            }

            function getCookie(name) {
                const value = `; ${document.cookie}`;
                const parts = value.split(`; ${name}=`);
                if (parts.length === 2) return parts.pop().split(';').shift();
            }

            $(document).ready(function() {
                // Set default date to today
                const today = new Date().toISOString().split('T')[0];
                $('#asAtDate').val(today);
                
                // Load KPIs initially
                loadKpis();

                dtReport = $('#tableArrears').DataTable({
                    processing: false,
                    serverSide: true,
                    deferLoading: true,
                    ordering: false,
                    ajax: function(data, callback, settings) {
                        $('#loaderText').text('Loading data, please wait...');
                        $('#cbsLoader').css('display', 'flex');
                        data.data = getFilters();
                        $.ajax({
                            url: '${pageContext.request.contextPath}/api/cbs/arrears',
                            type: 'POST',
                            contentType: 'application/json',
                            data: JSON.stringify(data),
                            success: function(res) { callback(res); },
                            complete: function() {
                                $('#cbsLoader').hide();
                            }
                        });
                    },
                    columns: [
                        { data: 'account_no' },
                        { data: 'series' },
                        { data: 'legacy_account_no', defaultContent: '-' },
                        { data: 'client_nic', defaultContent: '-' },
                        { data: 'client_mobile', defaultContent: '-' },
                        { data: 'client_address', defaultContent: '-' },
                        { data: 'loan_amount', render: $.fn.dataTable.render.number(',', '.', 2) },
                        { data: 'rental', render: $.fn.dataTable.render.number(',', '.', 2) },
                        { data: 'total_due', render: $.fn.dataTable.render.number(',', '.', 2) },
                        { data: 'exposure', render: $.fn.dataTable.render.number(',', '.', 2) },
                        { data: 'dpd' },
                        { data: 'loan_status', defaultContent: '-' },
                        { data: 'performing_status', defaultContent: '-' },
                        { data: 'npl_status', defaultContent: '-' },
                        { data: 'recovery_officer', defaultContent: '-' },
                        { data: 'client_name', defaultContent: '-' }
                    ]
                });

                // Row click handler to open facility info
                $('#tableArrears tbody').on('click', 'tr', function () {
                    const rowData = dtReport.row(this).data();
                    if (rowData) {
                        const searchVal = (rowData.legacy_account_no && rowData.legacy_account_no !== '-') ? rowData.legacy_account_no : rowData.account_no;
                        if (searchVal) {
                            window.location.href = '${pageContext.request.contextPath}/mobile?query=' + encodeURIComponent(searchVal);
                        }
                    }
                });

                $('#applyFiltersBtn').on('click', function() {
                    hasLoaded = true;
                    $(this).html('<span class="fas fa-sync-alt me-1"></span> Refresh Data');
                    dtReport.draw();
                    loadKpis();
                });

                if ($('#downloadExcelBtn').length) {
                    $('#downloadExcelBtn').on('click', function() {
                        const filters = getFilters();
                        let downloadUrl = '${pageContext.request.contextPath}/api/cbs/arrears/download';

                        const queryParams = new URLSearchParams();
                        queryParams.append('asAt', filters.asAt);

                        const token = new Date().getTime();
                        queryParams.append('downloadToken', token);

                        $('#loaderText').text('Generating Excel download, please wait... ');
                        $('#cbsLoader').css('display', 'flex');

                        window.location.href = downloadUrl + '?' + queryParams.toString();

                        const fallbackTimer = setTimeout(function() {
                            $('#cbsLoader').hide();
                            clearInterval(checkTimer);
                        }, 4000);

                        const checkTimer = setInterval(function() {
                            const cookieValue = getCookie("downloadToken");
                            if (cookieValue == token) {
                                $('#cbsLoader').hide();
                                document.cookie = "downloadToken=; Max-Age=-99999999; path=/";
                                clearTimeout(fallbackTimer);
                                clearInterval(checkTimer);
                            }
                        }, 500);
                    });
                }
            });
        </script>

        <div id="cbsLoader" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(255,255,255,0.7); z-index: 9999; justify-content: center; align-items: center; flex-direction: column;">
            <div class="spinner-border text-primary" role="status" style="width: 3rem; height: 3rem;"></div>
            <span class="mt-2 fw-semi-bold" id="loaderText">Generating Excel download, please wait...</span>
        </div>
    </body>
</html>
