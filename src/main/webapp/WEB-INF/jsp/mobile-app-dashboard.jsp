<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en-US" dir="ltr">

<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Fintrex | Mobile App Dashboard</title>

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
    <link href="https://fonts.googleapis.com/css2?family=Fira+Code:wght@500;600;700&family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/vendors/simplebar/simplebar.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/theme-rtl.min.css" rel="stylesheet" id="style-rtl">
    <link href="${pageContext.request.contextPath}/assets/css/theme.min.css" rel="stylesheet" id="style-default">
    <link href="${pageContext.request.contextPath}/assets/css/user-rtl.min.css" rel="stylesheet" id="user-style-rtl">
    <link href="${pageContext.request.contextPath}/assets/css/user.min.css" rel="stylesheet" id="user-style-default">

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        var linkRTL = document.getElementById('style-rtl');
        var userLinkRTL = document.getElementById('user-style-rtl');
        linkRTL.setAttribute('disabled', true);
        userLinkRTL.setAttribute('disabled', true);
    </script>

    <style>
        :root {
            --ma-primary: #4f46e5;
            --ma-secondary: #6366f1;
            --ma-purple: #a855f7;
            --ma-surface: #FFFFFF;
            --ma-border: #E2E8F0;
            --ma-text: #0F172A;
            --ma-muted: #475569;
        }

        body, .main, p, div, span, select, input, button, table, h1, h2, h3, h4, h5, h6 {
            font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, sans-serif !important;
        }

        .num-mono {
            font-variant-numeric: tabular-nums;
            letter-spacing: -0.02em;
        }

        /* Header Bar */
        .ma-header-bar {
            flex: 0 0 auto;
            flex-shrink: 0;
            background: linear-gradient(135deg, #4f46e5 0%, #6366f1 50%, #a855f7 100%);
            border-radius: 12px;
            padding: 0.85rem 1.3rem;
            color: #FFFFFF;
            box-shadow: 0 8px 22px -8px rgba(99, 102, 241, 0.38);
            position: relative;
            overflow: hidden;
        }
        .ma-header-bar::after {
            content: "";
            position: absolute;
            top: -55%;
            right: -6%;
            width: 300px;
            height: 300px;
            border-radius: 50%;
            background: radial-gradient(circle, rgba(255, 255, 255, 0.16) 0%, rgba(168, 85, 247, 0) 70%);
            pointer-events: none;
        }
        .ma-header-title {
            font-size: 1.18rem;
            font-weight: 800;
            color: #FFFFFF;
            letter-spacing: -0.025em;
            margin: 0;
        }
        .ma-header-sub {
            font-size: 0.76rem;
            color: rgba(255, 255, 255, 0.86);
            margin-top: 2px;
        }
        .ma-date-control {
            background: rgba(255, 255, 255, 0.16);
            border: 1px solid rgba(255, 255, 255, 0.28);
            border-radius: 9px;
            padding: 0.28rem 0.6rem;
            backdrop-filter: blur(8px);
        }
        .ma-date-control label {
            color: rgba(255, 255, 255, 0.88);
            font-size: 0.71rem;
            font-weight: 600;
        }
        .ma-date-control input[type="date"],
        .ma-date-control select {
            background: transparent;
            border: none;
            color: #FFFFFF;
            font-weight: 600;
            font-size: 0.78rem;
            outline: none;
            cursor: pointer;
            color-scheme: dark;
        }
        .ma-date-control select option {
            color: #0F172A;
            background: #FFFFFF;
        }
        .ma-btn-refresh {
            background: #FFFFFF;
            color: #4f46e5;
            border: none;
            border-radius: 9px;
            font-weight: 700;
            font-size: 0.78rem;
            padding: 0.42rem 0.95rem;
            cursor: pointer;
            transition: background-color 0.18s ease, color 0.18s ease, box-shadow 0.18s ease;
            box-shadow: 0 4px 10px rgba(15, 23, 42, 0.12);
        }
        .ma-btn-refresh:hover {
            background: #EEF2FF;
            color: #4338ca;
        }
        .ma-btn-refresh:disabled {
            opacity: 0.65;
            cursor: not-allowed;
        }

        /* Single-Page Main Body */
        .ma-page-body {
            flex: 1 1 auto;
            min-height: 0;
            overflow-y: auto;
            overflow-x: hidden;
            display: flex;
            flex-direction: column;
            gap: 0.9rem;
            padding: 2px 4px 12px 2px;
        }

        /* 7 Small KPI Cards in One Row */
        .ma-kpi-row {
            display: grid;
            grid-template-columns: repeat(7, minmax(0, 1fr));
            gap: 0.65rem;
            flex: 0 0 auto;
        }
        @media (max-width: 1280px) {
            .ma-kpi-row {
                grid-template-columns: repeat(4, minmax(0, 1fr));
            }
        }
        @media (max-width: 768px) {
            .ma-kpi-row {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        .ma-kpi-card {
            background: var(--ma-surface);
            border: 1px solid var(--ma-border);
            border-radius: 12px;
            padding: 0.78rem 0.88rem;
            position: relative;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            box-shadow: 0 2px 6px rgba(15, 23, 42, 0.03);
            transition: border-color 0.18s ease, box-shadow 0.18s ease;
        }
        .ma-kpi-card::before {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 3px;
            background: var(--accent-color, #6366f1);
        }
        .ma-kpi-card:hover {
            border-color: #CBD5E1;
            box-shadow: 0 8px 18px -8px rgba(15, 23, 42, 0.12);
        }
        .ma-kpi-label {
            font-size: 0.7rem;
            font-weight: 700;
            color: var(--ma-muted);
            line-height: 1.25;
            margin-bottom: 0.32rem;
        }
        .ma-kpi-value {
            font-size: 1.32rem;
            font-weight: 800;
            color: var(--ma-text);
            line-height: 1.15;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .ma-kpi-meta {
            margin-top: 0.45rem;
            padding-top: 0.4rem;
            border-top: 1px solid #F1F5F9;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 0.25rem;
            flex-wrap: wrap;
            font-size: 0.68rem;
            color: var(--ma-muted);
        }
        .ma-sub-pill {
            font-size: 0.64rem;
            font-weight: 700;
            padding: 1px 6px;
            border-radius: 999px;
            background: rgba(5, 150, 105, 0.12);
            color: #047857;
            white-space: nowrap;
        }
        .ma-kpi-ceft {
            background: linear-gradient(145deg, #EEF2FF 0%, #FFFFFF 70%);
            border-color: #C7D2FE;
        }
        .ma-kpi-ceft .ma-kpi-value {
            color: #4f46e5;
        }

        /* Delta Badges */
        .ma-delta {
            display: inline-flex;
            align-items: center;
            font-size: 0.67rem;
            font-weight: 700;
            padding: 2px 7px;
            border-radius: 999px;
            white-space: nowrap;
            font-variant-numeric: tabular-nums;
        }
        .ma-delta-up { background: #DCFCE7; color: #166534; }
        .ma-delta-down { background: #FEE2E2; color: #991B1B; }
        .ma-delta-flat { background: #F1F5F9; color: #475569; }

        /* Bottom 2 Spacious Cards */
        .ma-bottom-grid {
            flex: 1 1 auto;
            min-height: 360px;
            display: grid;
            grid-template-columns: 1.2fr 1fr;
            gap: 0.9rem;
        }
        @media (max-width: 1199px) {
            .ma-bottom-grid {
                grid-template-columns: 1fr;
            }
        }

        .ma-panel {
            background: var(--ma-surface);
            border: 1px solid var(--ma-border);
            border-radius: 14px;
            box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04);
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }
        .ma-panel-header {
            padding: 1rem 1.25rem;
            border-bottom: 1px solid #F1F5F9;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 0.75rem;
            flex-wrap: wrap;
            flex-shrink: 0;
        }
        .ma-panel-title {
            font-size: 0.96rem;
            font-weight: 800;
            color: var(--ma-text);
            margin: 0;
        }
        .ma-panel-subtitle {
            font-size: 0.76rem;
            color: var(--ma-muted);
            margin-top: 2px;
        }

        .ma-btn-detail {
            background: linear-gradient(135deg, #4f46e5 0%, #6366f1 100%);
            color: #FFFFFF;
            border: none;
            border-radius: 9px;
            font-size: 0.76rem;
            font-weight: 700;
            padding: 0.45rem 0.95rem;
            cursor: pointer;
            transition: opacity 0.18s ease, box-shadow 0.18s ease;
            box-shadow: 0 4px 12px rgba(79, 70, 229, 0.25);
            white-space: nowrap;
        }
        .ma-btn-detail:hover {
            opacity: 0.93;
            color: #FFFFFF;
            box-shadow: 0 6px 16px rgba(79, 70, 229, 0.34);
        }

        /* Tables */
        .ma-table {
            width: 100%;
            margin-bottom: 0;
            border-collapse: collapse;
        }
        .ma-table thead th {
            background: #F8FAFC;
            color: #475569;
            font-size: 0.7rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            padding: 0.78rem 1.05rem;
            border-bottom: 1px solid #E2E8F0;
            white-space: nowrap;
        }
        .ma-table tbody td {
            padding: 0.85rem 1.05rem;
            font-size: 0.83rem;
            color: #0F172A;
            border-bottom: 1px solid #F1F5F9;
            vertical-align: middle;
        }
        .ma-table tbody tr:hover {
            background-color: #F8FAFC;
        }
        .ma-table tfoot td {
            padding: 0.9rem 1.05rem;
            font-size: 0.85rem;
            font-weight: 800;
            color: #0F172A;
            background: #F1F5F9;
            border-top: 2px solid #CBD5E1;
        }

        .ma-code-pill {
            font-family: 'Fira Code', ui-monospace, SFMono-Regular, monospace !important;
            font-size: 0.7rem;
            font-weight: 600;
            color: #4338ca;
            background: #EEF2FF;
            border: 1px solid #C7D2FE;
            padding: 2px 7px;
            border-radius: 6px;
        }
        .ma-group-tag {
            font-size: 0.69rem;
            font-weight: 700;
            color: #334155;
            background: #F1F5F9;
            padding: 2px 8px;
            border-radius: 999px;
            white-space: nowrap;
        }
        .ma-ceft-tag {
            font-size: 0.64rem;
            font-weight: 700;
            color: #92400E;
            background: #FEF3C7;
            padding: 2px 6px;
            border-radius: 999px;
            margin-left: 6px;
        }

        /* Modal Spacious Styling */
        .ma-modal-header {
            background: linear-gradient(135deg, #4f46e5 0%, #6366f1 55%, #a855f7 100%);
            color: #FFFFFF;
            padding: 1.1rem 1.5rem;
            border-bottom: none;
        }
        .ma-modal-summary {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 0.85rem;
            margin-bottom: 1rem;
        }
        @media (max-width: 768px) {
            .ma-modal-summary {
                grid-template-columns: repeat(2, 1fr);
            }
        }
        .ma-modal-stat {
            background: #F8FAFC;
            border: 1px solid #E2E8F0;
            border-radius: 12px;
            padding: 0.8rem 1rem;
        }
        .ma-modal-stat-label {
            font-size: 0.71rem;
            font-weight: 700;
            color: #64748B;
            text-transform: uppercase;
            letter-spacing: 0.04em;
        }
        .ma-modal-stat-val {
            font-size: 1.25rem;
            font-weight: 800;
            color: #0F172A;
            margin-top: 3px;
        }
        .ma-filter-bar {
            display: flex;
            flex-wrap: wrap;
            gap: 0.45rem;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 1rem;
        }
        .ma-filter-pill {
            border: 1px solid #CBD5E1;
            background: #FFFFFF;
            color: #334155;
            font-size: 0.74rem;
            font-weight: 700;
            padding: 5px 12px;
            border-radius: 999px;
            cursor: pointer;
            transition: all 0.15s ease;
        }
        .ma-filter-pill:hover {
            border-color: #6366f1;
            color: #4f46e5;
            background: #EEF2FF;
        }
        .ma-filter-pill.active {
            background: linear-gradient(135deg, #4f46e5 0%, #6366f1 100%);
            border-color: transparent;
            color: #FFFFFF;
        }
        .ma-modal-table-wrap {
            border: 1px solid #E2E8F0;
            border-radius: 12px;
            overflow: hidden;
        }
        .ma-modal-table-scroll {
            max-height: 390px;
            overflow-y: auto;
        }
        .ma-modal-table-scroll .ma-table thead th {
            position: sticky;
            top: 0;
            z-index: 2;
        }
        .ma-modal-table-scroll .ma-table tfoot td {
            position: sticky;
            bottom: 0;
            z-index: 2;
        }

        .is-loading .ma-kpi-value {
            opacity: 0.45;
            transition: opacity 0.2s ease;
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

        <div class="content" id="dashboardRoot">
            <%@include file="../jspf/topbar.jspf" %>

            <!-- Executive Header Bar -->
            <div class="ma-header-bar d-flex flex-wrap align-items-center justify-content-between gap-2 mb-3 mt-1">
                <div>
                    <h4 class="ma-header-title">My Fintrex — Mobile App Dashboard</h4>
                    <div class="ma-header-sub">Records from 2026-06-01 onwards &middot; Fintrex (OWN) &amp; JustPay (OTHER)</div>
                </div>
                <div class="d-flex flex-wrap align-items-center gap-2 position-relative" style="z-index: 2;">
                    <div class="ma-date-control d-flex align-items-center gap-2">
                        <label for="fromDate" class="mb-0 text-nowrap">From</label>
                        <input type="date" id="fromDate" min="2026-06-01" aria-label="From date">
                    </div>
                    <div class="ma-date-control d-flex align-items-center gap-2">
                        <label for="toDate" class="mb-0 text-nowrap">To</label>
                        <input type="date" id="toDate" min="2026-06-01" aria-label="To date">
                    </div>
                    <div class="ma-date-control d-flex align-items-center gap-2">
                        <label for="compareMode" class="mb-0 text-nowrap">Compare</label>
                        <select id="compareMode" aria-label="Compare mode">
                            <option value="DAY" selected>vs Prev Day</option>
                            <option value="MONTH">vs Prev Month</option>
                        </select>
                    </div>
                    <button type="button" id="refreshBtn" class="ma-btn-refresh">Refresh</button>
                </div>
            </div>

            <div class="ma-page-body">
                <!-- Error Alert -->
                <div id="errorAlert" class="alert alert-danger d-none align-items-center justify-content-between py-2 px-3 mb-0 rounded-3" role="alert">
                    <span id="errorMessage">Unable to load Mobile App dashboard data.</span>
                    <button type="button" class="btn btn-sm btn-outline-danger ms-3" onclick="loadDashboard()">Retry</button>
                </div>

                <!-- 1 Row: All 7 Small KPI Cards -->
                <div class="ma-kpi-row">
                    <div class="ma-kpi-card" style="--accent-color: #6366f1;">
                        <div class="ma-kpi-label">App Downloads / Initiated</div>
                        <div class="ma-kpi-value num-mono" id="kpiInitiated">-</div>
                        <div class="ma-kpi-meta">
                            <span id="kpiInitiatedPrev">Prev: -</span>
                            <span id="kpiInitiatedDelta" class="ma-delta ma-delta-flat">-</span>
                        </div>
                    </div>

                    <div class="ma-kpi-card" style="--accent-color: #059669;">
                        <div class="ma-kpi-label">Active Customers</div>
                        <div class="ma-kpi-value num-mono" id="kpiActive">-</div>
                        <div class="ma-kpi-meta">
                            <span id="kpiActivePrev">Prev: -</span>
                            <span id="kpiActiveDelta" class="ma-delta ma-delta-flat">-</span>
                        </div>
                    </div>

                    <div class="ma-kpi-card" style="--accent-color: #f59e0b;">
                        <div class="ma-kpi-label">Active Non-Fintrex</div>
                        <div class="ma-kpi-value num-mono" id="kpiNonFintrex">-</div>
                        <div class="ma-kpi-meta">
                            <span id="kpiNonFintrexPrev">Prev: -</span>
                            <span id="kpiNonFintrexDelta" class="ma-delta ma-delta-flat">-</span>
                        </div>
                    </div>

                    <div class="ma-kpi-card" style="--accent-color: #0284c7;">
                        <div class="d-flex align-items-center justify-content-between gap-1 mb-1">
                            <div class="ma-kpi-label mb-0">Savings Opened</div>
                            <span class="ma-sub-pill" id="kpiSavingsActivePill">Act: -</span>
                        </div>
                        <div class="ma-kpi-value num-mono" id="kpiSavings">-</div>
                        <div class="ma-kpi-meta">
                            <span id="kpiSavingsPrev">Prev: -</span>
                            <span id="kpiSavingsDelta" class="ma-delta ma-delta-flat">-</span>
                        </div>
                    </div>

                    <div class="ma-kpi-card" style="--accent-color: #8b5cf6;">
                        <div class="ma-kpi-label">Successful Txns</div>
                        <div class="ma-kpi-value num-mono" id="kpiTxnCount">-</div>
                        <div class="ma-kpi-meta">
                            <span id="kpiTxnCountPrev">Prev: -</span>
                            <span id="kpiTxnCountDelta" class="ma-delta ma-delta-flat">-</span>
                        </div>
                    </div>

                    <div class="ma-kpi-card" style="--accent-color: #10b981;">
                        <div class="ma-kpi-label">Successful Txn Value</div>
                        <div class="ma-kpi-value num-mono" id="kpiTxnValue">-</div>
                        <div class="ma-kpi-meta">
                            <span id="kpiTxnValuePrev">Prev: -</span>
                            <span id="kpiTxnValueDelta" class="ma-delta ma-delta-flat">-</span>
                        </div>
                    </div>

                    <div class="ma-kpi-card ma-kpi-ceft" style="--accent-color: #4f46e5;">
                        <div class="ma-kpi-label">Total CEFT Revenue</div>
                        <div class="ma-kpi-value num-mono" id="kpiCeftRevenue">-</div>
                        <div class="ma-kpi-meta">
                            <span id="kpiCeftRevenuePrev">Prev: -</span>
                            <span id="kpiCeftRevenueDelta" class="ma-delta ma-delta-flat">-</span>
                        </div>
                    </div>
                </div>

                <!-- Below: 2 Spacious Cards (CEFT Revenue Breakdown + 14-Day Activity Chart) -->
                <div class="ma-bottom-grid">
                    <!-- Left Card: CEFT Revenue Breakdown (4 rows, no filter tabs, Detailed View button) -->
                    <div class="ma-panel">
                        <div class="ma-panel-header">
                            <div>
                                <h6 class="ma-panel-title">CEFT Revenue Breakdown</h6>
                                <div class="ma-panel-subtitle">Calculated at LKR 25.00 per successful transaction across the 4 eligible CEFT types</div>
                            </div>
                            <button type="button" class="ma-btn-detail" id="openDetailedViewBtn">
                                Detailed View
                            </button>
                        </div>
                        <div class="table-responsive flex-grow-1 d-flex flex-column justify-content-between">
                            <table class="ma-table">
                                <thead>
                                    <tr>
                                        <th>Transaction Type</th>
                                        <th>Code</th>
                                        <th class="text-end">Success Count</th>
                                        <th class="text-end" id="ceftDiffColHeader">vs Prev Day</th>
                                        <th class="text-end">Revenue (LKR)</th>
                                    </tr>
                                </thead>
                                <tbody id="ceftTableBody">
                                    <tr><td colspan="5" class="text-center text-muted py-4">Loading...</td></tr>
                                </tbody>
                                <tfoot id="ceftTableFoot"></tfoot>
                            </table>
                        </div>
                    </div>

                    <!-- Right Card: 14-Day Daily Activity Trend Chart -->
                    <div class="ma-panel">
                        <div class="ma-panel-header">
                            <div>
                                <h6 class="ma-panel-title">14-Day Daily Activity Trend</h6>
                                <div class="ma-panel-subtitle">Successful transaction count vs. CEFT revenue (LKR)</div>
                            </div>
                        </div>
                        <div class="p-3 flex-grow-1" style="min-height: 300px; position: relative;">
                            <canvas id="dailyTrendChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<!-- Spacious Detailed View Modal: Transaction Type-Wise Breakdown -->
<div class="modal fade" id="detailedTxnModal" tabindex="-1" aria-labelledby="detailedTxnModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 16px; overflow: hidden;">
            <div class="modal-header ma-modal-header">
                <div>
                    <h5 class="modal-title fw-bold mb-0 text-white" id="detailedTxnModalLabel">Transaction Type-Wise Breakdown</h5>
                    <div style="font-size: 0.78rem; color: rgba(255,255,255,0.85);">
                        Detailed performance across all Mobile App channels &middot; OWN = Fintrex, OTHER = JustPay
                    </div>
                </div>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body p-4">
                <!-- Modal Summary Strip -->
                <div class="ma-modal-summary">
                    <div class="ma-modal-stat">
                        <div class="ma-modal-stat-label">Filtered Transactions</div>
                        <div class="ma-modal-stat-val num-mono" id="modalStatCount">-</div>
                    </div>
                    <div class="ma-modal-stat">
                        <div class="ma-modal-stat-label">Filtered Value (LKR)</div>
                        <div class="ma-modal-stat-val num-mono" id="modalStatValue">-</div>
                    </div>
                    <div class="ma-modal-stat">
                        <div class="ma-modal-stat-label">CEFT Revenue (LKR)</div>
                        <div class="ma-modal-stat-val num-mono" style="color: #4f46e5;" id="modalStatCeft">-</div>
                    </div>
                    <div class="ma-modal-stat">
                        <div class="ma-modal-stat-label">Date Range</div>
                        <div class="ma-modal-stat-val num-mono" style="font-size: 0.96rem; margin-top: 7px;" id="modalStatRange">-</div>
                    </div>
                </div>

                <!-- Category Filter Pills + Search -->
                <div class="ma-filter-bar">
                    <div class="d-flex flex-wrap gap-2" id="txnGroupFilterBar">
                        <button type="button" class="ma-filter-pill active" data-group="ALL">All</button>
                        <button type="button" class="ma-filter-pill" data-group="CEFT">CEFT Only</button>
                        <button type="button" class="ma-filter-pill" data-group="Leasing">Leasing (CR)</button>
                        <button type="button" class="ma-filter-pill" data-group="Loan Payments">Loan (MF)</button>
                        <button type="button" class="ma-filter-pill" data-group="Pawning">Pawning</button>
                        <button type="button" class="ma-filter-pill" data-group="Bill Payments">Bill (BP)</button>
                        <button type="button" class="ma-filter-pill" data-group="Fund Transfers">Fund (FT)</button>
                        <button type="button" class="ma-filter-pill" data-group="Credit Card">Credit (CC)</button>
                        <button type="button" class="ma-filter-pill" data-group="QR Payments">QR</button>
                    </div>
                    <input type="text" id="modalTxnSearch" class="form-control form-control-sm" placeholder="Search type or code..." style="max-width: 210px; border-radius: 999px; padding-left: 14px;">
                </div>

                <!-- Full-Width Spacious Transaction Breakdown Table -->
                <div class="ma-modal-table-wrap">
                    <div class="ma-modal-table-scroll">
                        <table class="ma-table">
                            <thead>
                                <tr>
                                    <th>Transaction Type</th>
                                    <th>Group</th>
                                    <th>Code</th>
                                    <th class="text-end">Count</th>
                                    <th class="text-end">Value (LKR)</th>
                                    <th class="text-end" id="txnDiffColHeader">vs Prev Day</th>
                                </tr>
                            </thead>
                            <tbody id="txnBreakdownBody"></tbody>
                            <tfoot id="txnBreakdownFoot"></tfoot>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Scripts -->
<script src="${pageContext.request.contextPath}/vendors/jquery/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/vendors/popper/popper.min.js"></script>
<script src="${pageContext.request.contextPath}/vendors/bootstrap/bootstrap.min.js"></script>
<script src="${pageContext.request.contextPath}/vendors/fontawesome/all.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/theme.js"></script>

<script>
    const DATA_FLOOR = '2026-06-01';
    let dailyTrendChart = null;
    let lastPayload = null;
    let activeTxnGroup = 'ALL';
    let detailModal = null;

    function getLocalToday() {
        const now = new Date();
        return now.getFullYear() + '-' + String(now.getMonth() + 1).padStart(2, '0') + '-' + String(now.getDate()).padStart(2, '0');
    }

    function fmtInt(val) {
        return Number(val || 0).toLocaleString('en-US', { maximumFractionDigits: 0 });
    }

    function fmtCurrency(val) {
        return Number(val || 0).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    }

    function fmtCompactLkr(val) {
        const n = Number(val || 0);
        if (Math.abs(n) >= 1e9) return 'LKR ' + (n / 1e9).toFixed(2) + ' Bn';
        if (Math.abs(n) >= 1e6) return 'LKR ' + (n / 1e6).toFixed(2) + ' Mn';
        if (Math.abs(n) >= 1e3) return 'LKR ' + (n / 1e3).toFixed(1) + ' K';
        return 'LKR ' + fmtCurrency(n);
    }

    function renderTotalDeltaBadge(elId, currentTotal, prevTotal, isCurrency) {
        const el = document.getElementById(elId);
        if (!el) return;
        const diff = Number(currentTotal || 0) - Number(prevTotal || 0);
        el.classList.remove('ma-delta-up', 'ma-delta-down', 'ma-delta-flat');

        const formatted = isCurrency ? fmtCompactLkr(Math.abs(diff)) : fmtInt(Math.abs(diff));
        if (diff > 0) {
            el.classList.add('ma-delta-up');
            el.textContent = '+' + formatted;
        } else if (diff < 0) {
            el.classList.add('ma-delta-down');
            el.textContent = '-' + formatted;
        } else {
            el.classList.add('ma-delta-flat');
            el.textContent = '0';
        }
    }

    function diffPillHtml(diffVal) {
        const d = Number(diffVal || 0);
        if (d > 0) return '<span class="ma-delta ma-delta-up">+' + fmtInt(d) + '</span>';
        if (d < 0) return '<span class="ma-delta ma-delta-down">' + fmtInt(d) + '</span>';
        return '<span class="ma-delta ma-delta-flat">0</span>';
    }

    function escapeHtml(str) {
        return String(str || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    }

    function loadDashboard() {
        let fromDate = $('#fromDate').val() || DATA_FLOOR;
        if (fromDate < DATA_FLOOR) {
            fromDate = DATA_FLOOR;
            $('#fromDate').val(DATA_FLOOR);
        }
        const toDate = $('#toDate').val() || getLocalToday();
        const compareMode = $('#compareMode').val() || 'DAY';

        $('#errorAlert').addClass('d-none').removeClass('d-flex');
        $('#refreshBtn').prop('disabled', true).text('Loading...');
        $('#dashboardRoot').addClass('is-loading');

        const qs = new URLSearchParams({ fromDate, toDate, compareMode }).toString();
        fetch('${pageContext.request.contextPath}/api/mobile-app-dashboard/summary?' + qs)
            .then(async res => {
                const body = await res.json();
                if (!res.ok || body.error) throw new Error(body.message || 'HTTP ' + res.status);
                return body;
            })
            .then(data => {
                lastPayload = data;
                const mode = data.compareMode || 'DAY';
                const shortPrev = mode === 'MONTH' ? 'Prev Mo: ' : 'Prev: ';
                const colLbl = mode === 'MONTH' ? 'vs Prev Mo' : 'vs Prev Day';

                $('#ceftDiffColHeader').text(colLbl);
                $('#txnDiffColHeader').text(colLbl);

                const c = data.customerInfo || {};
                $('#kpiInitiated').text(fmtInt(c.totalInitiated));
                $('#kpiInitiatedPrev').text(shortPrev + fmtInt(c.prevInitiated)).attr('title', 'Previous cutoff: ' + data.prevCutoffDate);
                renderTotalDeltaBadge('kpiInitiatedDelta', c.totalInitiated, c.prevInitiated, false);

                $('#kpiActive').text(fmtInt(c.totalActive));
                $('#kpiActivePrev').text(shortPrev + fmtInt(c.prevActive)).attr('title', 'Previous cutoff: ' + data.prevCutoffDate);
                renderTotalDeltaBadge('kpiActiveDelta', c.totalActive, c.prevActive, false);

                $('#kpiNonFintrex').text(fmtInt(c.totalNonFintrex));
                $('#kpiNonFintrexPrev').text(shortPrev + fmtInt(c.prevNonFintrex)).attr('title', 'Previous cutoff: ' + data.prevCutoffDate);
                renderTotalDeltaBadge('kpiNonFintrexDelta', c.totalNonFintrex, c.prevNonFintrex, false);

                $('#kpiSavings').text(fmtInt(c.totalSavings));
                $('#kpiSavingsActivePill').text('Act: ' + fmtInt(c.activeSavings)).attr('title', 'Active Savings Accounts: ' + fmtInt(c.activeSavings));
                $('#kpiSavingsPrev').text(shortPrev + fmtInt(c.prevSavings)).attr('title', 'Previous cutoff: ' + data.prevCutoffDate);
                renderTotalDeltaBadge('kpiSavingsDelta', c.totalSavings, c.prevSavings, false);

                const t = data.transactionInfo || {};
                $('#kpiTxnCount').text(fmtInt(t.totalSuccessCount));
                $('#kpiTxnCountPrev').text(shortPrev + fmtInt(t.prevSuccessCount)).attr('title', 'Previous cutoff: ' + data.prevCutoffDate);
                renderTotalDeltaBadge('kpiTxnCountDelta', t.totalSuccessCount, t.prevSuccessCount, false);

                $('#kpiTxnValue').text(fmtCompactLkr(t.totalSuccessValue)).attr('title', 'LKR ' + fmtCurrency(t.totalSuccessValue));
                $('#kpiTxnValuePrev').text(shortPrev + fmtCompactLkr(t.prevSuccessValue)).attr('title', 'Previous cutoff: ' + data.prevCutoffDate);
                renderTotalDeltaBadge('kpiTxnValueDelta', t.totalSuccessValue, t.prevSuccessValue, true);

                const ceft = data.ceftRevenue || {};
                $('#kpiCeftRevenue').text(fmtCompactLkr(ceft.totalCeftRevenue)).attr('title', 'LKR ' + fmtCurrency(ceft.totalCeftRevenue));
                $('#kpiCeftRevenuePrev').text(shortPrev + fmtCompactLkr(ceft.prevCeftRevenue)).attr('title', 'Previous cutoff: ' + data.prevCutoffDate);
                renderTotalDeltaBadge('kpiCeftRevenueDelta', ceft.totalCeftRevenue, ceft.prevCeftRevenue, true);

                renderCeftTable();
                renderDailyTrendChart(data.dailyTrend || []);
                renderTxnBreakdownModalTable();
            })
            .catch(err => {
                $('#errorMessage').text(err.message || 'Unable to load Mobile App dashboard data.');
                $('#errorAlert').removeClass('d-none').addClass('d-flex');
            })
            .finally(() => {
                $('#refreshBtn').prop('disabled', false).text('Refresh');
                $('#dashboardRoot').removeClass('is-loading');
            });
    }

    function renderCeftTable() {
        if (!lastPayload) return;
        const ceft = lastPayload.ceftRevenue || {};
        const rows = ceft.breakdown || [];

        let sumCount = 0, sumDiff = 0, sumRev = 0;
        const html = rows.map(r => {
            sumCount += Number(r.successCount || 0);
            sumDiff += Number(r.diffCount || 0);
            sumRev += Number(r.revenue || 0);
            return '<tr>' +
                '<td class="fw-semi-bold">' + escapeHtml(r.transactionType) + '</td>' +
                '<td><span class="ma-code-pill">' + escapeHtml(r.transactionCode) + '</span></td>' +
                '<td class="text-end num-mono fw-semi-bold">' + fmtInt(r.successCount) + '</td>' +
                '<td class="text-end num-mono">' + diffPillHtml(r.diffCount) + '</td>' +
                '<td class="text-end num-mono fw-bold" style="color:#4f46e5;">' + fmtCurrency(r.revenue) + '</td>' +
            '</tr>';
        }).join('');

        $('#ceftTableBody').html(html || '<tr><td colspan="5" class="text-center text-muted py-4">No CEFT transactions found</td></tr>');
        $('#ceftTableFoot').html(
            '<tr>' +
                '<td colspan="2">Total CEFT Revenue</td>' +
                '<td class="text-end num-mono">' + fmtInt(sumCount) + '</td>' +
                '<td class="text-end num-mono">' + diffPillHtml(sumDiff) + '</td>' +
                '<td class="text-end num-mono" style="color:#4f46e5;">LKR ' + fmtCurrency(sumRev) + '</td>' +
            '</tr>'
        );
    }

    function renderTxnBreakdownModalTable() {
        if (!lastPayload) return;
        let list = lastPayload.transactionBreakdown || [];
        if (activeTxnGroup === 'CEFT') {
            list = list.filter(i => i.isCeft);
        } else if (activeTxnGroup !== 'ALL') {
            list = list.filter(i => i.group === activeTxnGroup);
        }

        const q = ($('#modalTxnSearch').val() || '').trim().toLowerCase();
        if (q) {
            list = list.filter(i =>
                (i.displayName || '').toLowerCase().includes(q) ||
                (i.txnCode || '').toLowerCase().includes(q) ||
                (i.group || '').toLowerCase().includes(q)
            );
        }

        let sumCount = 0, sumVal = 0, sumDiff = 0, sumCeft = 0;
        list.forEach(item => {
            sumCount += Number(item.totalCount || 0);
            sumVal += Number(item.totalValue || 0);
            sumDiff += Number(item.diffCount || 0);
            sumCeft += Number(item.ceftRevenue || 0);
        });

        $('#modalStatCount').text(fmtInt(sumCount));
        $('#modalStatValue').text('LKR ' + fmtCurrency(sumVal));
        $('#modalStatCeft').text('LKR ' + fmtCurrency(sumCeft));
        $('#modalStatRange').text(lastPayload.fromDate + ' → ' + lastPayload.toDate);

        if (!list.length) {
            $('#txnBreakdownBody').html('<tr><td colspan="6" class="text-center text-muted py-4">No transactions match this filter.</td></tr>');
            $('#txnBreakdownFoot').empty();
            return;
        }

        const html = list.map(item => {
            const ceftTag = item.isCeft ? '<span class="ma-ceft-tag">CEFT</span>' : '';
            return '<tr>' +
                '<td class="fw-semi-bold">' + escapeHtml(item.displayName) + ceftTag + '</td>' +
                '<td><span class="ma-group-tag">' + escapeHtml(item.group) + '</span></td>' +
                '<td><span class="ma-code-pill">' + escapeHtml(item.txnCode) + '</span></td>' +
                '<td class="text-end num-mono">' + fmtInt(item.totalCount) + '</td>' +
                '<td class="text-end num-mono fw-semi-bold">' + fmtCurrency(item.totalValue) + '</td>' +
                '<td class="text-end num-mono">' + diffPillHtml(item.diffCount) + '</td>' +
            '</tr>';
        }).join('');

        $('#txnBreakdownBody').html(html);
        $('#txnBreakdownFoot').html(
            '<tr>' +
                '<td colspan="3">Total (' + escapeHtml(activeTxnGroup) + ')</td>' +
                '<td class="text-end num-mono">' + fmtInt(sumCount) + '</td>' +
                '<td class="text-end num-mono">' + fmtCurrency(sumVal) + '</td>' +
                '<td class="text-end num-mono">' + diffPillHtml(sumDiff) + '</td>' +
            '</tr>'
        );
    }

    function renderDailyTrendChart(trend) {
        const ctx = document.getElementById('dailyTrendChart');
        if (dailyTrendChart) dailyTrendChart.destroy();

        dailyTrendChart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: trend.map(d => d.date.slice(5)),
                datasets: [
                    {
                        label: 'Successful Txns',
                        data: trend.map(d => Number(d.txnCount || 0)),
                        backgroundColor: 'rgba(99, 102, 241, 0.8)',
                        hoverBackgroundColor: '#4f46e5',
                        borderRadius: 6,
                        yAxisID: 'y'
                    },
                    {
                        label: 'CEFT Revenue (LKR)',
                        data: trend.map(d => Number(d.ceftRevenue || 0)),
                        type: 'line',
                        borderColor: '#F59E0B',
                        backgroundColor: 'rgba(245, 158, 11, 0.14)',
                        fill: true,
                        borderWidth: 2.5,
                        tension: 0.35,
                        pointRadius: 3.5,
                        pointBackgroundColor: '#F59E0B',
                        yAxisID: 'y1'
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                interaction: { mode: 'index', intersect: false },
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: { boxWidth: 12, usePointStyle: true, padding: 14, font: { family: 'Plus Jakarta Sans', size: 11, weight: '600' } }
                    }
                },
                scales: {
                    x: { grid: { display: false }, ticks: { color: '#475569', font: { size: 11 } } },
                    y: { beginAtZero: true, position: 'left', grid: { color: '#F1F5F9' }, ticks: { color: '#475569' }, title: { display: true, text: 'Txns', color: '#475569', font: { size: 11, weight: '600' } } },
                    y1: { beginAtZero: true, position: 'right', grid: { drawOnChartArea: false }, ticks: { color: '#475569' }, title: { display: true, text: 'LKR', color: '#475569', font: { size: 11, weight: '600' } } }
                }
            }
        });
    }

    $(document).ready(function () {
        $('#fromDate').val(DATA_FLOOR);
        $('#toDate').val(getLocalToday());

        $('#fromDate, #toDate, #compareMode').on('change', loadDashboard);
        $('#refreshBtn').on('click', loadDashboard);

        const modalEl = document.getElementById('detailedTxnModal');
        detailModal = new bootstrap.Modal(modalEl);

        $('#openDetailedViewBtn').on('click', function () {
            renderTxnBreakdownModalTable();
            detailModal.show();
        });

        $('#txnGroupFilterBar').on('click', '.ma-filter-pill', function () {
            $('#txnGroupFilterBar .ma-filter-pill').removeClass('active');
            $(this).addClass('active');
            activeTxnGroup = $(this).data('group');
            renderTxnBreakdownModalTable();
        });

        $('#modalTxnSearch').on('input', renderTxnBreakdownModalTable);

        loadDashboard();
    });
</script>
</body>
</html>
