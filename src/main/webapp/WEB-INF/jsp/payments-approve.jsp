<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en-US" dir="ltr">

    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title>Fintrex | Bulk Payments Approval</title>

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
            .card-header-gradient {
                background: linear-gradient(135deg, #6366f1 0%, #a855f7 100%);
                color: white;
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

                    <div class="d-flex mb-3 align-items-center justify-content-between mt-2">
                        <div>
                            <h4 class="mb-0 text-primary"><i class="fas fa-check-double me-2"></i>Bulk Payments Approvals</h4>
                        </div>
                    </div>

                    <div class="card glass-card">
                        <div class="card-header p-3 border-bottom card-header-gradient">
                            <h6 class="mb-0 text-white"><i class="fas fa-list-ul me-2"></i>Pending Approvals Queue</h6>
                        </div>
                        <div class="card-body p-3">
                            <div class="table-responsive scrollbar">
                                <table class="table table-hover table-striped align-middle mb-0 fs--1 w-100" id="tablePendingApprovals">
                                    <thead class="bg-200 text-900">
                                        <tr>
                                            <th>ID</th>
                                            <th>Upload Date</th>
                                            <th>Uploaded By</th>
                                            <th>Service</th>
                                            <th>Comment</th>
                                            <th>Total Records</th>
                                            <th>Action</th>
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

        <!-- Details Modal -->
        <div class="modal fade" id="detailsModal" tabindex="-1" aria-labelledby="detailsModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-xl modal-dialog-centered">
                <div class="modal-content glass-card border-0">
                    <div class="modal-header card-header-gradient text-white p-3">
                        <h5 class="modal-title text-white" id="detailsModalLabel"><i class="fas fa-info-circle me-2"></i>Staged Upload Detail Records</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-4">
                        <div class="table-responsive scrollbar">
                            <table class="table table-hover table-striped align-middle mb-0 fs--1 w-100" id="tableBulkDetails">
                                <thead class="bg-200 text-900">
                                    <tr>
                                        <th>ID</th>
                                        <th>Payment ID</th>
                                        <th>Account No</th>
                                        <th>Amount</th>
                                        <th>Narration</th>
                                        <th>Status</th>
                                        <th>Pushed At</th>
                                        <th>Ended At</th>
                                    </tr>
                                </thead>
                                <tbody></tbody>
                            </table>
                        </div>
                    </div>
                    <div class="modal-footer p-2">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Close</button>
                        <button type="button" class="btn btn-success btn-sm" id="modalApproveBtn">
                            <i class="fas fa-check me-1"></i>Approve & Post Payments
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <script src="${pageContext.request.contextPath}/vendors/bootstrap/bootstrap.min.js"></script>
        <script src="${pageContext.request.contextPath}/vendors/anchorjs/anchor.min.js"></script>
        <script src="${pageContext.request.contextPath}/vendors/is/is.min.js"></script>
        <script src="${pageContext.request.contextPath}/vendors/fontawesome/all.min.js"></script>
        <script src="${pageContext.request.contextPath}/vendors/lodash/lodash.min.js"></script>
        <script src="${pageContext.request.contextPath}/vendors/jquery/jquery.min.js"></script>
        <script src="${pageContext.request.contextPath}/vendors/datatables.net/jquery.dataTables.min.js"></script>
        <script src="${pageContext.request.contextPath}/vendors/datatables.net-bs5/dataTables.bootstrap5.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/theme.js"></script>

        <script>
            $(document).ready(function() {
                var tablePending = $('#tablePendingApprovals').DataTable({
                    processing: true,
                    serverSide: true,
                    ajax: {
                        url: '${pageContext.request.contextPath}/api/payments/pending',
                        type: 'POST',
                        contentType: 'application/json',
                        data: function(d) {
                            return JSON.stringify(d);
                        }
                    },
                    columns: [
                        { data: 'id' },
                        { data: 'date' },
                        { data: 'uploaded' },
                        { data: 'service' },
                        { data: 'comment' },
                        { data: 'total' },
                        {
                            data: 'id',
                            orderable: false,
                            render: function(data) {
                                return '<button class="btn btn-primary btn-xs view-details-btn" data-id="' + data + '"><i class="fas fa-eye me-1"></i>View Details</button>';
                            }
                        }
                    ],
                    order: [[0, 'desc']]
                });

                var tableDetails = $('#tableBulkDetails').DataTable({
                    processing: true,
                    serverSide: true,
                    deferLoading: 0,
                    ajax: {
                        url: '${pageContext.request.contextPath}/api/payments/detail',
                        type: 'POST',
                        contentType: 'application/json',
                        data: function(d) {
                            d.data = currentBulkId;
                            return JSON.stringify(d);
                        }
                    },
                    columns: [
                        { data: 'id' },
                        { data: 'payment_id' },
                        { data: 'account_no' },
                        { data: 'amount' },
                        { data: 'narration' },
                        { 
                            data: 'status',
                            render: function(data) {
                                var badgeClass = 'bg-secondary';
                                if (data === 'Success') badgeClass = 'bg-success';
                                else if (data === 'Error') badgeClass = 'bg-danger';
                                else if (data === 'Pending') badgeClass = 'bg-warning';
                                return '<span class="badge ' + badgeClass + '">' + data + '</span>';
                            }
                        },
                        { data: 'pushed' },
                        { data: 'ended' }
                    ]
                });

                var currentBulkId = null;

                $('#tablePendingApprovals').on('click', '.view-details-btn', function() {
                    currentBulkId = $(this).data('id');
                    tableDetails.ajax.reload();
                    $('#detailsModal').modal('show');
                });

                $('#modalApproveBtn').on('click', function() {
                    if (!currentBulkId) return;

                    Swal.fire({
                        title: 'Confirm Approval',
                        text: 'Are you sure you want to approve bulk upload ID: ' + currentBulkId + '? This will process and post payments.',
                        icon: 'warning',
                        showCancelButton: true,
                        confirmButtonColor: '#10b981',
                        cancelButtonColor: '#aaa',
                        confirmButtonText: 'Yes, Approve'
                    }).then((result) => {
                        if (result.isConfirmed) {
                            var btn = $('#modalApproveBtn');
                            btn.prop('disabled', true).text('Approving...');
                            
                            $.post('${pageContext.request.contextPath}/api/payments/approve', { bulkId: currentBulkId })
                                .done(function(response) {
                                    Swal.fire({
                                        title: 'Success!',
                                        text: response.message,
                                        icon: 'success',
                                        confirmButtonColor: '#10b981'
                                    });
                                    $('#detailsModal').modal('hide');
                                    tablePending.ajax.reload();
                                })
                                .fail(function(xhr) {
                                    var errMsg = 'Approval failed!';
                                    if (xhr.responseJSON && xhr.responseJSON.message) {
                                        errMsg = xhr.responseJSON.message;
                                    }
                                    Swal.fire({
                                        title: 'Error!',
                                        text: errMsg,
                                        icon: 'error',
                                        confirmButtonColor: '#ef4444'
                                    });
                                })
                                .always(function() {
                                    btn.prop('disabled', false).html('<i class="fas fa-check me-1"></i>Approve & Post Payments');
                                });
                        }
                    });
                });
            });
        </script>

    </body>
</html>
