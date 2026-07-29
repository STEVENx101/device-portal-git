<%-- Document : login Created on : Jul 6, 2026, 12:43:02 PM Author : poornap --%>

    <%@page contentType="text/html" pageEncoding="UTF-8" %>
        <!DOCTYPE html>
        <html lang="en-US" dir="ltr">

        <head>
            <meta charset="utf-8">
            <meta http-equiv="X-UA-Compatible" content="IE=edge">
            <meta name="viewport" content="width=device-width, initial-scale=1">

            <title>Fintrex | Dashboard &amp; Device Finance Portal</title>

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
            <link
                href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,500,600,700%7cPoppins:300,400,500,600,700,800,900&amp;display=swap"
                rel="stylesheet">
            <link href="vendors/simplebar/simplebar.min.css" rel="stylesheet">
            <link href="assets/css/theme-rtl.min.css" rel="stylesheet" id="style-rtl">
            <link href="assets/css/theme.min.css" rel="stylesheet" id="style-default">
            <link href="assets/css/user-rtl.min.css" rel="stylesheet" id="user-style-rtl">
            <link href="assets/css/user.min.css" rel="stylesheet" id="user-style-default">
            <script>
                var isRTL = JSON.parse(localStorage.getItem('isRTL'));
                if (isRTL) {
                    var linkDefault = document.getElementById('style-default');
                    var userLinkDefault = document.getElementById('user-style-default');
                    linkDefault.setAttribute('disabled', true);
                    userLinkDefault.setAttribute('disabled', true);
                    document.querySelector('html').setAttribute('dir', 'rtl');
                } else {
                    var linkRTL = document.getElementById('style-rtl');
                    var userLinkRTL = document.getElementById('user-style-rtl');
                    linkRTL.setAttribute('disabled', true);
                    userLinkRTL.setAttribute('disabled', true);
                }
            </script>
        </head>

        <style>
            @import url('https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap');

            body {
                font-family: 'Plus Jakarta Sans', sans-serif;
                background-color: #f8fafc !important;
                background-image: radial-gradient(rgba(99, 102, 241, 0.04) 1.5px, transparent 1.5px) !important;
                background-size: 24px 24px !important;
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .main-login-container {
                width: 100%;
                max-width: 950px;
                padding: 1.5rem;
            }

            .login-card {
                background: rgba(255, 255, 255, 0.85) !important;
                backdrop-filter: blur(20px) !important;
                border: 1px solid rgba(255, 255, 255, 0.5) !important;
                box-shadow: 0 25px 50px -12px rgba(99, 102, 241, 0.15) !important;
                border-radius: 24px !important;
                overflow: hidden;
            }

            .login-left-panel {
                background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
                padding: 3rem 2.5rem;
                display: flex;
                flex-direction: column;
                justify-content: space-between;
                color: #ffffff;
                position: relative;
                overflow: hidden;
            }

            .login-left-panel::before {
                content: '';
                position: absolute;
                top: -50%;
                left: -50%;
                width: 200%;
                height: 200%;
                background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, rgba(255,255,255,0) 60%);
                animation: rotate-bg 20s linear infinite;
                pointer-events: none;
            }

            @keyframes rotate-bg {
                0% { transform: rotate(0deg); }
                100% { transform: rotate(360deg); }
            }

            .brand-badge {
                background: rgba(255, 255, 255, 0.15);
                backdrop-filter: blur(8px);
                border: 1px solid rgba(255, 255, 255, 0.2);
                padding: 0.5rem 1rem;
                border-radius: 30px;
                font-family: 'Outfit', sans-serif;
                font-weight: 600;
                font-size: 0.85rem;
                letter-spacing: 0.05em;
                display: inline-flex;
                align-items: center;
                gap: 8px;
                width: fit-content;
            }

            .badge-dot {
                width: 8px;
                height: 8px;
                background-color: #10b981;
                border-radius: 50%;
                box-shadow: 0 0 10px #10b981;
            }

            .left-panel-content {
                z-index: 2;
                margin-top: 4rem;
                margin-bottom: 4rem;
            }

            .left-title {
                font-family: 'Outfit', sans-serif;
                font-weight: 800;
                font-size: 2.2rem;
                line-height: 1.2;
                letter-spacing: -0.02em;
                margin-bottom: 1rem;
                background: linear-gradient(to right, #ffffff, #e0e7ff);
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
            }

            .left-desc {
                font-size: 0.95rem;
                color: #e0e7ff;
                font-weight: 400;
                line-height: 1.6;
            }

            .left-footer {
                z-index: 2;
                font-size: 0.75rem;
                color: rgba(255, 255, 255, 0.7);
                display: flex;
                justify-content: space-between;
                align-items: center;
                border-top: 1px solid rgba(255, 255, 255, 0.1);
                padding-top: 1.5rem;
            }

            .login-right-panel {
                padding: 4rem 3.5rem;
            }

            .right-title {
                font-family: 'Outfit', sans-serif;
                font-weight: 700;
                color: #1e1b4b;
                margin-bottom: 0.5rem;
            }

            .right-subtitle {
                font-size: 0.9rem;
                color: #64748b;
                margin-bottom: 2.5rem;
            }

            .sso-btn {
                background: linear-gradient(135deg, #4f46e5 0%, #6366f1 100%) !important;
                border: none !important;
                color: white !important;
                padding: 0.9rem 1.5rem !important;
                font-weight: 600 !important;
                border-radius: 12px !important;
                box-shadow: 0 4px 15px rgba(79, 70, 229, 0.3) !important;
                transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1) !important;
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 10px;
                width: 100%;
                cursor: pointer;
            }

            .sso-btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 25px rgba(79, 70, 229, 0.45) !important;
                background: linear-gradient(135deg, #4338ca 0%, #4f46e5 100%) !important;
            }

            .sso-btn:active {
                transform: translateY(0);
            }

            .security-notice {
                margin-top: 2rem;
                padding: 1rem;
                background-color: rgba(241, 245, 249, 0.5);
                border-radius: 12px;
                border: 1px solid #e2e8f0;
                font-size: 0.8rem;
                color: #475569;
                display: flex;
                gap: 10px;
                align-items: flex-start;
            }

            .security-icon {
                color: #4f46e5;
                font-size: 1rem;
                margin-top: 2px;
            }

            /* Responsive design */
            @media (max-width: 768px) {
                .login-left-panel {
                    display: none;
                }
                .login-right-panel {
                    padding: 3rem 2rem;
                }
            }
        </style>

        <body>
            <main class="main" id="top">
                <div class="container main-login-container">
                    <div class="card login-card">
                        <div class="card-body p-0">
                            <div class="row g-0 h-100">
                                <div class="col-md-5 login-left-panel">
                                    <div class="brand-badge">
                                        <div class="badge-dot"></div>
                                        FINTREX FINANCE
                                    </div>
                                    <div class="left-panel-content">
                                        <h1 class="left-title">Secure Device Finance Portal</h1>
                                        <p class="left-desc">Access analytics, real-time locking controls, and exception reports in a single secure environment.</p>
                                    </div>
                                    <div class="left-footer">
                                        <span>© 2026 Fintrex Finance</span>
                                        <span>v2.1.0</span>
                                    </div>
                                </div>
                                <div class="col-md-7 d-flex align-items-center">
                                    <div class="login-right-panel w-100">
                                        <h2 class="right-title">Welcome Back</h2>
                                        <p class="right-subtitle">Please authenticate using your corporate SSO credentials.</p>
                                        
                                        <div id="error-message" class="alert alert-danger p-3 fs--1 mb-4" style="display: none; border-radius: 12px;"></div>

                                        <button id="ssoLoginBtn" class="btn sso-btn" type="button">
                                            <span class="fas fa-shield-alt"></span>
                                            <span>Sign in with SSO</span>
                                        </button>

                                        <div class="security-notice">
                                            <span class="fas fa-info-circle security-icon"></span>
                                            <div>
                                                <strong>Authorized Access Only</strong>
                                                <div class="mt-1">This portal contains confidential financial and device management metrics. All logins and activities are monitored.</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </main>


            <script src="vendors/popper/popper.min.js"></script>
            <script src="vendors/bootstrap/bootstrap.min.js"></script>
            <script src="vendors/anchorjs/anchor.min.js"></script>
            <script src="vendors/is/is.min.js"></script>
            <script src="vendors/fontawesome/all.min.js"></script>
            <script src="vendors/lodash/lodash.min.js"></script>
            <script src="polyfill.io/v3/polyfill.min58be.js?features=window.scroll"></script>
            <script src="vendors/list.js/list.min.js"></script>
            <script src="assets/js/theme.js"></script>

            <script>
                const AUTH_SERVER = 'https://auth.fintrexfinance.com:2083';
                const CTX = '<%= request.getContextPath() %>';

                function getRedirectTarget() {
                    const p = new URLSearchParams(window.location.search);
                    return p.get('redirect') || '/dashboard';
                }

                async function redirectToLoginSSO() {
                    const target = getRedirectTarget();
                    // Route directly to the whitelisted device-portal/login endpoint
                    const clientRedirectUrl = window.location.origin + CTX + '/login?sso=true';
                    window.location.href = AUTH_SERVER + '/auth/login?client_redirect_uri=' + encodeURIComponent(clientRedirectUrl) + '&redirect=' + encodeURIComponent(target);
                }

                async function handleSSOClick() {
                    const errorDiv = document.getElementById('error-message');
                    if (errorDiv) errorDiv.style.display = 'none';

                    const ssoBtn = document.getElementById('ssoLoginBtn');
                    ssoBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>Connecting to SSO...';
                    ssoBtn.disabled = true;

                    try {
                        // Check if they already have an active session on the auth server
                        const res = await fetch(AUTH_SERVER + '/me', { credentials: 'include' });
                        if (res.ok) {
                            const ssoUser = await res.json();

                            // Establish local session
                            const localRes = await fetch(CTX + '/api/login-callback', {
                                  method: 'POST',
                                  headers: { 'Content-Type': 'application/json' },
                                  credentials: 'same-origin',
                                  body: JSON.stringify(ssoUser)
                            });

                            if (localRes.ok) {
                                window.location.replace(CTX + getRedirectTarget());
                                return;
                            }
                        }
                    } catch (err) {
                        console.error('SSO verification check failed:', err);
                    }

                    // If check fails or not logged in, proceed to redirect to auth server login page
                    redirectToLoginSSO();
                }

                document.getElementById('ssoLoginBtn').addEventListener('click', handleSSOClick);

                // Auto-trigger callback if returning from SSO server
                const urlParams = new URLSearchParams(window.location.search);
                if (urlParams.get('sso') === 'true') {
                    handleSSOClick();
                }
            </script>
        </body>

        </html>