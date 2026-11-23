<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en-US" dir="ltr">

<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Fintrex | Mobile App Live Dashboard</title>

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
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
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
        body, .main, p, div, span, select, input, button, table, h1, h2, h3, h4, h5, h6 {
            font-family: 'Plus Jakarta Sans', sans-serif !important;
        }
        .section-heading {
            font-size: 0.78rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.06em;
            color: #64748b;
            margin-bottom: 0.6rem;
        }
        .kpi-card {
            background: #ffffff;
            border: 1px solid rgba(226, 232, 240, 0.8);
            border-radius: 10px;
            padding: 1rem 1.15rem;
            height: 100%;
            transition: transform 0.18s ease, box-shadow 0.18s ease;
            box-shadow: 0 2px 6px rgba(15, 23, 42, 0.03);
        }
        .kpi-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(99, 102, 241, 0.09);
        }
        .kpi-icon {
            width: 38px;
            height: 38px;
            border-radius: 9px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 1rem;
            flex-shrink: 0;
        }
        .kpi-label {
            font-size: 0.76rem;
            font-weight: 600;
            color: #64748b;
            margin-bottom: 0.25rem;
        }
        .kpi-value {
            font-size: 1.55rem;
            font-weight: 800;
            color: #0f172a;
            line-height: 1.15;
            letter-spacing: -0.02em;
        }
        .kpi-sub {
            font-size: 0.74rem;
            color: #64748b;
            margin-top: 0.45rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 0.5rem;
            flex-wrap: wrap;
        }
        .delta-badge {
            display: inline-flex;
            align-items: center;
            gap: 3px;
            font-size: 0.72rem;
            font-weight: 700;
            padding: 2px 7px;
            border-radius: 999px;
            white-space: nowrap;
        }
        .delta-up {
            background: rgba(16, 185, 129, 0.12);
            color: #059669;
        }
        .delta-down {
            background: rgba(239, 68, 68, 0.12);
            color: #dc2626;
        }
        .delta-flat {
            background: rgba(100, 116, 139, 0.12);
            color: #475569;
        }
        .dashboard-card {
            background: #ffffff;
            border: 1px solid rgba(226, 232, 240, 0.8);
            border-radius: 10px;
            box-shadow: 0 2px 6px rgba(15, 23, 42, 0.03);
        }
        .dashboard-card .card-header {
            background: transparent;
            border-bottom: 1px solid rgba(226, 232, 240, 0.75);
            padding: 0.85rem 1.15rem;
        }
        .btn-primary-grad {
            background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%) !important;
            border: none !important;
            color: #ffffff !important;
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.22);
        }
        .btn-primary-grad:hover {
            background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%) !important;
            color: #ffffff !important;
        }
        .code-pill {
            font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace !important;
            font-size: 0.72rem;
            background: #f1f5f9;
            color: #334155;
            padding: 2px 6px;
            border-radius: 4px;
            font-weight: 600;
        }
        .ceft-pill {
            font-size: 0.68rem;
            font-weight: 700;
            background: rgba(99, 102, 241, 0.12);
            color: #4f46e5;
            padding: 2px 6px;
            border-radius: 999px;
        }
        .live-dot {
            display: inline-block;
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: #10b981;
            margin-right: 6px;
            box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.2);
        }
        .table th {
            font-size: 0.74rem;
            text-transform: uppercase;
            letter-spacing: 0.03em;
            color: #475569;
            font-weight: 700;
        }
        .table td {
            font-size: 0.82rem;
            vertical-align: middle;
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

            <!-- Page Header & Controls -->
            <div class="d-flex flex-wrap align-items-center justify-content-between gap-2 mb-3 mt-2">
                <div>
                    <h4 class="mb-0 fw-bold" style="color: #4f46e5;">
                        <i class="fas fa-mobile-alt me-2"></i>My Fintrex — Mobile App Live Dashboard
                    </h4>
                    <div class="text-muted small mt-1">
                        <span class="live-dot"></span>
                        <span>Live DB: <code>fintrex_live_app_backend</code></span>
                        <span class="mx-2">|</span>
                        <span>Last updated: <strong id="lastUpdatedText">-</strong></span>
                    </div>
                </div>
                <div class="d-flex align-items-center gap-2">
                    <div class="d-flex align-items-center gap-2 bg-white border rounded px-2 py-1">
                        <label for="asAtDate" class="mb-0 small fw-semi-bold text-muted text-nowrap">As at</label>
                        <input type="date" id="asAtDate" class="form-control form-control-sm border-0 p-0" style="width: 135px; box-shadow: none;">
                    </div>
                    <button type="button" id="refreshBtn" class="btn btn-sm btn-primary-grad px-3">
                        <i class="fas fa-sync-alt me-1" id="refreshIcon"></i> Refresh
                    </button>
                </div>
            </div>

            <!-- Error Alert -->
            <div id="errorAlert" class="alert alert-danger d-none align-items-center justify-content-between mb-3" role="alert">
                <div>
                    <i class="fas fa-exclamation-triangle me-2"></i>
                    <span id="errorMessage">Unable to load Mobile App dashboard data.</span>
                </div>
                <button type="button" class="btn btn-sm btn-outline-danger" onclick="loadDashboard()">Retry</button>
            </div>

            <!-- 1. Customer / App Information -->
            <div class="section-heading">Customer &amp; App Information</div>
            <div class="row g-3 mb-3">
                <div class="col-12 col-sm-6 col-xl-3">
                    <div class="kpi-card">
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <div class="kpi-label">Total App Downloads / Initiated</div>
                                <div class="kpi-value" id="kpiInitiated">-</div>
                            </div>
                            <div class="kpi-icon" style="background: rgba(99, 102, 241, 0.12); color: #6366f1;">
                                <i class="fas fa-download"></i>
                            </div>
                        </div>
                        <div class="kpi-sub">
                            <span id="kpiInitiatedToday">Today: -</span>
                            <span id="kpiInitiatedDelta" class="delta-badge delta-flat">-</span>
                        </div>
                    </div>
                </div>
                <div class="col-12 col-sm-6 col-xl-3">
                    <div class="kpi-card">
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <div class="kpi-label">Total Active Customers</div>
                                <div class="kpi-value" id="kpiActive">-</div>
                            </div>
                            <div class="kpi-icon" style="background: rgba(16, 185, 129, 0.12); color: #10b981;">
                                <i class="fas fa-user-check"></i>
                            </div>
                        </div>
                        <div class="kpi-sub">
                            <span id="kpiActiveToday">Today: -</span>
                            <span id="kpiActiveDelta" class="delta-badge delta-flat">-</span>
                        </div>
                    </div>
                </div>
                <div class="col-12 col-sm-6 col-xl-3">
                    <div class="kpi-card">
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <div class="kpi-label">Non-Fintrex Users</div>
                                <div class="kpi-value" id="kpiNonFintrex">-</div>
                            </div>
                            <div class="kpi-icon" style="background: rgba(245, 158, 11, 0.12); color: #d97706;">
                                <i class="fas fa-user-friends"></i>
                            </div>
                        </div>
                        <div class="kpi-sub">
                            <span id="kpiNonFintrexToday">Today: -</span>
                            <span id="kpiNonFintrexDelta" class="delta-badge delta-flat">-</span>
                        </div>
                    </div>
                </div>
                <div class="col-12 col-sm-6 col-xl-3">
                    <div class="kpi-card">
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <div class="kpi-label">Total Savings Accounts Opened</div>
                                <div class="kpi-value" id="kpiSavings">-</div>
                            </div>
                            <div class="kpi-icon" style="background: rgba(14, 165, 233, 0.12); color: #0284c7;">
                                <i class="fas fa-piggy-bank"></i>
                            </div>
                        </div>
                        <div class="kpi-sub">
                            <span id="kpiSavingsToday">Today: -</span>
                            <span id="kpiSavingsDelta" class="delta-badge delta-flat">-</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 2. Transaction & CEFT Revenue KPIs -->
            <div class="section-heading">Transactions &amp; CEFT Revenue</div>
            <div class="row g-3 mb-3">
                <div class="col-12 col-md-4">
                    <div class="kpi-card">
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <div class="kpi-label">Total Successful Transactions</div>
                                <div class="kpi-value" id="kpiTxnCount">-</div>
                            </div>
                            <div class="kpi-icon" style="background: rgba(139, 92, 246, 0.12); color: #7c3aed;">
                                <i class="fas fa-exchange-alt"></i>
                            </div>
                        </div>
                        <div class="kpi-sub">
                            <span id="kpiTxnCountToday">Today: -</span>
                            <span id="kpiTxnCountDelta" class="delta-badge delta-flat">-</span>
                        </div>
                    </div>
                </div>
                <div class="col-12 col-md-4">
                    <div class="kpi-card">
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <div class="kpi-label">Total Successful Transaction Value</div>
                                <div class="kpi-value" id="kpiTxnValue">-</div>
                            </div>
                            <div class="kpi-icon" style="background: rgba(16, 185, 129, 0.12); color: #059669;">
                                <i class="fas fa-coins"></i>
                            </div>
                        </div>
                        <div class="kpi-sub">
                            <span id="kpiTxnValueToday">Today: -</span>
                            <span id="kpiTxnValueDelta" class="delta-badge delta-flat">-</span>
                        </div>
                    </div>
                </div>
                <div class="col-12 col-md-4">
                    <div class="kpi-card" style="border-left: 4px solid #6366f1;">
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <div class="kpi-label">Total CEFT Revenue (LKR 25 / Txn)</div>
                                <div class="kpi-value text-primary" id="kpiCeftRevenue">-</div>
                            </div>
                            <div class="kpi-icon" style="background: rgba(99, 102, 241, 0.14); color: #4f46e5;">
                                <i class="fas fa-hand-holding-usd"></i>
                            </div>
                        </div>
                        <div class="kpi-sub">
                            <span id="kpiCeftRevenueToday">Today: -</span>
                            <span id="kpiCeftRevenueDelta" class="delta-badge delta-flat">-</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 3. CEFT Revenue Breakdown & 14-Day Trend -->
            <div class="row g-3 mb-3">
                <div class="col-12 col-xl-7">
                    <div class="card dashboard-card h-100">
                        <div class="card-header d-flex align-items-center justify-content-between">
                            <div>
                                <h6 class="mb-0 fw-bold text-900"><i class="fas fa-calculator me-2 text-primary"></i>CEFT Revenue Breakdown</h6>
                                <small class="text-muted">Calculated at LKR 25.00 per successful transaction across the 4 CEFT transaction types</small>
                            </div>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-hover mb-0">
                                    <thead class="bg-200">
                                        <tr>
                                            <th>Transaction Type</th>
                                            <th>Code</th>
                                            <th class="text-end">Success Count</th>
                                            <th class="text-end">Daily Mov.</th>
                                            <th class="text-end">Fee (LKR)</th>
                                            <th class="text-end">CEFT Revenue (LKR)</th>
                                        </tr>
                                    </thead>
                                    <tbody id="ceftTableBody">
                                        <tr><td colspan="6" class="text-center text-muted py-4">Loading...</td></tr>
                                    </tbody>
                                    <tfoot id="ceftTableFoot" class="bg-100 fw-bold"></tfoot>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-12 col-xl-5">
                    <div class="card dashboard-card h-100">
                        <div class="card-header d-flex align-items-center justify-content-between">
                            <div>
                                <h6 class="mb-0 fw-bold text-900"><i class="fas fa-chart-line me-2 text-primary"></i>14-Day Daily Activity Trend</h6>
                                <small class="text-muted">Successful transactions vs. CEFT revenue (LKR)</small>
                            </div>
                        </div>
                        <div class="card-body">
                            <div style="height: 250px; position: relative;">
                                <canvas id="dailyTrendChart"></canvas>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 4. Transaction Type-Wise Breakdown -->
            <div class="row g-3 mb-4">
                <div class="col-12 col-xl-7">
                    <div class="card dashboard-card h-100">
                        <div class="card-header d-flex align-items-center justify-content-between">
                            <div>
                                <h6 class="mb-0 fw-bold text-900"><i class="fas fa-list-alt me-2 text-primary"></i>Transaction Type-Wise Breakdown</h6>
                                <small class="text-muted">Successful transaction count &amp; value by type (cumulative + daily movement)</small>
                            </div>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-hover table-striped mb-0">
                                    <thead class="bg-200">
                                        <tr>
                                            <th>Transaction Type</th>
                                            <th>Code</th>
                                            <th class="text-end">Total Count</th>
                                            <th class="text-end">Total Value (LKR)</th>
                                            <th class="text-end">Today Count</th>
                                            <th class="text-end">Today Value (LKR)</th>
                                            <th class="text-end">vs Prev Day</th>
                                        </tr>
                                    </thead>
                                    <tbody id="txnBreakdownBody">
                                        <tr><td colspan="7" class="text-center text-muted py-4">Loading...</td></tr>
                                    </tbody>
                                    <tfoot id="txnBreakdownFoot" class="bg-100 fw-bold"></tfoot>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-12 col-xl-5">
                    <div class="card dashboard-card h-100">
                        <div class="card-header d-flex align-items-center justify-content-between">
                            <div>
                                <h6 class="mb-0 fw-bold text-900"><i class="fas fa-chart-bar me-2 text-primary"></i>Transaction Value by Type</h6>
                                <small class="text-muted">Cumulative successful transaction value (LKR)</small>
                            </div>
                        </div>
                        <div class="card-body">
                            <div style="height: 300px; position: relative;">
                                <canvas id="txnTypeChart"></canvas>
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
        const n = Number(val || 0);
        return n.toLocaleString('en-US', { maximumFractionDigits: 0 });
    }

    function fmtCurrency(val) {
        const n = Number(val || 0);
        return n.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
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
        el.classList.remove('delta-up', 'delta-down', 'delta-flat');

        const formattedDiff = isCurrency ? fmtCurrency(Math.abs(diff)) : fmtInt(Math.abs(diff));
        if (diff > 0) {
            el.classList.add('delta-up');
            el.innerHTML = '<i class="fas fa-arrow-up"></i> +' + formattedDiff + ' vs prev';
        } else if (diff < 0) {
            el.classList.add('delta-down');
            el.innerHTML = '<i class="fas fa-arrow-down"></i> -' + formattedDiff + ' vs prev';
        } else {
            el.classList.add('delta-flat');
            el.innerHTML = '<i class="fas fa-minus"></i> 0 vs prev';
        }
    }

    function deltaPillHtml(todayVal, prevVal) {
        const diff = Number(todayVal || 0) - Number(prevVal || 0);
        if (diff > 0) return '<span class="delta-badge delta-up">+' + fmtInt(diff) + '</span>';
        if (diff < 0) return '<span class="delta-badge delta-down">' + fmtInt(diff) + '</span>';
        return '<span class="delta-badge delta-flat">0</span>';
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
        $('#refreshBtn').prop('disabled', true);
        $('#refreshIcon').addClass('fa-spin');

        fetch('${pageContext.request.contextPath}/api/mobile-app-dashboard/summary?asAt=' + encodeURIComponent(asAt))
            .then(async res => {
                const body = await res.json();
                if (!res.ok || body.error) {
                    throw new Error(body.message || 'HTTP ' + res.status);
                }
                return body;
            })
            .then(data => {
                $('#lastUpdatedText').text(data.lastUpdated || '-');

                // Customer / App KPIs
                const c = data.customerInfo || {};
                $('#kpiInitiated').text(fmtInt(c.totalInitiated));
                $('#kpiInitiatedToday').text('On ' + data.asAtDate + ': +' + fmtInt(c.initiatedToday));
                renderDeltaBadge('kpiInitiatedDelta', c.initiatedToday, c.initiatedPrev, false);

                $('#kpiActive').text(fmtInt(c.totalActive));
                $('#kpiActiveToday').text('On ' + data.asAtDate + ': +' + fmtInt(c.activeToday));
                renderDeltaBadge('kpiActiveDelta', c.activeToday, c.activePrev, false);

                $('#kpiNonFintrex').text(fmtInt(c.totalNonFintrex));
                $('#kpiNonFintrexToday').text('On ' + data.asAtDate + ': +' + fmtInt(c.nonFintrexToday));
                renderDeltaBadge('kpiNonFintrexDelta', c.nonFintrexToday, c.nonFintrexPrev, false);

                $('#kpiSavings').text(fmtInt(c.totalSavings));
                $('#kpiSavingsToday').text('On ' + data.asAtDate + ': +' + fmtInt(c.savingsToday));
                renderDeltaBadge('kpiSavingsDelta', c.savingsToday, c.savingsPrev, false);

                // Transaction & CEFT KPIs
                const t = data.transactionInfo || {};
                $('#kpiTxnCount').text(fmtInt(t.totalSuccessCount));
                $('#kpiTxnCountToday').text('On ' + data.asAtDate + ': ' + fmtInt(t.todaySuccessCount));
                renderDeltaBadge('kpiTxnCountDelta', t.todaySuccessCount, t.prevSuccessCount, false);

                $('#kpiTxnValue').text(fmtCompactLkr(t.totalSuccessValue)).attr('title', 'LKR ' + fmtCurrency(t.totalSuccessValue));
                $('#kpiTxnValueToday').text('On ' + data.asAtDate + ': ' + fmtCompactLkr(t.todaySuccessValue));
                renderDeltaBadge('kpiTxnValueDelta', t.todaySuccessValue, t.prevSuccessValue, true);

                const ceft = data.ceftRevenue || {};
                $('#kpiCeftRevenue').text('LKR ' + fmtCurrency(ceft.totalCeftRevenue));
                $('#kpiCeftRevenueToday').text('On ' + data.asAtDate + ': LKR ' + fmtCurrency(ceft.todayCeftRevenue) + ' (' + fmtInt(ceft.todayCeftCount) + ' txns)');
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
                $('#refreshBtn').prop('disabled', false);
                $('#refreshIcon').removeClass('fa-spin');
            });
    }

    function renderCeftTable(ceft) {
        const rows = ceft.breakdown || [];
        let html = '';
        rows.forEach(r => {
            html += '<tr>' +
                '<td class="fw-semi-bold text-900">' + escapeHtml(r.transactionType) + '</td>' +
                '<td><span class="code-pill">' + escapeHtml(r.transactionCode) + '</span></td>' +
                '<td class="text-end fw-semi-bold">' + fmtInt(r.successCount) + '</td>' +
                '<td class="text-end">' + fmtInt(r.todayCount) + ' ' + deltaPillHtml(r.todayCount, r.prevCount) + '</td>' +
                '<td class="text-end text-muted">' + fmtCurrency(r.feePerTxn) + '</td>' +
                '<td class="text-end fw-bold text-primary">' + fmtCurrency(r.revenue) + '</td>' +
            '</tr>';
        });
        $('#ceftTableBody').html(html || '<tr><td colspan="6" class="text-center text-muted py-3">No CEFT transactions found</td></tr>');

        $('#ceftTableFoot').html(
            '<tr>' +
                '<td colspan="2" class="text-900">Total CEFT Revenue</td>' +
                '<td class="text-end">' + fmtInt(ceft.totalCeftCount) + '</td>' +
                '<td class="text-end">' + fmtInt(ceft.todayCeftCount) + ' ' + deltaPillHtml(ceft.todayCeftCount, ceft.prevCeftCount) + '</td>' +
                '<td class="text-end text-muted">' + fmtCurrency(ceft.feePerTxn || 25) + '</td>' +
                '<td class="text-end text-primary">LKR ' + fmtCurrency(ceft.totalCeftRevenue) + '</td>' +
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
            const ceftTag = item.isCeft ? ' <span class="ceft-pill ms-1">CEFT</span>' : '';
            html += '<tr>' +
                '<td class="fw-semi-bold text-900">' + escapeHtml(item.displayName) + ceftTag + '</td>' +
                '<td><span class="code-pill">' + escapeHtml(item.txnCode) + '</span></td>' +
                '<td class="text-end">' + fmtInt(item.totalCount) + '</td>' +
                '<td class="text-end fw-semi-bold">' + fmtCurrency(item.totalValue) + '</td>' +
                '<td class="text-end">' + fmtInt(item.todayCount) + '</td>' +
                '<td class="text-end">' + fmtCurrency(item.todayValue) + '</td>' +
                '<td class="text-end">' + deltaPillHtml(item.todayCount, item.prevCount) + '</td>' +
            '</tr>';
        });
        $('#txnBreakdownBody').html(html);

        $('#txnBreakdownFoot').html(
            '<tr>' +
                '<td colspan="2">Total</td>' +
                '<td class="text-end">' + fmtInt(totals.totalSuccessCount) + '</td>' +
                '<td class="text-end">' + fmtCurrency(totals.totalSuccessValue) + '</td>' +
                '<td class="text-end">' + fmtInt(totals.todaySuccessCount) + '</td>' +
                '<td class="text-end">' + fmtCurrency(totals.todaySuccessValue) + '</td>' +
                '<td class="text-end">' + deltaPillHtml(totals.todaySuccessCount, totals.prevSuccessCount) + '</td>' +
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
                        backgroundColor: 'rgba(99, 102, 241, 0.72)',
                        borderRadius: 4,
                        yAxisID: 'y'
                    },
                    {
                        label: 'CEFT Revenue (LKR)',
                        data: ceftRev,
                        type: 'line',
                        borderColor: '#10b981',
                        backgroundColor: 'rgba(16, 185, 129, 0.12)',
                        borderWidth: 2,
                        tension: 0.3,
                        pointRadius: 3,
                        yAxisID: 'y1'
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                interaction: { mode: 'index', intersect: false },
                plugins: {
                    legend: { position: 'bottom', labels: { boxWidth: 12, font: { size: 11 } } }
                },
                scales: {
                    y: { beginAtZero: true, position: 'left', title: { display: true, text: 'Txns', font: { size: 10 } } },
                    y1: { beginAtZero: true, position: 'right', grid: { drawOnChartArea: false }, title: { display: true, text: 'LKR', font: { size: 10 } } }
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
                    backgroundColor: top.map(i => i.isCeft ? 'rgba(99, 102, 241, 0.85)' : 'rgba(14, 165, 233, 0.72)'),
                    borderRadius: 5
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
                    x: {
                        beginAtZero: true,
                        ticks: {
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
