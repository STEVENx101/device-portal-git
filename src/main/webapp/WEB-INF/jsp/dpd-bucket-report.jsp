<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en-US" dir="ltr">

    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title>Fintrex | DPD Bucket Report</title>

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

        <!-- DataTables CSS -->
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
            .nav-pills .nav-link {
                color: #475569 !important;
                font-weight: 600;
                border-radius: 10px;
                padding: 0.5rem 1.25rem;
                transition: all 0.2s ease-in-out;
            }
            .nav-pills .nav-link.active {
                background: linear-gradient(135deg, #6366f1 0%, #a855f7 100%) !important;
                color: #ffffff !important;
                box-shadow: 0 4px 12px rgba(99, 102, 241, 0.25) !important;
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
            .table-bucket th {
                text-align: center;
                vertical-align: middle;
                border-bottom-width: 1px;
                font-size: 0.78rem;
            }
            .table-bucket td {
                vertical-align: middle;
                font-size: 0.8rem;
            }
            .bucket-header-0 { background-color: rgba(16, 185, 129, 0.1) !important; color: #047857 !important; }
            .bucket-header-1 { background-color: rgba(245, 158, 11, 0.1) !important; color: #b45309 !important; }
            .bucket-header-2 { background-color: rgba(249, 115, 22, 0.1) !important; color: #c2410c !important; }
            .bucket-header-3 { background-color: rgba(239, 68, 68, 0.1) !important; color: #b91c1c !important; }
            .bucket-header-tot { background-color: rgba(99, 102, 241, 0.1) !important; color: #4338ca !important; }
            .totals-row {
                font-weight: 700;
                background-color: rgba(99, 102, 241, 0.08) !important;
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
                            <h4 class="mb-0 text-primary"><i class="fas fa-chart-bar me-2"></i>DPD Bucket Analysis Report</h4>
                        </div>
                    </div>

                    <!-- Summary KPI Cards -->
                    <div class="row g-3 mb-3">
                        <div class="col-md-3">
                            <div class="kpi-card">
                                <div class="kpi-title"><i class="fas fa-file-contract me-1 text-primary"></i>Total Contracts</div>
                                <div class="kpi-value" id="kpiTotalContracts">-</div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="kpi-card">
                                <div class="kpi-title"><i class="fas fa-coins me-1 text-success"></i>Total Exposure (Mn)</div>
                                <div class="kpi-value" id="kpiTotalExposure">-</div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="kpi-card">
                                <div class="kpi-title"><i class="fas fa-check-circle me-1 text-info"></i>DPD 0 Exposure (Mn)</div>
                                <div class="kpi-value text-success" id="kpiDpd0Exposure">-</div>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="kpi-card">
                                <div class="kpi-title"><i class="fas fa-exclamation-circle me-1 text-danger"></i>Arrears 1-90 DPD (Mn)</div>
                                <div class="kpi-value text-danger" id="kpiArrearsExposure">-</div>
                            </div>
                        </div>
                    </div>

                    <!-- Filter panel -->
                    <div class="card glass-card mb-3" style="position: relative; z-index: 10;">
                        <div class="card-body py-2">
                            <form id="filterForm">
                                <div class="row g-3 align-items-center">
                                    <div class="col-md-5">
                                        <!-- Dimension Pills -->
                                        <ul class="nav nav-pills" id="dimensionTabs">
                                            <li class="nav-item">
                                                <a class="nav-link active" href="javascript:void(0)" data-dimension="dealer">
                                                    <i class="fas fa-store me-1"></i>Dealer Wise
                                                </a>
                                            </li>
                                            <li class="nav-item">
                                                <a class="nav-link" href="javascript:void(0)" data-dimension="security">
                                                    <i class="fas fa-shield-alt me-1"></i>Security Type
                                                </a>
                                            </li>
                                            <li class="nav-item">
                                                <a class="nav-link" href="javascript:void(0)" data-dimension="model">
                                                    <i class="fas fa-mobile me-1"></i>Model Wise
                                                </a>
                                            </li>
                                        </ul>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="d-flex align-items-center">
                                            <label class="form-label text-700 fw-semi-bold mb-0 me-2 text-nowrap" for="asAtDate">As At Date</label>
                                            <input class="form-control form-control-sm" type="date" id="asAtDate">
                                        </div>
                                    </div>
                                    <div class="col-md-4 d-flex align-items-center justify-content-end gap-2">
                                        <button class="btn btn-primary btn-sm" type="button" id="applyFiltersBtn">
                                            <span class="fas fa-search me-1"></span> Load Report
                                        </button>
                                        <% if (canDownloadReports) { %>
                                        <button class="btn btn-success btn-sm" type="button" id="downloadCsvBtn">
                                            <span class="fas fa-file-excel me-1"></span> Download CSV
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
                                <table class="table table-hover table-bordered table-bucket align-middle mb-0 w-100" id="tableDpdBucket">
                                    <thead class="bg-200 text-900">
                                        <tr>
                                            <th rowspan="2" class="align-middle" id="colCategoryHeader" style="min-width: 180px;">Category</th>
                                            <th colspan="3" class="bucket-header-0">DPD 0</th>
                                            <th colspan="3" class="bucket-header-1">DPD 1 - 30</th>
                                            <th colspan="3" class="bucket-header-2">DPD 31 - 60</th>
                                            <th colspan="3" class="bucket-header-3">DPD 61 - 90</th>
                                            <th colspan="3" class="bucket-header-tot">Total (0 - 90 DPD)</th>
                                        </tr>
                                        <tr>
                                            <th class="bucket-header-0">No</th>
                                            <th class="bucket-header-0">Value (Mn)</th>
                                            <th class="bucket-header-0">%</th>

                                            <th class="bucket-header-1">No</th>
                                            <th class="bucket-header-1">Value (Mn)</th>
                                            <th class="bucket-header-1">%</th>

                                            <th class="bucket-header-2">No</th>
                                            <th class="bucket-header-2">Value (Mn)</th>
                                            <th class="bucket-header-2">%</th>

                                            <th class="bucket-header-3">No</th>
                                            <th class="bucket-header-3">Value (Mn)</th>
                                            <th class="bucket-header-3">%</th>

                                            <th class="bucket-header-tot">No</th>
                                            <th class="bucket-header-tot">Value (Mn)</th>
                                            <th class="bucket-header-tot">%</th>
                                        </tr>
                                    </thead>
                                    <tbody id="tableBody">
                                        <tr>
                                            <td colspan="16" class="text-center py-4 text-muted">Click "Load Report" to view DPD Bucket Analysis</td>
                                        </tr>
                                    </tbody>
                                    <tfoot id="tableFoot"></tfoot>
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
            let activeDimension = 'dealer';

            function formatNumber(val, decimals = 2) {
                if (val === null || val === undefined || isNaN(val)) return '0.00';
                return Number(val).toLocaleString(undefined, { minimumFractionDigits: decimals, maximumFractionDigits: decimals });
            }

            function formatInt(val) {
                if (val === null || val === undefined || isNaN(val)) return '0';
                return Number(val).toLocaleString();
            }

            function loadReportData() {
                const filters = {
                    dimension: activeDimension,
                    asAt: $('#asAtDate').val()
                };

                $('#tableBody').html('<tr><td colspan="16" class="text-center py-4"><div class="spinner-border spinner-border-sm text-primary me-2"></div>Loading data...</td></tr>');
                $('#tableFoot').empty();

                $.ajax({
                    url: '${pageContext.request.contextPath}/api/cbs/dpd-bucket',
                    type: 'POST',
                    contentType: 'application/json',
                    data: JSON.stringify(filters),
                    success: function(res) {
                        renderTable(res);
                    },
                    error: function(err) {
                        $('#tableBody').html('<tr><td colspan="16" class="text-center py-4 text-danger"><i class="fas fa-exclamation-triangle me-2"></i>Failed to load report data</td></tr>');
                    }
                });
            }

            function renderTable(res) {
                const rows = res.rows || [];
                const totals = res.totals || {};

                // Update Dimension Column Label
                let catLabel = 'Dealer Name';
                if (activeDimension === 'security') catLabel = 'Security Type (Knox / Datacultr)';
                if (activeDimension === 'model') catLabel = 'Device Model';
                $('#colCategoryHeader').text(catLabel);

                // Update KPI Cards
                $('#kpiTotalContracts').text(formatInt(totals.totalCount || 0));
                $('#kpiTotalExposure').text(formatNumber(totals.totalValMn || 0) + ' Mn');
                $('#kpiDpd0Exposure').text(formatNumber(totals.dpd0ValMn || 0) + ' Mn');
                
                const arrearsMn = (totals.dpd1_30ValMn || 0) + (totals.dpd31_60ValMn || 0) + (totals.dpd61_90ValMn || 0);
                $('#kpiArrearsExposure').text(formatNumber(arrearsMn) + ' Mn');

                if (rows.length === 0) {
                    $('#tableBody').html('<tr><td colspan="16" class="text-center py-4 text-muted">No records found for the selected criteria</td></tr>');
                    return;
                }

                let bodyHtml = '';
                rows.forEach(function(r) {
                    bodyHtml += '<tr>' +
                        '<td class="fw-semi-bold text-dark">' + (r.category || 'Unknown') + '</td>' +
                        '<td class="text-end">' + formatInt(r.dpd0Count) + '</td>' +
                        '<td class="text-end fw-semi-bold">' + formatNumber(r.dpd0ValMn) + '</td>' +
                        '<td class="text-end text-muted">' + formatNumber(r.dpd0Pct) + '%</td>' +
                        '<td class="text-end">' + formatInt(r.dpd1_30Count) + '</td>' +
                        '<td class="text-end fw-semi-bold">' + formatNumber(r.dpd1_30ValMn) + '</td>' +
                        '<td class="text-end text-muted">' + formatNumber(r.dpd1_30Pct) + '%</td>' +
                        '<td class="text-end">' + formatInt(r.dpd31_60Count) + '</td>' +
                        '<td class="text-end fw-semi-bold">' + formatNumber(r.dpd31_60ValMn) + '</td>' +
                        '<td class="text-end text-muted">' + formatNumber(r.dpd31_60Pct) + '%</td>' +
                        '<td class="text-end">' + formatInt(r.dpd61_90Count) + '</td>' +
                        '<td class="text-end fw-semi-bold">' + formatNumber(r.dpd61_90ValMn) + '</td>' +
                        '<td class="text-end text-muted">' + formatNumber(r.dpd61_90Pct) + '%</td>' +
                        '<td class="text-end fw-bold text-primary">' + formatInt(r.totalCount) + '</td>' +
                        '<td class="text-end fw-bold text-primary">' + formatNumber(r.totalValMn) + '</td>' +
                        '<td class="text-end fw-bold text-primary">' + formatNumber(r.totalPct) + '%</td>' +
                    '</tr>';
                });
                $('#tableBody').html(bodyHtml);

                if (totals && totals.category) {
                    let footHtml = '<tr class="totals-row">' +
                        '<td class="text-dark">TOTAL</td>' +
                        '<td class="text-end">' + formatInt(totals.dpd0Count) + '</td>' +
                        '<td class="text-end">' + formatNumber(totals.dpd0ValMn) + '</td>' +
                        '<td class="text-end">' + formatNumber(totals.dpd0Pct) + '%</td>' +
                        '<td class="text-end">' + formatInt(totals.dpd1_30Count) + '</td>' +
                        '<td class="text-end">' + formatNumber(totals.dpd1_30ValMn) + '</td>' +
                        '<td class="text-end">' + formatNumber(totals.dpd1_30Pct) + '%</td>' +
                        '<td class="text-end">' + formatInt(totals.dpd31_60Count) + '</td>' +
                        '<td class="text-end">' + formatNumber(totals.dpd31_60ValMn) + '</td>' +
                        '<td class="text-end">' + formatNumber(totals.dpd31_60Pct) + '%</td>' +
                        '<td class="text-end">' + formatInt(totals.dpd61_90Count) + '</td>' +
                        '<td class="text-end">' + formatNumber(totals.dpd61_90ValMn) + '</td>' +
                        '<td class="text-end">' + formatNumber(totals.dpd61_90Pct) + '%</td>' +
                        '<td class="text-end text-primary">' + formatInt(totals.totalCount) + '</td>' +
                        '<td class="text-end text-primary">' + formatNumber(totals.totalValMn) + '</td>' +
                        '<td class="text-end text-primary">' + formatNumber(totals.totalPct) + '%</td>' +
                    '</tr>';
                    $('#tableFoot').html(footHtml);
                }
            }

            $(document).ready(function() {
                // Default today's date
                const today = new Date().toISOString().split('T')[0];
                $('#asAtDate').val(today);

                // Tab Switchers
                $('#dimensionTabs .nav-link').on('click', function() {
                    $('#dimensionTabs .nav-link').removeClass('active');
                    $(this).addClass('active');
                    activeDimension = $(this).data('dimension');
                    loadReportData();
                });

                $('#applyFiltersBtn').on('click', function() {
                    loadReportData();
                });

                $('#downloadCsvBtn').on('click', function() {
                    const asAt = $('#asAtDate').val() || '';
                    const url = '${pageContext.request.contextPath}/api/cbs/dpd-bucket/download?dimension=' + encodeURIComponent(activeDimension) + '&asAt=' + encodeURIComponent(asAt);
                    window.location.href = url;
                });

                // Initial load
                loadReportData();
            });
        </script>
    </body>
</html>
