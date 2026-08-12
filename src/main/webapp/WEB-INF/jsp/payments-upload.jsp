<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<!DOCTYPE html>
<html lang="en-US" dir="ltr">

    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title>Fintrex | Bulk Payments Upload</title>

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
                            <h4 class="mb-0 text-primary"><i class="fas fa-upload me-2"></i>Bulk Payments Upload</h4>
                        </div>
                    </div>

                    <div class="row g-3">
                        <!-- Upload Form -->
                        <div class="col-lg-3 col-12">
                            <div class="card glass-card">
                                <div class="card-header card-header-gradient p-3">
                                    <h6 class="mb-0 text-white"><i class="fas fa-file-excel me-2"></i>Upload Payments File</h6>
                                </div>
                                <div class="card-body">
                                    <form id="uploadForm" enctype="multipart/form-data">
                                        <div class="mb-3">
                                            <label class="form-label fw-semi-bold text-700" for="serviceSelect">Service Code</label>
                                            <select class="form-select" id="serviceSelect" name="service" required>
                                                <option value="" disabled selected>Select service...</option>
                                                <%
                                                    List<Map<String, Object>> services = (List<Map<String, Object>>) request.getAttribute("services");
                                                    if (services != null) {
                                                        for (Map<String, Object> srv : services) {
                                                            String code = (String) srv.get("code");
                                                            String name = (String) srv.get("name");
                                                %>
                                                <option value="<%= code %>"><%= name %> (<%= code %>)</option>
                                                <%
                                                        }
                                                    }
                                                %>
                                            </select>
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label fw-semi-bold text-700" for="fileInput">Excel File</label>
                                            <input class="form-control" type="file" id="fileInput" name="file" accept=".xlsx" required>
                                            <small class="text-muted d-block mt-1">Excel file columns format: [Request ID, Account No, Amount, Narration]</small>
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label fw-semi-bold text-700" for="commentInput">Comment</label>
                                            <textarea class="form-control" id="commentInput" name="comment" rows="2" placeholder="Describe the upload..."></textarea>
                                        </div>
                                        <button class="btn btn-primary w-100" type="button" id="showInstructionsBtn">
                                            <span class="fas fa-cloud-upload-alt me-1"></span> Upload Payments
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </div>

                        <!-- Upload History Table -->
                        <div class="col-lg-9 col-12">
                            <div class="card glass-card">
                                <div class="card-header p-3 border-bottom">
                                    <h6 class="mb-0 text-primary"><i class="fas fa-history me-2"></i>Upload History</h6>
                                </div>
                                <div class="card-body p-3">
                                    <div class="table-responsive scrollbar">
                                        <table class="table table-hover table-striped align-middle mb-0 fs--1 w-100" id="tableUploadHistory">
                                            <thead class="bg-200 text-900">
                                                <tr>
                                                    <th>ID</th>
                                                    <th>Upload Date</th>
                                                    <th>Uploaded By</th>
                                                    <th>Approver</th>
                                                    <th>Service</th>
                                                    <th>Total</th>
                                                    <th>Success</th>
                                                    <th>Failed</th>
                                                    <th>Status</th>
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
                </div>
            </div>
        </main>

        <!-- Details Modal -->
        <div class="modal fade" id="detailsModal" tabindex="-1" aria-labelledby="detailsModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-xl modal-dialog-centered">
                <div class="modal-content glass-card border-0">
                    <div class="modal-header card-header-gradient text-white p-3">
                        <h5 class="modal-title text-white" id="detailsModalLabel"><i class="fas fa-info-circle me-2"></i>Bulk Upload Detail Records</h5>
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
                    </div>
                </div>
            </div>
        </div>

        <!-- Instructions Modal -->
        <div class="modal fade" id="instructionsModal" tabindex="-1" aria-labelledby="instructionsModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg modal-dialog-centered">
                <div class="modal-content glass-card border-0">
                    <div class="modal-header bg-warning text-white p-3">
                        <h5 class="modal-title text-white" id="instructionsModalLabel"><i class="fas fa-exclamation-triangle me-2"></i>Upload Instructions</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-4">
                        <ul class="text-900 fs--1 lh-lg mb-4">
                            <li>Only Excel (.xlsx) Files can be uploaded.</li>
                            <li>Make sure you choose the correct service.</li>
                            <li>Make sure to use the correct request id to avoid duplicate payments.</li>
                            <li>Please Include the full amounts, Commisions will be reduced from CBS.</li>
                        </ul>
                        
                        <h6 class="text-700 fw-bold mb-2">Below is a sample Template:</h6>
                        <div class="table-responsive scrollbar">
                            <table class="table table-bordered table-striped fs--1 mb-0">
                                <thead class="bg-200 text-900">
                                    <tr>
                                        <th>Payment ID</th>
                                        <th>Account No</th>
                                        <th>Amount</th>
                                        <th>Narration</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td>20264895978</td>
                                        <td>5800125087247</td>
                                        <td>5000</td>
                                        <td>Payment 1</td>
                                    </tr>
                                    <tr>
                                        <td>20256895978</td>
                                        <td>5800125032159</td>
                                        <td>10000</td>
                                        <td>Payment 2</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <div class="modal-footer p-2">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Cancel</button>
                        <button type="button" class="btn btn-primary btn-sm" id="confirmUploadBtn">
                            <i class="fas fa-cloud-upload-alt me-1"></i>Proceed with Upload
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
                var tableHistory = $('#tableUploadHistory').DataTable({
                    processing: true,
                    serverSide: true,
                    ajax: {
                        url: '${pageContext.request.contextPath}/api/payments/history',
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
                        { data: 'approver' },
                        { data: 'service' },
                        { data: 'total' },
                        { data: 'success' },
                        { data: 'failed' },
                        { 
                            data: 'status',
                            render: function(data) {
                                var badgeClass = 'bg-secondary';
                                if (data === 'Complete') badgeClass = 'bg-success';
                                else if (data === 'Pending Approval') badgeClass = 'bg-warning';
                                else if (data === 'Updating') badgeClass = 'bg-info';
                                else if (data === 'Error') badgeClass = 'bg-danger';
                                return '<span class="badge ' + badgeClass + '">' + data + '</span>';
                            }
                        },
                        {
                            data: 'id',
                            orderable: false,
                            render: function(data) {
                                return '<button class="btn btn-primary btn-xs view-details-btn" data-id="' + data + '"><i class="fas fa-eye me-1"></i>View</button>';
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

                $('#tableUploadHistory').on('click', '.view-details-btn', function() {
                    currentBulkId = $(this).data('id');
                    tableDetails.ajax.reload();
                    $('#detailsModal').modal('show');
                });

                $('#showInstructionsBtn').on('click', function() {
                    var form = $('#uploadForm')[0];
                    if (!form.checkValidity()) {
                        form.reportValidity();
                        return;
                    }
                    $('#instructionsModal').modal('show');
                });

                $('#confirmUploadBtn').on('click', function() {
                    $('#instructionsModal').modal('hide');
                    var selectedServiceText = $('#serviceSelect option:selected').text();
                    
                    Swal.fire({
                        title: 'Confirm Upload',
                        text: 'Are you sure you want to upload this Excel sheet for service: ' + selectedServiceText + '?',
                        icon: 'question',
                        showCancelButton: true,
                        confirmButtonColor: '#6366f1',
                        cancelButtonColor: '#aaa',
                        confirmButtonText: 'Yes, Upload'
                    }).then((result) => {
                        if (result.isConfirmed) {
                            submitUploadForm();
                        }
                    });
                });

                function submitUploadForm() {
                    var form = $('#uploadForm')[0];
                    var formData = new FormData(form);
                    $('#showInstructionsBtn').prop('disabled', true).text('Uploading...');

                    $.ajax({
                        url: '${pageContext.request.contextPath}/api/payments/upload',
                        type: 'POST',
                        data: formData,
                        processData: false,
                        contentType: false,
                        success: function(response) {
                            Swal.fire({
                                title: 'Success!',
                                text: response.message,
                                icon: 'success',
                                confirmButtonColor: '#6366f1'
                            });
                            form.reset();
                            tableHistory.ajax.reload();
                        },
                        error: function(xhr) {
                            var errMsg = 'Upload failed!';
                            if (xhr.responseJSON && xhr.responseJSON.message) {
                                errMsg = xhr.responseJSON.message;
                            }
                            Swal.fire({
                                title: 'Error!',
                                text: errMsg,
                                icon: 'error',
                                confirmButtonColor: '#ef4444'
                            });
                        },
                        complete: function() {
                            $('#showInstructionsBtn').prop('disabled', false).html('<span class="fas fa-cloud-upload-alt me-1"></span> Upload Payments');
                        }
                    });
                }
            });
        </script>

    </body>
</html>
