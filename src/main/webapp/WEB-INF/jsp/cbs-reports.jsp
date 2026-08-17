<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html lang="en-US" dir="ltr">

    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title>Fintrex | CBS Reports</title>

        <link rel="apple-touch-icon" sizes="180x180" href="assets/img/favicons/apple-touch-icon.png">
        <link rel="icon" type="image/png" sizes="32x32" href="assets/img/favicons/favicon-32x32.png">
        <link rel="icon" type="image/png" sizes="16x16" href="assets/img/favicons/favicon-16x16.png">
        <link rel="shortcut icon" type="image/x-icon" href="assets/img/favicons/favicon.ico">
        <link rel="manifest" href="assets/img/favicons/manifest.json">
        <meta name="msapplication-TileImage" content="assets/img/favicons/mstile-150x150.png">
        <meta name="theme-color" content="#ffffff">
        <script src="assets/js/config.js"></script>
        <script src="vendors/simplebar/simplebar.min.js"></script>


        <link rel="preconnect" href="https://fonts.gstatic.com/">
        <link
            href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,500,600,700%7cPoppins:300,400,500,600,700,800,900&amp;display=swap"
            rel="stylesheet">
        <link href="vendors/simplebar/simplebar.min.css" rel="stylesheet">
        <link href="assets/css/theme-rtl.min.css" rel="stylesheet" id="style-rtl">
        <link href="assets/css/theme.min.css" rel="stylesheet" id="style-default">
        <link href="assets/css/user-rtl.min.css" rel="stylesheet" id="user-style-rtl">
        <link href="assets/css/user.min.css" rel="stylesheet" id="user-style-default">

        <!-- Vendors for DataTables and Choices.js -->
        <link href="vendors/choices/choices.min.css" rel="stylesheet">
        <link href="vendors/datatables.net-bs5/dataTables.bootstrap5.min.css" rel="stylesheet">

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

            .btn-primary:hover,
            .btn-primary:focus,
            .btn-primary:active {
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

            /* Custom choices tags style matching screenshot */
            .choices__inner {
                background: rgba(255, 255, 255, 0.6) !important;
                border: 1px solid rgba(226, 232, 240, 0.8) !important;
                border-radius: 8px !important;
                min-height: 42px !important;
            }

            .choices__list--multiple .choices__item {
                background-color: #2b4eff !important;
                border: 1px solid #2b4eff !important;
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

                            <div class="d-flex mb-3 align-items-center justify-content-between">
                                <div>
                                    <h4 class="mb-1 text-primary"><i class="fas fa-file-invoice-dollar me-2"></i>CBS
                                        Core Reports</h4>
                                    <p class="mb-0 text-500 fs--1">Consolidated reports from the core banking systems
                                    </p>
                                </div>
                            </div>

                            <!-- Filter panel matching screenshot layout -->
                            <div class="card glass-card mb-4">
                                <div class="card-header border-bottom border-200 bg-light">
                                    <h5 class="mb-0 text-800"><span class="fas fa-filter me-2"></span>Report Filter
                                        Panel</h5>
                                </div>
                                <div class="card-body">
                                    <form id="filterForm">
                                        <div class="row g-3">
                                            <div class="col-md-3">
                                                <label class="form-label text-700 fw-semi-bold" for="reportType">Report
                                                    Type</label>
                                                <select class="form-select" id="reportType">
                                                    <option value="branch">Branch Wise</option>
                                                    <option value="product">Product Wise</option>
                                                </select>
                                            </div>
                                            <div class="col-md-3">
                                                <label class="form-label text-700 fw-semi-bold"
                                                    for="selectBranch">Select Branch</label>
                                                <select class="form-select" id="selectBranch">
                                                    <option value="All">All</option>
                                                </select>
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label text-700 fw-semi-bold"
                                                    for="selectProducts">Product</label>
                                                <select class="form-select" id="selectProducts" multiple></select>
                                            </div>
                                            <div class="col-md-3" id="asAtDateContainer">
                                                <label class="form-label text-700 fw-semi-bold" for="asAtDate">As
                                                    at</label>
                                                <input class="form-control" type="date" id="asAtDate"
                                                    value="2026-07-13">
                                            </div>
                                            <div class="col-md-3" id="fromDateContainer" style="display: none;">
                                                <label class="form-label text-700 fw-semi-bold" for="fromDate">From
                                                    Date</label>
                                                <input class="form-control" type="date" id="fromDate"
                                                    value="2026-07-01">
                                            </div>
                                            <div class="col-md-3" id="toDateContainer" style="display: none;">
                                                <label class="form-label text-700 fw-semi-bold" for="toDate">To
                                                    Date</label>
                                                <input class="form-control" type="date" id="toDate" value="2026-07-13">
                                            </div>
                                            <div class="col-md-9 d-flex align-items-end justify-content-end gap-2"
                                                id="buttonContainer">
                                                <button class="btn btn-primary" type="button" id="applyFiltersBtn">
                                                    <span class="fas fa-search me-1"></span> Refresh Data
                                                </button>
                                                <% if (canDownloadReports) { %>
                                                    <button class="btn btn-success" type="button" id="downloadExcelBtn">
                                                        <span class="fas fa-file-excel me-1"></span> Download CSV
                                                    </button>
                                                    <% } %>
                                            </div>
                                        </div>
                                    </form>
                                </div>
                            </div>

                            <!-- Tabs containing the 3 reports -->
                            <div class="card glass-card" id="tabsCard">
                                <div class="card-header p-0 border-bottom border-200">
                                    <ul class="nav nav-tabs border-0" id="reportTabs" role="tablist">
                                        <li class="nav-item">
                                            <a class="nav-link active" id="tab-report1" data-bs-toggle="tab"
                                                href="#report1-pane" role="tab" aria-controls="report1-pane"
                                                aria-selected="true">
                                                <span class="fas fa-link me-2"></span>Portfolio
                                            </a>
                                        </li>
                                        <li class="nav-item">
                                            <a class="nav-link" id="tab-report2" data-bs-toggle="tab"
                                                href="#report2-pane" role="tab" aria-controls="report2-pane"
                                                aria-selected="false">
                                                <span class="fas fa-user-tag me-2"></span>Client Report
                                            </a>
                                        </li>
                                        <li class="nav-item">
                                            <a class="nav-link" id="tab-report3" data-bs-toggle="tab"
                                                href="#report3-pane" role="tab" aria-controls="report3-pane"
                                                aria-selected="false">
                                                <span class="fas fa-receipt me-2"></span>Customer Payments
                                            </a>
                                        </li>
                                    </ul>
                                </div>
                                <div class="card-body p-0">
                                    <div class="tab-content">
                                        <!-- Report 1 Pane -->
                                        <div class="tab-pane fade show active" id="report1-pane" role="tabpanel"
                                            aria-labelledby="tab-report1">
                                            <div class="table-responsive scrollbar">
                                                <table
                                                    class="table table-hover table-striped align-middle mb-0 fs--1 w-100"
                                                    id="tableReport1">
                                                    <thead class="bg-200 text-900">
                                                        <tr>
                                                            <th>Account No</th>
                                                            <th>Series</th>
                                                            <th>Legacy Account</th>
                                                            <th>Branch Name</th>
                                                            <th>Product Name</th>
                                                            <th>Loan Amount</th>
                                                            <th>Rental</th>
                                                            <th>Total Due</th>
                                                            <th>Exposure</th>
                                                            <th>DPD</th>
                                                            <th>Perf. Status</th>
                                                            <th>Status</th>
                                                            <th>Disbursed Date</th>
                                                            <th>Closed Date</th>
                                                            <th>IMEI No</th>
                                                            <th>Device Status</th>
                                                            <th>Workhub SP No</th>
                                                            <th>Platform</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody></tbody>
                                                </table>
                                            </div>
                                        </div>

                                        <!-- Report 2 Pane -->
                                        <div class="tab-pane fade" id="report2-pane" role="tabpanel"
                                            aria-labelledby="tab-report2">
                                            <div class="table-responsive scrollbar">
                                                <table
                                                    class="table table-hover table-striped align-middle mb-0 fs--1 w-100"
                                                    id="tableReport2">
                                                    <thead class="bg-200 text-900">
                                                        <tr>
                                                            <th>Client Code</th>
                                                            <th>Type</th>
                                                            <th>Title</th>
                                                            <th>Full Name</th>
                                                            <th>NIC No</th>
                                                            <th>Mobile</th>
                                                            <th>Address</th>
                                                            <th>Branch Name</th>
                                                            <th>Entered Date</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody></tbody>
                                                </table>
                                            </div>
                                        </div>

                                        <!-- Report 3 Pane -->
                                        <div class="tab-pane fade" id="report3-pane" role="tabpanel"
                                            aria-labelledby="tab-report3">
                                            <div class="table-responsive scrollbar">
                                                <table
                                                    class="table table-hover table-striped align-middle mb-0 fs--1 w-100"
                                                    id="tableReport3">
                                                    <thead class="bg-200 text-900">
                                                        <tr>
                                                            <th>Transaction ID</th>
                                                            <th>Account No</th>
                                                            <th>Legacy Account</th>
                                                            <th>Branch Name</th>
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

                    </div>
            </div>
        </main>

        <!-- Scripts -->
        <script src="vendors/jquery/jquery.min.js"></script>
        <script src="vendors/popper/popper.min.js"></script>
        <script src="vendors/bootstrap/bootstrap.min.js"></script>
        <script src="vendors/anchorjs/anchor.min.js"></script>
        <script src="vendors/is/is.min.js"></script>
        <script src="vendors/fontawesome/all.min.js"></script>
        <script src="vendors/lodash/lodash.min.js"></script>
        <script src="vendors/choices/choices.min.js"></script>
        <script src="vendors/datatables.net/jquery.dataTables.min.js"></script>
        <script src="vendors/datatables.net-bs5/dataTables.bootstrap5.min.js"></script>
        <script src="assets/js/theme.js"></script>

        <script>
            let productChoices;
            let dtReport1, dtReport2, dtReport3;

            // Retrieve filter values helper
            function getFilters() {
                const products = productChoices ? productChoices.getValue(true) : [];
                return {
                    branch: $('#selectBranch').val(),
                    products: products,
                    asAt: $('#asAtDate').val(),
                    fromDate: $('#fromDate').val(),
                    toDate: $('#toDate').val()
                };
            }

            $(document).ready(function () {
                // Initialize Choices for multi-select products
                productChoices = new Choices('#selectProducts', {
                    removeItemButton: true,
                    placeholder: true,
                    placeholderValue: 'Select Products',
                    shouldSort: false
                });

                // Load Metadata (branches and products dropdown options)
                fetch('<%= request.getContextPath() %>/api/cbs/metadata')
                    .then(res => res.json())
                    .then(data => {
                        // Populate Branches dropdown
                        const branchSelect = $('#selectBranch');
                        data.branches.forEach(b => {
                            branchSelect.append(new Option(b.branch_name, b.legacy_branch_code));
                        });

                        // Populate Products multi-select
                        const productList = data.products.map(p => ({
                            value: p.product_code,
                            label: p.product_name,
                            selected: false
                        }));
                        productChoices.setChoices(productList, 'value', 'label', true);
                    })
                    .catch(err => console.error("Error loading filter metadata:", err));

                // Initialize DataTables with AJAX paging
                dtReport1 = $('#tableReport1').DataTable({
                    processing: true,
                    serverSide: true,
                    ajax: {
                        url: '<%= request.getContextPath() %>/api/cbs/report1',
                        type: 'POST',
                        contentType: 'application/json',
                        data: function (d) {
                            d.data = getFilters();
                            return JSON.stringify(d);
                        }
                    },
                    columns: [
                        { data: 'account_no' },
                        { data: 'series' },
                        { data: 'legacy_account_no', defaultContent: '-' },
                        { data: 'branch_name' },
                        { data: 'product_name' },
                        { data: 'loan_amount', render: $.fn.dataTable.render.number(',', '.', 2) },
                        { data: 'rental', render: $.fn.dataTable.render.number(',', '.', 2) },
                        { data: 'total_due', render: $.fn.dataTable.render.number(',', '.', 2) },
                        { data: 'exposure', render: $.fn.dataTable.render.number(',', '.', 2) },
                        { data: 'dpd' },
                        { data: 'performing_status' },
                        { data: 'portfolio_loan_status' },
                        { data: 'disbursed_date', defaultContent: '-' },
                        { data: 'closed_date', defaultContent: '-' },
                        { data: 'device_id', defaultContent: '-' },
                        { data: 'device_status', defaultContent: '-' },
                        { data: 'external_id', defaultContent: '-' },
                        { data: 'platform', defaultContent: '-' }
                    ]
                });

                dtReport2 = $('#tableReport2').DataTable({
                    processing: true,
                    serverSide: true,
                    ajax: {
                        url: '<%= request.getContextPath() %>/api/cbs/report2',
                        type: 'POST',
                        contentType: 'application/json',
                        data: function (d) {
                            d.data = getFilters();
                            return JSON.stringify(d);
                        }
                    },
                    columns: [
                        { data: 'client_code' },
                        { data: 'client_type' },
                        { data: 'title' },
                        { data: 'full_name' },
                        { data: 'id_no' },
                        { data: 'mobile', defaultContent: '-' },
                        { data: 'address', defaultContent: '-' },
                        { data: 'branch_name', defaultContent: '-' },
                        { data: 'entered_date' }
                    ]
                });

                dtReport3 = $('#tableReport3').DataTable({
                    processing: true,
                    serverSide: true,
                    ajax: {
                        url: '<%= request.getContextPath() %>/api/cbs/report3',
                        type: 'POST',
                        contentType: 'application/json',
                        data: function (d) {
                            d.data = getFilters();
                            return JSON.stringify(d);
                        }
                    },
                    columns: [
                        { data: 'tran_id' },
                        { data: 'account_no' },
                        { data: 'legacy_account_no', defaultContent: '-' },
                        { data: 'branch_name', defaultContent: '-' },
                        { data: 'product_name', defaultContent: '-' },
                        { data: 'amount', render: $.fn.dataTable.render.number(',', '.', 2) },
                        { data: 'date' },
                        { data: 'user' },
                        { data: 'channel', defaultContent: '-' },
                        { data: 'narration' }
                    ]
                });

                // Listen to tab switches to toggle date inputs
                $('#reportTabs a').on('shown.bs.tab', function (e) {
                    const targetId = $(e.target).attr('href');
                    if (targetId === '#report1-pane') {
                        $('#asAtDateContainer').show();
                        $('#fromDateContainer').hide();
                        $('#toDateContainer').hide();
                        $('#buttonContainer').removeClass('col-md-6').addClass('col-md-9');
                    } else {
                        $('#asAtDateContainer').hide();
                        $('#fromDateContainer').show();
                        $('#toDateContainer').show();
                        $('#buttonContainer').removeClass('col-md-9').addClass('col-md-6');
                    }
                });

                // Apply Filters
                $('#applyFiltersBtn').on('click', function () {
                    dtReport1.draw();
                    dtReport2.draw();
                    dtReport3.draw();
                });

                // Download Excel/CSV
                if ($('#downloadExcelBtn').length) {
                    $('#downloadExcelBtn').on('click', function () {
                        const filters = getFilters();
                        const activeTabId = $('#reportTabs a.active').attr('href');

                        let downloadUrl = '<%= request.getContextPath() %>/api/cbs/';
                        if (activeTabId === '#report1-pane') {
                            downloadUrl += 'report1/download';
                        } else if (activeTabId === '#report2-pane') {
                            downloadUrl += 'report2/download';
                        } else if (activeTabId === '#report3-pane') {
                            downloadUrl += 'report3/download';
                        }

                        // Build query params
                        const queryParams = new URLSearchParams();
                        queryParams.append('branch', filters.branch);
                        if (activeTabId === '#report1-pane') {
                            queryParams.append('asAt', filters.asAt);
                        } else {
                            queryParams.append('fromDate', filters.fromDate);
                            queryParams.append('toDate', filters.toDate);
                        }
                        if (filters.products && filters.products.length > 0) {
                            filters.products.forEach(p => queryParams.append('products', p));
                        }

                        window.location.href = downloadUrl + '?' + queryParams.toString();
                    });
                }
            });
        </script>

    </body>

    </html>
    <%-- Touch JSP for JSPF compile v8 --%>