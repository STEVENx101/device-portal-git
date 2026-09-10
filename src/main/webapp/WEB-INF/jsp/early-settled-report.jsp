<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en-US" dir="ltr">

    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title>Fintrex | Early Settled Report</title>

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
            .bg-soft-primary {
                background-color: rgba(99, 102, 241, 0.15) !important;
                color: #6366f1 !important;
            }
            .bg-primary {
                background: linear-gradient(135deg, #6366f1 0%, #a855f7 100%) !important;
            }
            #tableEarlySettled th, #tableEarlySettled td {
                text-align: left !important;
            }
            #tableEarlySettled tbody tr {
                cursor: pointer;
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
                            <h4 class="mb-0 text-primary"><i class="fas fa-money-check-alt me-2"></i>Exception Reports - Early Settled</h4>
                        </div>
                    </div>

                    <!-- Filter panel -->
                    <div class="card glass-card mb-3" style="position: relative; z-index: 10;">
                        <div class="card-body">
                            <form id="filterForm">
                                <div class="row g-3 align-items-end">
                                     <div class="col-md-2">
                                          <label class="form-label text-700 fw-semi-bold" for="asAtDate">As at Portfolio Date</label>
                                         <input class="form-control" type="date" id="asAtDate" value="">
                                     </div>
                                     <div class="col-md-3">
                                         <label class="form-label text-700 fw-semi-bold" for="lowAmount">Max Balance (Low Amount)</label>
                                         <input class="form-control" type="number" id="lowAmount" value="1000" placeholder="1000">
                                     </div>
                                     
                                    <div class="col-md-3">
                                        <label class="form-label text-700 fw-semi-bold" for="selectProducts">Product</label>
                                        <select class="form-select" id="selectProducts" multiple></select>
                                    </div>
                                    <div class="col-12 d-flex justify-content-end gap-2 mt-2">
                                         <button class="btn btn-primary btn-sm text-nowrap" type="button" id="applyFiltersBtn">
                                             <span class="fas fa-search me-1"></span> Load Data
                                         </button>
                                         <% if (canDownloadReports) { %>
                                         <button class="btn btn-success btn-sm text-nowrap" type="button" id="downloadExcelBtn">
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
                                <table class="table table-hover table-striped align-middle mb-0 fs--1 w-100" id="tableEarlySettled">
                                    <thead class="bg-200 text-900">
                                        <tr>
                                            <th>Account No</th>
                                            <th>Series</th>
                                            <th>Legacy Account</th>
                                            <th>NIC/ID No</th>
                                            <th>Mobile No</th>
                                            <th>Early Settlement Amount</th>
                                            <th>Repayment Balance</th>
                                            <th>Future Capital</th>
                                            <th>Future Interest</th>
                                            <th>Maturity Date</th>
                                            <th>Loan Amount</th>
                                            <th>Rental</th>
                                            <th>Total Due</th>
                                            <th>Exposure</th>
                                            <th>DPD</th>
                                            <th>Account Status</th>
                                            <th>Locked Status</th>
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

        <!-- Loading spinner overlay -->
        <div id="cbsLoader" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(255,255,255,0.7); z-index:9999; align-items:center; justify-content:center; flex-direction:column;">
            <div class="spinner-border text-primary mb-2" role="status">
                <span class="visually-hidden">Loading...</span>
            </div>
            <div id="loaderText" class="fw-bold text-primary">Generating Excel download, please wait...</div>
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
            let dtReport;
            let hasLoaded = false;

            function getFilters() {
                const products = productChoices ? productChoices.getValue(true) : [];
                return {
                    asAt: $('#asAtDate').val(),
                    lowAmount: $('#lowAmount').val(),
                    products: products
                };
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
    
                const today = new Date().toISOString().split('T')[0];
                $('#asAtDate').val(today);

                dtReport = $('#tableEarlySettled').DataTable({
                    processing: false,
                    serverSide: true,
                    deferLoading: true,
                    ordering: false,
                    ajax: function(data, callback, settings) {
                        $('#loaderText').text('Loading data, please wait...');
                        $('#cbsLoader').css('display', 'flex');
                        data.data = getFilters();
                        
                        $.ajax({
                            url: '${pageContext.request.contextPath}/api/cbs/early-settled',
                            type: 'POST',
                            contentType: 'application/json',
                            data: JSON.stringify(data),
                            success: function(response) {
                                $('#cbsLoader').hide();
                                callback(response);
                            },
                            error: function(xhr, status, error) {
                                $('#cbsLoader').hide();
                                console.error('Error fetching early settled report:', error);
                                callback({
                                    draw: data.draw,
                                    recordsTotal: 0,
                                    recordsFiltered: 0,
                                    data: []
                                });
                            }
                        });
                    },
                    columns: [
                        { data: 'account_no', defaultContent: '', className: 'text-start' },
                        { data: 'series', defaultContent: '', className: 'text-start' },
                        { data: 'legacy_account_no', defaultContent: '', className: 'text-start' },
                        { data: 'client_nic', defaultContent: '', className: 'text-start' },
                        { data: 'client_mobile', defaultContent: '', className: 'text-start' },
                        { 
                            data: 'early_settlement', 
                            defaultContent: '0.00',
                            className: 'text-start',
                            render: function(data) {
                                return data ? parseFloat(data).toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2}) : '0.00';
                            }
                        },
                        { 
                            data: 'repayment_balance', 
                            defaultContent: '0.00',
                            className: 'text-start',
                            render: function(data) {
                                return data ? parseFloat(data).toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2}) : '0.00';
                            }
                        },
                        { 
                            data: 'future_capital', 
                            defaultContent: '0.00',
                            className: 'text-start',
                            render: function(data) {
                                return data ? parseFloat(data).toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2}) : '0.00';
                            }
                        },
                        { 
                            data: 'future_interest', 
                            defaultContent: '0.00',
                            className: 'text-start',
                            render: function(data) {
                                return data ? parseFloat(data).toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2}) : '0.00';
                            }
                        },
                        { data: 'maturity_date', defaultContent: '', className: 'text-start' },
                        { 
                            data: 'loan_amount', 
                            defaultContent: '0.00',
                            className: 'text-start',
                            render: function(data) {
                                return data ? parseFloat(data).toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2}) : '0.00';
                            }
                        },
                        { 
                            data: 'rental', 
                            defaultContent: '0.00',
                            className: 'text-start',
                            render: function(data) {
                                return data ? parseFloat(data).toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2}) : '0.00';
                            }
                        },
                        { 
                            data: 'total_due', 
                            defaultContent: '0.00',
                            className: 'text-start',
                            render: function(data) {
                                return data ? parseFloat(data).toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2}) : '0.00';
                            }
                        },
                        { 
                            data: 'exposure', 
                            defaultContent: '0.00',
                            className: 'text-start',
                            render: function(data) {
                                return data ? parseFloat(data).toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2}) : '0.00';
                            }
                        },
                        { data: 'dpd', defaultContent: '0', className: 'text-start' },
                        { data: 'account_status', defaultContent: '', className: 'text-start' },
                        { data: 'lock_status', defaultContent: '', className: 'text-start' },
                        { data: 'recovery_officer', defaultContent: '', className: 'text-start' },
                        { data: 'client_name', defaultContent: '', className: 'text-start' }
                    ],
                    pageLength: 25,
                    language: {
                        emptyTable: "No data available in table",
                        info: "Showing _START_ to _END_ of _TOTAL_ entries",
                        infoEmpty: "Showing 0 to 0 of 0 entries"
                    }
                });

                // Row click handler to open facility info
                $('#tableEarlySettled tbody').on('click', 'tr', function () {
                    const rowData = dtReport.row(this).data();
                    if (rowData) {
                        const searchVal = (rowData.legacy_account_no && rowData.legacy_account_no !== '-') ? rowData.legacy_account_no : rowData.account_no;
                        if (searchVal) {
                            window.open('${pageContext.request.contextPath}/mobile?query=' + encodeURIComponent(searchVal), '_blank');
                        }
                    }
                });

                $('#applyFiltersBtn').on('click', function() {
                    hasLoaded = true;
                    dtReport.ajax.reload();
                });

                $('#downloadExcelBtn').on('click', function() {
                    const filters = getFilters();
                    let downloadUrl = '${pageContext.request.contextPath}/api/cbs/early-settled/download';
                    let queryParams = [];

                    const token = new Date().getTime().toString();
                    queryParams.push('downloadToken=' + encodeURIComponent(token));

                    if (filters.asAt) queryParams.push('asAt=' + encodeURIComponent(filters.asAt));
                    if (filters.lowAmount) queryParams.push('lowAmount=' + encodeURIComponent(filters.lowAmount));

                    if (filters.products && filters.products.length > 0) {
                        filters.products.forEach(p => queryParams.push('products=' + encodeURIComponent(p)));
                    }

                    if (queryParams.length > 0) {
                        downloadUrl += '?' + queryParams.join('&');
                    }

                    $('#loaderText').text('Generating Excel download, please wait...');
                    $('#cbsLoader').css('display', 'flex');

                    window.location.href = downloadUrl;

                    const checkTokenInterval = setInterval(function() {
                        if (getCookie('downloadToken') === token) {
                            $('#cbsLoader').hide();
                            document.cookie = 'downloadToken=; Max-Age=-99999999; path=/';
                            clearInterval(checkTokenInterval);
                        }
                    }, 500);
                });
            });
        </script>
    </body>
</html>
