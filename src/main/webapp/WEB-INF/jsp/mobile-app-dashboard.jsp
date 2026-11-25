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
            --ma-amber: #f59e0b;
            --ma-emerald: #10b981;
            --ma-surface: #FFFFFF;
            --ma-bg: #F8FAFC;
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

        /* Hero Header Banner */
        .ma-header-bar {
            flex: 0 0 auto;
            flex-shrink: 0;
            background: linear-gradient(135deg, #4f46e5 0%, #6366f1 50%, #a855f7 100%);
            border-radius: 14px;
            padding: 1.15rem 1.5rem;
            color: #FFFFFF;
            box-shadow: 0 10px 26px -8px rgba(99, 102, 241, 0.38);
            position: relative;
            overflow: hidden;
        }
        .ma-scroll-body {
            flex: 1 1 auto;
            min-height: 0;
            overflow-y: auto;
            overflow-x: hidden;
            padding: 2px 4px 16px 2px;
        }
        .ma-header-bar::after {
            content: "";
            position: absolute;
            top: -55%;
            right: -6%;
            width: 320px;
            height: 320px;
            border-radius: 50%;
            background: radial-gradient(circle, rgba(255, 255, 255, 0.16) 0%, rgba(168, 85, 247, 0) 70%);
            pointer-events: none;
        }
        .ma-header-title {
            font-size: 1.35rem;
            font-weight: 800;
            color: #FFFFFF;
            letter-spacing: -0.025em;
            margin: 0;
        }
        .ma-header-sub {
            font-size: 0.82rem;
            color: rgba(255, 255, 255, 0.82);
            margin-top: 0.2rem;
        }
        .ma-date-control {
            background: rgba(255, 255, 255, 0.14);
            border: 1px solid rgba(255, 255, 255, 0.25);
            border-radius: 10px;
            padding: 0.35rem 0.75rem;
            backdrop-filter: blur(8px);
        }
        .ma-date-control label {
            color: rgba(255, 255, 255, 0.85);
            font-size: 0.76rem;
            font-weight: 600;
        }
        .ma-date-control input[type="date"] {
            background: transparent;
            border: none;
            color: #FFFFFF;
            font-weight: 600;
            font-size: 0.84rem;
            outline: none;
            cursor: pointer;
            color-scheme: dark;
        }
        .ma-btn-refresh {
            background: #FFFFFF;
            color: #4f46e5;
            border: none;
            border-radius: 10px;
            font-weight: 700;
            font-size: 0.82rem;
            padding: 0.5rem 1.05rem;
            cursor: pointer;
            transition: background-color 0.2s ease, box-shadow 0.2s ease, color 0.2s ease;
            box-shadow: 0 4px 12px rgba(15, 23, 42, 0.14);
        }
        .ma-btn-refresh:hover {
            background: #EEF2FF;
            color: #4338ca;
            box-shadow: 0 6px 16px rgba(15, 23, 42, 0.2);
        }
        .ma-btn-refresh:disabled {
            opacity: 0.65;
            cursor: not-allowed;
        }

        /* Section Headings */
        .ma-section-label {
            display: flex;
            align-items: center;
            gap: 0.6rem;
            font-size: 0.74rem;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            color: #475569;
            margin-bottom: 0.75rem;
        }
        .ma-section-label::before {
            content: "";
            width: 18px;
            height: 3px;
            border-radius: 99px;
            background: linear-gradient(90deg, #6366f1, #a855f7);
        }

        /* KPI Cards (Icon-Free, Typographic Precision) */
        .ma-kpi-card {
            background: var(--ma-surface);
            border: 1px solid var(--ma-border);
            border-radius: 14px;
            padding: 1.2rem 1.3rem;
            height: 100%;
            position: relative;
            overflow: hidden;
            transition: border-color 0.2s ease, box-shadow 0.2s ease;
            box-shadow: 0 1px 3px rgba(15, 23, 42, 0.04);
        }
        .ma-kpi-card::before {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 3px;
            background: var(--accent-color, #1E40AF);
        }
        .ma-kpi-card:hover {
            border-color: #CBD5E1;
            box-shadow: 0 10px 24px -10px rgba(15, 23, 42, 0.12);
        }
        .ma-kpi-label {
            font-size: 0.78rem;
            font-weight: 600;
            color: var(--ma-muted);
            margin-bottom: 0.45rem;
        }
        .ma-kpi-value {
            font-size: 1.85rem;
            font-weight: 800;
            color: var(--ma-text);
            line-height: 1.1;
            font-variant-numeric: tabular-nums;
            letter-spacing: -0.03em;
        }
        .ma-kpi-meta {
            margin-top: 0.65rem;
            padding-top: 0.6rem;
            border-top: 1px solid #F1F5F9;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 0.5rem;
            flex-wrap: wrap;
            font-size: 0.76rem;
            color: var(--ma-muted);
        }
        .ma-sub-pill {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 2px 8px;
            border-radius: 999px;
            font-size: 0.72rem;
            font-weight: 700;
            background: rgba(5, 150, 105, 0.1);
            color: #047857;
        }

        /* Highlight CEFT Revenue Card */
        .ma-kpi-ceft {
            background: linear-gradient(145deg, #EEF2FF 0%, #FFFFFF 68%);
            border: 1px solid #C7D2FE;
        }
        .ma-kpi-ceft .ma-kpi-value {
            color: #4f46e5;
        }

        /* Delta Badges */
        .ma-delta {
            display: inline-flex;
            align-items: center;
            font-size: 0.72rem;
            font-weight: 700;
            padding: 2px 8px;
            border-radius: 999px;
            white-space: nowrap;
            font-variant-numeric: tabular-nums;
        }
        .ma-delta-up {
            background: #DCFCE7;
            color: #166534;
        }
        .ma-delta-down {
            background: #FEE2E2;
            color: #991B1B;
        }
        .ma-delta-flat {
            background: #F1F5F9;
            color: #475569;
        }

        /* Data Panels & Tables */
        .ma-panel {
            background: var(--ma-surface);
            border: 1px solid var(--ma-border);
            border-radius: 14px;
            box-shadow: 0 1px 3px rgba(15, 23, 42, 0.04);
            overflow: hidden;
        }
        .ma-panel-header {
            padding: 1rem 1.3rem;
            border-bottom: 1px solid #F1F5F9;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 0.75rem;
            flex-wrap: wrap;
        }
        .ma-panel-title {
            font-size: 0.96rem;
            font-weight: 700;
            color: var(--ma-text);
            margin: 0;
        }
        .ma-panel-subtitle {
            font-size: 0.77rem;
            color: var(--ma-muted);
            margin-top: 0.15rem;
        }
        .ma-rate-tag {
            font-size: 0.73rem;
            font-weight: 700;
            color: #92400E;
            background: #FEF3C7;
            border: 1px solid #FDE68A;
            padding: 4px 10px;
            border-radius: 999px;
            white-space: nowrap;
        }

        .ma-table {
            width: 100%;
            margin-bottom: 0;
            border-collapse: collapse;
        }
        .ma-table thead th {
            background: #F8FAFC;
            color: #475569;
            font-size: 0.71rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            padding: 0.75rem 1rem;
            border-bottom: 1px solid #E2E8F0;
            white-space: nowrap;
        }
        .ma-table tbody td {
            padding: 0.78rem 1rem;
            font-size: 0.83rem;
            color: #0F172A;
            border-bottom: 1px solid #F1F5F9;
            vertical-align: middle;
        }
        .ma-table tbody tr {
            transition: background-color 0.15s ease;
        }
        .ma-table tbody tr:hover {
            background-color: #F8FAFC;
        }
        .ma-table tfoot td {
            padding: 0.85rem 1rem;
            font-size: 0.85rem;
            font-weight: 800;
            color: #0F172A;
            background: #F1F5F9;
            border-top: 2px solid #CBD5E1;
        }

        .ma-code-pill {
            font-family: 'Fira Code', ui-monospace, SFMono-Regular, monospace !important;
            font-size: 0.71rem;
            font-weight: 600;
            color: #1E3A8A;
            background: #EFF6FF;
            border: 1px solid #DBEAFE;
            padding: 2px 7px;
            border-radius: 6px;
        }
        .ma-ceft-tag {
            font-size: 0.66rem;
            font-weight: 700;
            color: #92400E;
            background: #FEF3C7;
            padding: 2px 6px;
            border-radius: 999px;
            margin-left: 6px;
            vertical-align: middle;
        }

        /* Loading shimmer state */
        .is-loading .ma-kpi-value {
            opacity: 0.45;
            transition: opacity 0.2s ease;
        }

        @media (prefers-reduced-motion: reduce) {
            *, *::before, *::after {
                transition: none !important;
                animation: none !important;
            }
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

            <!-- Clean Executive Header -->
            <div class="ma-header-bar d-flex flex-wrap align-items-center justify-content-between gap-3 mb-3 mt-2">
                <div>
                    <h4 class="ma-header-title">My Fintrex — Mobile App Dashboard</h4>
                    <div class="ma-header-sub">Real-time customer adoption, transaction volume, and CEFT revenue analytics</div>
                </div>
                <div class="d-flex align-items-center gap-2 position-relative" style="z-index: 2;">
                    <div class="ma-date-control d-flex align-items-center gap-2">
                        <label for="asAtDate" class="mb-0 text-nowrap">As at</label>
                        <input type="date" id="asAtDate" aria-label="As at date">
                    </div>
                    <button type="button" id="refreshBtn" class="ma-btn-refresh">
                        Refresh
                    </button>
                </div>
            </div>

            <div class="ma-scroll-body">
            <!-- Error Alert -->
            <div id="errorAlert" class="alert alert-danger d-none align-items-center justify-content-between mb-4 rounded-3" role="alert">
                <span id="errorMessage">Unable to load Mobile App dashboard data.</span>
                <button type="button" class="btn btn-sm btn-outline-danger ms-3" onclick="loadDashboard()">Retry</button>
            </div>

            <!-- Section 1: Customer & App Information -->
            <div class="ma-section-label">Customer &amp; App Overview</div>
            <div class="row g-3 mb-4">
                <div class="col-12 col-sm-6 col-xl-3">
                    <div class="ma-kpi-card" style="--accent-color: #6366f1;">
                        <div class="ma-kpi-label">Total App Downloads / Initiated</div>
                        <div class="ma-kpi-value num-mono" id="kpiInitiated">-</div>
                        <div class="ma-kpi-meta">
                            <span id="kpiInitiatedToday">Day: -</span>
                            <span id="kpiInitiatedDelta" class="ma-delta ma-delta-flat">-</span>
                        </div>
                    </div>
                </div>
                <div class="col-12 col-sm-6 col-xl-3">
                    <div class="ma-kpi-card" style="--accent-color: #059669;">
                        <div class="ma-kpi-label">Total Active Customers</div>
                        <div class="ma-kpi-value num-mono" id="kpiActive">-</div>
                        <div class="ma-kpi-meta">
                            <span id="kpiActiveToday">Day: -</span>
                            <span id="kpiActiveDelta" class="ma-delta ma-delta-flat">-</span>
                        </div>
                    </div>
                </div>
                <div class="col-12 col-sm-6 col-xl-3">
                    <div class="ma-kpi-card" style="--accent-color: #F59E0B;">
                        <div class="ma-kpi-label">Non-Fintrex Users</div>
                        <div class="ma-kpi-value num-mono" id="kpiNonFintrex">-</div>
                        <div class="ma-kpi-meta">
                            <span id="kpiNonFintrexToday">Day: -</span>
                            <span id="kpiNonFintrexDelta" class="ma-delta ma-delta-flat">-</span>
                        </div>
                    </div>
                </div>
                <div class="col-12 col-sm-6 col-xl-3">
                    <div class="ma-kpi-card" style="--accent-color: #0284C7;">
                        <div class="d-flex align-items-center justify-content-between gap-2 mb-1">
                            <div class="ma-kpi-label mb-0">Savings Accounts Opened</div>
                            <span class="ma-sub-pill" id="kpiSavingsActivePill">Active: -</span>
                        </div>
                        <div class="ma-kpi-value num-mono" id="kpiSavings">-</div>
                        <div class="ma-kpi-meta">
                            <span id="kpiSavingsToday">Day: -</span>
                            <span id="kpiSavingsDelta" class="ma-delta ma-delta-flat">-</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Section 2: Transactions & CEFT Revenue Summary -->
            <div class="ma-section-label">Transactions &amp; CEFT Revenue</div>
            <div class="row g-3 mb-4">
                <div class="col-12 col-md-4">
                    <div class="ma-kpi-card" style="--accent-color: #8b5cf6;">
                        <div class="ma-kpi-label">Total Successful Transactions</div>
                        <div class="ma-kpi-value num-mono" id="kpiTxnCount">-</div>
                        <div class="ma-kpi-meta">
                            <span id="kpiTxnCountToday">Day: -</span>
                            <span id="kpiTxnCountDelta" class="ma-delta ma-delta-flat">-</span>
                        </div>
                    </div>
                </div>
                <div class="col-12 col-md-4">
                    <div class="ma-kpi-card" style="--accent-color: #059669;">
                        <div class="ma-kpi-label">Total Successful Transaction Value</div>
                        <div class="ma-kpi-value num-mono" id="kpiTxnValue">-</div>
                        <div class="ma-kpi-meta">
                            <span id="kpiTxnValueToday">Day: -</span>
                            <span id="kpiTxnValueDelta" class="ma-delta ma-delta-flat">-</span>
                        </div>
                    </div>
                </div>
                <div class="col-12 col-md-4">
                    <div class="ma-kpi-card ma-kpi-ceft" style="--accent-color: #6366f1;">
                        <div class="ma-kpi-label">Total CEFT Revenue</div>
                        <div class="ma-kpi-value num-mono" id="kpiCeftRevenue">-</div>
                        <div class="ma-kpi-meta">
                            <span id="kpiCeftRevenueToday">Day: -</span>
                            <span id="kpiCeftRevenueDelta" class="ma-delta ma-delta-flat">-</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Section 3: CEFT Revenue Breakdown & 14-Day Trend -->
            <div class="row g-3 mb-4">
                <div class="col-12 col-xl-7">
                    <div class="ma-panel h-100">
                        <div class="ma-panel-header">
                            <div>
                                <h6 class="ma-panel-title">CEFT Revenue Breakdown</h6>
                                <div class="ma-panel-subtitle">Automatic revenue calculation across the 4 eligible CEFT transaction types</div>
                            </div>
                            <span class="ma-rate-tag">LKR 25.00 / Successful Txn</span>
                        </div>
                        <div class="table-responsive">
                            <table class="ma-table">
                                <thead>
                                    <tr>
                                        <th>Transaction Type</th>
                                        <th>Code</th>
                                        <th class="text-end">Success Count</th>
                                        <th class="text-end">Daily Movement</th>
                                        <th class="text-end">Fee (LKR)</th>
                                        <th class="text-end">Revenue (LKR)</th>
                                    </tr>
                                </thead>
                                <tbody id="ceftTableBody">
                                    <tr><td colspan="6" class="text-center text-muted py-4">Loading...</td></tr>
                                </tbody>
                                <tfoot id="ceftTableFoot"></tfoot>
                            </table>
                        </div>
                    </div>
                </div>
                <div class="col-12 col-xl-5">
                    <div class="ma-panel h-100 d-flex flex-column">
                        <div class="ma-panel-header">
                            <div>
                                <h6 class="ma-panel-title">14-Day Activity Trend</h6>
                                <div class="ma-panel-subtitle">Daily successful transaction count vs. CEFT revenue (LKR)</div>
                            </div>
                        </div>
                        <div class="p-3 flex-grow-1" style="min-height: 265px; position: relative;">
                            <canvas id="dailyTrendChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Section 4: Transaction Type-Wise Breakdown -->
            <div class="row g-3 mb-4">
                <div class="col-12 col-xl-7">
                    <div class="ma-panel h-100">
                        <div class="ma-panel-header">
                            <div>
                                <h6 class="ma-panel-title">Transaction Type-Wise Breakdown</h6>
                                <div class="ma-panel-subtitle">Cumulative and daily successful transaction counts and values</div>
                            </div>
                        </div>
                        <div class="table-responsive">
                            <table class="ma-table">
                                <thead>
                                    <tr>
                                        <th>Transaction Type</th>
                                        <th>Code</th>
                                        <th class="text-end">Total Count</th>
                                        <th class="text-end">Total Value (LKR)</th>
                                        <th class="text-end">Day Count</th>
                                        <th class="text-end">Day Value (LKR)</th>
                                        <th class="text-end">vs Prev Day</th>
                                    </tr>
                                </thead>
                                <tbody id="txnBreakdownBody">
                                    <tr><td colspan="7" class="text-center text-muted py-4">Loading...</td></tr>
                                </tbody>
                                <tfoot id="txnBreakdownFoot"></tfoot>
                            </table>
                        </div>
                    </div>
                </div>
                <div class="col-12 col-xl-5">
                    <div class="ma-panel h-100 d-flex flex-column">
                        <div class="ma-panel-header">
                            <div>
                                <h6 class="ma-panel-title">Transaction Value by Type</h6>
                                <div class="ma-panel-subtitle">Top transaction categories by cumulative successful value (LKR)</div>
                            </div>
                        </div>
                        <div class="p-3 flex-grow-1" style="min-height: 310px; position: relative;">
                            <canvas id="txnTypeChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>

            </div><!-- /.ma-scroll-body -->
        </div>
    </div>
</main>

<!-- Scripts -->
<script src="${pageContext.request.contextPath}/vendors/jquery/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/vendors/popper/popper.min.js"></script>
<script src="${pageContext.request.contextPath}/vendors/bootstrap/bootstrap.min.js"></script>
<script src="${pageContext.request.contextPath}/vendors/fontawesome/all.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/theme.js"></script>

<script>
    let dailyTrendChart = null;
    let txnTypeChart = null;

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
        return 'LKR ' + fmtCurrency(n);
    }

    function renderDeltaBadge(elId, todayVal, prevVal, isCurrency) {
        const el = document.getElementById(elId);
        if (!el) return;
        const diff = Number(todayVal || 0) - Number(prevVal || 0);
        el.classList.remove('ma-delta-up', 'ma-delta-down', 'ma-delta-flat');

        const formattedDiff = isCurrency ? fmtCurrency(Math.abs(diff)) : fmtInt(Math.abs(diff));
        if (diff > 0) {
            el.classList.add('ma-delta-up');
            el.textContent = '+' + formattedDiff + ' vs prev';
        } else if (diff < 0) {
            el.classList.add('ma-delta-down');
            el.textContent = '-' + formattedDiff + ' vs prev';
        } else {
            el.classList.add('ma-delta-flat');
            el.textContent = '0 vs prev';
        }
    }

    function deltaPillHtml(todayVal, prevVal) {
        const diff = Number(todayVal || 0) - Number(prevVal || 0);
        if (diff > 0) return '<span class="ma-delta ma-delta-up">+' + fmtInt(diff) + '</span>';
        if (diff < 0) return '<span class="ma-delta ma-delta-down">' + fmtInt(diff) + '</span>';
        return '<span class="ma-delta ma-delta-flat">0</span>';
    }

    function escapeHtml(str) {
        return String(str || '')
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;');
    }

    function loadDashboard() {
        const asAt = $('#asAtDate').val() || getLocalToday();
        $('#errorAlert').addClass('d-none').removeClass('d-flex');
        $('#refreshBtn').prop('disabled', true).text('Loading...');
        $('#dashboardRoot').addClass('is-loading');

        fetch('${pageContext.request.contextPath}/api/mobile-app-dashboard/summary?asAt=' + encodeURIComponent(asAt))
            .then(async res => {
                const body = await res.json();
                if (!res.ok || body.error) {
                    throw new Error(body.message || 'HTTP ' + res.status);
                }
                return body;
            })
            .then(data => {
                const c = data.customerInfo || {};
                $('#kpiInitiated').text(fmtInt(c.totalInitiated));
                $('#kpiInitiatedToday').text(data.asAtDate + ': +' + fmtInt(c.initiatedToday));
                renderDeltaBadge('kpiInitiatedDelta', c.initiatedToday, c.initiatedPrev, false);

                $('#kpiActive').text(fmtInt(c.totalActive));
                $('#kpiActiveToday').text(data.asAtDate + ': +' + fmtInt(c.activeToday));
                renderDeltaBadge('kpiActiveDelta', c.activeToday, c.activePrev, false);

                $('#kpiNonFintrex').text(fmtInt(c.totalNonFintrex));
                $('#kpiNonFintrexToday').text(data.asAtDate + ': +' + fmtInt(c.nonFintrexToday));
                renderDeltaBadge('kpiNonFintrexDelta', c.nonFintrexToday, c.nonFintrexPrev, false);

                $('#kpiSavings').text(fmtInt(c.totalSavings));
                $('#kpiSavingsActivePill').text('Active: ' + fmtInt(c.activeSavings));
                $('#kpiSavingsToday').text(data.asAtDate + ': +' + fmtInt(c.savingsToday));
                renderDeltaBadge('kpiSavingsDelta', c.savingsToday, c.savingsPrev, false);

                const t = data.transactionInfo || {};
                $('#kpiTxnCount').text(fmtInt(t.totalSuccessCount));
                $('#kpiTxnCountToday').text(data.asAtDate + ': ' + fmtInt(t.todaySuccessCount));
                renderDeltaBadge('kpiTxnCountDelta', t.todaySuccessCount, t.prevSuccessCount, false);

                $('#kpiTxnValue').text(fmtCompactLkr(t.totalSuccessValue)).attr('title', 'LKR ' + fmtCurrency(t.totalSuccessValue));
                $('#kpiTxnValueToday').text(data.asAtDate + ': ' + fmtCompactLkr(t.todaySuccessValue));
                renderDeltaBadge('kpiTxnValueDelta', t.todaySuccessValue, t.prevSuccessValue, true);

                const ceft = data.ceftRevenue || {};
                $('#kpiCeftRevenue').text('LKR ' + fmtCurrency(ceft.totalCeftRevenue));
                $('#kpiCeftRevenueToday').text(data.asAtDate + ': LKR ' + fmtCurrency(ceft.todayCeftRevenue) + ' (' + fmtInt(ceft.todayCeftCount) + ' txns)');
                renderDeltaBadge('kpiCeftRevenueDelta', ceft.todayCeftRevenue, ceft.prevCeftRevenue, true);

                renderCeftTable(ceft);
                renderTxnBreakdownTable(data.transactionBreakdown || [], t);
                renderDailyTrendChart(data.dailyTrend || []);
                renderTxnTypeChart(data.transactionBreakdown || []);
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

    function renderCeftTable(ceft) {
        const rows = ceft.breakdown || [];
        let html = '';
        rows.forEach(r => {
            html += '<tr>' +
                '<td class="fw-semi-bold">' + escapeHtml(r.transactionType) + '</td>' +
                '<td><span class="ma-code-pill">' + escapeHtml(r.transactionCode) + '</span></td>' +
                '<td class="text-end num-mono fw-semi-bold">' + fmtInt(r.successCount) + '</td>' +
                '<td class="text-end num-mono">' + fmtInt(r.todayCount) + ' ' + deltaPillHtml(r.todayCount, r.prevCount) + '</td>' +
                '<td class="text-end num-mono text-muted">' + fmtCurrency(r.feePerTxn) + '</td>' +
                '<td class="text-end num-mono fw-bold" style="color:#4f46e5;">' + fmtCurrency(r.revenue) + '</td>' +
            '</tr>';
        });
        $('#ceftTableBody').html(html || '<tr><td colspan="6" class="text-center text-muted py-4">No CEFT transactions found</td></tr>');

        $('#ceftTableFoot').html(
            '<tr>' +
                '<td colspan="2">Total CEFT Revenue</td>' +
                '<td class="text-end num-mono">' + fmtInt(ceft.totalCeftCount) + '</td>' +
                '<td class="text-end num-mono">' + fmtInt(ceft.todayCeftCount) + ' ' + deltaPillHtml(ceft.todayCeftCount, ceft.prevCeftCount) + '</td>' +
                '<td class="text-end num-mono text-muted">' + fmtCurrency(ceft.feePerTxn || 25) + '</td>' +
                '<td class="text-end num-mono" style="color:#4f46e5;">LKR ' + fmtCurrency(ceft.totalCeftRevenue) + '</td>' +
            '</tr>'
        );
    }

    function renderTxnBreakdownTable(list, totals) {
        if (!list.length) {
            $('#txnBreakdownBody').html('<tr><td colspan="7" class="text-center text-muted py-4">No successful transactions found for the selected date.</td></tr>');
            $('#txnBreakdownFoot').empty();
            return;
        }
        let html = '';
        list.forEach(item => {
            const ceftTag = item.isCeft ? '<span class="ma-ceft-tag">CEFT</span>' : '';
            html += '<tr>' +
                '<td class="fw-semi-bold">' + escapeHtml(item.displayName) + ceftTag + '</td>' +
                '<td><span class="ma-code-pill">' + escapeHtml(item.txnCode) + '</span></td>' +
                '<td class="text-end num-mono">' + fmtInt(item.totalCount) + '</td>' +
                '<td class="text-end num-mono fw-semi-bold">' + fmtCurrency(item.totalValue) + '</td>' +
                '<td class="text-end num-mono">' + fmtInt(item.todayCount) + '</td>' +
                '<td class="text-end num-mono">' + fmtCurrency(item.todayValue) + '</td>' +
                '<td class="text-end num-mono">' + deltaPillHtml(item.todayCount, item.prevCount) + '</td>' +
            '</tr>';
        });
        $('#txnBreakdownBody').html(html);

        $('#txnBreakdownFoot').html(
            '<tr>' +
                '<td colspan="2">Total</td>' +
                '<td class="text-end num-mono">' + fmtInt(totals.totalSuccessCount) + '</td>' +
                '<td class="text-end num-mono">' + fmtCurrency(totals.totalSuccessValue) + '</td>' +
                '<td class="text-end num-mono">' + fmtInt(totals.todaySuccessCount) + '</td>' +
                '<td class="text-end num-mono">' + fmtCurrency(totals.todaySuccessValue) + '</td>' +
                '<td class="text-end num-mono">' + deltaPillHtml(totals.todaySuccessCount, totals.prevSuccessCount) + '</td>' +
            '</tr>'
        );
    }

    function renderDailyTrendChart(trend) {
        const ctx = document.getElementById('dailyTrendChart');
        if (dailyTrendChart) dailyTrendChart.destroy();

        const labels = trend.map(d => d.date.slice(5));
        const counts = trend.map(d => Number(d.txnCount || 0));
        const ceftRev = trend.map(d => Number(d.ceftRevenue || 0));

        dailyTrendChart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [
                    {
                        label: 'Successful Txns',
                        data: counts,
                        backgroundColor: 'rgba(99, 102, 241, 0.78)',
                        hoverBackgroundColor: '#4f46e5',
                        borderRadius: 6,
                        yAxisID: 'y'
                    },
                    {
                        label: 'CEFT Revenue (LKR)',
                        data: ceftRev,
                        type: 'line',
                        borderColor: '#F59E0B',
                        backgroundColor: 'rgba(245, 158, 11, 0.16)',
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
                        labels: { boxWidth: 12, usePointStyle: true, padding: 16, font: { family: 'Plus Jakarta Sans', size: 11, weight: '600' } }
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

    function renderTxnTypeChart(list) {
        const ctx = document.getElementById('txnTypeChart');
        if (txnTypeChart) txnTypeChart.destroy();

        const top = list.slice(0, 8);
        const labels = top.map(i => i.displayName);
        const values = top.map(i => Number(i.totalValue || 0));

        txnTypeChart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Value (LKR)',
                    data: values,
                    backgroundColor: top.map(i => i.isCeft ? '#6366f1' : '#a855f7'),
                    borderRadius: 6,
                    barThickness: 18
                }]
            },
            options: {
                indexAxis: 'y',
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        callbacks: {
                            label: ctx => 'LKR ' + fmtCurrency(ctx.parsed.x)
                        }
                    }
                },
                scales: {
                    y: { grid: { display: false }, ticks: { color: '#0F172A', font: { size: 11, weight: '600' } } },
                    x: {
                        beginAtZero: true,
                        grid: { color: '#F1F5F9' },
                        ticks: {
                            color: '#475569',
                            callback: v => v >= 1e6 ? (v / 1e6).toFixed(1) + 'M' : (v >= 1e3 ? (v / 1e3).toFixed(0) + 'K' : v)
                        }
                    }
                }
            }
        });
    }

    $(document).ready(function() {
        $('#asAtDate').val(getLocalToday());
        $('#asAtDate').on('change', loadDashboard);
        $('#refreshBtn').on('click', loadDashboard);
        loadDashboard();
    });
</script>
</body>
</html>
