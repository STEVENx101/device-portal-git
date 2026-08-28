<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en-US" dir="ltr">

    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title>Fintrex | Customer Payments</title>

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

        <!-- Vendors for DataTables and Choices.js -->
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
                background-color: rgba(99, 102, 241, 0.15) !important;
                color: #6366f1 !important;
            }
            .bg-primary {
                background: linear-gradient(135deg, #6366f1 0%, #a855f7 100%) !important;
            }
            /* Custom choices tags style */
            .choices {
                z-index: 1005 !important;
            }
            .choices__inner {
                background: rgba(255, 255, 255, 0.6) !important;
                border: 1px solid rgba(226, 232, 240, 0.8) !important;
                border-radius: 8px !important;
                min-height: 42px !important;
            }
            .choices__list--multiple .choices__item,
            .choices__list--multiple .choices__item * {
                background-color: #2b4eff !important;
                border: none !important;
                border-radius: 4px !important;
                font-weight: 600;
                font-size: 0.8rem;
                padding: 3px 8px !important;
                color: #ffffff !important;
            }
            .choices__list--dropdown {
                background: rgba(255, 255, 255, 0.95) !important;
                backdrop-filter: blur(10px);
                border-radius: 8px !important;
                border: 1px solid rgba(226, 232, 240, 0.8) !important;
                z-index: 1005 !important;
            }
            select[data-choice="active"] {
                display: none !important;
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
                            <h4 class="mb-0 text-primary"><i class="fas fa-file-invoice-dollar me-2"></i>Device Finance Reports - Customer Payments</h4>
                        </div>
                    </div>

                    <!-- Filter panel matching screenshot layout -->
                    <div class="card glass-card mb-3" style="position: relative; z-index: 10;">
                        <div class="card-body">
                            <form id="filterForm">
                                <div class="row g-3 align-items-end">
                                    <div class="col-md-2">
                                        <label class="form-label text-700 fw-semi-bold" for="selectBranch">Select Branch</label>
                                        <select class="form-select" id="selectBranch">
                                            <option value="All">All</option>
                                        </select>
                                    </div>
                                    <div class="col-md-2">
                                        <label class="form-label text-700 fw-semi-bold" for="selectProducts">Product</label>
                                        <select class="form-select" id="selectProducts" multiple></select>
                                    </div>
                                    <div class="col-md-2">
                                        <label class="form-label text-700 fw-semi-bold" for="fromDate">From Date</label>
                                        <input class="form-control" type="date" id="fromDate" value="2026-07-01">
                                    </div>
                                    <div class="col-md-2">
                                        <label class="form-label text-700 fw-semi-bold" for="toDate">To Date</label>
                                        <input class="form-control" type="date" id="toDate" value="2026-07-13">
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
                                <table class="table table-hover table-striped align-middle mb-0 fs--1 w-100" id="tableReport3">
                                    <thead class="bg-200 text-900">
                                        <tr>
                                            <th>Transaction ID</th>
                                            <th>Account No</th>
                                            <th>Legacy Account</th>
                                            <th>Product Name</th>
                                            <th>Amount</th>
                                            <th>Date</th>
                                            <th>User</th>
                                            <th>Channel</th>
                                            <th>Narration</th>
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
            let productChoices;
            let dtReport;
            let hasLoaded = false;

            function getFilters() {
                const products = productChoices ? productChoices.getValue(true) : [];
                return {
                    branch: $('#selectBranch').val(),
                    products: products,
                    fromDate: $('#fromDate').val(),
                    toDate: $('#toDate').val()
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
                        const branchSelect = $('#selectBranch');
                        data.branches.forEach(b => {
                            branchSelect.append(new Option(b.branch_name, b.legacy_branch_code));
                        });

                        const productList = data.products.map(p => ({
                            value: p.product_code,
                            label: p.product_name,
                            selected: false
                        }));
                        productChoices.setChoices(productList, 'value', 'label', true);
                    })
                    .catch(err => console.error("Error loading filter metadata:", err));

                dtReport = $('#tableReport3').DataTable({
                    processing: false,
                    serverSide: true,
                    deferLoading: true,
                    ajax: function(data, callback, settings) {
                        $('#loaderText').text('Loading data, please wait...');
                        $('#cbsLoader').css('display', 'flex');
                        data.data = getFilters();
                        $.ajax({
                            url: '${pageContext.request.contextPath}/api/cbs/report3',
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
                        { data: 'tran_id' },
                        { data: 'account_no' },
                        { data: 'legacy_account_no', defaultContent: '-' },
                        { data: 'product_name', defaultContent: '-' },
                        { data: 'amount', render: $.fn.dataTable.render.number(',', '.', 2) },
                        { data: 'date' },
                        { data: 'user' },
                        { data: 'channel', defaultContent: '-' },
                        { data: 'narration' }
                    ]
                });

                // Row click handler to open facility info
                $('#tableReport3 tbody').on('click', 'tr', function () {
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
                });

                if ($('#downloadExcelBtn').length) {
                    $('#downloadExcelBtn').on('click', function() {
                        const filters = getFilters();
                        let downloadUrl = '${pageContext.request.contextPath}/api/cbs/report3/download';

                        const queryParams = new URLSearchParams();
                        queryParams.append('branch', filters.branch);
                        queryParams.append('fromDate', filters.fromDate);
                        queryParams.append('toDate', filters.toDate);
                        if (filters.products && filters.products.length > 0) {
                            filters.products.forEach(p => queryParams.append('products', p));
                        }

                        const token = new Date().getTime();
                        queryParams.append('downloadToken', token);

                        $('#loaderText').text('Generating Excel download, please wait...');
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
