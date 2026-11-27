<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en-US" dir="ltr">

    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title>Fintrex | Loan Debits Exception Report</title>

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
                color: #ffffff !important;
            }
            .btn-success {
                background: linear-gradient(135deg, #10b981 0%, #059669 100%) !important;
                border: none !important;
                box-shadow: 0 4px 12px rgba(16, 185, 129, 0.2) !important;
                color: #ffffff !important;
            }
            #tableLoanDebitsException tbody tr {
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
                            <h4 class="mb-0 text-danger"><i class="fas fa-exclamation-triangle me-2"></i>Exception Reports - Loan Debits (Duplicate Monthly Debits)</h4>
                            <small class="text-muted">Accounts debited more than once in the same month with the same narration (<code>cbs.loan_debits</code>)</small>
                        </div>
                    </div>

                    <!-- Filter Panel -->
                    <div class="card glass-card mb-3" style="position: relative; z-index: 10;">
                        <div class="card-body py-2">
                            <form id="filterForm">
                                <div class="row g-2 align-items-end">
                                    <div class="col-md-2">
                                        <label class="form-label text-700 fw-semi-bold mb-1 fs--1" for="filterMonth">Month</label>
                                        <input type="month" class="form-control form-control-sm" id="filterMonth">
                                    </div>
                                    <div class="col-md-2">
                                        <label class="form-label text-700 fw-semi-bold mb-1 fs--1" for="fromDate">From Date</label>
                                        <input type="date" class="form-control form-control-sm" id="fromDate">
                                    </div>
                                    <div class="col-md-2">
                                        <label class="form-label text-700 fw-semi-bold mb-1 fs--1" for="toDate">To Date</label>
                                        <input type="date" class="form-control form-control-sm" id="toDate">
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label text-700 fw-semi-bold mb-1 fs--1" for="filterNarration">Narration</label>
                                        <input type="text" class="form-control form-control-sm" id="filterNarration" placeholder="Search narration...">
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label text-700 fw-semi-bold mb-1 fs--1" for="filterAccount">Account / Legacy No</label>
                                        <input type="text" class="form-control form-control-sm" id="filterAccount" placeholder="Search account...">
                                    </div>
                                    <div class="col-12 d-flex justify-content-end gap-2 mt-2">
                                        <button class="btn btn-outline-secondary btn-sm text-nowrap" type="button" id="clearFiltersBtn">
                                            <span class="fas fa-undo me-1"></span> Reset
                                        </button>
                                        <button class="btn btn-primary btn-sm text-nowrap" type="button" id="applyFiltersBtn">
                                            <span class="fas fa-search me-1"></span> Load Report
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
                                <table class="table table-hover table-striped align-middle mb-0 w-100 fs--1" id="tableLoanDebitsException">
                                    <thead class="bg-200 text-900">
                                        <tr>
                                            <th>Tran ID</th>
                                            <th>Account No</th>
                                            <th>Legacy Account</th>
                                            <th>Date</th>
                                            <th>Month</th>
                                            <th class="text-end">Amount (LKR)</th>
                                            <th>Narration</th>
                                            <th class="text-center">SMS Sent</th>
                                            <th class="text-end">Count (Same Month)</th>
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
        <script src="${pageContext.request.contextPath}/vendors/datatables.net/jquery.dataTables.min.js"></script>
        <script src="${pageContext.request.contextPath}/vendors/datatables.net-bs5/dataTables.bootstrap5.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/theme.js"></script>

        <script>
            let dtReport = null;

            function formatNumber(val) {
                if (val === null || val === undefined || isNaN(val)) return '0.00';
                return Number(val).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
            }

            function getFilters() {
                return {
                    month: $('#filterMonth').val() || '',
                    fromDate: $('#fromDate').val() || '',
                    toDate: $('#toDate').val() || '',
                    narration: $('#filterNarration').val() || '',
                    account: $('#filterAccount').val() || ''
                };
            }

            function loadReport() {
                const filters = getFilters();
                $('#cbsLoader').css('display', 'flex');

                $.ajax({
                    url: '${pageContext.request.contextPath}/api/cbs/loan-debits-exception',
                    type: 'POST',
                    contentType: 'application/json',
                    data: JSON.stringify(filters),
                    success: function(res) {
                        const rows = res.rows || [];
                        if (dtReport) {
                            dtReport.clear().rows.add(rows).draw();
                        } else {
                            dtReport = $('#tableLoanDebitsException').DataTable({
                                data: rows,
                                pageLength: 25,
                                order: [[4, 'desc'], [1, 'asc'], [6, 'asc'], [3, 'asc']],
                                columns: [
                                    { data: 'tran_id', defaultContent: '-' },
                                    { data: 'account_no', defaultContent: '-' },
                                    { data: 'legacy_account', defaultContent: '-' },
                                    { data: 'trx_date', defaultContent: '-' },
                                    { data: 'debit_month', defaultContent: '-' },
                                    {
                                        data: 'amount',
                                        className: 'text-end fw-semi-bold',
                                        render: function(data) { return formatNumber(data); }
                                    },
                                    { data: 'narration', defaultContent: '-' },
                                    {
                                        data: 'sms_sent',
                                        className: 'text-center',
                                        render: function(data) {
                                            const v = String(data || '').trim().toLowerCase();
                                            if (v === '1' || v === 'y' || v === 'yes' || v === 'true' || v === 'sent') {
                                                return '<span class="badge bg-soft-success text-success">Sent</span>';
                                            }
                                            if (v === '0' || v === 'n' || v === 'no' || v === 'false') {
                                                return '<span class="badge bg-soft-secondary text-secondary">No</span>';
                                            }
                                            return data ? '<span class="badge bg-soft-info text-info">' + data + '</span>' : '-';
                                        }
                                    },
                                    {
                                        data: 'dup_count',
                                        className: 'text-end',
                                        render: function(data) {
                                            return '<span class="badge bg-soft-danger text-danger fw-bold">' + (data || 0) + 'x</span>';
                                        }
                                    }
                                ]
                            });
                        }
                    },
                    error: function(xhr) {
                        console.error('Failed to load Loan Debits Exception Report:', xhr);
                        alert('Unable to load Loan Debits Exception Report.');
                    },
                    complete: function() {
                        $('#cbsLoader').hide();
                    }
                });
            }

            $(document).ready(function() {
                // Default to current month
                const now = new Date();
                const currentMonth = now.getFullYear() + '-' + String(now.getMonth() + 1).padStart(2, '0');
                $('#filterMonth').val(currentMonth);

                $('#applyFiltersBtn').on('click', loadReport);

                $('#clearFiltersBtn').on('click', function() {
                    $('#filterMonth').val('');
                    $('#fromDate').val('');
                    $('#toDate').val('');
                    $('#filterNarration').val('');
                    $('#filterAccount').val('');
                    loadReport();
                });

                $('#filterMonth').on('change', function() {
                    if ($(this).val()) {
                        $('#fromDate').val('');
                        $('#toDate').val('');
                    }
                });

                $('#fromDate, #toDate').on('change', function() {
                    if ($('#fromDate').val() || $('#toDate').val()) {
                        $('#filterMonth').val('');
                    }
                });

                $('#tableLoanDebitsException tbody').on('click', 'tr', function() {
                    if (!dtReport) return;
                    const rowData = dtReport.row(this).data();
                    if (rowData) {
                        const searchVal = (rowData.legacy_account && rowData.legacy_account !== '-') ? rowData.legacy_account : rowData.account_no;
                        if (searchVal) {
                            window.open('${pageContext.request.contextPath}/mobile?query=' + encodeURIComponent(searchVal), '_blank');
                        }
                    }
                });

                if ($('#downloadExcelBtn').length) {
                    $('#downloadExcelBtn').on('click', function() {
                        const f = getFilters();
                        const qs = new URLSearchParams();
                        if (f.month) qs.append('month', f.month);
                        if (f.fromDate) qs.append('fromDate', f.fromDate);
                        if (f.toDate) qs.append('toDate', f.toDate);
                        if (f.narration) qs.append('narration', f.narration);
                        if (f.account) qs.append('account', f.account);
                        window.location.href = '${pageContext.request.contextPath}/api/cbs/loan-debits-exception/download?' + qs.toString();
                    });
                }

                loadReport();
            });
        </script>

        <div id="cbsLoader" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(255,255,255,0.7); z-index: 9999; justify-content: center; align-items: center; flex-direction: column;">
            <div class="spinner-border text-primary" role="status" style="width: 3rem; height: 3rem;"></div>
            <span class="mt-2 fw-semi-bold">Loading Loan Debits Exception Report...</span>
        </div>
    </body>
</html>
