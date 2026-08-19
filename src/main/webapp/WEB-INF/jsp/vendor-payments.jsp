<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en-US" dir="ltr">

    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title>Fintrex | Vendor Payments Report</title>

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
            .text-primary { color: #6366f1 !important; }
            .kpi-card {
                background: rgba(255, 255, 255, 0.85);
                border-radius: 12px;
                padding: 12px 16px;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
            }
            .kpi-title {
                font-size: 0.75rem;
                font-weight: 600;
                text-transform: uppercase;
                color: #64748b;
            }
            .kpi-value {
                font-size: 1.25rem;
                font-weight: 750;
                margin-top: 2px;
            }
            .date-filter-group {
                display: flex;
                gap: 8px;
                align-items: center;
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
                            <h4 class="mb-0 text-primary"><i class="fas fa-file-invoice-dollar me-2"></i>Vendor Payments Report</h4>
                        </div>
                    </div>

                    <!-- Top Summary KPI Cards -->
                    <div class="row row-cols-1 row-cols-sm-2 row-cols-md-4 g-3 mb-3">
                        <div class="col">
                            <div class="kpi-card border-start border-4 border-primary">
                                <div class="kpi-title"><i class="fas fa-coins me-1 text-primary"></i>Total Payments</div>
                                <div class="kpi-value text-primary" id="kpiTotalAmount">LKR 0.00</div>
                                <div class="small text-muted mt-1" id="kpiTotalCount">0 Transactions</div>
                            </div>
                        </div>
                        <div class="col">
                            <div class="kpi-card border-start border-4 border-success">
                                <div class="kpi-title"><i class="fas fa-check-circle me-1 text-success"></i>Completed</div>
                                <div class="kpi-value text-success" id="kpiCompletedAmount">LKR 0.00</div>
                                <div class="small text-muted mt-1" id="kpiCompletedCount">0 Transactions</div>
                            </div>
                        </div>
                        <div class="col">
                            <div class="kpi-card border-start border-4 border-warning">
                                <div class="kpi-title"><i class="fas fa-clock me-1 text-warning"></i>Pending</div>
                                <div class="kpi-value text-warning" id="kpiPendingAmount">LKR 0.00</div>
                                <div class="small text-muted mt-1" id="kpiPendingCount">0 Transactions</div>
                            </div>
                        </div>
                        <div class="col">
                            <div class="kpi-card border-start border-4 border-danger">
                                <div class="kpi-title"><i class="fas fa-times-circle me-1 text-danger"></i>Failed</div>
                                <div class="kpi-value text-danger" id="kpiFailedAmount">LKR 0.00</div>
                                <div class="small text-muted mt-1" id="kpiFailedCount">0 Transactions</div>
                            </div>
                        </div>
                    </div>

                    <!-- Filter panel -->
                    <div class="card glass-card mb-3" style="position: relative; z-index: 10;">
                        <div class="card-body py-2">
                            <form id="filterForm">
                                <div class="row g-2 align-items-center">
                                    <div class="col-md-2">
                                        <label class="form-label text-700 fw-semi-bold mb-1 fs--1">Date Preset</label>
                                        <select class="form-select form-select-sm" id="dateModeSelect">
                                            <option value="today" selected>Today</option>
                                            <option value="monthly">Monthly</option>
                                            <option value="accumulating">Accumulating (Date Range)</option>
                                            <option value="last3years">Last 3 Years</option>
                                        </select>
                                    </div>

                                    <!-- Dynamic Date Mode Inputs -->
                                    <div class="col-md-3" id="dateInputsContainer">
                                        <!-- Rendered dynamically -->
                                    </div>

                                    <div class="col-md-2">
                                        <label class="form-label text-700 fw-semi-bold mb-1 fs--1">Status</label>
                                        <select class="form-select form-select-sm" id="statusSelect">
                                            <option value="ALL" selected>All Statuses</option>
                                            <option value="Completed">Completed</option>
                                            <option value="Pending">Pending</option>
                                            <option value="Failed">Failed</option>
                                            <option value="Initiated">Initiated</option>
                                        </select>
                                    </div>

                                    <div class="col-md-3">
                                        <label class="form-label text-700 fw-semi-bold mb-1 fs--1">Vendor</label>
                                        <select class="form-select form-select-sm" id="vendorSelect">
                                            <option value="ALL" selected>All Vendors</option>
                                        </select>
                                    </div>

                                    
                                    <div class="col-md-3">
                                        <label class="form-label text-700 fw-semi-bold mb-1 fs--1" for="selectProducts">Product</label>
                                        <select class="form-select form-select-sm" id="selectProducts" multiple></select>
                                    </div>
                                    <div class="col-md-2 d-flex align-items-end justify-content-end gap-2 pt-3">
                                        <button class="btn btn-primary btn-sm" type="button" id="applyFiltersBtn">
                                            <span class="fas fa-search me-1"></span> Load Report
                                        </button>
                                        <% if (canDownloadReports) { %>
                                        <button class="btn btn-success btn-sm" type="button" id="downloadCsvBtn">
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
                                <table class="table table-hover table-striped align-middle mb-0 w-100 fs--1" id="tableVendorPayments">
                                    <thead class="bg-200 text-900">
                                        <tr>
                                            <th>Trx Date</th>
                                            <th>Consumer Tran ID</th>
                                            <th>Account ID</th>
                                            <th>Vendor (Code - Name)</th>
                                            <th>Destination Account</th>
                                            <th>Bank / Branch</th>
                                            <th class="text-end">Amount (LKR)</th>
                                            <th>Ref / SP No</th>
                                            <th class="text-center">Status</th>
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
        <script src="${pageContext.request.contextPath}/vendors/choices/choices.min.js"></script>
        <script src="${pageContext.request.contextPath}/vendors/datatables.net/jquery.dataTables.min.js"></script>
        <script src="${pageContext.request.contextPath}/vendors/datatables.net-bs5/dataTables.bootstrap5.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/theme.js"></script>

        <script>
            let dataTable = null;

            function formatNumber(val) {
                if (val === null || val === undefined || isNaN(val)) return '0.00';
                return Number(val).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 });
            }

            function updateDateInputs() {
                const mode = $('#dateModeSelect').val();
                const container = $('#dateInputsContainer');
                container.empty();

                const currentYear = new Date().getFullYear();

                if (mode === 'today') {
                    container.html('<label class="form-label text-700 fw-semi-bold mb-1 fs--1">Date</label><input type="text" class="form-control form-control-sm" value="Today (' + new Date().toISOString().split('T')[0] + ')" readonly>');
                } else if (mode === 'monthly') {
                    let monthOpts = '';
                    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
                    months.forEach((m, idx) => {
                        const sel = (idx === new Date().getMonth()) ? 'selected' : '';
                        monthOpts += '<option value="' + (idx + 1) + '" ' + sel + '>' + m + '</option>';
                    });
                    container.html(
                        '<div class="row g-2">' +
                            '<div class="col-6"><label class="form-label text-700 fw-semi-bold mb-1 fs--1">Year</label><select class="form-select form-select-sm" id="monthYearSelect">' +
                                '<option value="' + currentYear + '" selected>' + currentYear + '</option>' +
                                '<option value="' + (currentYear - 1) + '">' + (currentYear - 1) + '</option>' +
                                '<option value="' + (currentYear - 2) + '">' + (currentYear - 2) + '</option>' +
                            '</select></div>' +
                            '<div class="col-6"><label class="form-label text-700 fw-semi-bold mb-1 fs--1">Month</label><select class="form-select form-select-sm" id="monthSelect">' + monthOpts + '</select></div>' +
                        '</div>'
                    );
                } else if (mode === 'accumulating') {
                    const todayStr = new Date().toISOString().split('T')[0];
                    container.html(
                        '<div class="row g-2">' +
                            '<div class="col-6"><label class="form-label text-700 fw-semi-bold mb-1 fs--1">From</label><input type="date" class="form-control form-control-sm" id="fromDateInput" value="' + todayStr + '"></div>' +
                            '<div class="col-6"><label class="form-label text-700 fw-semi-bold mb-1 fs--1">To</label><input type="date" class="form-control form-control-sm" id="toDateInput" value="' + todayStr + '"></div>' +
                        '</div>'
                    );
                } else if (mode === 'last3years') {
                    container.html(
                        '<label class="form-label text-700 fw-semi-bold mb-1 fs--1">Year</label><select class="form-select form-select-sm" id="last3YearsSelect">' +
                            '<option value="ALL" selected>All Last 3 Years (' + (currentYear - 2) + ' - ' + currentYear + ')</option>' +
                            '<option value="' + currentYear + '">' + currentYear + '</option>' +
                            '<option value="' + (currentYear - 1) + '">' + (currentYear - 1) + '</option>' +
                            '<option value="' + (currentYear - 2) + '">' + (currentYear - 2) + '</option>' +
                        '</select>'
                    );
                }
            }

            function buildFiltersPayload() {
                const mode = $('#dateModeSelect').val();
                const payload = {
                    dateMode: mode,
                    status: $('#statusSelect').val(),
                    vendor: $('#vendorSelect').val()
                };

                if (mode === 'monthly') {
                    payload.year = $('#monthYearSelect').val();
                    payload.month = $('#monthSelect').val();
                } else if (mode === 'accumulating') {
                    payload.fromDate = $('#fromDateInput').val();
                    payload.toDate = $('#toDateInput').val();
                } else if (mode === 'last3years') {
                    payload.year = $('#last3YearsSelect').val();
                }
                return payload;
            }

            function loadReportData() {
                const filters = buildFiltersPayload();

                if (dataTable) {
                    dataTable.destroy();
                    $('#tableVendorPayments tbody').empty();
                }

                $('#loaderText').text('Loading data, please wait...');
                $('#cbsLoader').css('display', 'flex');

                $.ajax({
                    url: '${pageContext.request.contextPath}/api/cbs/vendor-payments',
                    type: 'POST',
                    contentType: 'application/json',
                    data: JSON.stringify(filters),
                    success: function(res) {
                        const rows = res.rows || [];
                        const totals = res.totals || {};

                        $('#kpiTotalAmount').text('LKR ' + formatNumber(totals.totalAmount || 0));
                        $('#kpiTotalCount').text((totals.totalCount || 0) + ' Transactions');

                        $('#kpiCompletedAmount').text('LKR ' + formatNumber(totals.completedAmount || 0));
                        $('#kpiCompletedCount').text((totals.completedCount || 0) + ' Transactions');

                        $('#kpiPendingAmount').text('LKR ' + formatNumber(totals.pendingAmount || 0));
                        $('#kpiPendingCount').text((totals.pendingCount || 0) + ' Transactions');

                        $('#kpiFailedAmount').text('LKR ' + formatNumber(totals.failedAmount || 0));
                        $('#kpiFailedCount').text((totals.failedCount || 0) + ' Transactions');

                        dataTable = $('#tableVendorPayments').DataTable({
                            data: rows,
                            columns: [
                                { data: 'trx_date' },
                                { data: 'consumer_tran_id' },
                                { data: 'account_id', render: function(d) { return '<span class="fw-bold">' + (d || '-') + '</span>'; } },
                                { 
                                    data: null, 
                                    render: function(d, type, row) { 
                                        return (row.vendor_code || '') + ' - ' + (row.vendor_name || 'Unknown');
                                    } 
                                },
                                { 
                                    data: null, 
                                    render: function(d, type, row) { 
                                        return (row.destination_account || '') + ' (' + (row.destination_account_name || 'N/A') + ')';
                                    } 
                                },
                                { 
                                    data: null, 
                                    render: function(d, type, row) { 
                                        return (row.bank_name || row.bank_code || '') + ' / ' + (row.branch_code || '');
                                    } 
                                },
                                { 
                                    data: 'amount', 
                                    className: 'text-end fw-bold',
                                    render: function(d) { return formatNumber(d); } 
                                },
                                { 
                                    data: null, 
                                    render: function(d, type, row) { 
                                        return (row.ref || '') + (row.sp_number ? ' / ' + row.sp_number : '');
                                    } 
                                },
                                { 
                                    data: 'status', 
                                    className: 'text-center',
                                    render: function(d) {
                                        let bg = 'bg-secondary';
                                        if (d === 'Completed') bg = 'bg-success';
                                        else if (d === 'Pending') bg = 'bg-warning text-dark';
                                        else if (d === 'Failed') bg = 'bg-danger';
                                        else if (d === 'Initiated') bg = 'bg-info text-dark';
                                        return '<span class="badge ' + bg + '">' + (d || 'Unknown') + '</span>';
                                    } 
                                }
                            ],
                            pageLength: 25,
                            order: [[0, 'desc']],
                            language: {
                                emptyTable: 'No vendor payment records found for the selected filter criteria'
                            }
                        });
                    },
                    error: function(err) {
                        console.error("Failed to load vendor payments:", err);
                    },
                    complete: function() {
                        $('#cbsLoader').hide();
                    }
                });
            }

            function getCookie(name) {
                const value = `; ${document.cookie}`;
                const parts = value.split(`; ${name}=`);
                if (parts.length === 2) return parts.pop().split(';').shift();
            }

            $(document).ready(function() {

                productChoices = new Choices('#selectProducts', {
                    removeItemButton: true,
                    placeholder: true,
                    placeholderValue: 'Select Products',
                    shouldSort: false
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
                    })
                    .catch(err => console.error("Error loading filter metadata:", err));
    
                updateDateInputs();
                $('#dateModeSelect').on('change', updateDateInputs);
                $('#applyFiltersBtn').on('click', loadReportData);

                // Fetch distinct vendors list
                $.ajax({
                    url: '${pageContext.request.contextPath}/api/cbs/vendors',
                    type: 'GET',
                    success: function(vendors) {
                        let optHtml = '<option value="ALL" selected>All Vendors</option>';
                        vendors.forEach(function(v) {
                            optHtml += '<option value="' + v.vendor_code + '">' + v.vendor_name + ' (' + v.vendor_code + ')</option>';
                        });
                        $('#vendorSelect').html(optHtml);
                    }
                });

                $('#downloadCsvBtn').on('click', function() {
                    const filters = buildFiltersPayload();
                    
                    const token = new Date().getTime();
                    filters.downloadToken = token;
                    
                    const queryStr = $.param(filters);
                    
                    $('#loaderText').text('Generating Excel download, please wait...');
                    $('#cbsLoader').css('display', 'flex');
                    
                    window.location.href = '${pageContext.request.contextPath}/api/cbs/vendor-payments/download?' + queryStr;

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
