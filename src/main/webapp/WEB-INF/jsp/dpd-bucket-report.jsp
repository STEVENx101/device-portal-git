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
        <!-- Vendors for Choices.js and DataTables -->
        <link href="${pageContext.request.contextPath}/vendors/choices/choices.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/vendors/datatables.net-bs5/dataTables.bootstrap5.min.css" rel="stylesheet">

        <script>
            let productChoices;

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
            .table-bucket th, .table-bucket td {
                padding: 0.35rem 0.5rem !important;
                font-size: 0.76rem !important;
            }
            .table-bucket th {
                text-align: center;
                vertical-align: middle;
                border-bottom-width: 1px;
            }
            .table-bucket td {
                vertical-align: middle;
            }
            .bucket-header-above90 { background-color: rgba(30, 41, 59, 0.1) !important; color: #1e293b !important; }
            .bucket-header-tot { background-color: rgba(99, 102, 241, 0.1) !important; color: #4338ca !important; }
            .totals-row {
                font-weight: 700;
                background-color: rgba(99, 102, 241, 0.08) !important;
            }
            /* Style Choices.js with checkboxes and summary text instead of pills */
            .choices-checkbox .choices__inner {
                position: relative;
                min-height: 31px;
                padding: 2px 4px !important;
                background-color: #fff !important;
                border: 1px solid #d8e2ef !important;
                border-radius: .25rem !important;
            }
            .choices-checkbox .choices__list--multiple {
                display: none !important; /* Hide the tag pills */
            }
            .choices-checkbox .choices__input {
                margin-bottom: 0 !important;
                margin-top: 0 !important;
                padding: 2px 2px !important;
                height: 25px;
                background-color: transparent !important;
            }
            .choices-checkbox .choices__list--dropdown .choices__item--selectable {
                padding: 6px 12px !important;
                display: flex;
                align-items: center;
            }
            .choices-checkbox .choices__list--dropdown .choices__item--selectable.is-highlighted {
                background-color: #f1f5f9 !important;
                color: #1e293b !important;
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
                    <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-xl-6 g-3 mb-3">
                        <div class="col">
                            <div class="kpi-card border-start border-4 border-primary">
                                <div class="kpi-title"><i class="fas fa-wallet me-1 text-primary"></i>Total Portfolio</div>
                                <div class="kpi-value text-primary" id="kpiTotalExposure">-</div>
                                <div class="small text-muted mt-1" id="kpiTotalSub">-</div>
                            </div>
                        </div>
                        <div class="col">
                            <div class="kpi-card border-start border-4 border-success">
                                <div class="kpi-title"><i class="fas fa-check-circle me-1 text-success"></i>DPD 0</div>
                                <div class="kpi-value text-success" id="kpiDpd0Exposure">-</div>
                                <div class="small text-muted mt-1" id="kpiDpd0Sub">-</div>
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
                        <div class="card-body py-2">
                            <form id="filterForm">
                                <div class="row g-2 align-items-center">
                                    <div class="col-md-3">
                                        <!-- Dimension Pills -->
                                        <ul class="nav nav-pills" id="dimensionTabs">
                                            <li class="nav-item">
                                                <a class="nav-link" href="javascript:void(0)" data-dimension="dealer">
                                                    <i class="fas fa-store me-1"></i>Dealer Wise
                                                </a>
                                            </li>
                                            <li class="nav-item">
                                                <a class="nav-link active" href="javascript:void(0)" data-dimension="security">
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
                                    <div class="col-md-2">
                                        <div class="d-flex align-items-center">
                                            <label class="form-label text-700 fw-semi-bold mb-0 me-2 text-nowrap" for="asAtDate">As At</label>
                                            <input class="form-control form-control-sm" type="date" id="asAtDate">
                                        </div>
                                    </div>
                                    <div class="col-md-2" id="dynamicFilterCol" style="display: none;">
                                        <div class="d-flex align-items-center">
                                            <label class="form-label text-700 fw-semi-bold mb-0 me-2 text-nowrap" id="dynamicFilterLabel" for="dynamicFilterSelect">Filter</label>
                                            <select class="form-select form-select-sm" id="dynamicFilterSelect">
                                                <option value="ALL">All</option>
                                            </select>
                                        </div>
                                    </div>
                                    
                                    <div class="col-md-3">
                                        <div class="d-flex align-items-center w-100">
                                            <label class="form-label text-700 fw-semi-bold mb-0 me-2 text-nowrap" for="selectProducts">Product</label>
                                            <div class="flex-grow-1">
                                                <select class="form-select form-select-sm" id="selectProducts" multiple></select>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-auto ms-auto d-flex align-items-center justify-content-end gap-2">
                                        <button class="btn btn-primary btn-sm text-nowrap" type="button" id="applyFiltersBtn">
                                            <span class="fas fa-search me-1"></span> Load Report
                                        </button>
                                        <% if (canDownloadReports) { %>
                                        <button class="btn btn-success btn-sm text-nowrap" type="button" id="downloadCsvBtn">
                                            <span class="fas fa-file-excel me-1"></span> Excel
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
                                            <th colspan="3" class="bucket-header-above90">Over 90 DPD</th>
                                            <th colspan="3" class="bucket-header-tot">Total</th>
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

                                            <th class="bucket-header-above90">No</th>
                                            <th class="bucket-header-above90">Value (Mn)</th>
                                            <th class="bucket-header-above90">%</th>

                                            <th class="bucket-header-tot">No</th>
                                            <th class="bucket-header-tot">Value (Mn)</th>
                                            <th class="bucket-header-tot">%</th>
                                        </tr>
                                    </thead>
                                    <tbody id="tableBody">
                                        <tr>
                                            <td colspan="19" class="text-center py-4 text-muted">Click "Load Report" to view DPD Bucket Analysis</td>
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
        <script src="${pageContext.request.contextPath}/vendors/choices/choices.min.js"></script>
        <script src="${pageContext.request.contextPath}/vendors/datatables.net/jquery.dataTables.min.js"></script>
        <script src="${pageContext.request.contextPath}/vendors/datatables.net-bs5/dataTables.bootstrap5.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/theme.js"></script>

        <script>
            let activeDimension = 'security';
            let dealerOptionsHtml = '<option value="ALL" selected>All Dealers</option>';
            let modelOptionsHtml = '<option value="ALL" selected>All Models</option>';

            function formatNumber(val, decimals = 2) {
                if (val === null || val === undefined || isNaN(val)) return '0.00';
                return Number(val).toLocaleString(undefined, { minimumFractionDigits: decimals, maximumFractionDigits: decimals });
            }

            function formatInt(val) {
                if (val === null || val === undefined || isNaN(val)) return '0';
                return Number(val).toLocaleString();
            }

            function updateDynamicFilterOptions() {
                const col = $('#dynamicFilterCol');
                const select = $('#dynamicFilterSelect');
                const label = $('#dynamicFilterLabel');

                if (activeDimension === 'dealer') {
                    col.show();
                    label.text('Dealer:');
                    select.html(dealerOptionsHtml);
                } else if (activeDimension === 'model') {
                    col.show();
                    label.text('Model:');
                    select.html(modelOptionsHtml);
                } else {
                    col.hide();
                }
            }

            function loadReportData() {
                const products = productChoices ? productChoices.getValue(true) : [];
                const filters = {
                    dimension: activeDimension,
                    asAt: $('#asAtDate').val(),
                    products: products
                };

                const filterVal = $('#dynamicFilterSelect').val() || 'ALL';
                if (activeDimension === 'dealer') {
                    filters.dealer = filterVal;
                } else if (activeDimension === 'model') {
                    filters.model = filterVal;
                }

                $('#loaderText').text('Loading data, please wait...');
                $('#cbsLoader').css('display', 'flex');
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
                        $('#tableBody').html('<tr><td colspan="19" class="text-center py-4 text-danger"><i class="fas fa-exclamation-triangle me-2"></i>Failed to load report data</td></tr>');
                    },
                    complete: function() {
                        $('#cbsLoader').hide();
                    }
                });
            }

            function renderTable(res) {
                const rows = res.rows || [];
                const totals = res.totals || {};

                // Update Dimension Column Label
                let catLabel = 'Dealer Name';
                if (activeDimension === 'security') catLabel = 'Security Type';
                if (activeDimension === 'model') catLabel = 'Device Model';
                $('#colCategoryHeader').text(catLabel);

                // Update KPI Cards
                // Card 1: Total Portfolio
                $('#kpiTotalExposure').text(formatNumber(totals.totalValMn || 0) + ' Mn');
                $('#kpiTotalSub').text(formatInt(totals.totalCount || 0) + ' Contracts');

                // Card 2: DPD 0
                $('#kpiDpd0Exposure').text(formatNumber(totals.totalValMn ? (totals.dpd0ValMn || 0) : 0) + ' Mn');
                $('#kpiDpd0Sub').text(formatInt(totals.dpd0Count || 0) + ' Contracts (' + formatNumber(totals.dpd0Pct || 0) + '%)');

                // Card 3: DPD 1 - 30
                $('#kpiDpd1_30Exposure').text(formatNumber(totals.dpd1_30ValMn || 0) + ' Mn');
                $('#kpiDpd1_30Sub').text(formatInt(totals.dpd1_30Count || 0) + ' Contracts (' + formatNumber(totals.dpd1_30Pct || 0) + '%)');

                // Card 4: DPD 31 - 60
                $('#kpiDpd31_60Exposure').text(formatNumber(totals.dpd31_60ValMn || 0) + ' Mn');
                $('#kpiDpd31_60Sub').text(formatInt(totals.dpd31_60Count || 0) + ' Contracts (' + formatNumber(totals.dpd31_60Pct || 0) + '%)');

                // Card 5: DPD 61 - 90
                $('#kpiDpd61_90Exposure').text(formatNumber(totals.dpd61_90ValMn || 0) + ' Mn');
                $('#kpiDpd61_90Sub').text(formatInt(totals.dpd61_90Count || 0) + ' Contracts (' + formatNumber(totals.dpd61_90Pct || 0) + '%)');

                // Card 6: Over 90 DPD
                $('#kpiAbove90Exposure').text(formatNumber(totals.above90ValMn || 0) + ' Mn');
                $('#kpiAbove90Sub').text(formatInt(totals.above90Count || 0) + ' Contracts (' + formatNumber(totals.above90Pct || 0) + '%)');

                if (rows.length === 0) {
                    $('#tableBody').html('<tr><td colspan="19" class="text-center py-4 text-muted">No records found for the selected criteria</td></tr>');
                    return;
                }

                let bodyHtml = '';
                rows.forEach(function(r) {
                    bodyHtml += '<tr>' +
                        '<td class="fw-semi-bold text-dark text-truncate" style="max-width: 150px;" title="' + (r.category || 'Unknown') + '">' + (r.category || 'Unknown') + '</td>' +
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
                        '<td class="text-end">' + formatInt(r.dpdAbove90Count) + '</td>' +
                        '<td class="text-end fw-semi-bold">' + formatNumber(r.dpdAbove90ValMn) + '</td>' +
                        '<td class="text-end text-muted">' + formatNumber(r.dpdAbove90Pct) + '%</td>' +
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
                        '<td class="text-end">' + formatInt(totals.above90Count) + '</td>' +
                        '<td class="text-end">' + formatNumber(totals.above90ValMn) + '</td>' +
                        '<td class="text-end">' + formatNumber(totals.above90Pct) + '%</td>' +
                        '<td class="text-end text-primary">' + formatInt(totals.totalCount) + '</td>' +
                        '<td class="text-end text-primary">' + formatNumber(totals.totalValMn) + '</td>' +
                        '<td class="text-end text-primary">' + formatNumber(totals.totalPct) + '%</td>' +
                    '</tr>';
                    $('#tableFoot').html(footHtml);
                }
            }

            function getCookie(name) {
                const value = `; ${document.cookie}`;
                const parts = value.split(`; ${name}=`);
                if (parts.length === 2) return parts.pop().split(';').shift();
            }

            $(document).ready(function() {

                productChoices = new Choices('#selectProducts', {
                    removeItemButton: false,
                    placeholder: true,
                    placeholderValue: 'Select Products',
                    shouldSort: false,
                    classNames: {
                        containerOuter: 'choices choices-checkbox w-100',
                    },
                    callbackOnCreateTemplates: function(template) {
                        return {
                            choice: function(classNames, data) {
                                return template(`
                                    <div class="${classNames.item} ${classNames.itemChoice} ${data.disabled ? classNames.itemDisabled : classNames.itemSelectable}" data-select-text="" data-choice data-id="${data.id}" data-value="${data.value}" role="option">
                                        <input type="checkbox" class="form-check-input me-2" ${data.selected ? 'checked' : ''} style="pointer-events: none; width: 14px; height: 14px; margin-top: 0;">
                                        <span>${data.label}</span>
                                    </div>
                                `);
                            }
                        };
                    }
                });

                function updateProductPlaceholder() {
                    const selected = productChoices.getValue(true);
                    const container = $('.choices-checkbox .choices__inner');
                    container.find('.choices-summary').remove();
                    
                    if (selected.length > 0) {
                        container.prepend(`<div class="choices-summary ps-1 text-800 fs--1" style="position: absolute; pointer-events: none; line-height: 25px; left: 8px;">${selected.length} Product(s) Selected</div>`);
                        $('.choices-checkbox .choices__input').css('opacity', 0);
                    } else {
                        $('.choices-checkbox .choices__input').css('opacity', 1);
                    }
                }

                $('#selectProducts').on('change', function() {
                    updateProductPlaceholder();
                });

                // Load Metadata
                fetch('${pageContext.request.contextPath}/api/cbs/metadata')
                    .then(res => res.json())
                    .then(data => {
                        const productList = data.products.map(p => ({
                            value: p.product_code,
                            label: p.product_name,
                            selected: false
                        }));
                        productChoices.setChoices(productList, 'value', 'label', true);
                        updateProductPlaceholder();
                    })
                    .catch(err => console.error("Error loading filter metadata:", err));
    
                // Default today's date
                const today = new Date().toISOString().split('T')[0];
                $('#asAtDate').val(today);

                // Fetch distinct dealers
                $.ajax({
                    url: '${pageContext.request.contextPath}/api/cbs/dealers',
                    type: 'GET',
                    success: function(res) {
                        res.forEach(function(d) {
                            dealerOptionsHtml += '<option value="' + d.code + '">' + d.name + ' (' + d.code + ')</option>';
                        });
                        updateDynamicFilterOptions();
                    }
                });

                // Fetch distinct models
                $.ajax({
                    url: '${pageContext.request.contextPath}/api/cbs/models',
                    type: 'GET',
                    success: function(res) {
                        res.forEach(function(m) {
                            modelOptionsHtml += '<option value="' + m.id + '">' + m.name + '</option>';
                        });
                        updateDynamicFilterOptions();
                    }
                });

                // Tab Switchers
                $('#dimensionTabs .nav-link').on('click', function() {
                    $('#dimensionTabs .nav-link').removeClass('active');
                    $(this).addClass('active');
                    activeDimension = $(this).data('dimension');
                    updateDynamicFilterOptions();
                });

                $('#applyFiltersBtn').on('click', function() {
                    loadReportData();
                });

                $('#downloadCsvBtn').on('click', function() {
                    const asAt = $('#asAtDate').val() || '';
                    const token = new Date().getTime();
                    const filterVal = $('#dynamicFilterSelect').val() || 'ALL';
                    const dealerVal = activeDimension === 'dealer' ? filterVal : 'ALL';
                    const modelVal = activeDimension === 'model' ? filterVal : 'ALL';
                    const products = productChoices ? productChoices.getValue(true) : [];

                    const queryParams = new URLSearchParams();
                    queryParams.append('dimension', activeDimension);
                    queryParams.append('asAt', asAt);
                    queryParams.append('dealer', dealerVal);
                    queryParams.append('model', modelVal);
                    queryParams.append('downloadToken', token);
                    if (products && products.length > 0) {
                        products.forEach(p => queryParams.append('products', p));
                    }

                    const url = '${pageContext.request.contextPath}/api/cbs/dpd-bucket/download?' + queryParams.toString();
                    
                    $('#loaderText').text('Generating Excel download, please wait...');
                    $('#cbsLoader').css('display', 'flex');
                    
                    window.location.href = url;

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
            });
        </script>
        <div id="cbsLoader" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(255,255,255,0.7); z-index: 9999; justify-content: center; align-items: center; flex-direction: column;">
            <div class="spinner-border text-primary" role="status" style="width: 3rem; height: 3rem;"></div>
            <span class="mt-2 fw-semi-bold" id="loaderText">Generating Excel download, please wait...</span>
        </div>
    </body>
</html>
