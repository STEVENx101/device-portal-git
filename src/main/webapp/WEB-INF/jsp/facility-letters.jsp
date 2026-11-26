<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en-US" dir="ltr">

<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Fintrex | Facility Letters Generator</title>

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
    <link href="${pageContext.request.contextPath}/vendors/choices/choices.min.css" rel="stylesheet">

    <script>
        var linkRTL = document.getElementById('style-rtl');
        var userLinkRTL = document.getElementById('user-style-rtl');
        linkRTL.setAttribute('disabled', true);
        userLinkRTL.setAttribute('disabled', true);
    </script>

    <style>
        :root {
            --fl-primary: #4f46e5;
            --fl-secondary: #6366f1;
            --fl-purple: #a855f7;
            --fl-surface: #ffffff;
            --fl-border: #e2e8f0;
            --fl-text: #0f172a;
            --fl-muted: #475569;
        }

        body, .main, p, div, span, select, input, button, table, h1, h2, h3, h4, h5, h6 {
            font-family: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, sans-serif !important;
        }

        .fl-header-bar {
            flex: 0 0 auto;
            flex-shrink: 0;
            background: linear-gradient(135deg, #4f46e5 0%, #6366f1 50%, #a855f7 100%);
            border-radius: 14px;
            padding: 1.1rem 1.5rem;
            color: #ffffff;
            box-shadow: 0 10px 26px -8px rgba(99, 102, 241, 0.38);
            position: relative;
            overflow: hidden;
        }
        .fl-header-bar::after {
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
        .fl-header-title {
            font-size: 1.3rem;
            font-weight: 800;
            color: #ffffff;
            letter-spacing: -0.025em;
            margin: 0;
        }
        .fl-header-sub {
            font-size: 0.81rem;
            color: rgba(255, 255, 255, 0.85);
            margin-top: 0.18rem;
        }
        .fl-dir-badge {
            background: rgba(255, 255, 255, 0.16);
            border: 1px solid rgba(255, 255, 255, 0.28);
            color: #ffffff;
            border-radius: 999px;
            padding: 0.35rem 0.85rem;
            font-size: 0.75rem;
            font-weight: 600;
            backdrop-filter: blur(8px);
        }

        .fl-scroll-body {
            flex: 1 1 auto;
            min-height: 0;
            overflow-y: auto;
            overflow-x: hidden;
            padding: 2px 4px 18px 2px;
        }

        .fl-panel {
            background: var(--fl-surface);
            border: 1px solid var(--fl-border);
            border-radius: 14px;
            box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04);
            overflow: visible;
        }
        .fl-panel-header {
            padding: 1rem 1.3rem;
            border-bottom: 1px solid #f1f5f9;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 0.75rem;
        }
        .fl-panel-title {
            font-size: 0.96rem;
            font-weight: 700;
            color: var(--fl-text);
            margin: 0;
        }
        .fl-panel-sub {
            font-size: 0.76rem;
            color: var(--fl-muted);
            margin-top: 0.12rem;
        }

        .fl-step-label {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 0.77rem;
            font-weight: 700;
            color: #334155;
            margin-bottom: 0.4rem;
        }
        .fl-step-num {
            width: 20px;
            height: 20px;
            border-radius: 999px;
            background: #eef2ff;
            color: #4f46e5;
            font-size: 0.7rem;
            font-weight: 800;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }

        /* Category Pills */
        .fl-cat-group {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 0.5rem;
        }
        .fl-cat-btn {
            border: 1px solid #cbd5e1;
            background: #ffffff;
            color: #334155;
            border-radius: 10px;
            padding: 0.5rem 0.6rem;
            font-size: 0.8rem;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.18s ease;
        }
        .fl-cat-btn:hover {
            border-color: #6366f1;
            color: #4f46e5;
            background: #f5f3ff;
        }
        .fl-cat-btn.active {
            background: linear-gradient(135deg, #4f46e5 0%, #6366f1 100%);
            border-color: transparent;
            color: #ffffff;
            box-shadow: 0 4px 12px rgba(79, 70, 229, 0.25);
        }

        /* Print Mode Cards */
        .fl-mode-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 0.6rem;
        }
        .fl-mode-card {
            border: 1.5px solid #e2e8f0;
            border-radius: 10px;
            padding: 0.65rem 0.75rem;
            cursor: pointer;
            background: #ffffff;
            transition: border-color 0.18s ease, background-color 0.18s ease;
        }
        .fl-mode-card:hover {
            border-color: #a5b4fc;
            background: #fafaff;
        }
        .fl-mode-card.active {
            border-color: #4f46e5;
            background: #eef2ff;
        }
        .fl-mode-title {
            font-size: 0.78rem;
            font-weight: 700;
            color: #0f172a;
        }
        .fl-mode-desc {
            font-size: 0.69rem;
            color: #64748b;
            margin-top: 2px;
            line-height: 1.25;
        }

        /* Action Buttons */
        .fl-btn-primary {
            background: linear-gradient(135deg, #4f46e5 0%, #6366f1 60%, #a855f7 100%);
            border: none;
            color: #ffffff;
            border-radius: 10px;
            padding: 0.65rem 1.1rem;
            font-size: 0.84rem;
            font-weight: 700;
            cursor: pointer;
            transition: opacity 0.18s ease, box-shadow 0.18s ease;
            box-shadow: 0 6px 16px rgba(99, 102, 241, 0.28);
        }
        .fl-btn-primary:hover {
            opacity: 0.94;
            color: #ffffff;
            box-shadow: 0 8px 20px rgba(99, 102, 241, 0.36);
        }
        .fl-btn-primary:disabled {
            opacity: 0.55;
            cursor: not-allowed;
        }
        .fl-btn-outline {
            background: #ffffff;
            border: 1.5px solid #cbd5e1;
            color: #1e293b;
            border-radius: 10px;
            padding: 0.62rem 1rem;
            font-size: 0.82rem;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.18s ease;
        }
        .fl-btn-outline:hover {
            border-color: #4f46e5;
            color: #4f46e5;
            background: #eef2ff;
        }
        .fl-btn-outline:disabled {
            opacity: 0.55;
            cursor: not-allowed;
        }

        /* Preview Frame */
        .fl-preview-wrap {
            background: #f1f5f9;
            border-radius: 0 0 14px 14px;
            min-height: 540px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            position: relative;
            overflow: hidden;
        }
        .fl-preview-empty {
            text-align: center;
            padding: 2.5rem 2rem;
            max-width: 380px;
        }
        .fl-preview-empty h6 {
            font-size: 0.98rem;
            font-weight: 700;
            color: #0f172a;
            margin-bottom: 0.4rem;
        }
        .fl-preview-empty p {
            font-size: 0.8rem;
            color: #64748b;
            margin: 0;
        }
        #pdfPreviewFrame {
            width: 100%;
            height: 600px;
            border: none;
            display: none;
            background: #ffffff;
        }

        /* Tabs */
        .fl-tab-btn {
            border: none;
            background: transparent;
            font-size: 0.8rem;
            font-weight: 700;
            color: #64748b;
            padding: 0.45rem 0.9rem;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.16s ease;
        }
        .fl-tab-btn.active {
            background: #eef2ff;
            color: #4f46e5;
        }

        /* Choices styling */
        .choices {
            margin-bottom: 0;
        }
        .choices__inner {
            background: #ffffff !important;
            border: 1px solid #cbd5e1 !important;
            border-radius: 10px !important;
            min-height: 40px !important;
            padding: 5px 10px !important;
            font-size: 0.84rem !important;
        }
        .choices__list--dropdown {
            border-radius: 10px !important;
            border: 1px solid #cbd5e1 !important;
            box-shadow: 0 10px 24px rgba(15, 23, 42, 0.1) !important;
            z-index: 30 !important;
        }

        /* Audit Table */
        .fl-table {
            width: 100%;
            margin-bottom: 0;
            border-collapse: collapse;
        }
        .fl-table thead th {
            background: #f8fafc;
            color: #475569;
            font-size: 0.7rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            padding: 0.7rem 0.9rem;
            border-bottom: 1px solid #e2e8f0;
        }
        .fl-table tbody td {
            padding: 0.7rem 0.9rem;
            font-size: 0.8rem;
            color: #0f172a;
            border-bottom: 1px solid #f1f5f9;
        }
        .fl-badge-mode {
            font-size: 0.68rem;
            font-weight: 700;
            padding: 2px 7px;
            border-radius: 999px;
            background: #eef2ff;
            color: #4f46e5;
        }
        .fl-badge-fmt {
            font-family: 'Fira Code', monospace !important;
            font-size: 0.68rem;
            font-weight: 600;
            padding: 2px 6px;
            border-radius: 5px;
            background: #f1f5f9;
            color: #334155;
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

            <!-- Executive Header -->
            <div class="fl-header-bar d-flex flex-wrap align-items-center justify-content-between gap-3 mb-3 mt-2">
                <div>
                    <h4 class="fl-header-title">Facility Letters Generator</h4>
                    <div class="fl-header-sub">Generate, preview, and download leasing &amp; facility documents in PDF or Word format</div>
                </div>
                <div class="position-relative" style="z-index: 2;">
                    <span class="fl-dir-badge" id="templateCountBadge">25 Templates Ready</span>
                </div>
            </div>

            <div class="fl-scroll-body">
                <!-- Status / Error Alert -->
                <div id="flAlert" class="alert alert-danger d-none align-items-center justify-content-between mb-3 rounded-3" role="alert">
                    <span id="flAlertMsg"></span>
                    <button type="button" class="btn-close" onclick="$('#flAlert').addClass('d-none').removeClass('d-flex')"></button>
                </div>

                <div class="row g-3">
                    <!-- Left Column: Letter Configuration -->
                    <div class="col-12 col-xl-5">
                        <div class="fl-panel p-3 p-md-4">
                            <div class="mb-3 pb-2 border-bottom">
                                <h6 class="fl-panel-title">Document Configuration</h6>
                                <div class="fl-panel-sub">Select product, letter template, agreement, and print mode</div>
                            </div>

                            <!-- Step 1: Product Category -->
                            <div class="mb-3">
                                <div class="fl-step-label"><span class="fl-step-num">1</span> Product Category</div>
                                <div class="fl-cat-group" id="categoryGroup">
                                    <button type="button" class="fl-cat-btn active" data-cat="ALL">All</button>
                                    <button type="button" class="fl-cat-btn" data-cat="2W">2W</button>
                                    <button type="button" class="fl-cat-btn" data-cat="3W">3W</button>
                                    <button type="button" class="fl-cat-btn" data-cat="4W">4W</button>
                                </div>
                            </div>

                            <!-- Step 2: Letter Template Dropdown (from device_portal.letter_template) -->
                            <div class="mb-3">
                                <div class="fl-step-label"><span class="fl-step-num">2</span> Select Letter Template</div>
                                <select id="selectLetter" class="form-select"></select>
                            </div>

                            <!-- Step 3: Product (from CMS DB) -->
                            <div class="mb-3">
                                <div class="fl-step-label"><span class="fl-step-num">3</span> Product</div>
                                <select id="selectProduct" class="form-select"></select>
                            </div>

                            <!-- Step 4: Agreement / Lease No -->
                            <div class="mb-3">
                                <div class="fl-step-label"><span class="fl-step-num">4</span> Agreement No</div>
                                <select id="selectLease" class="form-select"></select>
                                <div class="form-text text-muted mt-1" style="font-size: 0.72rem;">
                                    Optional when generating a blank <strong>Document Template</strong>.
                                </div>
                            </div>

                            <!-- Step 5: Print Mode -->
                            <div class="mb-4">
                                <div class="fl-step-label"><span class="fl-step-num">5</span> Print Mode</div>
                                <div class="fl-mode-grid" id="modeGrid">
                                    <div class="fl-mode-card active" data-mode="Full_Document">
                                        <div class="fl-mode-title">Complete</div>
                                        <div class="fl-mode-desc">Full letter text &amp; filled values</div>
                                    </div>
                                    <div class="fl-mode-card" data-mode="Doc_Format">
                                        <div class="fl-mode-title">Template</div>
                                        <div class="fl-mode-desc">Static layout only, values blank</div>
                                    </div>
                                    <div class="fl-mode-card" data-mode="Pre_Printed_Document">
                                        <div class="fl-mode-title">Pre-Printed</div>
                                        <div class="fl-mode-desc">Values only for letterhead paper</div>
                                    </div>
                                </div>
                            </div>

                            <!-- Action Buttons -->
                            <div class="d-grid gap-2">
                                <button type="button" id="previewPdfBtn" class="fl-btn-primary">
                                    Preview PDF
                                </button>
                                <div class="row g-2">
                                    <div class="col-6">
                                        <button type="button" id="downloadPdfBtn" class="fl-btn-outline w-100">
                                            Download PDF
                                        </button>
                                    </div>
                                    <div class="col-6">
                                        <button type="button" id="downloadDocxBtn" class="fl-btn-outline w-100">
                                            Download DOCX
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Right Column: Inline Preview & Recent History -->
                    <div class="col-12 col-xl-7">
                        <div class="fl-panel h-100 d-flex flex-column">
                            <div class="fl-panel-header">
                                <div>
                                    <h6 class="fl-panel-title" id="rightPanelTitle">Live Document Preview</h6>
                                    <div class="fl-panel-sub" id="rightPanelSub">Click Preview PDF to inspect the generated letter before printing</div>
                                </div>
                                <div class="d-flex align-items-center gap-1">
                                    <button type="button" class="fl-tab-btn active" id="tabPreviewBtn">Preview</button>
                                    <button type="button" class="fl-tab-btn" id="tabHistoryBtn">Recent History</button>
                                </div>
                            </div>

                            <!-- Preview Pane -->
                            <div id="previewPane" class="fl-preview-wrap flex-grow-1">
                                <div class="fl-preview-empty" id="previewEmptyState">
                                    <h6>Ready to Generate</h6>
                                    <p>Choose a letter template, select an agreement number (or pick <strong>Template</strong> mode), and click <strong>Preview PDF</strong> to view it right here.</p>
                                </div>
                                <iframe id="pdfPreviewFrame" title="Generated Facility Letter PDF Preview"></iframe>
                            </div>

                            <!-- History Pane -->
                            <div id="historyPane" class="d-none flex-grow-1">
                                <div class="table-responsive">
                                    <table class="fl-table">
                                        <thead>
                                            <tr>
                                                <th>Date</th>
                                                <th>Letter</th>
                                                <th>Agreement</th>
                                                <th>Customer</th>
                                                <th>Mode</th>
                                                <th>Format</th>
                                                <th>User</th>
                                            </tr>
                                        </thead>
                                        <tbody id="historyTableBody">
                                            <tr><td colspan="7" class="text-center text-muted py-4">Loading history...</td></tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<script src="${pageContext.request.contextPath}/vendors/jquery/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/vendors/popper/popper.min.js"></script>
<script src="${pageContext.request.contextPath}/vendors/bootstrap/bootstrap.min.js"></script>
<script src="${pageContext.request.contextPath}/vendors/fontawesome/all.min.js"></script>
<script src="${pageContext.request.contextPath}/vendors/choices/choices.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/theme.js"></script>

<script>
    const CTX = '${pageContext.request.contextPath}';
    let selectedCategory = 'ALL';
    let selectedMode = 'Full_Document';
    let letterChoices, productChoices, leaseChoices;
    let currentPreviewBlobUrl = null;
    let productLookup = {};

    function showError(msg) {
        $('#flAlertMsg').text(msg);
        $('#flAlert').removeClass('d-none').addClass('d-flex');
    }

    function clearError() {
        $('#flAlert').addClass('d-none').removeClass('d-flex');
    }

    function setBusy(busy, label) {
        $('#previewPdfBtn, #downloadPdfBtn, #downloadDocxBtn').prop('disabled', busy);
        $('#previewPdfBtn').text(busy ? (label || 'Generating...') : 'Preview PDF');
    }

    function loadLetterTemplates(category) {
        fetch(CTX + '/api/facility-letters/templates?category=' + encodeURIComponent(category))
            .then(r => r.json())
            .then(data => {
                const list = (data.templates || []).map(t => ({
                    value: t.file_name,
                    label: t.letter_name
                }));
                $('#templateCountBadge').text(list.length + ' Templates Ready');
                letterChoices.clearStore();
                letterChoices.setChoices(
                    [{ value: '', label: 'Select a letter template...', placeholder: true, selected: true }].concat(list),
                    'value', 'label', true
                );
            })
            .catch(err => showError('Unable to load letter templates: ' + err.message));
    }

    function loadProducts(category, search) {
        const catParam = category === 'ALL' ? '' : category;
        fetch(CTX + '/api/facility-letters/products?category=' + encodeURIComponent(catParam) + '&q=' + encodeURIComponent(search || ''))
            .then(async r => {
                const data = await r.json();
                if (!r.ok || data.error) throw new Error(data.message || 'CMS DB unavailable');
                return data;
            })
            .then(rows => {
                productLookup = {};
                const choices = rows.map(row => {
                    productLookup[String(row.value)] = row.text;
                    return { value: String(row.value), label: row.text };
                });
                productChoices.clearStore();
                productChoices.setChoices(
                    [{ value: '', label: 'Select product...', placeholder: true, selected: true }].concat(choices),
                    'value', 'label', true
                );
                clearLeaseDropdown();
            })
            .catch(err => {
                productChoices.clearStore();
                productChoices.setChoices([{ value: '', label: 'Unable to load products (' + err.message + ')', disabled: true, selected: true }], 'value', 'label', true);
            });
    }

    function clearLeaseDropdown() {
        leaseChoices.clearStore();
        leaseChoices.setChoices([{ value: '', label: 'Select product first...', placeholder: true, selected: true }], 'value', 'label', true);
    }

    function loadLeases(productId, productName, search) {
        if (!productId) {
            clearLeaseDropdown();
            return;
        }
        const url = CTX + '/api/facility-letters/leases?productId=' + encodeURIComponent(productId) +
            '&productName=' + encodeURIComponent(productName || '') +
            '&q=' + encodeURIComponent(search || '');
        fetch(url)
            .then(async r => {
                const data = await r.json();
                if (!r.ok || data.error) throw new Error(data.message || 'Unable to load agreements');
                return data;
            })
            .then(rows => {
                const choices = rows.map(row => ({ value: String(row.value), label: row.text }));
                leaseChoices.clearStore();
                leaseChoices.setChoices(
                    [{ value: '', label: choices.length ? 'Select agreement no...' : 'No agreements found', placeholder: true, selected: true }].concat(choices),
                    'value', 'label', true
                );
            })
            .catch(err => showError('Unable to load agreements: ' + err.message));
    }

    function loadHistory() {
        fetch(CTX + '/api/facility-letters/logs')
            .then(r => r.json())
            .then(rows => {
                if (!rows || !rows.length) {
                    $('#historyTableBody').html('<tr><td colspan="7" class="text-center text-muted py-4">No letters generated yet.</td></tr>');
                    return;
                }
                const html = rows.map(r =>
                    '<tr>' +
                        '<td class="text-nowrap text-muted">' + escapeHtml(r.generated_at) + '</td>' +
                        '<td class="fw-semi-bold">' + escapeHtml(r.letter_name) + '</td>' +
                        '<td>' + escapeHtml(r.agreement_no || '-') + '</td>' +
                        '<td>' + escapeHtml(r.customer_name || '-') + '</td>' +
                        '<td><span class="fl-badge-mode">' + escapeHtml(r.letter_type) + '</span></td>' +
                        '<td><span class="fl-badge-fmt">' + escapeHtml(r.output_format) + '</span></td>' +
                        '<td class="text-muted">' + escapeHtml(r.generated_by || '-') + '</td>' +
                    '</tr>'
                ).join('');
                $('#historyTableBody').html(html);
            })
            .catch(() => $('#historyTableBody').html('<tr><td colspan="7" class="text-center text-muted py-4">Unable to load history.</td></tr>'));
    }

    function escapeHtml(s) {
        return String(s || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    }

    function buildPayload(outputFormat, inline) {
        const letterFileName = letterChoices.getValue(true) || '';
        const productId = productChoices.getValue(true) || '';
        const productName = productLookup[productId] || '';
        const leaseId = leaseChoices.getValue(true) || '';

        if (!letterFileName) {
            showError('Please select a Letter Template.');
            return null;
        }
        if (!leaseId && selectedMode !== 'Doc_Format') {
            showError('Please select an Agreement No (or choose Template mode to preview a blank template).');
            return null;
        }
        return {
            productCategory: selectedCategory,
            productId: productId,
            productName: productName,
            letterFileName: letterFileName,
            leaseId: leaseId,
            letterType: selectedMode,
            outputFormat: outputFormat,
            inline: String(inline)
        };
    }

    async function requestDocument(outputFormat, inline) {
        clearError();
        const payload = buildPayload(outputFormat, inline);
        if (!payload) return;

        setBusy(true, inline ? 'Rendering Preview...' : 'Generating ' + outputFormat + '...');
        try {
            const res = await fetch(CTX + '/api/facility-letters/generate', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload)
            });

            if (!res.ok) {
                let errMsg = 'Failed to generate document (HTTP ' + res.status + ')';
                try {
                    const errJson = await res.json();
                    if (errJson.message) errMsg = errJson.message;
                } catch (_) {}
                throw new Error(errMsg);
            }

            const blob = await res.blob();
            const suggestedName = res.headers.get('X-Suggested-Filename') || ('Facility_Letter.' + outputFormat.toLowerCase());

            if (inline && outputFormat === 'PDF') {
                if (currentPreviewBlobUrl) URL.revokeObjectURL(currentPreviewBlobUrl);
                currentPreviewBlobUrl = URL.createObjectURL(blob);
                $('#previewEmptyState').hide();
                $('#pdfPreviewFrame').attr('src', currentPreviewBlobUrl).show();
                switchTab('preview');
            } else {
                const url = URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = suggestedName;
                document.body.appendChild(a);
                a.click();
                a.remove();
                setTimeout(() => URL.revokeObjectURL(url), 5000);
            }
            loadHistory();
        } catch (err) {
            showError(err.message);
        } finally {
            setBusy(false);
        }
    }

    function switchTab(tab) {
        if (tab === 'history') {
            $('#tabHistoryBtn').addClass('active');
            $('#tabPreviewBtn').removeClass('active');
            $('#previewPane').addClass('d-none');
            $('#historyPane').removeClass('d-none');
            $('#rightPanelTitle').text('Recent Generated Letters');
            $('#rightPanelSub').text('Audit log of the last 30 facility letters generated in this portal');
            loadHistory();
        } else {
            $('#tabPreviewBtn').addClass('active');
            $('#tabHistoryBtn').removeClass('active');
            $('#historyPane').addClass('d-none');
            $('#previewPane').removeClass('d-none');
            $('#rightPanelTitle').text('Live Document Preview');
            $('#rightPanelSub').text('Inspect the generated PDF before downloading or printing');
        }
    }

    $(document).ready(function () {
        letterChoices = new Choices('#selectLetter', { searchEnabled: true, itemSelectText: '', shouldSort: false });
        productChoices = new Choices('#selectProduct', { searchEnabled: true, itemSelectText: '', shouldSort: false });
        leaseChoices = new Choices('#selectLease', { searchEnabled: true, itemSelectText: '', shouldSort: false });

        // Category filter buttons
        $('#categoryGroup').on('click', '.fl-cat-btn', function () {
            $('#categoryGroup .fl-cat-btn').removeClass('active');
            $(this).addClass('active');
            selectedCategory = $(this).data('cat');
            loadLetterTemplates(selectedCategory);
            loadProducts(selectedCategory, '');
        });

        // Print mode cards
        $('#modeGrid').on('click', '.fl-mode-card', function () {
            $('#modeGrid .fl-mode-card').removeClass('active');
            $(this).addClass('active');
            selectedMode = $(this).data('mode');
        });

        // Product change -> load agreements
        $('#selectProduct').on('change', function () {
            const pid = productChoices.getValue(true) || '';
            loadLeases(pid, productLookup[pid] || '', '');
        });

        // Tabs
        $('#tabPreviewBtn').on('click', () => switchTab('preview'));
        $('#tabHistoryBtn').on('click', () => switchTab('history'));

        // Actions
        $('#previewPdfBtn').on('click', () => requestDocument('PDF', true));
        $('#downloadPdfBtn').on('click', () => requestDocument('PDF', false));
        $('#downloadDocxBtn').on('click', () => requestDocument('DOCX', false));

        // Initial load
        loadLetterTemplates('ALL');
        loadProducts('ALL', '');
    });
</script>
</body>
</html>
