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
            .log-bg {
                background-color: #f8fafc;
            }

            .ft-size {
                font-size: small;
            }
        </style>

        <body>
            <main class="main" id="top">
                <div class="container-fluid log-bg">
                    <div class="row min-vh-100 flex-center g-0">
                        <div class="col-lg-5 col-xxl-5 py-3 position-relative">
                            <div class="card overflow-hidden z-index-1">
                                <div class="card-body p-0">
                                    <div class="row g-0 h-100">
                                        <div class="col-md-5 text-center">
                                            <div class="position-relative p-4 pt-md-5 pb-md-7 light">
                                                <div class="row">
                                                    <div class="col-sm-12">
                                                        <!--<img src="assets/img/fintrex-logo.png" width="70%">-->
                                                    </div>
                                                </div>
                                                <div class="bg-holder bg-auth-card-shape">
                                                    <img src="assets/img/login_img.png" width="100%"
                                                        style="opacity: 0.8">
                                                </div>
                                                <div class="z-index-1 position-relative">
                                                    <p class="opacity-75 text-white"></p>
                                                </div>
                                            </div>
                                            <div class="mt-3 mb-4 mt-md-4 mb-md-5 light">
                                                <p class="text-white"><br><a
                                                        class="text-decoration-underline link-light"
                                                        href="register.html"></a></p>
                                                <p class="mb-0 mt-4 mt-md-5 fs--1 fw-semi-bold text-white opacity-75"><a
                                                        class="text-decoration-underline text-white" href="#!"></a> <a
                                                        class="text-decoration-underline text-white" href="#!"> </a></p>
                                            </div>
                                        </div>
                                        <div class="col-md-7 d-flex flex-center">
                                            <div class="p-4 p-md-5 flex-grow-1">
                                                <div class="row flex-between-center">
                                                    <div class="col-auto">
                                                        <h3>LOGIN</h3>
                                                    </div>
                                                </div>
                                                <div id="error-message" class="alert alert-danger p-2 fs--1"
                                                    style="display: none;"></div>

                                                <button id="ssoLoginBtn" class="btn btn-outline-primary d-block w-100" type="button">
                                                    <span class="fas fa-key me-2"></span>Login with SSO
                                                </button>
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