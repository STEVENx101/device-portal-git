<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en-US" dir="ltr">

    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title>Fintrex | Disbursement Report</title>

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
        <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=Outfit:wght@400;500;600;700;800&display=swap" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/vendors/simplebar/simplebar.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/theme-rtl.min.css" rel="stylesheet" id="style-rtl">
        <link href="${pageContext.request.contextPath}/assets/css/theme.min.css" rel="stylesheet" id="style-default">
        <link href="${pageContext.request.contextPath}/assets/css/user-rtl.min.css" rel="stylesheet" id="user-style-rtl">
        <link href="${pageContext.request.contextPath}/assets/css/user.min.css" rel="stylesheet" id="user-style-default">

        <!-- Vendors for Choices.js and DataTables -->
        <link href="${pageContext.request.contextPath}/vendors/choices/choices.min.css" rel="stylesheet">
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
                background-color: rgba(99, 102, 241, 0.12) !important;
                color: #6366f1 !important;
            }
            .bg-soft-success {
                background-color: rgba(16, 185, 129, 0.12) !important;
                color: #059669 !important;
            }
            .bg-soft-warning {
                background-color: rgba(245, 158, 11, 0.12) !important;
                color: #d97706 !important;
            }
            .bg-soft-info {
                background-color: rgba(14, 165, 233, 0.12) !important;
                color: #0284c7 !important;
            }
            .bg-primary {
                background: linear-gradient(135deg, #6366f1 0%, #a855f7 100%) !important;
            }

            /* Custom KPI Cards */
            .kpi-card {
                background: #ffffff;
                border-radius: 14px;
                padding: 16px 20px;
                box-shadow: 0 4px 14px rgba(0, 0, 0, 0.04);
                border: 1px solid #edf2f7;
                transition: transform 0.2s ease, box-shadow 0.2s ease;
                position: relative;
                overflow: hidden;
            }
            .kpi-card:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 20px rgba(0, 0, 0, 0.07);
            }
            .kpi-title {
                font-size: 0.76rem;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 0.05em;
                color: #64748b;
                display: flex;
                align-items: center;
                margin-bottom: 6px;
            }
            .kpi-value {
                font-family: 'Outfit', sans-serif;
                font-size: 1.45rem;
                font-weight: 800;
                line-height: 1.2;
                letter-spacing: -0.02em;
            }
            .kpi-subtext {
                font-size: 0.8rem;
                color: #64748b;
                margin-top: 6px;
                display: flex;
                align-items: center;
                gap: 6px;
                flex-wrap: wrap;
            }

            /* Choices Dropdown overrides */
            .choices {
                z-index: 1005 !important;
                margin-bottom: 0;
            }
            .choices__inner {
                background: #ffffff !important;
                border: 1px solid #cbd5e1 !important;
                border-radius: 8px !important;
                min-height: 38px !important;
                padding: 3px 8px !important;
            }
            .choices__list--multiple .choices__item,
            .choices__list--multiple .choices__item * {
                background-color: #6366f1 !important;
                border: none !important;
                border-radius: 5px !important;
                font-weight: 600;
                font-size: 0.78rem;
                padding: 2px 7px !important;
                color: #ffffff !important;
            }
            .choices__list--dropdown {
                background: rgba(255, 255, 255, 0.98) !important;
                backdrop-filter: blur(10px);
                border-radius: 8px !important;
                border: 1px solid #cbd5e1 !important;
                box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1) !important;
                z-index: 1005 !important;
            }
            select[data-choice="active"] {
                display: none !important;
            }

            /* Table Styles */
            #tableDisbursement th {
                white-space: nowrap;
                font-size: 0.78rem;
                letter-spacing: 0.03em;
            }
            #tableDisbursement td {
                font-size: 0.81rem;
                vertical-align: middle;
            }
            .clickable-row {
                cursor: pointer;
                transition: background-color 0.15s ease;
            }
            .clickable-row:hover {
                background-color: #f1f5f9 !important;
            }

            /* Badge pill accents */
            .badge-account {
                font-family: monospace;
                font-weight: 600;
                background-color: #f8fafc;
                border: 1px solid #e2e8f0;
                color: #334155;
                padding: 3px 6px;
                border-radius: 4px;
            }
            .badge-product {
                background: #e0e7ff;
                color: #4338ca;
                font-weight: 700;
                font-size: 0.75rem;
                padding: 3px 8px;
                border-radius: 6px;
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

                    <!-- Header Title & Breadcrumb -->
                    <div class="d-flex flex-wrap mb-3 align-items-center justify-content-between mt-2 gap-2">
                        <div>
                            <div class="d-flex align-items-center gap-2">
                                <div class="avatar avatar-l text-white rounded-3 d-flex align-items-center justify-content-center" style="background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%); width: 40px; height: 40px;">
                                    <i class="fas fa-hand-holding-usd fa-lg"></i>
                                </div>
                                <div>
                                    <h4 class="mb-0 fw-bold" style="color: #1e1b4b;">Disbursement Report</h4>
                                    <div class="text-500 fs--1">General Reports &bull; Core Banking System (CBS) Loan Portfolio</div>
                                </div>
                            </div>
                        </div>
                        <div class="d-flex align-items-center gap-2">
                            <span class="badge bg-soft-primary px-3 py-2 rounded-pill fs--1" id="activeFilterBadge">
                                <i class="fas fa-calendar-check me-1"></i> Month: <span id="badgeMonthText">Current Month</span>
                            </span>
                        </div>
                    </div>

                    <!-- Summary KPI Cards (Current Month & Financial Year to Date) -->
                    <div class="row row-cols-1 row-cols-md-2 g-3 mb-3">
                        <!-- Current / Selected Month Card -->
                        <div class="col">
                            <div class="kpi-card border-start border-4 border-primary h-100">
                                <div class="kpi-title d-flex justify-content-between align-items-center">
                                    <span>
                                        <i class="fas fa-calendar-alt text-primary me-2"></i>
                                        <span id="kpiMonthLabel">CURRENT MONTH</span>
                                    </span>
                                    <span class="badge bg-soft-primary text-primary fs--2" id="kpiMonthBadge">Monthly</span>
                                </div>
                                <div class="kpi-value text-primary" id="kpiMonthAmount" title="0.00">0.00 Mn</div>
                                <div class="kpi-subtext" id="kpiMonthSub">
                                    <span class="badge bg-soft-primary"><i class="fas fa-file-contract me-1"></i><span id="kpiMonthCount">0</span> Loans</span>
                                    <span class="text-500 fs--2 ms-1" id="kpiMonthPeriodText">Selected Month</span>
                                </div>
                            </div>
                        </div>

                        <!-- Financial Year to Date (FYTD) Card -->
                        <div class="col">
                            <div class="kpi-card border-start border-4 border-success h-100">
                                <div class="kpi-title d-flex justify-content-between align-items-center">
                                    <span>
                                        <i class="fas fa-chart-line text-success me-2"></i>
                                        <span id="kpiYtdLabel">FINANCIAL YEAR TO DATE</span>
                                    </span>
                                    <span class="badge bg-soft-success text-success fs--2" id="kpiFyBadge">Financial Year</span>
                                </div>
                                <div class="kpi-value text-success" id="kpiYtdAmount" title="0.00">0.00 Mn</div>
                                <div class="kpi-subtext" id="kpiYtdSub">
                                    <span class="badge bg-soft-success"><i class="fas fa-check-circle me-1"></i><span id="kpiYtdCount">0</span> Total Loans</span>
                                    <span class="text-500 fs--2 ms-1" id="kpiFyPeriodText">Financial Year (Apr - Mar)</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Filter panel -->
                    <div class="card glass-card mb-3" style="position: relative; z-index: 10;">
                        <div class="card-body p-3">
                            <div id="productAlert" class="alert alert-warning py-2 px-3 fs--1 mb-3 d-none align-items-center" role="alert">
                                <i class="fas fa-exclamation-triangle me-2"></i> Please select at least one <strong>Product</strong>, then click <strong>Load Data</strong>.
                            </div>
                            <form id="filterForm">
                                <div class="row g-3 align-items-end">
                                    <div class="col-md-3 col-sm-6">
                                        <label class="form-label text-700 fw-semi-bold fs--1 mb-1" for="selectMonth">
                                            <i class="fas fa-calendar me-1 text-primary"></i>Disbursement Month
                                        </label>
                                        <div class="input-group input-group-sm">
                                            <input class="form-control form-control-sm" type="month" id="selectMonth">
                                            <button class="btn btn-outline-secondary" type="button" id="btnCurrentMonth" title="Reset to Current Month">
                                                This Month
                                            </button>
                                        </div>
                                    </div>

                                    <div class="col-md-4 col-sm-6">
                                        <label class="form-label text-700 fw-semi-bold fs--1 mb-1" for="selectProducts">
                                            <i class="fas fa-cube me-1 text-primary"></i>Product
                                        </label>
                                        <select class="form-select form-select-sm" id="selectProducts" multiple></select>
                                    </div>

                                    <div class="col-md-5 col-12 d-flex flex-wrap justify-content-md-end align-items-center gap-2">
                                        <button class="btn btn-primary btn-sm text-nowrap" type="button" id="applyFiltersBtn">
                                            <span class="fas fa-search me-1"></span> Load Data
                                        </button>
                                        <button class="btn btn-outline-secondary btn-sm text-nowrap" type="button" id="resetFiltersBtn">
                                            <span class="fas fa-undo me-1"></span> Reset
                                        </button>
                                        <% if (canDownloadReports) { %>
                                        <button class="btn btn-success btn-sm text-nowrap" type="button" id="downloadExcelBtn">
                                            <span class="fas fa-file-excel me-1"></span> Download Excel
                                        </button>
                                        <% } %>
                                        <% if (hasReportLogs) { %>
                                        <a class="btn btn-info btn-sm text-nowrap" href="${pageContext.request.contextPath}/report-logs" style="background: linear-gradient(135deg, #0ea5e9 0%, #0284c7 100%) !important; border: none !important; color: #ffffff !important; box-shadow: 0 4px 12px rgba(14, 165, 233, 0.2) !important;">
                                            <span class="fas fa-history me-1"></span> View Logs
                                        </a>
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
                                <table class="table table-hover table-striped align-middle mb-0 fs--1 w-100" id="tableDisbursement">
                                    <thead class="bg-200 text-900">
                                        <tr>
                                            <th>Account No</th>
                                            <th>Application No</th>
                                            <th>Series</th>
                                            <th>Status</th>
                                            <th>Product</th>
                                            <th>Branch</th>
                                            <th>Client Code</th>
                                            <th>Client Name</th>
                                            <th>Disbursed Date</th>
                                            <th>Start Date</th>
                                            <th>Maturity Date</th>
                                            <th class="text-end">Loan Amount</th>
                                            <th class="text-end">Rate (%)</th>
                                            <th class="text-center">Period</th>
                                            <th class="text-end">Rental</th>
                                            <th class="text-center">Due Day</th>
                                            <th>Marketing Officer</th>
                                            <th>Security</th>
                                            <th>Vendor</th>
                                            <th>Key Account</th>
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

        <!-- Loading spinner overlay -->
        <div id="cbsLoader" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(255,255,255,0.75); backdrop-filter:blur(3px); z-index:9999; align-items:center; justify-content:center; flex-direction:column;">
            <div class="spinner-border text-primary mb-2" role="status" style="width: 3rem; height: 3rem;">
                <span class="visually-hidden">Loading...</span>
            </div>
            <div id="loaderText" class="fw-bold text-primary fs-0">Processing, please wait...</div>
        </div>

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
            let productChoices;
            let dtDisbursement;

            function getCurrentYearMonth() {
                const now = new Date();
                const year = now.getFullYear();
                const month = String(now.getMonth() + 1).padStart(2, '0');
                return year + '-' + month;
            }

            function getFilters() {
                const products = productChoices ? productChoices.getValue(true) : [];
                return {
                    month: $('#selectMonth').val(),
                    products: products
                };
            }

            function getCookie(name) {
                const value = `; ` + document.cookie;
                const parts = value.split(`; ` + name + `=`);
                if (parts.length === 2) return parts.pop().split(';').shift();
            }

            function formatCurrency(val) {
                if (val === null || val === undefined || isNaN(val)) return 'LKR 0.00';
                return 'LKR ' + Number(val).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
            }

            function formatCurrencyInMillions(val) {
                if (val === null || val === undefined || isNaN(val)) return '0.00 Mn';
                const millions = Number(val) / 1000000.0;
                return millions.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + ' Mn';
            }

            function loadSummaryCards() {
                const filters = getFilters();
                if (!filters.products || filters.products.length === 0) {
                    $('#kpiMonthAmount').text('0.00 Mn').attr('title', '0.00');
                    $('#kpiMonthCount').text('0');
                    $('#kpiYtdAmount').text('0.00 Mn').attr('title', '0.00');
                    $('#kpiYtdCount').text('0');
                    $('#kpiFyBadge').text('Financial Year');
                    $('#kpiFyPeriodText').text('Financial Year (Apr - Mar)');
                    return;
                }

                const queryParams = new URLSearchParams();
                if (filters.month) queryParams.append('month', filters.month);
                filters.products.forEach(p => queryParams.append('products', p));

                fetch('${pageContext.request.contextPath}/api/cbs/disbursement/summary?' + queryParams.toString())
                    .then(res => res.json())
                    .then(data => {
                        // Month KPI
                        $('#kpiMonthLabel').text(data.curMonthLabel ? data.curMonthLabel.toUpperCase() : 'CURRENT MONTH');
                        $('#badgeMonthText').text(data.curMonthLabel || 'Selected Month');
                        $('#kpiMonthAmount').text(formatCurrencyInMillions(data.curMonthAmount)).attr('title', formatCurrency(data.curMonthAmount));
                        $('#kpiMonthCount').text(Number(data.curMonthCount || 0).toLocaleString());
                        $('#kpiMonthPeriodText').text(data.curMonthLabel || 'Selected Month');

                        // Financial Year to Date KPI
                        $('#kpiYtdLabel').text(data.ytdLabel || 'FINANCIAL YEAR TO DATE');
                        $('#kpiYtdAmount').text(formatCurrencyInMillions(data.ytdAmount)).attr('title', formatCurrency(data.ytdAmount));
                        $('#kpiYtdCount').text(Number(data.ytdCount || 0).toLocaleString());
                        if (data.fyLabel) {
                            $('#kpiFyBadge').text(data.fyLabel);
                        }
                        if (data.fyStartYear) {
                            $('#kpiFyPeriodText').text('Financial Year (From 01 Apr ' + data.fyStartYear + ')');
                        }
                    })
                    .catch(err => {
                        console.error("Error loading disbursement summary cards:", err);
                        $('#kpiMonthAmount').text('0.00 Mn');
                        $('#kpiYtdAmount').text('0.00 Mn');
                    });
            }

            $(document).ready(function() {
                // Initialize Month filter to current year-month
                const curYm = getCurrentYearMonth();
                $('#selectMonth').val(curYm);

                $('#btnCurrentMonth').on('click', function() {
                    $('#selectMonth').val(getCurrentYearMonth());
                });

                // Initialize Choices for product selection
                productChoices = new Choices('#selectProducts', {
                    removeItemButton: true,
                    placeholder: true,
                    placeholderValue: 'Select Product(s)...',
                    shouldSort: false
                });

                $('#selectProducts').on('change', function() {
                    const products = productChoices ? productChoices.getValue(true) : [];
                    if (products && products.length > 0) {
                        $('#productAlert').addClass('d-none').removeClass('d-flex');
                    }
                });

                // Load Metadata for product filter
                fetch('${pageContext.request.contextPath}/api/cbs/metadata')
                    .then(res => res.json())
                    .then(data => {
                        if (data && data.products) {
                            const productList = data.products.map(p => ({
                                value: p.product_code,
                                label: p.product_name + ' (' + p.product_code + ')',
                                selected: false
                            }));
                            productChoices.setChoices(productList, 'value', 'label', true);
                        }
                    })
                    .catch(err => console.error("Error loading filter metadata:", err));

                // Initialize DataTable
                dtDisbursement = $('#tableDisbursement').DataTable({
                    processing: false,
                    serverSide: true,
                    deferLoading: 0,
                    order: [[8, 'desc']],
                    pageLength: 25,
                    lengthMenu: [[10, 25, 50, 100], [10, 25, 50, 100]],
                    language: {
                        emptyTable: "Please select a product and click 'Load Data' to view records.",
                        zeroRecords: "No matching disbursed loans found for the selected criteria."
                    },
                    ajax: function(data, callback, settings) {
                        const filters = getFilters();
                        if (!filters.products || filters.products.length === 0) {
                            callback({ draw: data.draw, recordsTotal: 0, recordsFiltered: 0, data: [] });
                            return;
                        }

                        $('#loaderText').text('Loading disbursement data...');
                        $('#cbsLoader').css('display', 'flex');
                        data.data = filters;

                        $.ajax({
                            url: '${pageContext.request.contextPath}/api/cbs/disbursement',
                            type: 'POST',
                            contentType: 'application/json',
                            data: JSON.stringify(data),
                            success: function(res) {
                                callback(res);
                            },
                            error: function(xhr, error, thrown) {
                                console.error("Error fetching disbursement report:", thrown);
                                callback({ draw: data.draw, recordsTotal: 0, recordsFiltered: 0, data: [] });
                            },
                            complete: function() {
                                $('#cbsLoader').hide();
                            }
                        });
                    },
                    columns: [
                        {
                            data: 'account_no',
                            render: function(data, type, row) {
                                let legacy = (row.legacy_account_no && row.legacy_account_no !== '-') ? '<small class="text-muted d-block fs--2">Legacy: ' + row.legacy_account_no + '</small>' : '';
                                return '<span class="badge-account">' + data + '</span>' + legacy;
                            }
                        },
                        { data: 'application_no', defaultContent: '-' },
                        { data: 'series', defaultContent: '-' },
                        {
                            data: 'account_status',
                            render: function(data) {
                                if (!data) return '-';
                                let bg = 'bg-soft-primary';
                                if (data === 'A' || data === 'ACTIVE') bg = 'bg-soft-success';
                                else if (data === 'C' || data === 'CLOSED') bg = 'bg-soft-secondary';
                                else if (data === 'P' || data === 'F') bg = 'bg-soft-info';
                                return '<span class="badge ' + bg + '">' + data + '</span>';
                            }
                        },
                        {
                            data: 'product_name',
                            render: function(data, type, row) {
                                return '<span class="badge-product">' + (data || row.product || '-') + '</span>';
                            }
                        },
                        { data: 'branch_name', defaultContent: '-' },
                        { data: 'client_code', defaultContent: '-' },
                        { data: 'client_name', defaultContent: '-' },
                        {
                            data: 'disbursed_date',
                            render: function(data) {
                                return data ? '<span class="fw-semi-bold text-dark">' + data + '</span>' : '-';
                            }
                        },
                        { data: 'start_date', defaultContent: '-' },
                        { data: 'maturity_date', defaultContent: '-' },
                        {
                            data: 'loan_amount',
                            className: 'text-end',
                            render: function(data) {
                                return '<span class="fw-bold text-900">' + (data ? Number(data).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) : '0.00') + '</span>';
                            }
                        },
                        {
                            data: 'rate',
                            className: 'text-end',
                            render: function(data) {
                                return data ? Number(data).toFixed(2) + '%' : '-';
                            }
                        },
                        {
                            data: 'period',
                            className: 'text-center',
                            render: function(data) {
                                return data ? data + ' M' : '-';
                            }
                        },
                        {
                            data: 'rental',
                            className: 'text-end',
                            render: function(data) {
                                return data ? Number(data).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) : '0.00';
                            }
                        },
                        { data: 'due_day', className: 'text-center', defaultContent: '-' },
                        { data: 'marketing_officer', defaultContent: '-' },
                        { data: 'security', defaultContent: '-' },
                        { data: 'vendor', defaultContent: '-' },
                        { data: 'key_account', defaultContent: '-' }
                    ],
                    rowCallback: function(row, data) {
                        $(row).addClass('clickable-row');
                    }
                });

                // Row click handler to open facility info directly
                $('#tableDisbursement tbody').on('click', 'tr', function () {
                    const rowData = dtDisbursement.row(this).data();
                    if (rowData) {
                        const searchVal = (rowData.legacy_account_no && rowData.legacy_account_no !== '-') ? rowData.legacy_account_no : rowData.account_no;
                        if (searchVal) {
                            window.open('${pageContext.request.contextPath}/mobile?query=' + encodeURIComponent(searchVal), '_blank');
                        }
                    }
                });

                // Apply Filters button click
                $('#applyFiltersBtn').on('click', function() {
                    const filters = getFilters();
                    if (!filters.products || filters.products.length === 0) {
                        $('#productAlert').removeClass('d-none').addClass('d-flex');
                        return;
                    }
                    $('#productAlert').addClass('d-none').removeClass('d-flex');

                    $(this).html('<span class="fas fa-sync-alt me-1 fa-spin"></span> Loading...');
                    loadSummaryCards();
                    dtDisbursement.draw();
                    setTimeout(() => {
                        $('#applyFiltersBtn').html('<span class="fas fa-search me-1"></span> Load Data');
                    }, 500);
                });

                // Reset button click
                $('#resetFiltersBtn').on('click', function() {
                    $('#selectMonth').val(getCurrentYearMonth());
                    if (productChoices) {
                        productChoices.removeActiveItems();
                    }
                    $('#productAlert').addClass('d-none').removeClass('d-flex');
                    $('#kpiMonthAmount').text('0.00 Mn').attr('title', '0.00');
                    $('#kpiMonthCount').text('0');
                    $('#kpiYtdAmount').text('0.00 Mn').attr('title', '0.00');
                    $('#kpiYtdCount').text('0');
                    $('#kpiMonthLabel').text('CURRENT MONTH');
                    $('#kpiYtdLabel').text('FINANCIAL YEAR TO DATE');
                    $('#kpiFyBadge').text('Financial Year');
                    $('#kpiFyPeriodText').text('Financial Year (Apr - Mar)');
                    $('#kpiMonthPeriodText').text('Selected Month');
                    $('#badgeMonthText').text('Current Month');
                    dtDisbursement.clear().draw();
                });

                // Download Excel handler
                if ($('#downloadExcelBtn').length) {
                    $('#downloadExcelBtn').on('click', function() {
                        const filters = getFilters();
                        if (!filters.products || filters.products.length === 0) {
                            $('#productAlert').removeClass('d-none').addClass('d-flex');
                            return;
                        }
                        $('#productAlert').addClass('d-none').removeClass('d-flex');

                        let downloadUrl = '${pageContext.request.contextPath}/api/cbs/disbursement/download';

                        const queryParams = new URLSearchParams();
                        if (filters.month) queryParams.append('month', filters.month);
                        filters.products.forEach(p => queryParams.append('products', p));

                        const token = new Date().getTime();
                        queryParams.append('downloadToken', token);

                        $('#loaderText').text('Generating Excel download for ' + (filters.month || 'selected period') + '...');
                        $('#cbsLoader').css('display', 'flex');

                        window.location.href = downloadUrl + '?' + queryParams.toString();

                        const fallbackTimer = setTimeout(function() {
                            $('#cbsLoader').hide();
                            clearInterval(checkTimer);
                        }, 5000);

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
    </body>
</html>
