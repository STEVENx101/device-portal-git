<%-- 
    Document   : mf-details
    Created on : Jul 4, 2026, 12:03:43 PM
    Author     : thisara
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en-US" dir="ltr">

    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title>Fintrex | Facility Information</title>

        <link rel="apple-touch-icon" sizes="180x180" href="../assets/img/favicons/apple-touch-icon.png">
        <link rel="icon" type="image/png" sizes="32x32" href="../assets/img/favicons/favicon-32x32.png">
        <link rel="icon" type="image/png" sizes="16x16" href="../assets/img/favicons/favicon-16x16.png">
        <link rel="shortcut icon" type="image/x-icon" href="../assets/img/favicons/favicon.ico">
        <link rel="manifest" href="../assets/img/favicons/manifest.json">
        <meta name="msapplication-TileImage" content="../assets/img/favicons/mstile-150x150.png">
        <meta name="theme-color" content="#ffffff">
        <script src="assets/js/config.js"></script>
        <script src="vendors/simplebar/simplebar.min.js"></script>

        <link rel="preconnect" href="https://fonts.gstatic.com/">
        <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,500,600,700%7cPoppins:300,400,500,600,700,800,900&amp;display=swap" rel="stylesheet">
        <link href="vendors/simplebar/simplebar.min.css" rel="stylesheet">
        <link href="vendors/datatables.net-bs5/dataTables.bootstrap5.min.css" rel="stylesheet">
        <link href="assets/css/theme-rtl.min.css" rel="stylesheet" id="style-rtl">
        <link href="assets/css/theme.min.css" rel="stylesheet" id="style-default">
        <link href="assets/css/user-rtl.min.css" rel="stylesheet" id="user-style-rtl">
        <link href="assets/css/user.min.css" rel="stylesheet" id="user-style-default">
        <script>
            var linkRTL = document.getElementById('style-rtl');
            var userLinkRTL = document.getElementById('user-style-rtl');
            linkRTL.setAttribute('disabled', true);
            userLinkRTL.setAttribute('disabled', true);
        </script>
        <style>
            /* Floating Search Bar on Hover */
            .search-collapsed {
                position: fixed !important;
                top: -120px !important;
                left: 50% !important;
                transform: translateX(-50%) !important;
                width: 50% !important;
                z-index: 1050 !important;
                background: rgba(255, 255, 255, 0.98) !important;
                backdrop-filter: blur(10px) !important;
                padding: 10px 20px !important;
                border-radius: 0 0 15px 15px !important;
                box-shadow: 0 10px 30px rgba(0,0,0,0.15) !important;
                transition: top 0.3s ease-in-out !important;
                border: 1px solid rgba(0,0,0,0.1) !important;
                border-top: none !important;
                margin-top: 0 !important;
                margin-bottom: 0 !important;
            }
            .search-collapsed.hovered {
                top: 0 !important;
            }
            .search-hover-trigger {
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 15px;
                z-index: 1049;
                background: transparent;
                display: none;
            }
            .dark__bg-1000 .search-collapsed {
                background: rgba(21, 26, 35, 0.98) !important;
                border: 1px solid rgba(255,255,255,0.1) !important;
                border-top: none !important;
            }
            .search-box .search-input {
                padding-left: 2.5rem !important;
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

                <nav class="navbar navbar-light navbar-glass navbar-top navbar-expand-lg" style="display: none;">
                    <button class="btn navbar-toggler-humburger-icon navbar-toggler me-1 me-sm-3" type="button" data-bs-toggle="collapse" data-bs-target="#navbarStandard" aria-controls="navbarStandard" aria-expanded="false" aria-label="Toggle Navigation"><span class="navbar-toggle-icon"><span class="toggle-line"></span></span></button>
                    <a class="navbar-brand me-1 me-sm-3" href="../index.html">
                        <div class="d-flex align-items-center"><img class="me-2" src="../assets/img/icons/spot-illustrations/falcon.png" alt="" width="40" /><span class="font-sans-serif">falcon</span></div>
                    </a>                    
                </nav>

                <div class="content">
                    <%@include file="../jspf/topbar.jspf" %>

                    <script>
                        var navbarPosition = localStorage.getItem('navbarPosition');
                        var navbarVertical = document.querySelector('.navbar-vertical');
                        var navbarTopVertical = document.querySelector('.content .navbar-top');
                        var navbarTop = document.querySelector('[data-layout] .navbar-top:not([data-double-top-nav');

                        navbarVertical.removeAttribute('style');
                        navbarTopVertical.removeAttribute('style');
                        navbarTop.remove(navbarTop);
                    </script>

                    <div class="search-hover-trigger" id="searchHoverTrigger"></div>
                    
                    <div id="searchContainer" class="d-flex flex-column align-items-center mt-2 mb-2">
                        <div class="search-box w-50" data-list='{"valueNames":["title"]}'>
                            <form class="position-relative w-100" data-bs-toggle="search" data-bs-display="static"><input class="form-control search-input fuzzy-search" type="search" placeholder="Search by Finance No, Name, or NIC..." aria-label="Search" />
                                <span class="fas fa-search search-box-icon"></span>
                            </form>
                            <div class="btn-close-falcon-container position-absolute end-0 top-50 translate-middle shadow-none" data-bs-dismiss="search"><button class="btn btn-link btn-close-falcon p-0" aria-label="Close"></button></div>
                            <div class="dropdown-menu border font-base start-0 mt-2 py-0 overflow-hidden w-100">
                                <div class="scrollbar list py-3" style="max-height: 24rem;">
                                    <h6 class="dropdown-header fw-medium text-uppercase px-x1 fs--2 pt-0 pb-2">Recently Searched</h6>
                                    <hr class="text-200 dark__text-900" />
                                </div>
                                <div class="text-center mt-n3">
                                    <p class="fallback fw-bold fs-1 d-none">No Result Found.</p>
                                </div>
                            </div>
                        </div>
                        <div class="text-500 fs--2 mt-2" id="searchHelpText">
                            <span class="fas fa-info-circle me-1"></span>Search by <strong>Finance No</strong>, <strong>Customer Name</strong>, or <strong>NIC</strong>
                        </div>
                    </div>

                    <div class="card" id="detailsCard" style="display: none;">
                        <div class="card-header bg-light">
                            <h5 class="mb-0 text-primary"><span class="fas fa-info-circle me-2"></span>Contract Information Overview</h5>
                        </div>
                        <div class="card-body">
                            <div class="row g-3">
                                <div class="col-6 col-sm-4 col-md-3 col-lg-2 text-center">
                                    <div class="text-500 fs--2 font-sans-serif fw-semi-bold">ACCOUNT NO</div>
                                    <div class="fs--1 fw-bold val-account-no">-</div>
                                </div>
                                <div class="col-6 col-sm-4 col-md-3 col-lg-2 text-center">
                                    <div class="text-500 fs--2 font-sans-serif fw-semi-bold">ACCOUNT STATUS</div>
                                    <div class="fs--1 fw-bold val-account-status">-</div>
                                </div>
                                <div class="col-6 col-sm-4 col-md-3 col-lg-2 text-center">
                                    <div class="text-500 fs--2 font-sans-serif fw-semi-bold">TOTAL OUTSTANDING</div>
                                    <div class="fs--1 fw-bold val-outstanding">-</div>
                                </div>
                                <div class="col-6 col-sm-4 col-md-3 col-lg-2 text-center">
                                    <div class="text-500 fs--2 font-sans-serif fw-semi-bold">PORTFOLIO EXPOSURE</div>
                                    <div class="fs--1 fw-bold val-exposure">-</div>
                                </div>
                                <div class="col-6 col-sm-4 col-md-3 col-lg-2 text-center">
                                    <div class="text-500 fs--2 font-sans-serif fw-semi-bold">PERFORMING STATUS</div>
                                    <div class="fs--1 fw-bold val-performing-status">-</div>
                                </div>
                                <div class="col-6 col-sm-4 col-md-3 col-lg-2 text-center">
                                    <div class="text-500 fs--2 font-sans-serif fw-semi-bold">DPD</div>
                                    <div class="fs--1 fw-bold val-arr-days">-</div>
                                </div>
                                <div class="col-6 col-sm-4 col-md-3 col-lg-2 text-center">
                                    <div class="text-500 fs--2 font-sans-serif fw-semi-bold">SECURITY / MODEL</div>
                                    <div class="fs--1 fw-bold"><span class="val-security">-</span> / <span class="val-model">-</span></div>
                                </div>
                                <div class="col-6 col-sm-4 col-md-3 col-lg-2 row-lock-status text-center">
                                    <div class="text-500 fs--2 font-sans-serif fw-semi-bold">LOCK STATUS</div>
                                    <div class="fs--1 fw-bold val-lock-status">-</div>
                                </div>
                                <div class="col-6 col-sm-4 col-md-3 col-lg-2 row-next-lock-date text-center">
                                    <div class="text-500 fs--2 font-sans-serif fw-semi-bold">NEXT LOCK DATE</div>
                                    <div class="fs--1 fw-bold val-next-lock-date">-</div>
                                </div>
                                <div class="col-6 col-sm-4 col-md-3 col-lg-2 row-device-status text-center" style="display: none;">
                                    <div class="text-500 fs--2 font-sans-serif fw-semi-bold">CURRENT DEVICE STATUS</div>
                                    <div class="fs--1 fw-bold val-device-status">-</div>
                                </div>
                                <div class="col-6 col-sm-4 col-md-3 col-lg-2 text-center">
                                    <div class="text-500 fs--2 font-sans-serif fw-semi-bold">FACILITY GRANT DATE</div>
                                    <div class="fs--1 fw-bold val-facility-grant-date">-</div>
                                </div>
                                <div class="col-6 col-sm-4 col-md-3 col-lg-2 text-center">
                                    <div class="text-500 fs--2 font-sans-serif fw-semi-bold">MATURITY DATE</div>
                                    <div class="fs--1 fw-bold val-maturity-date">-</div>
                                </div>
                                <div class="col-6 col-sm-4 col-md-3 col-lg-2 text-center">
                                    <div class="text-500 fs--2 font-sans-serif fw-semi-bold">DUE DATE</div>
                                    <div class="fs--1 fw-bold val-due-date">-</div>
                                </div>
                                <div class="col-6 col-sm-4 col-md-3 col-lg-2 text-center">
                                    <div class="text-500 fs--2 font-sans-serif fw-semi-bold">RENTAL</div>
                                    <div class="fs--1 fw-bold val-rental">-</div>
                                </div>
                                <div class="col-6 col-sm-4 col-md-3 col-lg-2 text-center">
                                    <div class="text-500 fs--2 font-sans-serif fw-semi-bold">TENOR</div>
                                    <div class="fs--1 fw-bold val-period">-</div>
                                </div>
                                <div class="col-6 col-sm-4 col-md-3 col-lg-2 text-center">
                                    <div class="text-500 fs--2 font-sans-serif fw-semi-bold">LOAN AMOUNT</div>
                                    <div class="fs--1 fw-bold val-finance-amount">-</div>
                                </div>
                                <div class="col-6 col-sm-4 col-md-3 col-lg-2 text-center">
                                    <div class="text-500 fs--2 font-sans-serif fw-semi-bold">IMEI NO</div>
                                    <div class="fs--1 fw-bold val-imei-no">-</div>
                                </div>
                                <div class="col-6 col-sm-4 col-md-3 col-lg-2 text-center">
                                    <div class="text-500 fs--2 font-sans-serif fw-semi-bold">WORKHUB SP NO</div>
                                    <div class="fs--1 fw-bold val-workhub-sp-no">-</div>
                                </div>
                                <div class="col-6 col-sm-4 col-md-3 col-lg-2 text-center">
                                    <div class="text-500 fs--2 font-sans-serif fw-semi-bold">VENDOR NAME</div>
                                    <div class="fs--1 fw-bold val-vendor-name">-</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="card glass-card mt-3" id="tabsCard" style="display: none;">
                        <div class="card-header p-0 border-bottom border-200">
                            <ul class="nav nav-tabs border-0" id="detail-tabs-list" role="tablist">
                                <li class="nav-item">
                                    <a class="nav-link active" id="tab-cust" data-bs-toggle="tab" href="#cust-pane" role="tab" aria-controls="cust-pane" aria-selected="true">
                                        <span class="fas fa-user me-2"></span>Customer Details
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link" id="tab-guarantor" data-bs-toggle="tab" href="#guar-pane" role="tab" aria-controls="guar-pane" aria-selected="false">
                                        <span class="fas fa-users me-2"></span>Guarantor Details
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link" id="tab-statement" data-bs-toggle="tab" href="#stat-pane" role="tab" aria-controls="stat-pane" aria-selected="false">
                                        <span class="fas fa-file-invoice-dollar"></span>Account Statement
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link" id="tab-payments" data-bs-toggle="tab" href="#pay-pane" role="tab" aria-controls="pay-pane" aria-selected="false">
                                        <span class="fas fa-receipt me-2"></span>Payments
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link" id="tab-sms" data-bs-toggle="tab" href="#sms-pane" role="tab" aria-controls="sms-pane" aria-selected="false">
                                        <span class="fas fa-sms me-2"></span>SMS Logs
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link" id="tab-locks" data-bs-toggle="tab" href="#locks-pane" role="tab" aria-controls="locks-pane" aria-selected="false">
                                        <span class="fas fa-lock me-2"></span>Lock/Unlock Logs
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link" id="tab-remarks" data-bs-toggle="tab" href="#remarks-pane" role="tab" aria-controls="remarks-pane" aria-selected="false">
                                        <span class="fas fa-comment me-2"></span>Remarks
                                    </a>
                                </li>
                            </ul>
                        </div>
                        <div class="card-body p-3">
                            <div class="tab-content" id="detail-tabs-content">
                                <!-- Customer details pane -->
                                <div class="tab-pane fade show active" id="cust-pane" role="tabpanel" aria-labelledby="tab-cust">
                                    <div class="table-responsive">
                                        <table class="table table-striped table-hover mb-0 fs--1">
                                            <tbody>
                                                <tr>
                                                    <td class="bg-100 fw-bold" style="width: 20%;">NIC:</td>
                                                    <td class="text-600"><span id="val-cust-nic">-</span></td>
                                                </tr>
                                                <tr>
                                                    <td class="bg-100 fw-bold" style="width: 20%;">Name:</td>
                                                    <td class="text-600"><span id="val-cust-name">-</span></td>
                                                </tr>
                                                <tr>
                                                    <td class="bg-100 fw-bold" style="width: 20%;">Address:</td>
                                                    <td class="text-600"><span id="val-cust-address">-</span></td>
                                                </tr>
                                                <tr>
                                                    <td class="bg-100 fw-bold" style="width: 20%;">Mobile No:</td>
                                                    <td><a class="text-600 text-decoration-none fw-bold" id="val-cust-mobile-link" href="#"><span id="val-cust-mobile">-</span></a></td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                                <!-- Guarantor details pane -->
                                <div class="tab-pane fade" id="guar-pane" role="tabpanel" aria-labelledby="tab-guarantor">
                                    <div id="guarantors-wrapper">
                                        <!-- Dynamically filled -->
                                    </div>
                                </div>
                                <!-- Account Statement pane -->
                                <div class="tab-pane fade" id="stat-pane" role="tabpanel" aria-labelledby="tab-statement">
                                    <p class="text-muted fs--1">No statement details registered for this account.</p>
                                </div>
                                <!-- Payments pane -->
                                <div class="tab-pane fade" id="pay-pane" role="tabpanel" aria-labelledby="tab-payments">
                                    <div class="table-responsive">
                                        <table id="receipt_table" class="table table-hover table-striped mb-0 fs--1 w-100">
                                            <thead>
                                                <tr>
                                                    <th>Receipt No</th>
                                                    <th>Receipt Date</th>
                                                    <th>Receipt Mode</th>
                                                    <th>Narration</th>
                                                    <th>Amount</th>
                                                </tr>
                                            </thead>
                                            <tbody></tbody>
                                        </table>
                                    </div>
                                </div>
                                <!-- SMS pane -->
                                <div class="tab-pane fade" id="sms-pane" role="tabpanel" aria-labelledby="tab-sms">
                                    <div class="table-responsive">
                                        <table id="sms_table" class="table table-hover table-striped mb-0 fs--1 w-100">
                                            <thead>
                                                <tr>
                                                    <th>Sent Date</th>
                                                    <th>Mobile No</th>
                                                    <th>Message</th>
                                                    <th>Status</th>
                                                </tr>
                                            </thead>
                                            <tbody></tbody>
                                        </table>
                                    </div>
                                </div>
                                <!-- Lock/Unlock logs pane -->
                                <div class="tab-pane fade" id="locks-pane" role="tabpanel" aria-labelledby="tab-locks">
                                    <div class="table-responsive" id="standard_locks_wrapper" style="max-height: 350px; overflow-y: auto;">
                                        <table id="locks_table" class="table table-hover table-striped mb-0 fs--1 w-100">
                                            <thead>
                                                <tr>
                                                    <th>Date & Time</th>
                                                    <th>Status</th>
                                                    <th>Changed By</th>
                                                    <th>Reason</th>
                                                </tr>
                                            </thead>
                                            <tbody></tbody>
                                        </table>
                                    </div>
                                    <div class="table-responsive" id="datacultr_locks_wrapper" style="display: none; max-height: 350px; overflow-y: auto;">
                                        <table id="datacultr_locks_table" class="table table-hover table-striped mb-0 fs--1 w-100">
                                            <thead>
                                                <tr>
                                                    <th>Action</th>
                                                    <th>Message</th>
                                                    <th>Status</th>
                                                    <th>Triggered Timestamp</th>
                                                    <th>Applied Timestamp</th>
                                                    <th>Code</th>
                                                </tr>
                                            </thead>
                                            <tbody></tbody>
                                        </table>
                                    </div>
                                </div>
                                <!-- Remarks pane -->
                                <div class="tab-pane fade" id="remarks-pane" role="tabpanel" aria-labelledby="tab-remarks">
                                    <div class="mb-3">
                                        <form id="remark-form">
                                            <div class="input-group">
                                                <input type="text" id="remark-input" class="form-control" placeholder="Enter remark here..." required />
                                                <button class="btn btn-primary" type="submit">
                                                    <span class="fas fa-paper-plane me-1"></span>Submit
                                                </button>
                                            </div>
                                        </form>
                                    </div>
                                    <div class="table-responsive">
                                        <table id="remarks_table" class="table table-hover table-striped mb-0 fs--1 w-100">
                                            <thead>
                                                <tr>
                                                    <th>Remark</th>
                                                    <th>By</th>
                                                    <th>When</th>
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

        <div id="detailsLoader" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(255,255,255,0.7); z-index: 9999; justify-content: center; align-items: center; flex-direction: column;">
            <div class="spinner-border text-primary" role="status" style="width: 3rem; height: 3rem;"></div>
            <span class="mt-2 fw-semi-bold">Loading contract details...</span>
        </div>


        <script src="vendors/jquery/jquery.min.js"></script>
        <script src="vendors/datatables.net/jquery.dataTables.min.js"></script>
        <script src="vendors/datatables.net-bs5/dataTables.bootstrap5.min.js"></script>
        <script src="vendors/popper/popper.min.js"></script>
        <script src="vendors/bootstrap/bootstrap.min.js"></script>
        <script src="vendors/anchorjs/anchor.min.js"></script>
        <script src="vendors/is/is.min.js"></script>
        <script src="vendors/fontawesome/all.min.js"></script>
        <script src="vendors/lodash/lodash.min.js"></script>
        <script src="../../../../polyfill.io/v3/polyfill.min58be.js?features=window.scroll"></script>
        <script src="vendors/list.js/list.min.js"></script>
        <script src="assets/js/theme.js"></script>

        <script>
                        let contextPath = '${pageContext.request.contextPath}';
                        if (!contextPath && window.location.pathname.includes('/device-portal')) {
                            contextPath = '/device-portal';
                        }
                        let currentFinanceNo = '';
                        $(document).ready(function () {
                            // Hover actions for floating search bar
                            $('#searchHoverTrigger, #searchContainer').on('mouseenter', function() {
                                if ($('#searchContainer').hasClass('search-collapsed')) {
                                    $('#searchContainer').addClass('hovered');
                                }
                            });
                            $('#searchContainer').on('mouseleave', function() {
                                if ($('#searchContainer').hasClass('search-collapsed')) {
                                    $('#searchContainer').removeClass('hovered');
                                }
                            });

                            ReceiptTable('');
                            SmsTable('');
                            LocksTable('');
                            RemarksTable('');

                            const remarkForm = document.getElementById('remark-form');
                            if (remarkForm) {
                                remarkForm.addEventListener('submit', function (e) {
                                    e.preventDefault();
                                    const input = document.getElementById('remark-input');
                                    const remark = input.value.trim();
                                    if (!remark || !currentFinanceNo) return;

                                    const params = new URLSearchParams();
                                    params.append('financeNo', currentFinanceNo);
                                    params.append('remark', remark);

                                    fetch(contextPath + '/api/contracts/remarks', {
                                        method: 'POST',
                                        headers: {
                                            'Content-Type': 'application/x-www-form-urlencoded'
                                        },
                                        body: params
                                    })
                                    .then(response => response.json())
                                    .then(res => {
                                        if (res.status === 'success') {
                                            input.value = '';
                                            RemarksTable(currentFinanceNo);
                                        } else {
                                            alert('Failed to add remark.');
                                        }
                                    })
                                    .catch(err => {
                                        console.error('Error adding remark:', err);
                                        alert('Error adding remark.');
                                    });
                                });
                            }
                        });


                        function ReceiptTable(financeNo) {

                            const tableId = '#receipt_table';

                            if ($.fn.DataTable.isDataTable(tableId)) {
                                $(tableId).DataTable().destroy();
                            }
                            
                            

                            $(tableId).DataTable({
                                paging: false,
                                lengthChange: false,
                                info: true,
                                searching: false,
                                ordering: false,
                                autoWidth: false,
                                processing: true,
                                serverSide: true,

                                ajax: {
                                    url: contextPath + '/api/contracts/fetchreceiptdata',
                                    type: 'POST',
                                    contentType: 'application/json',

                                    data: function (d) {
                                        d.data = financeNo || '';
                                        return JSON.stringify(d);
                                    },

                                    dataSrc: function (json) {
                                        return json.data || [];
                                    },

                                    error: function (xhr, error, code) {
                                        console.error("Failed to load receipt data", xhr, error, code);
                                    }
                                },

                                columns: [
                                    {
                                        data: "receipt_no",
                                        defaultContent: "-"
                                    },
                                    {
                                        data: "receipt_date",
                                        defaultContent: "-",
                                        render: function (data) {
                                            if (data) {
                                                return data.split(' ')[0].split('T')[0];
                                            }
                                            return "-";
                                        }
                                    },
                                    {
                                        data: "receipt_mode",
                                        defaultContent: "-"
                                    },
                                    {
                                        data: "narration",
                                        defaultContent: "-"
                                    },
                                    {
                                        data: "amount",
                                        defaultContent: "0.00",
                                        render: function (data) {
                                            if (data === null || data === undefined || data === "") {
                                                return "0.00";
                                            }

                                            return Number(data).toLocaleString('en-LK', {
                                                minimumFractionDigits: 2,
                                                maximumFractionDigits: 2
                                            });
                                        }
                                    }
                                ],

                                language: {
                                    processing: 'Loading...',
                                    emptyTable: "No receipt data available."
                                }
                            });
                        }


                        function SmsTable(financeNo) {

                            const tableId = '#sms_table';

                            if ($.fn.DataTable.isDataTable(tableId)) {
                                $(tableId).DataTable().destroy();
                            }

                            $(tableId).DataTable({
                                paging: false,
                                lengthChange: false,
                                info: true,
                                searching: false,
                                ordering: false,
                                autoWidth: false,
                                processing: true,
                                serverSide: true,

                                ajax: {
                                    url: contextPath + '/api/contracts/fetchsmsdata',
                                    type: 'POST',
                                    contentType: 'application/json',

                                    data: function (d) {
                                        d.data = financeNo || '';
                                        return JSON.stringify(d);
                                    },

                                    dataSrc: function (json) {
                                        return json.data || [];
                                    },

                                    error: function (xhr, error, code) {
                                        console.error("Failed to load SMS data", xhr, error, code);
                                    }
                                },

                                columns: [
                                    {
                                        data: "date",
                                        defaultContent: "-",
                                        render: function (data) {
                                            if (data) {
                                                return data.split(' ')[0].split('T')[0];
                                            }
                                            return "-";
                                        }
                                    },
                                    {
                                        data: "mobile",
                                        defaultContent: "-"
                                    },
                                     {
                                         data: "msg",
                                         defaultContent: "-",
                                         render: function (data) {
                                             if (!data || data === '-') return '-';
                                             if (data.length <= 65) {
                                                 return data;
                                             }
                                             const truncated = data.substring(0, 65);
                                             const escapedMsg = data.replace(/\\/g, "\\\\").replace(/'/g, "\\'").replace(/"/g, '&quot;').replace(/\n/g, '\\n').replace(/\r/g, '\\r');
                                             return '<span>' + truncated + '... </span>' +
                                                    '<a href="#" class="btn btn-link p-0 fs--2 fw-semi-bold" onclick="' +
                                                    'document.getElementById(\'smsModalContent\').innerText = \'' + escapedMsg + '\'; ' +
                                                    'const modal = new bootstrap.Modal(document.getElementById(\'smsModal\')); ' +
                                                    'modal.show(); return false;">Read More</a>';
                                         }
                                     },
                                    {
                                        data: "status",
                                        defaultContent: "-"
                                    }
                                ],

                                language: {
                                    processing: 'Loading...',
                                    emptyTable: "No SMS data available."
                                }
                            });
                        }


                        function LocksTable(financeNo, security, imei) {
                            const isDatacultr = security && (security.toUpperCase() === 'DATACULTR' || security.toUpperCase() === 'DATACULTE');
                            
                            if (isDatacultr) {
                                $('#standard_locks_wrapper').hide();
                                $('#datacultr_locks_wrapper').show();
                                
                                const tableId = '#datacultr_locks_table';
                                if ($.fn.DataTable.isDataTable(tableId)) {
                                    $(tableId).DataTable().destroy();
                                }
                                
                                 $(tableId).DataTable({
                                    paging: false,
                                    lengthChange: false,
                                    info: true,
                                    searching: false,
                                    ordering: false,
                                    autoWidth: false,
                                    processing: true,
                                    serverSide: false,
                                    ajax: {
                                        url: contextPath + '/api/contracts/datacultr-logs?imei=' + encodeURIComponent(imei || ''),
                                        type: 'GET',
                                        dataSrc: function (json) {
                                            return json.activity || [];
                                        },
                                        error: function (xhr, error, code) {
                                            console.error("Failed to load Datacultr lock logs", xhr, error, code);
                                        }
                                    },
                                    columns: [
                                        { data: "action", defaultContent: "-" },
                                        { data: "notification", defaultContent: "-" },
                                        { data: "status", defaultContent: "-" },
                                        { 
                                            data: "trigger_time", 
                                            defaultContent: "-",
                                            render: function(d) {
                                                if (!d || d === '-') return '-';
                                                try {
                                                    let parts = d.split('T');
                                                    let dateParts = parts[0].split('-');
                                                    let timePart = (parts[1] || '').split('.')[0];
                                                    return dateParts[2] + '-' + dateParts[1] + '-' + dateParts[0] + ' ' + timePart;
                                                } catch(e) { return d; }
                                            }
                                        },
                                        { 
                                            data: "applied_time", 
                                            defaultContent: "-",
                                            render: function(d) {
                                                if (!d || d === '-') return '-';
                                                try {
                                                    let parts = d.split('T');
                                                    let dateParts = parts[0].split('-');
                                                    let timePart = (parts[1] || '').split('.')[0];
                                                    return dateParts[2] + '-' + dateParts[1] + '-' + dateParts[0] + ' ' + timePart;
                                                } catch(e) { return d; }
                                            }
                                        },
                                        { data: "code", defaultContent: "-" }
                                    ],
                                    language: {
                                        processing: 'Loading...',
                                        emptyTable: "No lock logs available."
                                    }
                                });
                            } else {
                                $('#datacultr_locks_wrapper').hide();
                                $('#standard_locks_wrapper').show();
                                
                                const tableId = '#locks_table';
                                if ($.fn.DataTable.isDataTable(tableId)) {
                                    $(tableId).DataTable().destroy();
                                }
                                $(tableId).DataTable({
                                    paging: false,
                                    lengthChange: false,
                                    info: true,
                                    searching: false,
                                    ordering: false,
                                    autoWidth: false,
                                    processing: true,
                                    serverSide: true,
                                    ajax: {
                                        url: contextPath + '/api/contracts/fetchlockdata',
                                        type: 'POST',
                                        contentType: 'application/json',
                                        data: function (d) {
                                            d.data = financeNo || '';
                                            return JSON.stringify(d);
                                        },
                                        dataSrc: function (json) {
                                            return json.data || [];
                                        },
                                        error: function (xhr, error, code) {
                                            console.error("Failed to load lock logs", xhr, error, code);
                                        }
                                    },
                                    columns: [
                                        { data: "date", defaultContent: "-" },
                                        { 
                                            data: "status", 
                                            defaultContent: "-",
                                            render: function (data) {
                                                if (data === "LOCKED") {
                                                    return '<span class="badge badge-soft-danger">LOCKED</span>';
                                                } else if (data === "UNLOCKED") {
                                                    return '<span class="badge badge-soft-success">UNLOCKED</span>';
                                                }
                                                return data;
                                            }
                                        },
                                        { data: "changed_by", defaultContent: "-" },
                                        { data: "reason", defaultContent: "-" }
                                    ],
                                    language: {
                                        processing: 'Loading...',
                                        emptyTable: "No lock logs available."
                                    }
                                });
                            }
                        }

                        function RemarksTable(financeNo) {
                            const tableBody = document.querySelector('#remarks_table tbody');
                            if (!tableBody) return;

                            if (!financeNo) {
                                tableBody.innerHTML = '<tr><td colspan="3" class="text-center text-muted">No remarks registered.</td></tr>';
                                return;
                            }

                            tableBody.innerHTML = '<tr><td colspan="3" class="text-center"><div class="spinner-border text-primary spinner-border-sm" role="status"></div> Loading remarks...</td></tr>';

                            fetch(contextPath + '/api/contracts/remarks?financeNo=' + encodeURIComponent(financeNo))
                                .then(response => response.json())
                                .then(data => {
                                    if (!data || data.length === 0) {
                                        tableBody.innerHTML = '<tr><td colspan="3" class="text-center text-muted">No remarks registered.</td></tr>';
                                    } else {
                                        let html = '';
                                        data.forEach(item => {
                                            html += '<tr>' +
                                                    '<td>' + (item.remark || '-') + '</td>' +
                                                    '<td>' + (item.created_by || '-') + '</td>' +
                                                    '<td>' + (item.created_date || '-') + '</td>' +
                                                    '</tr>';
                                        });
                                        tableBody.innerHTML = html;
                                    }
                                })
                                .catch(error => {
                                    console.error('Error loading remarks:', error);
                                    tableBody.innerHTML = '<tr><td colspan="3" class="text-center text-danger">Failed to load remarks.</td></tr>';
                                });
                        }


                        document.addEventListener('DOMContentLoaded', function () {
                            const searchInput = document.querySelector('.search-box .search-input');
                            const suggestionsDropdown = document.querySelector('.search-box .dropdown-menu');
                            const listContainer = suggestionsDropdown ? suggestionsDropdown.querySelector('.list') : null;
                            const detailsCard = document.getElementById('detailsCard');
                            const tabsCard = document.getElementById('tabsCard');

                            const urlParams = new URLSearchParams(window.location.search);
                            const urlQuery = urlParams.get('query');
                            if (urlQuery && urlQuery.trim().length > 0 && searchInput) {
                                searchInput.value = urlQuery.trim();
                                fetchDetails(urlQuery.trim());
                            }


                            let debounceTimeout = null;

                            if (searchInput && suggestionsDropdown && listContainer) {
                                searchInput.addEventListener('input', function (e) {
                                    clearTimeout(debounceTimeout);
                                    const query = searchInput.value.trim();


                                    const fallbackEl = suggestionsDropdown.querySelector('.fallback');
                                    if (fallbackEl) {
                                        fallbackEl.style.setProperty('display', 'none', 'important');
                                    }

                                    if (query.length < 2) {
                                        suggestionsDropdown.classList.remove('show');
                                        return;
                                    }

                                    listContainer.innerHTML = '<div class="d-flex justify-content-center align-items-center py-4"><div class="spinner-border text-primary spinner-border-sm me-2" role="status"></div><span class="text-muted fs--1">Searching...</span></div>';
                                    suggestionsDropdown.classList.add('show');

                                    debounceTimeout = setTimeout(() => {
                                        fetch(contextPath + '/api/contracts/search?query=' + encodeURIComponent(query))
                                                .then(response => response.json())
                                                .then(data => {
                                                    listContainer.innerHTML = '';
                                                    if (data && data.length > 0) {

                                                        if (fallbackEl) {
                                                            fallbackEl.style.setProperty('display', 'none', 'important');
                                                        }
                                                        data.forEach(item => {
                                                            const btn = document.createElement('button');
                                                            btn.type = 'button';
                                                            btn.className = 'dropdown-item text-start py-2 border-0 bg-transparent w-100';
                                                            btn.innerHTML =
                                                                    '<div class="fw-bold text-primary text-truncate">' + item.financeNo + '</div>' +
                                                                    '<div class="fs--1 text-600 text-truncate">' + item.fullName + ' | NIC: ' + item.nicNo + '</div>';
                                                            btn.addEventListener('click', function (evt) {
                                                                evt.preventDefault();
                                                                evt.stopPropagation();
                                                                searchInput.value = item.financeNo;
                                                                suggestionsDropdown.classList.remove('show');
                                                                fetchDetails(item.financeNo);
                                                            });
                                                            listContainer.appendChild(btn);
                                                        });
                                                        suggestionsDropdown.classList.add('show');
                                                    } else {
                                                        listContainer.innerHTML = '<div class="dropdown-item text-muted py-2">No matching contracts found</div>';
                                                        suggestionsDropdown.classList.add('show');
                                                    }
                                                })
                                                .catch(error => {
                                                    console.error('Error fetching search results:', error);
                                                });
                                    }, 300);
                                });

                                searchInput.addEventListener('paste', function (e) {
                                    setTimeout(() => {
                                        const query = searchInput.value.trim();
                                        if (query.length >= 2) {
                                            listContainer.innerHTML = '<div class="d-flex justify-content-center align-items-center py-4"><div class="spinner-border text-primary spinner-border-sm me-2" role="status"></div><span class="text-muted fs--1">Searching...</span></div>';
                                            suggestionsDropdown.classList.add('show');
                                        }
                                    }, 0);
                                });

                                const searchForm = document.querySelector('.search-box form');
                                if (searchForm) {
                                    searchForm.addEventListener('submit', function (e) {
                                        e.preventDefault();
                                        const query = searchInput.value.trim();
                                        if (query.length >= 2) {
                                            suggestionsDropdown.classList.remove('show');
                                            fetchDetails(query);
                                        }
                                    });
                                }

                                document.addEventListener('click', function (e) {
                                    if (e.target !== searchInput && !suggestionsDropdown.contains(e.target)) {
                                        suggestionsDropdown.classList.remove('show');
                                    }
                                });
                            }

                            function fetchDetails(financeNo) {
                                const loader = document.getElementById('detailsLoader');
                                if (loader) loader.style.display = 'flex';

                                fetch(contextPath + '/api/contracts/details?financeNo=' + encodeURIComponent(financeNo))
                                        .then(response => {
                                            if (!response.ok) {
                                                throw new Error('Contract not found');
                                            }
                                            return response.json();
                                        })
                                        .then(data => {
                                            document.querySelectorAll('.val-account-no').forEach(el => el.textContent = data.financeNo || '-');
                                            document.querySelectorAll('.val-account-status').forEach(el => el.textContent = data.contractStatus || '-');
                                            document.querySelectorAll('.val-outstanding').forEach(el => el.textContent = data.amtToCollected !== null ? parseFloat(data.amtToCollected).toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2}) : '0.00');
                                            document.querySelectorAll('.val-exposure').forEach(el => el.textContent = data.exposure !== null ? parseFloat(data.exposure).toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2}) : '0.00');
                                            document.querySelectorAll('.val-performing-status').forEach(el => el.textContent = data.performingStatus || '-');
                                            document.querySelectorAll('.val-security').forEach(el => el.textContent = data.security || '-');
                                            document.querySelectorAll('.val-model').forEach(el => el.textContent = data.model || '-');
                                            currentFinanceNo = data.financeNo || '';
                                            document.querySelectorAll('.val-imei-no').forEach(el => el.textContent = data.imeiNo || '-');
                                            document.querySelectorAll('.val-workhub-sp-no').forEach(el => el.textContent = data.workhubSpNo || '-');
                                            document.querySelectorAll('.val-vendor-name').forEach(el => el.textContent = data.vendorName || '-');

                                            document.querySelectorAll('.val-facility-grant-date').forEach(el => el.textContent = data.facilityGrantDate || '-');
                                            document.querySelectorAll('.val-maturity-date').forEach(el => el.textContent = data.maturityDate || '-');
                                            document.querySelectorAll('.val-due-date').forEach(el => el.textContent = data.dueDate || '-');
                                            document.querySelectorAll('.val-rental').forEach(el => el.textContent = data.rental !== null ? parseFloat(data.rental).toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2}) : '0.00');
                                            document.querySelectorAll('.val-period').forEach(el => el.textContent = data.period !== null ? data.period : '-');
                                            document.querySelectorAll('.val-finance-amount').forEach(el => el.textContent = data.financeAmount !== null ? parseFloat(data.financeAmount).toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2}) : '0.00');
                                            document.querySelectorAll('.val-arr-days').forEach(el => el.textContent = data.arrDays !== null ? data.arrDays : '0');
                                            const rowNextLock = document.querySelector('.row-next-lock-date');
                                            const rowLockStatus = document.querySelector('.row-lock-status');
                                            const rowDeviceStatus = document.querySelector('.row-device-status');

                                            if (data.product === 'LF') {
                                                if (rowNextLock)
                                                    rowNextLock.style.display = 'none';
                                                if (rowLockStatus)
                                                    rowLockStatus.style.display = 'none';
                                                if (rowDeviceStatus) {
                                                    rowDeviceStatus.style.display = '';
                                                    rowDeviceStatus.querySelector('.val-device-status').textContent = data.currentDeviceStatus || '-';
                                                }
                                            } else {
                                                if (rowNextLock)
                                                    rowNextLock.style.display = '';
                                                if (rowLockStatus)
                                                    rowLockStatus.style.display = '';
                                                if (rowDeviceStatus)
                                                    rowDeviceStatus.style.display = 'none';

                                                document.querySelectorAll('.val-next-lock-date').forEach(el => el.textContent = data.nextLockDate || '-');
                                                document.querySelectorAll('.val-lock-status').forEach(el => {
                                                    if (data.locked === 1) {
                                                        el.innerHTML = '<span class="badge badge-soft-danger">LOCKED</span>';
                                                    } else if (data.locked === 0) {
                                                        el.innerHTML = '<span class="badge badge-soft-success">Unlocked</span>';
                                                    } else {
                                                        el.textContent = '-';
                                                    }
                                                });
                                            }


                                            document.getElementById('val-cust-nic').textContent = data.nicNo || '-';
                                            document.getElementById('val-cust-name').textContent = data.fullName || '-';
                                            document.getElementById('val-cust-address').textContent = data.address || '-';
                                            if (data.mobileNo) {
                                                document.getElementById('val-cust-mobile').textContent = data.mobileNo;
                                                document.getElementById('val-cust-mobile-link').href = 'tel:' + data.mobileNo;
                                            } else {
                                                document.getElementById('val-cust-mobile').textContent = '-';
                                                document.getElementById('val-cust-mobile-link').removeAttribute('href');
                                            }


                                            const guarantorsWrapper = document.getElementById('guarantors-wrapper');
                                            let guarantorsHtml = '';
                                            function getGuarantorHtml(title, name, address, contact, nic) {
                                                return '<div class="table-responsive mb-3">' +
                                                        '<table class="table table-striped table-hover mb-0 fs--1">' +
                                                        '<tbody>' +
                                                        '<tr>' +
                                                        '<td class="bg-100 fw-bold" style="width: 20%;">NIC:</td>' +
                                                        '<td class="text-600">' + (nic || '-') + '</td>' +
                                                        '</tr>' +
                                                        '<tr>' +
                                                        '<td class="bg-100 fw-bold" style="width: 20%;">Name:</td>' +
                                                        '<td class="text-600">' + (name || '-') + '</td>' +
                                                        '</tr>' +
                                                        '<tr>' +
                                                        '<td class="bg-100 fw-bold" style="width: 20%;">Address:</td>' +
                                                        '<td class="text-600">' + (address || '-') + '</td>' +
                                                        '</tr>' +
                                                        '<tr>' +
                                                        '<td class="bg-100 fw-bold" style="width: 20%;">Mobile No:</td>' +
                                                        '<td>' +
                                                        (contact ? '<a class="text-600 text-decoration-none fw-bold" href="tel:' + contact + '">' + contact + '</a>' : '-') +
                                                        '</td>' +
                                                        '</tr>' +
                                                        '</tbody>' +
                                                        '</table>' +
                                                        '</div>';
                                            }

                                            function isGuarantorPresent(name) {
                                                return name && name.trim() !== '' && name.trim() !== '-';
                                            }

                                            let count = 0;
                                            if (isGuarantorPresent(data.g1))
                                                count++;
                                            if (isGuarantorPresent(data.g2))
                                                count++;
                                            if (isGuarantorPresent(data.g3))
                                                count++;

                                            const showNumber = count > 1;

                                            if (isGuarantorPresent(data.g1)) {
                                                guarantorsHtml += getGuarantorHtml(showNumber ? 'Guarantor 1' : 'Guarantor', data.g1, data.g1Address, data.g1Contact, data.g1Nic);
                                            }
                                            if (isGuarantorPresent(data.g2)) {
                                                guarantorsHtml += getGuarantorHtml(showNumber ? 'Guarantor 2' : 'Guarantor', data.g2, data.g2Address, data.g2Contact, data.g2Nic);
                                            }
                                            if (isGuarantorPresent(data.g3)) {
                                                guarantorsHtml += getGuarantorHtml(showNumber ? 'Guarantor 3' : 'Guarantor', data.g3, data.g3Address, data.g3Contact, data.g3Nic);
                                            }

                                            if (!guarantorsHtml) {
                                                guarantorsHtml = '<div class="font-sans-serif py-3 text-center text-muted fs--1">' +
                                                        'No Guarantor details associated with this contract.' +
                                                        '</div>';
                                            }
                                            guarantorsWrapper.innerHTML = guarantorsHtml;


                                            detailsCard.style.display = 'block';
                                            if (tabsCard) tabsCard.style.display = 'block';

                                            // Collapse search bar to top
                                            $('#searchContainer').addClass('search-collapsed');
                                            $('#searchHelpText').hide();
                                            $('#searchHoverTrigger').show();

                                            ReceiptTable(data.financeNo);
                                            SmsTable(data.financeNo);
                                            LocksTable(data.financeNo, data.security, data.imeiNo);
                                            RemarksTable(data.financeNo);
                                            if (loader) loader.style.display = 'none';
                                        })
                                        .catch(error => {
                                            if (loader) loader.style.display = 'none';
                                            console.error('Error fetching details:', error);
                                            alert('Could not load contract details. Please check the finance number.');
                                        });
                            }
                        });
         </script>
         
         <!-- SMS Modal -->
         <div class="modal fade" id="smsModal" tabindex="-1" aria-labelledby="smsModalLabel" aria-hidden="true">
             <div class="modal-dialog modal-dialog-centered">
                 <div class="modal-content">
                     <div class="modal-header">
                         <h5 class="modal-title" id="smsModalLabel"><span class="fas fa-sms me-2 text-primary"></span>Full Message Details</h5>
                         <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                     </div>
                     <div class="modal-body fs--1 text-800" style="white-space: pre-wrap;" id="smsModalContent">
                     </div>
                     <div class="modal-footer">
                         <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Close</button>
                     </div>
                 </div>
             </div>
         </div>
     </body>
 </html>
 <%-- Touch JSP for JSPF compile v8 --%>
