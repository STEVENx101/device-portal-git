<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en-US" dir="ltr">

<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Fintrex | Customer 360 View</title>

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
    <link href="${pageContext.request.contextPath}/vendors/datatables.net-bs5/dataTables.bootstrap5.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/theme-rtl.min.css" rel="stylesheet" id="style-rtl">
    <link href="${pageContext.request.contextPath}/assets/css/theme.min.css" rel="stylesheet" id="style-default">
    <link href="${pageContext.request.contextPath}/assets/css/user-rtl.min.css" rel="stylesheet" id="user-style-rtl">
    <link href="${pageContext.request.contextPath}/assets/css/user.min.css" rel="stylesheet" id="user-style-default">

    <script>
        var linkRTL = document.getElementById('style-rtl');
        var userLinkRTL = document.getElementById('user-style-rtl');
        if (linkRTL) linkRTL.setAttribute('disabled', true);
        if (userLinkRTL) userLinkRTL.setAttribute('disabled', true);
    </script>

    <style>
        /* Floating Search Bar matching facility info UI */
        .search-collapsed {
            position: fixed !important;
            top: -120px !important;
            left: 50% !important;
            transform: translateX(-50%) !important;
            width: 55% !important;
            z-index: 1050 !important;
            background: rgba(255, 255, 255, 0.98) !important;
            backdrop-filter: blur(12px) !important;
            padding: 12px 24px !important;
            border-radius: 0 0 16px 16px !important;
            box-shadow: 0 12px 35px rgba(0, 0, 0, 0.15) !important;
            transition: top 0.3s ease-in-out !important;
            border: 1px solid rgba(0, 0, 0, 0.1) !important;
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

        html.dark .search-collapsed {
            background: rgba(15, 23, 42, 0.96) !important;
            backdrop-filter: blur(20px) !important;
            -webkit-backdrop-filter: blur(20px) !important;
            border: 1px solid rgba(255, 255, 255, 0.1) !important;
            border-top: none !important;
            box-shadow: 0 12px 40px rgba(0, 0, 0, 0.5) !important;
        }

        .search-box .search-input {
            padding-left: 2.75rem !important;
            border: 2px solid #cbd5e1 !important;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05) !important;
            transition: all 0.25s ease-in-out !important;
            font-weight: 500 !important;
            border-radius: 12px !important;
        }

        .search-box .search-input:focus {
            border-color: #6366f1 !important;
            box-shadow: 0 0 0 4px rgba(99, 102, 241, 0.2), 0 4px 20px rgba(99, 102, 241, 0.15) !important;
        }

        html.dark .search-box .search-input {
            border: 2.5px solid rgba(255, 255, 255, 0.15) !important;
            background-color: rgba(15, 23, 42, 0.85) !important;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3) !important;
            color: #f8fafc !important;
        }

        html.dark .search-box .search-input:focus {
            border-color: #f59e0b !important;
            box-shadow: 0 0 0 4px rgba(245, 158, 11, 0.25), 0 4px 25px rgba(245, 158, 11, 0.2) !important;
        }

        /* Profile Grid Card Fields */
        .field-label {
            font-size: 0.72rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: #64748b;
            margin-bottom: 2px;
        }

        html.dark .field-label {
            color: #94a3b8;
        }

        .field-value {
            font-size: 0.88rem;
            font-weight: 600;
            color: #1e293b;
            word-break: break-word;
        }

        html.dark .field-value {
            color: #f8fafc;
        }

        /* Modern Tabs styling */
        .c360-nav-tabs {
            border-bottom: 2px solid #e2e8f0;
            gap: 8px;
        }

        html.dark .c360-nav-tabs {
            border-bottom-color: rgba(255, 255, 255, 0.1);
        }

        .c360-nav-tabs .nav-link {
            border: none !important;
            border-radius: 10px 10px 0 0 !important;
            padding: 0.75rem 1.25rem !important;
            font-weight: 700 !important;
            font-size: 0.85rem !important;
            color: #64748b !important;
            background: transparent !important;
            transition: all 0.2s ease-in-out !important;
            position: relative;
        }

        .c360-nav-tabs .nav-link:hover {
            color: #6366f1 !important;
            background: rgba(99, 102, 241, 0.05) !important;
        }

        html.dark .c360-nav-tabs .nav-link:hover {
            color: #f59e0b !important;
            background: rgba(245, 158, 11, 0.1) !important;
        }

        .c360-nav-tabs .nav-link.active {
            color: #6366f1 !important;
            background: #ffffff !important;
            box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.04) !important;
        }

        .c360-nav-tabs .nav-link.active::after {
            content: '';
            position: absolute;
            bottom: -2px;
            left: 0;
            width: 100%;
            height: 3px;
            background: linear-gradient(135deg, #6366f1 0%, #a855f7 100%);
            border-radius: 3px 3px 0 0;
        }

        html.dark .c360-nav-tabs .nav-link.active {
            color: #f59e0b !important;
            background: rgba(15, 23, 42, 0.9) !important;
        }

        html.dark .c360-nav-tabs .nav-link.active::after {
            background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
        }

        /* Page height override for smooth scrolling */
        html, body, .main, [data-layout="container"], .container-fluid, .content {
            height: auto !important;
            max-height: none !important;
            overflow: visible !important;
        }
    </style>
</head>

<body>

    <main class="main" id="top">
        <div class="container" data-layout="container">
            <script>
                var container = document.querySelector('[data-layout]');
                if (container) {
                    container.classList.remove('container');
                    container.classList.add('container-fluid');
                }
            </script>

            <%@include file="../jspf/navbar.jspf" %>

            <div class="content">
                <%@include file="../jspf/topbar.jspf" %>

                <!-- Search Container -->
                <div class="search-hover-trigger" id="searchHoverTrigger"></div>
                <div id="searchContainer" class="d-flex flex-column align-items-center mt-3 mb-3">
                    <div class="search-box w-50 position-relative">
                        <form class="position-relative w-100" id="searchForm" onsubmit="handleSearchSubmit(event)">
                            <input class="form-control search-input" type="search" id="searchInput"
                                placeholder="Search Customer by NIC No or Name..."
                                autocomplete="off" aria-label="Search Customer by NIC or Name" />
                            <span class="fas fa-search search-box-icon position-absolute top-50 start-0 translate-middle-y ms-3 text-400"></span>
                            <button type="submit" class="btn btn-primary btn-sm position-absolute end-0 top-50 translate-middle-y me-2 rounded-pill px-3">
                                <span class="fas fa-arrow-right"></span>
                            </button>
                        </form>
                        
                        <!-- Auto-suggest Dropdown -->
                        <div class="dropdown-menu border font-base start-0 mt-2 py-0 overflow-hidden w-100 shadow-lg" id="suggestionsDropdown">
                            <div class="scrollbar list py-2" id="suggestionsList" style="max-height: 22rem;">
                                <div class="px-3 py-2 text-muted fs--1">Type NIC No or Name to search...</div>
                            </div>
                        </div>
                    </div>
                    <div class="text-500 fs--2 mt-2" id="searchHelpText">
                        <span class="fas fa-info-circle me-1 text-primary"></span>Search by <strong>NIC No</strong> (e.g. 200076900989) or <strong>Customer Name</strong>
                    </div>
                </div>

                <!-- Main Loader -->
                <div class="justify-content-center align-items-center my-5" id="c360Loader" style="display: none;">
                    <div class="loader-widget">
                        <div class="orb-container">
                            <div class="orb"></div>
                            <div class="orb"></div>
                            <div class="orb"></div>
                        </div>
                        <span class="fw-bold text-700 fs--1">Fetching Customer 360 Information...</span>
                    </div>
                </div>

                <!-- Customer Details Card -->
                <div class="card glass-card mb-3" id="detailsCard" style="display: none;">
                    <div class="card-header bg-light py-3">
                        <h5 class="mb-0 text-primary fw-bold"><i class="fas fa-id-card me-2"></i>Customer Information Overview</h5>
                    </div>

                    <div class="card-body p-4">
                        <!-- Standard Customer Profile Fields Grid -->
                        <div class="row g-3">
                            <div class="col-6 col-sm-4 col-md-3 col-lg-2">
                                <div class="field-label"><i class="fas fa-tags me-1"></i>Client Type</div>
                                <div class="field-value" id="val-client_type_text">-</div>
                            </div>
                            <div class="col-6 col-sm-4 col-md-3 col-lg-2">
                                <div class="field-label"><i class="fas fa-barcode me-1"></i>Client Code</div>
                                <div class="field-value" id="val-client_code_text">-</div>
                            </div>
                            <div class="col-6 col-sm-4 col-md-3 col-lg-2">
                                <div class="field-label"><i class="fas fa-user-tag me-1"></i>Title</div>
                                <div class="field-value" id="val-title">-</div>
                            </div>
                            <div class="col-12 col-md-6 col-lg-4">
                                <div class="field-label"><i class="fas fa-user-alt me-1"></i>Full Name</div>
                                <div class="field-value text-primary" id="val-full_name_text">-</div>
                            </div>
                            <div class="col-6 col-sm-4 col-md-3 col-lg-2">
                                <div class="field-label"><i class="fas fa-signature me-1"></i>Short Name</div>
                                <div class="field-value" id="val-short_name">-</div>
                            </div>

                            <div class="col-6 col-sm-4 col-md-3 col-lg-2">
                                <div class="field-label"><i class="fas fa-id-card me-1"></i>ID / NIC No</div>
                                <div class="field-value" id="val-id_no_text">-</div>
                            </div>
                            <div class="col-6 col-sm-4 col-md-3 col-lg-2">
                                <div class="field-label"><i class="fas fa-calendar-alt me-1"></i>DOB / DOE</div>
                                <div class="field-value" id="val-dob-doe">-</div>
                            </div>
                            <div class="col-6 col-sm-4 col-md-3 col-lg-2">
                                <div class="field-label"><i class="fas fa-mobile-alt me-1"></i>Mobile</div>
                                <div class="field-value">
                                    <a class="text-decoration-none fw-bold" id="val-mobile-link" href="#"><span id="val-mobile">-</span></a>
                                </div>
                            </div>
                            <div class="col-6 col-sm-4 col-md-3 col-lg-2">
                                <div class="field-label"><i class="fas fa-mobile me-1"></i>Mobile 2</div>
                                <div class="field-value">
                                    <a class="text-decoration-none fw-bold" id="val-mobile2-link" href="#"><span id="val-mobile2">-</span></a>
                                </div>
                            </div>
                            <div class="col-6 col-sm-4 col-md-3 col-lg-2">
                                <div class="field-label"><i class="fas fa-phone-alt me-1"></i>Telephone</div>
                                <div class="field-value">
                                    <a class="text-decoration-none fw-bold" id="val-telephone-link" href="#"><span id="val-telephone">-</span></a>
                                </div>
                            </div>

                            <div class="col-12 col-md-6 col-lg-4">
                                <div class="field-label"><i class="fas fa-map-marker-alt me-1"></i>Address</div>
                                <div class="field-value" id="val-address">-</div>
                            </div>
                            <div class="col-6 col-sm-4 col-md-3 col-lg-2">
                                <div class="field-label"><i class="fas fa-clock me-1"></i>Entered Date</div>
                                <div class="field-value" id="val-entered_date">-</div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Tabs Card for Facilities -->
                <div class="card glass-card" id="tabsCard" style="display: none;">
                    <div class="card-header p-0 border-bottom border-200">
                        <ul class="nav c360-nav-tabs px-3 pt-2" id="facilityTabs" role="tablist">
                            <li class="nav-item" role="presentation">
                                <button class="nav-link active" id="tab-savings-btn" data-bs-toggle="tab" data-bs-target="#savings-pane" type="button" role="tab" onclick="switchFacilityTab('SAVINGS')">
                                    <i class="fas fa-piggy-bank me-2"></i>SAVINGS
                                    <span class="badge bg-soft-primary text-primary rounded-pill ms-2 count-badge" id="count-SAVINGS">0</span>
                                </button>
                            </li>
                            <li class="nav-item" role="presentation">
                                <button class="nav-link" id="tab-leasing-btn" data-bs-toggle="tab" data-bs-target="#leasing-pane" type="button" role="tab" onclick="switchFacilityTab('LEASING')">
                                    <i class="fas fa-car me-2"></i>LEASING
                                    <span class="badge bg-soft-primary text-primary rounded-pill ms-2 count-badge" id="count-LEASING">0</span>
                                </button>
                            </li>
                            <li class="nav-item" role="presentation">
                                <button class="nav-link" id="tab-loan-btn" data-bs-toggle="tab" data-bs-target="#loan-pane" type="button" role="tab" onclick="switchFacilityTab('LOAN')">
                                    <i class="fas fa-hand-holding-usd me-2"></i>LOAN
                                    <span class="badge bg-soft-primary text-primary rounded-pill ms-2 count-badge" id="count-LOAN">0</span>
                                </button>
                            </li>
                            <li class="nav-item" role="presentation">
                                <button class="nav-link" id="tab-goldloan-btn" data-bs-toggle="tab" data-bs-target="#goldloan-pane" type="button" role="tab" onclick="switchFacilityTab('Gold Loan')">
                                    <i class="fas fa-coins me-2"></i>Gold Loan
                                    <span class="badge bg-soft-primary text-primary rounded-pill ms-2 count-badge" id="count-Gold Loan">0</span>
                                </button>
                            </li>
                            <li class="nav-item" role="presentation">
                                <button class="nav-link" id="tab-fd-btn" data-bs-toggle="tab" data-bs-target="#fd-pane" type="button" role="tab" onclick="switchFacilityTab('FD')">
                                    <i class="fas fa-vault me-2"></i>FD
                                    <span class="badge bg-soft-primary text-primary rounded-pill ms-2 count-badge" id="count-FD">0</span>
                                </button>
                            </li>
                        </ul>
                    </div>

                    <div class="card-body p-3">
                        <!-- Tab Content -->
                        <div class="tab-content" id="facilityTabContent">
                            <div class="tab-pane fade show active" id="facilityPane" role="tabpanel">
                                <div class="table-responsive scrollbar">
                                     <table class="table table-hover table-striped align-middle mb-0 fs--1 w-100" id="facilityTable">
                                        <thead class="bg-200 text-900" id="facilityTableHead">
                                            <tr>
                                                <th>Account ID</th>
                                                <th>Product</th>
                                                <th>Status</th>
                                                <th>Location</th>
                                                <th class="text-end">Amount</th>
                                                <th class="text-end">Total Outstanding</th>
                                                <th class="text-end">Capital Outstanding</th>
                                                <th class="text-end">Interest Outstanding</th>
                                                <th class="text-end">ODI Outstanding</th>
                                                <th class="text-end">Total Arrears</th>
                                                <th class="text-end">Rental</th>
                                                <th class="text-center">Rate (%)</th>
                                                <th class="text-center">Tenor</th>
                                                <th class="text-center">Frequency</th>
                                                <th>Start Date</th>
                                                <th>Due Date</th>
                                                <th>Maturity Date</th>
                                                <th>Last Payment</th>
                                            </tr>
                                        </thead>
                                        <tbody id="facilityTableBody">
                                            <tr>
                                                <td colspan="18" class="text-center py-4 text-muted">
                                                    Select a customer to view facilities.
                                                </td>
                                            </tr>
                                        </tbody>
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
    <script src="${pageContext.request.contextPath}/vendors/jquery/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/vendors/popper/popper.min.js"></script>
    <script src="${pageContext.request.contextPath}/vendors/bootstrap/bootstrap.min.js"></script>
    <script src="${pageContext.request.contextPath}/vendors/anchorjs/anchor.min.js"></script>
    <script src="${pageContext.request.contextPath}/vendors/is/is.min.js"></script>
    <script src="${pageContext.request.contextPath}/vendors/fontawesome/all.min.js"></script>
    <script src="${pageContext.request.contextPath}/vendors/lodash/lodash.min.js"></script>
    <script src="${pageContext.request.contextPath}/vendors/datatables.net/jquery.dataTables.min.js"></script>
    <script src="${pageContext.request.contextPath}/vendors/datatables.net-bs5/dataTables.bootstrap5.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/theme.js"></script>

    <script>
        const contextPath = "${pageContext.request.contextPath}";
        let currentNic = "";
        let currentActiveTab = "SAVINGS";
        let activeSuggestionIndex = -1;
        let dtFacility = null;
        let allFacilityData = {
            'SAVINGS': [],
            'LEASING': [],
            'LOAN': [],
            'Gold Loan': [],
            'FD': []
        };

        document.addEventListener("DOMContentLoaded", () => {
            initSearchSuggestions();
            setupFloatingSearch();

            // Check URL parameters (e.g. ?nic=... or ?query=... or ?clientCode=...)
            const urlParams = new URLSearchParams(window.location.search);
            const queryParam = urlParams.get('nic') || urlParams.get('query') || urlParams.get('clientCode');
            if (queryParam) {
                document.getElementById('searchInput').value = queryParam;
                fetchCustomer360(queryParam);
            }
        });

        function setupFloatingSearch() {
            const searchContainer = document.getElementById('searchContainer');
            const searchHoverTrigger = document.getElementById('searchHoverTrigger');

            if (searchHoverTrigger && searchContainer) {
                searchHoverTrigger.addEventListener('mouseenter', () => {
                    if (searchContainer.classList.contains('search-collapsed')) {
                        searchContainer.classList.add('hovered');
                    }
                });

                searchContainer.addEventListener('mouseleave', () => {
                    if (searchContainer.classList.contains('search-collapsed')) {
                        searchContainer.classList.remove('hovered');
                    }
                });
            }
        }

        function initSearchSuggestions() {
            const searchInput = document.getElementById('searchInput');
            const suggestionsDropdown = document.getElementById('suggestionsDropdown');
            const suggestionsList = document.getElementById('suggestionsList');
            let debounceTimer;

            searchInput.addEventListener('input', function () {
                const query = this.value.trim();
                clearTimeout(debounceTimer);

                if (query.length < 2) {
                    suggestionsDropdown.classList.remove('show');
                    return;
                }

                debounceTimer = setTimeout(() => {
                    fetch(contextPath + '/api/customer360/search?query=' + encodeURIComponent(query))
                        .then(res => res.json())
                        .then(data => {
                            activeSuggestionIndex = -1;
                            if (data && data.length > 0) {
                                let html = '';
                                data.forEach(item => {
                                    html += `
                                        <a href="javascript:void(0)" class="dropdown-item px-3 py-2 border-bottom border-100 suggest-item" 
                                           onclick="selectCustomer('\${item.clientCode}', '\${item.idNo}')">
                                            <div class="d-flex align-items-center justify-content-between">
                                                <div>
                                                    <div class="fw-bold text-dark fs--1">\${escapeHtml(item.fullName || '-')}</div>
                                                    <div class="fs--2 text-muted">
                                                        Code: <span class="badge bg-soft-secondary text-dark">\${escapeHtml(item.clientCode || '-')}</span>
                                                        \${item.mobile ? ' • Mobile: ' + escapeHtml(item.mobile) : ''}
                                                    </div>
                                                </div>
                                                <div class="text-end">
                                                    <span class="badge bg-soft-primary text-primary fs--2">\${escapeHtml(item.idNo || 'NIC -')}</span>
                                                </div>
                                            </div>
                                        </a>
                                    `;
                                });
                                suggestionsList.innerHTML = html;
                                suggestionsDropdown.classList.add('show');
                            } else {
                                suggestionsList.innerHTML = '<div class="px-3 py-2 text-muted fs--1 text-center">No matching customer found.</div>';
                                suggestionsDropdown.classList.add('show');
                            }
                        })
                        .catch(err => {
                            console.error('Error auto-suggesting customer:', err);
                        });
                }, 250);
            });

            searchInput.addEventListener('keydown', function (e) {
                const items = suggestionsList.querySelectorAll('.suggest-item');
                if (!items.length || !suggestionsDropdown.classList.contains('show')) return;

                if (e.key === 'ArrowDown') {
                    e.preventDefault();
                    activeSuggestionIndex = (activeSuggestionIndex + 1) % items.length;
                    updateSuggestionHighlight(items);
                } else if (e.key === 'ArrowUp') {
                    e.preventDefault();
                    activeSuggestionIndex = (activeSuggestionIndex - 1 + items.length) % items.length;
                    updateSuggestionHighlight(items);
                } else if (e.key === 'Enter') {
                    if (activeSuggestionIndex >= 0 && activeSuggestionIndex < items.length) {
                        e.preventDefault();
                        items[activeSuggestionIndex].click();
                    }
                } else if (e.key === 'Escape') {
                    suggestionsDropdown.classList.remove('show');
                }
            });

            document.addEventListener('click', function (e) {
                if (e.target !== searchInput && !suggestionsDropdown.contains(e.target)) {
                    suggestionsDropdown.classList.remove('show');
                }
            });
        }

        function updateSuggestionHighlight(items) {
            items.forEach((item, index) => {
                if (index === activeSuggestionIndex) {
                    item.classList.add('active', 'bg-200');
                    item.scrollIntoView({ block: 'nearest' });
                } else {
                    item.classList.remove('active', 'bg-200');
                }
            });
        }

        function handleSearchSubmit(e) {
            e.preventDefault();
            const query = document.getElementById('searchInput').value.trim();
            if (query.length >= 2) {
                document.getElementById('suggestionsDropdown').classList.remove('show');
                fetchCustomer360(query);
            }
        }

        function selectCustomer(clientCode, nic) {
            const targetQuery = (nic && nic !== 'NIC -' && nic.trim() !== '') ? nic.trim() : (clientCode || '');
            document.getElementById('searchInput').value = targetQuery;
            document.getElementById('suggestionsDropdown').classList.remove('show');
            fetchCustomer360(targetQuery);
        }

        function fetchCustomer360(query) {
            const loader = document.getElementById('c360Loader');
            const detailsCard = document.getElementById('detailsCard');
            const tabsCard = document.getElementById('tabsCard');

            if (loader) loader.style.display = 'flex';
            if (detailsCard) detailsCard.style.display = 'none';
            if (tabsCard) tabsCard.style.display = 'none';

            fetch(contextPath + '/api/customer360/details?query=' + encodeURIComponent(query))
                .then(res => {
                    if (!res.ok) throw new Error('Customer not found');
                    return res.json();
                })
                .then(data => {
                    populateCustomerFields(data);

                    currentNic = data.idNo || "";

                    // Collapse search bar to top floating state like facility info UI
                    $('#searchContainer').addClass('search-collapsed');
                    $('#searchHelpText').hide();
                    $('#searchHoverTrigger').show();

                    if (loader) loader.style.display = 'none';
                    if (detailsCard) detailsCard.style.display = 'block';
                    if (tabsCard) tabsCard.style.display = 'block';

                    // Call all 5 tabs API at once in parallel
                    fetchAllTabsAtOnce(currentNic);
                })
                .catch(err => {
                    if (loader) loader.style.display = 'none';
                    console.error('Error fetching customer details:', err);
                    alert('Could not find customer matching: ' + query);
                });
        }

        function populateCustomerFields(data) {
            document.getElementById('val-full_name_text').textContent = data.fullName || '-';
            document.getElementById('val-client_code_text').textContent = data.clientCode || '-';
            document.getElementById('val-id_no_text').textContent = data.idNo || '-';
            document.getElementById('val-client_type_text').textContent = data.clientType || 'Individual';
            document.getElementById('val-title').textContent = data.title || '-';
            document.getElementById('val-short_name').textContent = data.shortName || '-';
            document.getElementById('val-dob-doe').textContent = data.dobDoe || '-';
            document.getElementById('val-address').textContent = data.address || '-';
            document.getElementById('val-entered_date').textContent = data.enteredDate || '-';

            // Mobile links
            bindPhoneLink('val-mobile', 'val-mobile-link', data.mobile);
            bindPhoneLink('val-mobile2', 'val-mobile2-link', data.mobile2);
            bindPhoneLink('val-telephone', 'val-telephone-link', data.telephone);
        }

        function bindPhoneLink(spanId, linkId, phoneNo) {
            const span = document.getElementById(spanId);
            const link = document.getElementById(linkId);
            if (span && link) {
                if (phoneNo && phoneNo !== '-') {
                    span.textContent = phoneNo;
                    link.href = 'tel:' + phoneNo;
                } else {
                    span.textContent = '-';
                    link.removeAttribute('href');
                }
            }
        }

        function fetchAllTabsAtOnce(nic) {
            const tabTypes = ['SAVINGS', 'LEASING', 'LOAN', 'Gold Loan', 'FD'];
            allFacilityData = { 'SAVINGS': [], 'LEASING': [], 'LOAN': [], 'Gold Loan': [], 'FD': [] };

            // Set loading indicators on badge counts
            tabTypes.forEach(t => {
                const badgeEl = document.getElementById('count-' + t);
                if (badgeEl) badgeEl.textContent = '...';
            });

            const tbody = document.getElementById('facilityTableBody');
            tbody.innerHTML = `
                <tr>
                    <td colspan="18" class="text-center py-4">
                        <div class="spinner-border text-primary spinner-border-sm me-2" role="status"></div>
                        <span class="text-muted fw-bold fs--1">Loading facility accounts...</span>
                    </td>
                </tr>
            `;

            // Fire API requests for all 5 tabs simultaneously
            tabTypes.forEach(tabType => {
                const requestBody = {
                    "type": tabType,
                    "nic": nic,
                    "page": 0,
                    "size": 31
                };

                fetch(contextPath + '/api/facility/list', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'Accept': 'application/json'
                    },
                    body: JSON.stringify(requestBody)
                })
                .then(res => res.json())
                .then(resData => {
                    let accounts = [];
                    if (resData && resData.data && resData.data.accounts) {
                        accounts = resData.data.accounts;
                    } else if (resData && resData.data && Array.isArray(resData.data)) {
                        accounts = resData.data;
                    } else if (resData && resData.accounts) {
                        accounts = resData.accounts;
                    } else if (resData && resData.content) {
                        accounts = resData.content;
                    } else if (Array.isArray(resData)) {
                        accounts = resData;
                    } else if (resData && typeof resData === 'object' && (resData.accountNumber || resData.id || resData.currentBalance)) {
                        accounts = [resData];
                    }

                    allFacilityData[tabType] = accounts;

                    const badgeEl = document.getElementById('count-' + tabType);
                    if (badgeEl) badgeEl.textContent = accounts.length;

                    // If this tab is the currently active tab, render immediately
                    if (tabType === currentActiveTab) {
                        renderFacilityTable(accounts);
                    }
                })
                .catch(err => {
                    console.error('Error fetching ' + tabType + ' facilities:', err);
                    allFacilityData[tabType] = [];
                    const badgeEl = document.getElementById('count-' + tabType);
                    if (badgeEl) badgeEl.textContent = '0';
                    if (tabType === currentActiveTab) {
                        renderFacilityTable([]);
                    }
                });
            });
        }

        function switchFacilityTab(tabType) {
            currentActiveTab = tabType;

            // Highlight tab button
            document.querySelectorAll('#facilityTabs .nav-link').forEach(btn => btn.classList.remove('active'));
            if (tabType === 'SAVINGS') document.getElementById('tab-savings-btn').classList.add('active');
            else if (tabType === 'LEASING') document.getElementById('tab-leasing-btn').classList.add('active');
            else if (tabType === 'LOAN') document.getElementById('tab-loan-btn').classList.add('active');
            else if (tabType === 'Gold Loan') document.getElementById('tab-goldloan-btn').classList.add('active');
            else if (tabType === 'FD') document.getElementById('tab-fd-btn').classList.add('active');

            // Instantly render cached tab data (0 delay)
            const accounts = allFacilityData[tabType] || [];
            renderFacilityTable(accounts);
        }

        function renderFacilityTable(accounts) {
            const tbody = document.getElementById('facilityTableBody');
            const thead = document.getElementById('facilityTableHead');

            if (dtFacility) {
                dtFacility.destroy();
                dtFacility = null;
            }

            if (currentActiveTab === 'SAVINGS') {
                if (thead) {
                    thead.innerHTML = `
                        <tr>
                            <th>Account Number</th>
                            <th>Product</th>
                            <th>Status</th>
                            <th class="text-end">Current Balance</th>
                            <th class="text-end">Amount On Hold</th>
                            <th class="text-end text-success">Available Balance</th>
                            <th>Start Date</th>
                        </tr>
                    `;
                }

                if (!accounts || accounts.length === 0) {
                    tbody.innerHTML = `
                        <tr>
                            <td colspan="7" class="text-center py-4 text-muted fs--1">
                                <i class="fas fa-folder-open me-2"></i>No Savings accounts found for this customer.
                            </td>
                        </tr>
                    `;
                    return;
                }

                let html = '';
                accounts.forEach(acc => {
                    const accNo = acc.accountNumber || acc.AccountID || acc.contractNo || '-';
                    const currentBal = acc.currentBalance != null ? parseFloat(acc.currentBalance) : (acc.amount != null ? parseFloat(acc.amount) : 0);
                    const holdAmt = acc.amountOnHold != null ? parseFloat(acc.amountOnHold) : 0;
                    const availBal = acc.availableBalance != null ? parseFloat(acc.availableBalance) : (currentBal - holdAmt);
                    const statusStr = acc.status || 'Active';
                    let statusBadge = '<span class="badge bg-soft-success text-success"><i class="fas fa-check-circle me-1"></i>Active</span>';
                    if (String(statusStr).toLowerCase() === 'closed') {
                        statusBadge = '<span class="badge bg-soft-secondary text-secondary">Closed</span>';
                    } else if (String(statusStr).toLowerCase() === 'inactive') {
                        statusBadge = '<span class="badge bg-soft-warning text-warning">Inactive</span>';
                    }

                    html += `
                        <tr>
                            <td class="fw-bold text-dark">\${escapeHtml(accNo)}</td>
                            <td class="fw-semi-bold">\${escapeHtml(acc.product || '-')}</td>
                            <td>\${statusBadge}</td>
                            <td class="text-end fw-bold">\${formatCurrency(currentBal)}</td>
                            <td class="text-end text-muted">\${formatCurrency(holdAmt)}</td>
                            <td class="text-end fw-bold text-success">\${formatCurrency(availBal)}</td>
                            <td>\${escapeHtml(acc.startDate || '-')}</td>
                        </tr>
                    `;
                });

                tbody.innerHTML = html;
            } else {
                if (thead) {
                    thead.innerHTML = `
                        <tr>
                            <th>Account ID</th>
                            <th>Product</th>
                            <th>Status</th>
                            <th>Location</th>
                            <th class="text-end">Amount</th>
                            <th class="text-end">Total Outstanding</th>
                            <th class="text-end">Capital Outstanding</th>
                            <th class="text-end">Interest Outstanding</th>
                            <th class="text-end">ODI Outstanding</th>
                            <th class="text-end">Total Arrears</th>
                            <th class="text-end">Rental</th>
                            <th class="text-center">Rate (%)</th>
                            <th class="text-center">Tenor</th>
                            <th class="text-center">Frequency</th>
                            <th>Start Date</th>
                            <th>Due Date</th>
                            <th>Maturity Date</th>
                            <th>Last Payment</th>
                        </tr>
                    `;
                }

                if (!accounts || accounts.length === 0) {
                    tbody.innerHTML = `
                        <tr>
                            <td colspan="18" class="text-center py-4 text-muted fs--1">
                                <i class="fas fa-folder-open me-2"></i>No \${escapeHtml(currentActiveTab)} accounts found for this customer.
                            </td>
                        </tr>
                    `;
                    return;
                }

                let html = '';
                accounts.forEach(acc => {
                    const amount = acc.amount != null ? parseFloat(acc.amount) : 0;
                    const totalOutstanding = acc.totalOutstanding != null ? parseFloat(acc.totalOutstanding) : 0;
                    const capitalOutstanding = acc.capitalOutstanding != null ? parseFloat(acc.capitalOutstanding) : 0;
                    const interestOutstanding = acc.interestOutstanding != null ? parseFloat(acc.interestOutstanding) : 0;
                    const odiOutstanding = acc.odiOutstanding != null ? parseFloat(acc.odiOutstanding) : 0;
                    const totalArrears = acc.totalArrears != null ? parseFloat(acc.totalArrears) : 0;
                    const rental = acc.rental != null ? parseFloat(acc.rental) : 0;

                    const accId = acc.AccountID || acc.contractNo || acc.accountNumber || '-';
                    const statusStr = acc.status || 'Active';
                    let statusBadge = '<span class="badge bg-soft-success text-success">Active</span>';
                    if (String(statusStr).toLowerCase() === 'closed') {
                        statusBadge = '<span class="badge bg-soft-secondary text-secondary">Closed</span>';
                    } else if (totalArrears > 0) {
                        statusBadge = '<span class="badge bg-soft-danger text-danger">Arrears</span>';
                    }

                    html += `
                        <tr>
                            <td class="fw-bold text-dark">\${escapeHtml(accId)}</td>
                            <td class="fw-semi-bold">\${escapeHtml(acc.product || '-')}</td>
                            <td>\${statusBadge}</td>
                            <td>\${escapeHtml(acc.location || '-')}</td>
                            <td class="text-end fw-bold">\${formatCurrency(amount)}</td>
                            <td class="text-end fw-bold text-warning">\${formatCurrency(totalOutstanding)}</td>
                            <td class="text-end">\${formatCurrency(capitalOutstanding)}</td>
                            <td class="text-end">\${formatCurrency(interestOutstanding)}</td>
                            <td class="text-end">\${formatCurrency(odiOutstanding)}</td>
                            <td class="text-end fw-bold text-danger">\${formatCurrency(totalArrears)}</td>
                            <td class="text-end">\${formatCurrency(rental)}</td>
                            <td class="text-center fw-bold">\${acc.rate != null ? acc.rate + '%' : '-'}</td>
                            <td class="text-center">\${acc.period != null ? acc.period + ' M' : '-'}</td>
                            <td class="text-center">\${escapeHtml(acc.frequency || 'M')}</td>
                            <td>\${escapeHtml(acc.startDate || '-')}</td>
                            <td>\${escapeHtml(acc.dueDate || '-')}</td>
                            <td>\${escapeHtml(acc.maturityDate || '-')}</td>
                            <td>
                                <div class="fs--2">
                                    <span class="fw-bold">\${formatCurrency(acc.lastPayment)}</span>
                                    <div class="text-muted">\${escapeHtml(acc.lastPaymentDate || '-')}</div>
                                </div>
                            </td>
                        </tr>
                    `;
                });

                tbody.innerHTML = html;
            }

            // Render clean table without search filter inside tabs
            dtFacility = $('#facilityTable').DataTable({
                paging: false,
                info: false,
                searching: false,
                order: []
            });
        }

        function formatCurrency(num) {
            if (num === null || num === undefined || isNaN(num)) return '0.00';
            return parseFloat(num).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
        }

        function escapeHtml(str) {
            if (!str) return '';
            return String(str)
                .replace(/&/g, "&amp;")
                .replace(/</g, "&lt;")
                .replace(/>/g, "&gt;")
                .replace(/"/g, "&quot;")
                .replace(/'/g, "&#039;");
        }
    </script>
</body>

</html>
