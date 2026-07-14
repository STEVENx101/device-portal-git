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

        <title>Fintrex | Mobile Details &amp; Device Finance Portal</title>

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

                    <div class="d-flex flex-column align-items-center mt-3 mb-4">
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
                        <div class="text-500 fs--2 mt-2">
                            <span class="fas fa-info-circle me-1"></span>Search by <strong>Finance No</strong>, <strong>Customer Name</strong>, or <strong>NIC</strong>
                        </div>
                    </div>

                    <div class="card" id="detailsCard" style="display: none;">
                        <div class="card-body overflow-hidden">
                            <div class="row">
                                <div class="col-lg-4 border-md-end border-dashed">
                                    <table class="table fs--1 mt-3">
                                        <tbody>
                                            <tr>
                                                <td class="bg-100" style="width: 40%;">Account No</td>
                                                <td><span class="val-account-no">-</span></td>
                                            </tr>
                                            <tr>
                                                <td class="bg-100" style="width: 40%;">Account Status</td>
                                                <td><span class="val-account-status">-</span></td>
                                            </tr>
                                            <tr>
                                                <td class="bg-100" style="width: 40%;">Total Outstanding</td>
                                                <td><span class="val-outstanding">-</span></td>
                                            </tr>
                                            <tr>
                                                <td class="bg-100" style="width: 40%;">Performing Status</td>
                                                <td><span class="val-performing-status">-</span></td>
                                            </tr>
                                            <tr>
                                                <td class="bg-100" style="width: 40%;">Security</td>
                                                <td><span class="val-security">-</span></td>
                                            </tr>
                                            <tr>
                                                <td class="bg-100" style="width: 40%;">Model</td>
                                                <td><span class="val-model">-</span></td>
                                            </tr>
                                            <tr class="row-next-lock-date">
                                                <td class="bg-100" style="width: 40%;">Next Lock Date</td>
                                                <td><span class="val-next-lock-date">-</span></td>
                                            </tr>
                                            <tr class="row-lock-status">
                                                <td class="bg-100" style="width: 40%;">Lock Status</td>
                                                <td><span class="val-lock-status">-</span></td>
                                            </tr>
                                            <tr class="row-device-status" style="display: none;">
                                                <td class="bg-100" style="width: 40%;">Current Device Status</td>
                                                <td><span class="val-device-status">-</span></td>
                                            </tr>
                                            <tr>
                                                <td class="bg-100" style="width: 40%;">Facility Grant Date</td>
                                                <td><span class="val-facility-grant-date">-</span></td>
                                            </tr>
                                            <tr>
                                                <td class="bg-100" style="width: 40%;">Maturity Date</td>
                                                <td><span class="val-maturity-date">-</span></td>
                                            </tr>
                                            <tr>
                                                <td class="bg-100" style="width: 40%;">Due Date</td>
                                                <td><span class="val-due-date">-</span></td>
                                            </tr>
                                            <tr>
                                                <td class="bg-100" style="width: 40%;">Rental</td>
                                                <td><span class="val-rental">-</span></td>
                                            </tr>
                                            <tr>
                                                <td class="bg-100" style="width: 40%;">Tenor</td>
                                                <td><span class="val-period">-</span></td>
                                            </tr>
                                            <tr>
                                                <td class="bg-100" style="width: 40%;">Loan Amount</td>
                                                <td><span class="val-finance-amount">-</span></td>
                                            </tr>
                                            <tr>
                                                <td class="bg-100" style="width: 40%;">DPD</td>
                                                <td><span class="val-arr-days">-</span></td>
                                            </tr>
                                            <tr>
                                                <td class="bg-100" style="width: 40%;">Early Settlement Amount</td>
                                                <td><span class="">-</span></td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                                <div class="col-lg-8">
                                    <ul class="nav nav-pills nav-justified mb-2" id="customer-guarantor-tabs" role="tablist">
                                        <li class="nav-item" role="presentation">
                                            <button class="nav-link active py-1 px-3 fs--1 fw-semi-bold" id="customer-tab" data-bs-toggle="pill" data-bs-target="#customer-details-pane" type="button" role="tab" aria-controls="customer-details-pane" aria-selected="true">Customer Details</button>
                                        </li>
                                        <li class="nav-item" role="presentation">
                                            <button class="nav-link py-1 px-3 fs--1 fw-semi-bold" id="guarantor-tab" data-bs-toggle="pill" data-bs-target="#guarantor-details-pane" type="button" role="tab" aria-controls="guarantor-details-pane" aria-selected="false">Guarantor Details</button>
                                        </li>
                                    </ul>
                                    <div class="tab-content" id="customer-guarantor-tabs-content">
                                        <div class="tab-pane fade show active" id="customer-details-pane" role="tabpanel" aria-labelledby="customer-tab">
                                            <table class="table table-borderless fs--1 fw-medium mb-0">
                                                <tbody>
                                                    <tr>
                                                        <td class="p-1" style="width: 25%;">NIC:</td>
                                                        <td class="p-1 text-600"><span id="val-cust-nic">-</span></td>
                                                    </tr>
                                                    <tr>
                                                        <td class="p-1" style="width: 25%;">Name:</td>
                                                        <td class="p-1 text-600"><span id="val-cust-name">-</span></td>
                                                    </tr>
                                                    <tr>
                                                        <td class="p-1" style="width: 25%;">Address:</td>
                                                        <td class="p-1 text-600"><span id="val-cust-address">-</span></td>
                                                    </tr>
                                                    <tr>
                                                        <td class="p-1" style="width: 25%;">Mobile No:</td>
                                                        <td class="p-1"><a class="text-600 text-decoration-none" id="val-cust-mobile-link" href="#"><span id="val-cust-mobile">-</span></a></td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </div>
                                        <div class="tab-pane fade" id="guarantor-details-pane" role="tabpanel" aria-labelledby="guarantor-tab">
                                            <div id="guarantors-wrapper">
                                                <!-- Dynamically filled -->
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Divider -->
                                    <hr class="my-4 border-dashed" />

                                    <!-- Additional Details Tabs -->
                                    <ul class="nav nav-pills nav-justified mb-2" id="additional-details-tabs" role="tablist">
                                        <li class="nav-item" role="presentation">
                                            <button class="nav-link active py-1 px-3 fs--1 fw-semi-bold" id="statement-tab" data-bs-toggle="pill" data-bs-target="#statement-pane" type="button" role="tab" aria-controls="statement-pane" aria-selected="true">Account Statement</button>
                                        </li>
                                        <li class="nav-item" role="presentation">
                                            <button class="nav-link py-1 px-3 fs--1 fw-semi-bold" id="payments-tab" data-bs-toggle="pill" data-bs-target="#payments-pane" type="button" role="tab" aria-controls="payments-pane" aria-selected="false">Payments</button>
                                        </li>
                                        <li class="nav-item" role="presentation">
                                            <button class="nav-link py-1 px-3 fs--1 fw-semi-bold" id="sms-tab" data-bs-toggle="pill" data-bs-target="#sms-pane" type="button" role="tab" aria-controls="sms-pane" aria-selected="false">SMS</button>
                                        </li>
                                    </ul>
                                    <div class="tab-content" id="additional-details-tabs-content">
                                        <div class="tab-pane fade show active" id="statement-pane" role="tabpanel" aria-labelledby="statement-tab">
                                            <!-- Account Statement Content -->
                                        </div>
                                        <div class="tab-pane fade" id="payments-pane" role="tabpanel" aria-labelledby="payments-tab">
                                            <div class="row mx-0 border-bottom border-dashed">
                                                <table id="receipt_table" class="table fs--1 w-100">
                                                    <thead>
                                                        <tr>
                                                            <th>Receipt No</th>
                                                            <th>Receipt Date</th>
                                                            <th>Receipt Mode</th>
                                                            <th>Amount</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody></tbody>
                                                </table>
                                            </div>
                                        </div>
                                        <div class="tab-pane fade" id="sms-pane" role="tabpanel" aria-labelledby="sms-tab">
                                            <div class="row mx-0 border-bottom border-dashed">
                                                <table id="sms_table" class="table fs--1 w-100">
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

                        $(document).ready(function () {
                            ReceiptTable('');
                            SmsTable('');
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
                                        defaultContent: "-"
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






                        document.addEventListener('DOMContentLoaded', function () {
                            const searchInput = document.querySelector('.search-box .search-input');
                            const suggestionsDropdown = document.querySelector('.search-box .dropdown-menu');
                            const listContainer = suggestionsDropdown ? suggestionsDropdown.querySelector('.list') : null;
                            const detailsCard = document.getElementById('detailsCard');


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
                                            document.querySelectorAll('.val-performing-status').forEach(el => el.textContent = data.performingStatus || '-');
                                            document.querySelectorAll('.val-security').forEach(el => el.textContent = data.security || '-');
                                            document.querySelectorAll('.val-model').forEach(el => el.textContent = data.model || '-');

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
                                             function getGuarantorHtml(title, name, address, contact) {
                                                 return '<div class="font-sans-serif border-bottom border-dashed py-2">' +
                                                         '<div class="card-body d-flex gap-3 flex-column align-items-start p-2">' +
                                                         '<h6 class="mb-2 text-primary fw-bold">' + title + '</h6>' +
                                                         '<table class="table table-borderless fs--1 fw-medium mb-0">' +
                                                         '<tbody>' +
                                                         '<tr>' +
                                                         '<td class="p-1" style="width: 25%;">Name:</td>' +
                                                         '<td class="p-1 text-600">' + (name || '-') + '</td>' +
                                                         '</tr>' +
                                                         '<tr>' +
                                                         '<td class="p-1" style="width: 25%;">Address:</td>' +
                                                         '<td class="p-1 text-600">' + (address || '-') + '</td>' +
                                                         '</tr>' +
                                                         '<tr>' +
                                                         '<td class="p-1" style="width: 25%;">Mobile No:</td>' +
                                                         '<td class="p-1">' +
                                                         (contact ? '<a class="text-600 text-decoration-none" href="tel:' + contact + '">' + contact + '</a>' : '-') +
                                                         '</td>' +
                                                         '</tr>' +
                                                         '</tbody>' +
                                                         '</table>' +
                                                         '</div>' +
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
                                                guarantorsHtml += getGuarantorHtml(showNumber ? 'Guarantor 1' : 'Guarantor', data.g1, data.g1Address, data.g1Contact);
                                            }
                                            if (isGuarantorPresent(data.g2)) {
                                                guarantorsHtml += getGuarantorHtml(showNumber ? 'Guarantor 2' : 'Guarantor', data.g2, data.g2Address, data.g2Contact);
                                            }
                                            if (isGuarantorPresent(data.g3)) {
                                                guarantorsHtml += getGuarantorHtml(showNumber ? 'Guarantor 3' : 'Guarantor', data.g3, data.g3Address, data.g3Contact);
                                            }

                                            if (!guarantorsHtml) {
                                                guarantorsHtml = '<div class="font-sans-serif py-3 text-center text-muted fs--1">' +
                                                        'No Guarantor details associated with this contract.' +
                                                        '</div>';
                                            }
                                            guarantorsWrapper.innerHTML = guarantorsHtml;


                                            detailsCard.style.display = 'block';
                                            ReceiptTable(data.financeNo);
                                            SmsTable(data.financeNo);
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
    </body>

</html>
<%-- Touch JSP for JSPF compile v8 --%>
