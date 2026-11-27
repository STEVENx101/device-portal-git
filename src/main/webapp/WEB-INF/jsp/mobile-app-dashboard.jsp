<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en-US" dir="ltr">

<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Fintrex | Mobile App Executive Dashboard</title>

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
    <link href="https://fonts.googleapis.com/css2?family=Fira+Code:wght@500;600&family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
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
            --bx-primary: #4f46e5;
            --bx-indigo: #6366f1;
            --bx-purple: #a855f7;
            --bx-emerald: #10b981;
            --bx-amber: #f59e0b;
            --bx-bg: #f4f6fb;
            --bx-card: #ffffff;
            --bx-border: #e5e9f2;
            --bx-text: #0f172a;
            --bx-muted: #64748b;
        }

        body, .main, p, div, span, select, input, button, table, h1, h2, h3, h4, h5, h6 {
            font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, sans-serif !important;
        }

        .num {
            font-variant-numeric: tabular-nums;
            letter-spacing: -0.025em;
        }

        /* Airy Floating Top Toolbar */
        .bx-topbar {
            flex: 0 0 auto;
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            justify-content: space-between;
            gap: 0.75rem;
            padding: 0.45rem 0.2rem 0.75rem 0.2rem;
        }
        .bx-title {
            font-size: 1.32rem;
            font-weight: 800;
            color: var(--bx-text);
            letter-spacing: -0.03em;
            margin: 0;
            line-height: 1.15;
        }
        .bx-subtitle {
            font-size: 0.78rem;
            color: var(--bx-muted);
            margin-top: 2px;
        }

        .bx-controls {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 0.5rem;
            background: var(--bx-card);
            border: 1px solid var(--bx-border);
            border-radius: 14px;
            padding: 0.38rem 0.5rem;
            box-shadow: 0 2px 10px rgba(15, 23, 42, 0.04);
        }
        .bx-date-pill {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 10px;
            padding: 0.28rem 0.65rem;
        }
        .bx-date-pill label {
            font-size: 0.71rem;
            font-weight: 700;
            color: var(--bx-muted);
            margin: 0;
        }
        .bx-date-pill input[type="date"] {
            border: none;
            background: transparent;
            font-size: 0.79rem;
            font-weight: 700;
            color: var(--bx-text);
            outline: none;
            cursor: pointer;
        }

        /* Segmented Control (Compare Mode & Tabs) */
        .bx-seg {
            display: inline-flex;
            background: #f1f5f9;
            border-radius: 10px;
            padding: 3px;
            gap: 2px;
        }
        .bx-seg-btn {
            border: none;
            background: transparent;
            color: #475569;
            font-size: 0.75rem;
            font-weight: 700;
            padding: 0.3rem 0.72rem;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.18s ease;
            white-space: nowrap;
        }
        .bx-seg-btn:hover {
            color: var(--bx-primary);
        }
        .bx-seg-btn.active {
            background: #ffffff;
            color: var(--bx-primary);
            box-shadow: 0 2px 6px rgba(15, 23, 42, 0.08);
        }

        .bx-refresh-btn {
            background: linear-gradient(135deg, #4f46e5 0%, #6366f1 55%, #a855f7 100%);
            color: #ffffff;
            border: none;
            border-radius: 10px;
            font-size: 0.78rem;
            font-weight: 700;
            padding: 0.42rem 1rem;
            cursor: pointer;
            transition: opacity 0.18s ease, box-shadow 0.18s ease;
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.28);
        }
        .bx-refresh-btn:hover {
            opacity: 0.93;
            box-shadow: 0 6px 16px rgba(99, 102, 241, 0.36);
        }
        .bx-refresh-btn:disabled {
            opacity: 0.6;
            cursor: not-allowed;
        }

        /* Scrollable Bento Canvas */
        .bx-canvas {
            flex: 1 1 auto;
            min-height: 0;
            overflow-y: auto;
            overflow-x: hidden;
            display: flex;
            flex-direction: column;
            gap: 1rem;
            padding: 2px 4px 14px 2px;
        }

        /* Row 1: 3 Spacious Bento Story Cards */
        .bx-hero-grid {
            display: grid;
            grid-template-columns: 1.25fr 1fr 1fr;
            gap: 1rem;
            flex: 0 0 auto;
        }
        @media (max-width: 1199px) {
            .bx-hero-grid {
                grid-template-columns: 1fr;
            }
        }

        .bx-card {
            background: var(--bx-card);
            border: 1px solid var(--bx-border);
            border-radius: 18px;
            padding: 1.25rem 1.4rem;
            box-shadow: 0 4px 16px -4px rgba(15, 23, 42, 0.05);
            transition: box-shadow 0.22s ease, border-color 0.22s ease;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }
        .bx-card:hover {
            border-color: #d5dce8;
            box-shadow: 0 12px 28px -10px rgba(15, 23, 42, 0.1);
        }

        /* Hero Financial Card (System Indigo-Purple Gradient) */
        .bx-card-hero {
            background: linear-gradient(135deg, #4f46e5 0%, #6366f1 52%, #a855f7 100%);
            border: none;
            color: #ffffff;
            position: relative;
            overflow: hidden;
            box-shadow: 0 14px 30px -10px rgba(79, 70, 229, 0.42);
        }
        .bx-card-hero::after {
            content: "";
            position: absolute;
            top: -40%;
            right: -12%;
            width: 260px;
            height: 260px;
            border-radius: 50%;
            background: radial-gradient(circle, rgba(255, 255, 255, 0.2) 0%, rgba(255, 255, 255, 0) 70%);
            pointer-events: none;
        }
        .bx-hero-eyebrow {
            font-size: 0.74rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.07em;
            color: rgba(255, 255, 255, 0.82);
        }
        .bx-hero-amount {
            font-size: 2.05rem;
            font-weight: 800;
            color: #ffffff;
            line-height: 1.1;
            margin-top: 0.3rem;
        }
        .bx-hero-substrip {
            margin-top: 1rem;
            padding-top: 0.85rem;
            border-top: 1px solid rgba(255, 255, 255, 0.2);
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 0.85rem;
            position: relative;
            z-index: 1;
        }
        .bx-hero-mini-label {
            font-size: 0.71rem;
            color: rgba(255, 255, 255, 0.78);
            font-weight: 600;
        }
        .bx-hero-mini-val {
            font-size: 1.12rem;
            font-weight: 800;
            color: #ffffff;
            margin-top: 2px;
        }
        .bx-hero-delta {
            display: inline-block;
            margin-top: 2px;
            font-size: 0.69rem;
            font-weight: 700;
            padding: 2px 8px;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.2);
            color: #ffffff;
        }

        /* White Story Cards (Customers & Savings) */
        .bx-eyebrow {
            font-size: 0.73rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.06em;
            color: var(--bx-muted);
        }
        .bx-big-num {
            font-size: 2rem;
            font-weight: 800;
            color: var(--bx-text);
            line-height: 1.1;
            margin-top: 0.28rem;
        }
        .bx-delta-pill {
            display: inline-flex;
            align-items: center;
            font-size: 0.72rem;
            font-weight: 700;
            padding: 3px 9px;
            border-radius: 999px;
            white-space: nowrap;
        }
        .bx-up { background: #dcfce7; color: #166534; }
        .bx-down { background: #fee2e2; color: #991b1b; }
        .bx-flat { background: #f1f5f9; color: #475569; }

        /* Visual Progress Bar inside Bento Card */
        .bx-bar-wrap {
            margin-top: 0.85rem;
        }
        .bx-bar-meta {
            display: flex;
            justify-content: space-between;
            font-size: 0.73rem;
            color: var(--bx-muted);
            font-weight: 600;
            margin-bottom: 5px;
        }
        .bx-bar-track {
            height: 7px;
            background: #eef2ff;
            border-radius: 999px;
            overflow: hidden;
        }
        .bx-bar-fill {
            height: 100%;
            border-radius: 999px;
            background: linear-gradient(90deg, #6366f1, #a855f7);
            transition: width 0.5s ease;
        }

        .bx-sub-grid {
            margin-top: 0.9rem;
            padding-top: 0.75rem;
            border-top: 1px solid #f1f5f9;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 0.75rem;
        }
        .bx-sub-label {
            font-size: 0.71rem;
            font-weight: 600;
            color: var(--bx-muted);
        }
        .bx-sub-val {
            font-size: 1.05rem;
            font-weight: 800;
            color: var(--bx-text);
            margin-top: 2px;
        }

        /* Row 2: 2-Column Interactive Workspace */
        .bx-work-grid {
            flex: 1 1 auto;
            min-height: 360px;
            display: grid;
            grid-template-columns: 1.35fr 1fr;
            gap: 1rem;
        }
        @media (max-width: 1199px) {
            .bx-work-grid {
                grid-template-columns: 1fr;
            }
        }

        .bx-panel {
            background: var(--bx-card);
            border: 1px solid var(--bx-border);
            border-radius: 18px;
            box-shadow: 0 4px 16px -4px rgba(15, 23, 42, 0.05);
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }
        .bx-panel-head {
            padding: 0.95rem 1.3rem;
            border-bottom: 1px solid #f1f5f9;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 0.75rem;
            flex-wrap: wrap;
            flex-shrink: 0;
        }
        .bx-panel-title {
            font-size: 0.95rem;
            font-weight: 800;
            color: var(--bx-text);
            margin: 0;
        }
        .bx-panel-sub {
            font-size: 0.74rem;
            color: var(--bx-muted);
            margin-top: 2px;
        }

        /* Filter Strip inside Tab */
        .bx-filter-row {
            padding: 0.65rem 1.3rem;
            background: #fafbfe;
            border-bottom: 1px solid #f1f5f9;
            display: flex;
            flex-wrap: wrap;
            gap: 0.4rem;
            align-items: center;
        }
        .bx-chip {
            border: 1px solid #dbe2ef;
            background: #ffffff;
            color: #475569;
            font-size: 0.72rem;
            font-weight: 700;
            padding: 4px 11px;
            border-radius: 999px;
            cursor: pointer;
            transition: all 0.15s ease;
        }
        .bx-chip:hover {
            border-color: #6366f1;
            color: #4f46e5;
            background: #eef2ff;
        }
        .bx-chip.active {
            background: linear-gradient(135deg, #4f46e5, #6366f1);
            border-color: transparent;
            color: #ffffff;
        }

        /* Clean Breathable Tables */
        .bx-table-wrap {
            flex: 1 1 auto;
            overflow-y: auto;
            overflow-x: auto;
            max-height: 360px;
        }
        .bx-table {
            width: 100%;
            margin-bottom: 0;
            border-collapse: collapse;
        }
        .bx-table thead th {
            position: sticky;
            top: 0;
            z-index: 2;
            background: #f8fafc;
            color: #64748b;
            font-size: 0.7rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            padding: 0.7rem 1.1rem;
            border-bottom: 1px solid #e2e8f0;
            white-space: nowrap;
        }
        .bx-table tbody td {
            padding: 0.78rem 1.1rem;
            font-size: 0.83rem;
            color: var(--bx-text);
            border-bottom: 1px solid #f1f5f9;
            vertical-align: middle;
        }
        .bx-table tbody tr:hover {
            background: #f8fafc;
        }
        .bx-table tfoot td {
            position: sticky;
            bottom: 0;
            z-index: 2;
            padding: 0.82rem 1.1rem;
            font-size: 0.84rem;
            font-weight: 800;
            color: var(--bx-text);
            background: #f1f5f9;
            border-top: 2px solid #cbd5e1;
        }

        .bx-code {
            font-family: 'Fira Code', ui-monospace, monospace !important;
            font-size: 0.7rem;
            font-weight: 600;
            color: #4338ca;
            background: #eef2ff;
            padding: 2px 7px;
            border-radius: 6px;
        }
        .bx-mini-bar {
            height: 4px;
            background: #eef2ff;
            border-radius: 999px;
            margin-top: 5px;
            overflow: hidden;
            max-width: 180px;
        }
        .bx-mini-bar > div {
            height: 100%;
            border-radius: 999px;
            background: linear-gradient(90deg, #6366f1, #a855f7);
        }
        .bx-tag-ceft {
            font-size: 0.64rem;
            font-weight: 700;
            color: #92400e;
            background: #fef3c7;
            padding: 2px 6px;
            border-radius: 999px;
            margin-left: 6px;
        }
        .bx-tag-grp {
            font-size: 0.69rem;
            font-weight: 700;
            color: #475569;
            background: #f1f5f9;
            padding: 2px 8px;
            border-radius: 999px;
            white-space: nowrap;
        }

        .is-loading .bx-big-num,
        .is-loading .bx-hero-amount {
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

            <!-- Clean Floating Executive Top Bar -->
            <div class="bx-topbar">
                <div>
                    <h4 class="bx-title">My Fintrex — Mobile App Overview</h4>
                    <div class="bx-subtitle">Live executive insights from 2026-06-01 onwards &middot; Fintrex (OWN) &amp; JustPay (OTHER)</div>
                </div>
                <div class="bx-controls">
                    <div class="bx-date-pill">
                        <label for="fromDate">From</label>
                        <input type="date" id="fromDate" min="2026-06-01" aria-label="From date">
                    </div>
                    <div class="bx-date-pill">
                        <label for="toDate">To</label>
                        <input type="date" id="toDate" min="2026-06-01" aria-label="To date">
                    </div>
                    <div class="bx-seg" id="compareSeg" role="group" aria-label="Comparison period">
                        <button type="button" class="bx-seg-btn active" data-compare="DAY">vs Prev Day</button>
                        <button type="button" class="bx-seg-btn" data-compare="MONTH">vs Prev Month</button>
                    </div>
                    <button type="button" id="refreshBtn" class="bx-refresh-btn">Refresh</button>
                </div>
            </div>

            <!-- Breathable Bento Canvas -->
            <div class="bx-canvas">
                <!-- Error Alert -->
                <div id="errorAlert" class="alert alert-danger d-none align-items-center justify-content-between py-2 px-3 mb-0 rounded-3" role="alert">
                    <span id="errorMessage">Unable to load Mobile App dashboard data.</span>
                    <button type="button" class="btn btn-sm btn-outline-danger ms-3" onclick="loadDashboard()">Retry</button>
                </div>

                <!-- ROW 1: 3 Spacious Bento Story Cards (All 7 KPIs, Effortless to Read) -->
                <div class="bx-hero-grid">
                    <!-- Story Card 1: Financial Hero (CEFT Revenue + Txn Count + Txn Value) -->
                    <div class="bx-card bx-card-hero">
                        <div class="d-flex align-items-start justify-content-between gap-2 position-relative" style="z-index: 1;">
                            <div>
                                <div class="bx-hero-eyebrow">Total CEFT Revenue (LKR 25 / Txn)</div>
                                <div class="bx-hero-amount num" id="kpiCeftRevenue">-</div>
                            </div>
                            <span class="bx-hero-delta num" id="kpiCeftRevenueDelta">-</span>
                        </div>
                        <div class="bx-hero-substrip">
                            <div>
                                <div class="bx-hero-mini-label">Successful Transactions</div>
                                <div class="bx-hero-mini-val num" id="kpiTxnCount">-</div>
                                <span class="bx-hero-delta num" id="kpiTxnCountDelta">-</span>
                            </div>
                            <div>
                                <div class="bx-hero-mini-label">Total Transaction Value</div>
                                <div class="bx-hero-mini-val num" id="kpiTxnValue">-</div>
                                <span class="bx-hero-delta num" id="kpiTxnValueDelta">-</span>
                            </div>
                        </div>
                    </div>

                    <!-- Story Card 2: Customer Adoption (Active Customers + Initiated + Active Non-Fintrex) -->
                    <div class="bx-card">
                        <div class="d-flex align-items-start justify-content-between gap-2">
                            <div>
                                <div class="bx-eyebrow">Active Customers</div>
                                <div class="bx-big-num num" id="kpiActive">-</div>
                            </div>
                            <span class="bx-delta-pill bx-flat num" id="kpiActiveDelta">-</span>
                        </div>
                        <div class="bx-bar-wrap">
                            <div class="bx-bar-meta">
                                <span>Active vs App Initiated</span>
                                <span class="num" id="activeRateText">-</span>
                            </div>
                            <div class="bx-bar-track">
                                <div class="bx-bar-fill" id="activeRateBar" style="width: 0%;"></div>
                            </div>
                        </div>
                        <div class="bx-sub-grid">
                            <div>
                                <div class="bx-sub-label">App Initiated</div>
                                <div class="bx-sub-val num" id="kpiInitiated">-</div>
                                <span class="bx-delta-pill bx-flat num mt-1" id="kpiInitiatedDelta">-</span>
                            </div>
                            <div>
                                <div class="bx-sub-label">Active Non-Fintrex</div>
                                <div class="bx-sub-val num" id="kpiNonFintrex">-</div>
                                <span class="bx-delta-pill bx-flat num mt-1" id="kpiNonFintrexDelta">-</span>
                            </div>
                        </div>
                    </div>

                    <!-- Story Card 3: Digital Savings & CEFT Share -->
                    <div class="bx-card">
                        <div class="d-flex align-items-start justify-content-between gap-2">
                            <div>
                                <div class="bx-eyebrow">Savings Accounts Opened</div>
                                <div class="bx-big-num num" id="kpiSavings">-</div>
                            </div>
                            <span class="bx-delta-pill bx-flat num" id="kpiSavingsDelta">-</span>
                        </div>
                        <div class="bx-bar-wrap">
                            <div class="bx-bar-meta">
                                <span>Active Savings Ratio</span>
                                <span class="num" id="savingsActiveRateText">-</span>
                            </div>
                            <div class="bx-bar-track">
                                <div class="bx-bar-fill" id="savingsActiveBar" style="width: 0%; background: linear-gradient(90deg, #0ea5e9, #10b981);"></div>
                            </div>
                        </div>
                        <div class="bx-sub-grid">
                            <div>
                                <div class="bx-sub-label">Active Savings Accounts</div>
                                <div class="bx-sub-val num" style="color: #059669;" id="kpiActiveSavings">-</div>
                            </div>
                            <div>
                                <div class="bx-sub-label">CEFT Eligible Txns</div>
                                <div class="bx-sub-val num" style="color: #4f46e5;" id="kpiCeftCount">-</div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ROW 2: Spacious 2-Column Workspace (Tabbed Tables + Switchable Visuals) -->
                <div class="bx-work-grid">
                    <!-- Left: Clean Tabbed Detail Panel -->
                    <div class="bx-panel">
                        <div class="bx-panel-head">
                            <div>
                                <h6 class="bx-panel-title" id="leftPanelTitle">CEFT Revenue Breakdown</h6>
                                <div class="bx-panel-sub" id="leftPanelSub">LKR 25.00 per successful transaction across the 4 eligible CEFT codes</div>
                            </div>
                            <div class="bx-seg" id="detailTabs">
                                <button type="button" class="bx-seg-btn active" data-tab="ceft">CEFT Revenue</button>
                                <button type="button" class="bx-seg-btn" data-tab="groups">By Category</button>
                                <button type="button" class="bx-seg-btn" data-tab="txns">All Types</button>
                            </div>
                        </div>

                        <!-- Tab 1: CEFT Revenue -->
                        <div id="pane-ceft" class="d-flex flex-column flex-grow-1">
                            <div class="bx-filter-row" id="ceftFilterBar">
                                <button type="button" class="bx-chip active" data-ceft-group="ALL">All CEFT</button>
                                <button type="button" class="bx-chip" data-ceft-group="Credit Card">Credit Card (CC)</button>
                                <button type="button" class="bx-chip" data-ceft-group="Fund Transfers">Fund Transfers (FT)</button>
                            </div>
                            <div class="bx-table-wrap">
                                <table class="bx-table">
                                    <thead>
                                        <tr>
                                            <th>Transaction Type</th>
                                            <th>Code</th>
                                            <th class="text-end">Success Count</th>
                                            <th class="text-end" id="ceftDiffCol">vs Prev Day</th>
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

                        <!-- Tab 2: Category Summary -->
                        <div id="pane-groups" class="d-none flex-column flex-grow-1">
                            <div class="bx-table-wrap">
                                <table class="bx-table">
                                    <thead>
                                        <tr>
                                            <th>Category Group</th>
                                            <th class="text-end">Success Count</th>
                                            <th class="text-end" id="grpDiffCol">vs Prev Day</th>
                                            <th class="text-end">Total Value (LKR)</th>
                                            <th class="text-end">Share</th>
                                        </tr>
                                    </thead>
                                    <tbody id="groupTableBody"></tbody>
                                    <tfoot id="groupTableFoot"></tfoot>
                                </table>
                            </div>
                        </div>

                        <!-- Tab 3: All Transaction Types -->
                        <div id="pane-txns" class="d-none flex-column flex-grow-1">
                            <div class="bx-filter-row" id="txnFilterBar">
                                <button type="button" class="bx-chip active" data-group="ALL">All</button>
                                <button type="button" class="bx-chip" data-group="CEFT">CEFT</button>
                                <button type="button" class="bx-chip" data-group="Leasing">Leasing</button>
                                <button type="button" class="bx-chip" data-group="Loan Payments">Loan</button>
                                <button type="button" class="bx-chip" data-group="Pawning">Pawning</button>
                                <button type="button" class="bx-chip" data-group="Bill Payments">Bill</button>
                                <button type="button" class="bx-chip" data-group="Fund Transfers">Fund</button>
                                <button type="button" class="bx-chip" data-group="Credit Card">Credit Card</button>
                                <button type="button" class="bx-chip" data-group="QR Payments">QR</button>
                            </div>
                            <div class="bx-table-wrap">
                                <table class="bx-table">
                                    <thead>
                                        <tr>
                                            <th>Transaction Type</th>
                                            <th>Group</th>
                                            <th>Code</th>
                                            <th class="text-end">Count</th>
                                            <th class="text-end">Value (LKR)</th>
                                            <th class="text-end" id="txnDiffCol">vs Prev Day</th>
                                        </tr>
                                    </thead>
                                    <tbody id="txnTableBody"></tbody>
                                    <tfoot id="txnTableFoot"></tfoot>
                                </table>
                            </div>
                        </div>
                    </div>

                    <!-- Right: Clean Switchable Visual Chart Panel -->
                    <div class="bx-panel">
                        <div class="bx-panel-head">
                            <div>
                                <h6 class="bx-panel-title" id="chartPanelTitle">Daily Activity Trend</h6>
                                <div class="bx-panel-sub" id="chartPanelSub">Successful transactions &amp; CEFT revenue over recent days</div>
                            </div>
                            <div class="bx-seg" id="chartTabs">
                                <button type="button" class="bx-seg-btn active" data-chart="trend">Trend</button>
                                <button type="button" class="bx-seg-btn" data-chart="groups">By Group</button>
                            </div>
                        </div>
                        <div class="p-3 flex-grow-1" style="min-height: 310px; position: relative;">
                            <canvas id="mainVisualChart"></canvas>
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
<script src="${pageContext.request.contextPath}/vendors/fontawesome/all.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/theme.js"></script>

<script>
    const DATA_FLOOR = '2026-06-01';
    let compareMode = 'DAY';
    let activeCeftGroup = 'ALL';
    let activeTxnGroup = 'ALL';
    let activeChartTab = 'trend';
    let lastPayload = null;
    let mainChart = null;

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

    function setPillDelta(elId, current, prev, isCurrency, isHero) {
        const el = document.getElementById(elId);
        if (!el) return;
        const diff = Number(current || 0) - Number(prev || 0);
        const suffix = compareMode === 'MONTH' ? ' vs prev mo' : ' vs prev day';
        const absText = isCurrency ? fmtCompactLkr(Math.abs(diff)) : fmtInt(Math.abs(diff));

        if (!isHero) {
            el.classList.remove('bx-up', 'bx-down', 'bx-flat');
            el.classList.add(diff > 0 ? 'bx-up' : (diff < 0 ? 'bx-down' : 'bx-flat'));
        }
        el.textContent = (diff > 0 ? '+' : (diff < 0 ? '-' : '')) + (diff === 0 ? '0' : absText) + suffix;
        el.title = 'Previous total: ' + (isCurrency ? 'LKR ' + fmtCurrency(prev) : fmtInt(prev));
    }

    function diffBadgeHtml(diffVal) {
        const d = Number(diffVal || 0);
        if (d > 0) return '<span class="bx-delta-pill bx-up">+' + fmtInt(d) + '</span>';
        if (d < 0) return '<span class="bx-delta-pill bx-down">' + fmtInt(d) + '</span>';
        return '<span class="bx-delta-pill bx-flat">0</span>';
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
                const colLbl = compareMode === 'MONTH' ? 'vs Prev Mo' : 'vs Prev Day';
                $('#ceftDiffCol, #grpDiffCol, #txnDiffCol').text(colLbl);

                // Financial Hero Card
                const t = data.transactionInfo || {};
                const ceft = data.ceftRevenue || {};
                $('#kpiCeftRevenue').text('LKR ' + fmtCurrency(ceft.totalCeftRevenue));
                setPillDelta('kpiCeftRevenueDelta', ceft.totalCeftRevenue, ceft.prevCeftRevenue, true, true);

                $('#kpiTxnCount').text(fmtInt(t.totalSuccessCount));
                setPillDelta('kpiTxnCountDelta', t.totalSuccessCount, t.prevSuccessCount, false, true);

                $('#kpiTxnValue').text(fmtCompactLkr(t.totalSuccessValue)).attr('title', 'LKR ' + fmtCurrency(t.totalSuccessValue));
                setPillDelta('kpiTxnValueDelta', t.totalSuccessValue, t.prevSuccessValue, true, true);

                // Customer Adoption Card
                const c = data.customerInfo || {};
                $('#kpiActive').text(fmtInt(c.totalActive));
                setPillDelta('kpiActiveDelta', c.totalActive, c.prevActive, false, false);

                $('#kpiInitiated').text(fmtInt(c.totalInitiated));
                setPillDelta('kpiInitiatedDelta', c.totalInitiated, c.prevInitiated, false, false);

                $('#kpiNonFintrex').text(fmtInt(c.totalNonFintrex));
                setPillDelta('kpiNonFintrexDelta', c.totalNonFintrex, c.prevNonFintrex, false, false);

                const activePct = c.totalInitiated > 0 ? Math.min(100, Math.round((c.totalActive / c.totalInitiated) * 100)) : 0;
                $('#activeRateText').text(activePct + '% (' + fmtInt(c.totalActive) + ' / ' + fmtInt(c.totalInitiated) + ')');
                $('#activeRateBar').css('width', activePct + '%');

                // Savings & CEFT Activity Card
                $('#kpiSavings').text(fmtInt(c.totalSavings));
                setPillDelta('kpiSavingsDelta', c.totalSavings, c.prevSavings, false, false);
                $('#kpiActiveSavings').text(fmtInt(c.activeSavings));
                $('#kpiCeftCount').text(fmtInt(ceft.totalCeftCount));

                const savPct = c.totalSavings > 0 ? Math.min(100, Math.round((c.activeSavings / c.totalSavings) * 100)) : 0;
                $('#savingsActiveRateText').text(savPct + '% active');
                $('#savingsActiveBar').css('width', savPct + '%');

                renderCeftTable();
                renderGroupTable();
                renderTxnTable();
                renderMainChart();
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
        let rows = ceft.breakdown || [];
        if (activeCeftGroup !== 'ALL') {
            rows = rows.filter(r => r.group === activeCeftGroup);
        }
        const maxRev = Math.max(1, ...rows.map(r => Number(r.revenue || 0)));

        let sumCount = 0, sumDiff = 0, sumRev = 0;
        const html = rows.map(r => {
            sumCount += Number(r.successCount || 0);
            sumDiff += Number(r.diffCount || 0);
            sumRev += Number(r.revenue || 0);
            const pct = Math.round((Number(r.revenue || 0) / maxRev) * 100);
            return '<tr>' +
                '<td><div class="fw-bold">' + escapeHtml(r.transactionType) + '</div>' +
                    '<div class="bx-mini-bar"><div style="width:' + pct + '%;"></div></div></td>' +
                '<td><span class="bx-code">' + escapeHtml(r.transactionCode) + '</span></td>' +
                '<td class="text-end num fw-semi-bold">' + fmtInt(r.successCount) + '</td>' +
                '<td class="text-end num">' + diffBadgeHtml(r.diffCount) + '</td>' +
                '<td class="text-end num fw-bold" style="color:#4f46e5;">' + fmtCurrency(r.revenue) + '</td>' +
            '</tr>';
        }).join('');

        $('#ceftTableBody').html(html || '<tr><td colspan="5" class="text-center text-muted py-4">No CEFT transactions found</td></tr>');
        $('#ceftTableFoot').html(
            '<tr>' +
                '<td colspan="2">Total CEFT Revenue</td>' +
                '<td class="text-end num">' + fmtInt(sumCount) + '</td>' +
                '<td class="text-end num">' + diffBadgeHtml(sumDiff) + '</td>' +
                '<td class="text-end num" style="color:#4f46e5;">LKR ' + fmtCurrency(sumRev) + '</td>' +
            '</tr>'
        );
    }

    function renderGroupTable() {
        if (!lastPayload) return;
        const groups = lastPayload.groupSummary || [];
        const grandVal = groups.reduce((s, g) => s + Number(g.totalValue || 0), 0);
        let sumCount = 0, sumDiff = 0;

        const html = groups.map(g => {
            sumCount += Number(g.totalCount || 0);
            sumDiff += Number(g.diffCount || 0);
            const share = grandVal > 0 ? ((Number(g.totalValue || 0) / grandVal) * 100).toFixed(1) : '0.0';
            return '<tr>' +
                '<td><div class="fw-bold">' + escapeHtml(g.group) + '</div>' +
                    '<div class="bx-mini-bar"><div style="width:' + Math.min(100, Number(share)) + '%;"></div></div></td>' +
                '<td class="text-end num fw-semi-bold">' + fmtInt(g.totalCount) + '</td>' +
                '<td class="text-end num">' + diffBadgeHtml(g.diffCount) + '</td>' +
                '<td class="text-end num fw-bold">' + fmtCurrency(g.totalValue) + '</td>' +
                '<td class="text-end num text-muted">' + share + '%</td>' +
            '</tr>';
        }).join('');

        $('#groupTableBody').html(html || '<tr><td colspan="5" class="text-center text-muted py-4">No data</td></tr>');
        $('#groupTableFoot').html(
            '<tr>' +
                '<td>All Categories</td>' +
                '<td class="text-end num">' + fmtInt(sumCount) + '</td>' +
                '<td class="text-end num">' + diffBadgeHtml(sumDiff) + '</td>' +
                '<td class="text-end num">LKR ' + fmtCurrency(grandVal) + '</td>' +
                '<td class="text-end num">100%</td>' +
            '</tr>'
        );
    }

    function renderTxnTable() {
        if (!lastPayload) return;
        let list = lastPayload.transactionBreakdown || [];
        if (activeTxnGroup === 'CEFT') {
            list = list.filter(i => i.isCeft);
        } else if (activeTxnGroup !== 'ALL') {
            list = list.filter(i => i.group === activeTxnGroup);
        }

        if (!list.length) {
            $('#txnTableBody').html('<tr><td colspan="6" class="text-center text-muted py-4">No transactions for this filter.</td></tr>');
            $('#txnTableFoot').empty();
            return;
        }

        let sumCount = 0, sumVal = 0, sumDiff = 0;
        const html = list.map(item => {
            sumCount += Number(item.totalCount || 0);
            sumVal += Number(item.totalValue || 0);
            sumDiff += Number(item.diffCount || 0);
            const ceftTag = item.isCeft ? '<span class="bx-tag-ceft">CEFT</span>' : '';
            return '<tr>' +
                '<td class="fw-semi-bold">' + escapeHtml(item.displayName) + ceftTag + '</td>' +
                '<td><span class="bx-tag-grp">' + escapeHtml(item.group) + '</span></td>' +
                '<td><span class="bx-code">' + escapeHtml(item.txnCode) + '</span></td>' +
                '<td class="text-end num">' + fmtInt(item.totalCount) + '</td>' +
                '<td class="text-end num fw-bold">' + fmtCurrency(item.totalValue) + '</td>' +
                '<td class="text-end num">' + diffBadgeHtml(item.diffCount) + '</td>' +
            '</tr>';
        }).join('');

        $('#txnTableBody').html(html);
        $('#txnTableFoot').html(
            '<tr>' +
                '<td colspan="3">Total (' + escapeHtml(activeTxnGroup) + ')</td>' +
                '<td class="text-end num">' + fmtInt(sumCount) + '</td>' +
                '<td class="text-end num">' + fmtCurrency(sumVal) + '</td>' +
                '<td class="text-end num">' + diffBadgeHtml(sumDiff) + '</td>' +
            '</tr>'
        );
    }

    function renderMainChart() {
        if (!lastPayload) return;
        const ctx = document.getElementById('mainVisualChart');
        if (mainChart) mainChart.destroy();

        if (activeChartTab === 'trend') {
            $('#chartPanelTitle').text('Daily Activity Trend');
            $('#chartPanelSub').text('Successful transactions & CEFT revenue (LKR)');
            const trend = lastPayload.dailyTrend || [];
            mainChart = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: trend.map(d => d.date.slice(5)),
                    datasets: [
                        {
                            label: 'Successful Txns',
                            data: trend.map(d => Number(d.txnCount || 0)),
                            backgroundColor: 'rgba(99, 102, 241, 0.82)',
                            hoverBackgroundColor: '#4f46e5',
                            borderRadius: 6,
                            yAxisID: 'y'
                        },
                        {
                            label: 'CEFT Revenue (LKR)',
                            data: trend.map(d => Number(d.ceftRevenue || 0)),
                            type: 'line',
                            borderColor: '#f59e0b',
                            backgroundColor: 'rgba(245, 158, 11, 0.14)',
                            fill: true,
                            borderWidth: 2.5,
                            tension: 0.38,
                            pointRadius: 3.5,
                            pointBackgroundColor: '#f59e0b',
                            yAxisID: 'y1'
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    interaction: { mode: 'index', intersect: false },
                    plugins: {
                        legend: { position: 'bottom', labels: { usePointStyle: true, padding: 14, font: { family: 'Plus Jakarta Sans', size: 11, weight: '600' } } }
                    },
                    scales: {
                        x: { grid: { display: false }, ticks: { color: '#64748b', font: { size: 11 } } },
                        y: { beginAtZero: true, position: 'left', grid: { color: '#f1f5f9' }, ticks: { color: '#64748b' } },
                        y1: { beginAtZero: true, position: 'right', grid: { drawOnChartArea: false }, ticks: { color: '#64748b' } }
                    }
                }
            });
        } else {
            $('#chartPanelTitle').text('Transaction Value by Group');
            $('#chartPanelSub').text('Distribution across Leasing, Loan, Pawning, Bill, Fund, CC & QR (LKR)');
            const groups = (lastPayload.groupSummary || []).filter(g => Number(g.totalValue || 0) > 0);
            const palette = ['#4f46e5', '#6366f1', '#8b5cf6', '#a855f7', '#0ea5e9', '#10b981', '#f59e0b', '#64748b'];
            mainChart = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: groups.map(g => g.group),
                    datasets: [{
                        label: 'Value (LKR)',
                        data: groups.map(g => Number(g.totalValue || 0)),
                        backgroundColor: groups.map((_, idx) => palette[idx % palette.length]),
                        borderRadius: 8,
                        barThickness: 22
                    }]
                },
                options: {
                    indexAxis: 'y',
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: false },
                        tooltip: { callbacks: { label: c => 'LKR ' + fmtCurrency(c.parsed.x) } }
                    },
                    scales: {
                        y: { grid: { display: false }, ticks: { color: '#0f172a', font: { size: 11, weight: '700' } } },
                        x: {
                            beginAtZero: true,
                            grid: { color: '#f1f5f9' },
                            ticks: {
                                color: '#64748b',
                                callback: v => v >= 1e6 ? (v / 1e6).toFixed(1) + 'M' : (v >= 1e3 ? (v / 1e3).toFixed(0) + 'K' : v)
                            }
                        }
                    }
                }
            });
        }
    }

    $(document).ready(function () {
        $('#fromDate').val(DATA_FLOOR);
        $('#toDate').val(getLocalToday());

        $('#fromDate, #toDate').on('change', loadDashboard);
        $('#refreshBtn').on('click', loadDashboard);

        // Compare mode toggle
        $('#compareSeg').on('click', '.bx-seg-btn', function () {
            $('#compareSeg .bx-seg-btn').removeClass('active');
            $(this).addClass('active');
            compareMode = $(this).data('compare');
            loadDashboard();
        });

        // Left panel tabs
        $('#detailTabs').on('click', '.bx-seg-btn', function () {
            $('#detailTabs .bx-seg-btn').removeClass('active');
            $(this).addClass('active');
            const tab = $(this).data('tab');
            $('#pane-ceft, #pane-groups, #pane-txns').addClass('d-none').removeClass('d-flex');
            $('#pane-' + tab).removeClass('d-none').addClass('d-flex');

            if (tab === 'ceft') {
                $('#leftPanelTitle').text('CEFT Revenue Breakdown');
                $('#leftPanelSub').text('LKR 25.00 per successful transaction across the 4 eligible CEFT codes');
            } else if (tab === 'groups') {
                $('#leftPanelTitle').text('Category Group Summary');
                $('#leftPanelSub').text('Leasing, Loan Payments, Pawning, Bill, Fund, Credit Card & QR share');
            } else {
                $('#leftPanelTitle').text('All Transaction Types');
                $('#leftPanelSub').text('OWN = Fintrex · OTHER = JustPay');
            }
        });

        // Right chart tabs
        $('#chartTabs').on('click', '.bx-seg-btn', function () {
            $('#chartTabs .bx-seg-btn').removeClass('active');
            $(this).addClass('active');
            activeChartTab = $(this).data('chart');
            renderMainChart();
        });

        // CEFT group chips
        $('#ceftFilterBar').on('click', '.bx-chip', function () {
            $('#ceftFilterBar .bx-chip').removeClass('active');
            $(this).addClass('active');
            activeCeftGroup = $(this).data('ceft-group');
            renderCeftTable();
        });

        // Txn group chips
        $('#txnFilterBar').on('click', '.bx-chip', function () {
            $('#txnFilterBar .bx-chip').removeClass('active');
            $(this).addClass('active');
            activeTxnGroup = $(this).data('group');
            renderTxnTable();
        });

        loadDashboard();
    });
</script>
</body>
</html>
