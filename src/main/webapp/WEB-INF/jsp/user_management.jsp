<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.fintrex.deviceportal.dto.User"%>
<%@page import="com.fintrex.deviceportal.dto.UserType"%>
<%@page import="com.fintrex.deviceportal.dto.Screen"%>
<%@page import="java.util.List"%>
<!DOCTYPE html>
<html lang="en-US" dir="ltr">

    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title>Fintrex | User Management</title>

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
        <link href="${pageContext.request.contextPath}/assets/css/theme-rtl.min.css" rel="stylesheet" id="style-rtl">
        <link href="${pageContext.request.contextPath}/assets/css/theme.min.css" rel="stylesheet" id="style-default">
        <link href="${pageContext.request.contextPath}/assets/css/user-rtl.min.css" rel="stylesheet" id="user-style-rtl">
        <link href="${pageContext.request.contextPath}/assets/css/user.min.css" rel="stylesheet" id="user-style-default">
        <script>
            var linkRTL = document.getElementById('style-rtl');
            var userLinkRTL = document.getElementById('user-style-rtl');
            linkRTL.setAttribute('disabled', true);
            userLinkRTL.setAttribute('disabled', true);
        </script>
        <style>
            .permission-switch {
                font-size: 1.1rem;
            }
            /* Align with theme colors */
            .btn-primary {
                background: linear-gradient(135deg, #6366f1 0%, #a855f7 100%) !important;
                border: none !important;
                box-shadow: 0 4px 12px rgba(99, 102, 241, 0.2) !important;
                color: #ffffff !important;
            }
            .btn-primary:hover, .btn-primary:focus, .btn-primary:active {
                background: linear-gradient(135deg, #4f46e5 0%, #9333ea 100%) !important;
                box-shadow: 0 4px 15px rgba(99, 102, 241, 0.3) !important;
                color: #ffffff !important;
            }
            .text-primary {
                color: #6366f1 !important;
            }
            .bg-soft-primary {
                background-color: rgba(99, 102, 241, 0.15) !important;
                color: #6366f1 !important;
            }
            .bg-primary {
                background: linear-gradient(135deg, #6366f1 0%, #a855f7 100%) !important;
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
                        <div class="d-flex align-items-center"><img class="me-2" src="assets/img/icons/spot-illustrations/falcon.png" alt="" width="40" /><span class="font-sans-serif">falcon</span></div>
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
                        if(navbarTop) navbarTop.remove(navbarTop);
                    </script>

                    <!-- Alert Box -->
                    <div id="alertContainer" class="position-fixed top-0 end-0 p-3" style="z-index: 1100;"></div>

                    <!-- Header -->
                    <div class="d-flex mb-4 align-items-center justify-content-between">
                        <div>
                            <h4 class="mb-1 text-primary"><i class="fas fa-users-cog me-2"></i>User & Access Management</h4>
                            <p class="mb-0 text-500 fs--1">Configure system roles, user details, and screen-level access rights</p>
                        </div>
                        <div>
                            <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#addUserModal">
                                <span class="fas fa-user-plus me-1"></span> New User
                            </button>
                        </div>
                    </div>

                    <div class="row g-4">
                        <!-- Left Panel: User Directory -->
                        <div class="col-lg-7">
                            <div class="card glass-card h-100">
                                <div class="card-header border-bottom border-200 bg-light d-flex flex-wrap justify-content-between align-items-center gap-2">
                                    <h5 class="mb-0 text-800"><span class="fas fa-user-shield me-2"></span>User Accounts</h5>
                                    <div class="d-flex align-items-center gap-2">
                                        <input type="text" id="userSearchInput" class="form-control form-control-sm" placeholder="Search users..." style="max-width: 180px;" />
                                        <span class="badge bg-soft-primary text-primary" id="userCount">0 Users</span>
                                    </div>
                                </div>
                                <div class="card-body p-0">
                                    <div class="table-responsive scrollbar">
                                        <table class="table table-hover table-striped align-middle mb-0 fs--1">
                                            <thead class="bg-200 text-900">
                                                <tr>
                                                    <th class="ps-3">Full Name</th>
                                                    <th>Username</th>
                                                    <th>Email</th>
                                                    <th>Role</th>
                                                    <th class="pe-3 text-end">Action</th>
                                                </tr>
                                            </thead>
                                            <tbody id="userTableBody">
                                                <!-- Dynamic load -->
                                                <% 
                                                    List<User> userList = (List<User>) request.getAttribute("users");
                                                    if (userList != null) {
                                                        for (User u : userList) {
                                                %>
                                                <tr>
                                                    <td class="ps-3 fw-semi-bold text-900"><%= u.getFullName() %></td>
                                                    <td><span class="badge bg-soft-secondary text-secondary font-monospace"><%= u.getUsername() %></span></td>
                                                    <td><%= u.getEmail() %></td>
                                                    <td><span class="badge rounded-pill bg-soft-success text-success"><%= u.getUserTypeName() %></span></td>
                                                    <td class="pe-3 text-end">
                                                        <button class="btn btn-link p-0 edit-user-btn" type="button" 
                                                                data-id="<%= u.getId() %>"
                                                                data-username="<%= u.getUsername() %>"
                                                                data-fullname="<%= u.getFullName() %>"
                                                                data-email="<%= u.getEmail() %>"
                                                                data-role-id="<%= u.getUserTypeId() %>"
                                                                data-bs-toggle="modal" 
                                                                data-bs-target="#editUserModal"
                                                                title="Edit">
                                                            <span class="text-500 fas fa-edit"></span>
                                                        </button>
                                                    </td>
                                                </tr>
                                                <% 
                                                        }
                                                    } 
                                                %>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Right Panel: Screen Permissions -->
                        <div class="col-lg-5">
                            <div class="row g-4">
                                <!-- Card 1: Select Role & Set Permissions -->
                                <div class="col-12">
                                    <div class="card glass-card">
                                        <div class="card-header border-bottom border-200 bg-light">
                                            <h5 class="mb-0 text-800"><span class="fas fa-key me-2"></span>Screen Permissions</h5>
                                        </div>
                                        <div class="card-body">
                                            <div class="mb-3">
                                                <label class="form-label text-700 fw-semi-bold" for="roleSelect">Select User Type (Role)</label>
                                                <div class="input-group">
                                                    <select class="form-select" id="roleSelect">
                                                        <%
                                                            List<UserType> roleList = (List<UserType>) request.getAttribute("userTypes");
                                                            if (roleList != null) {
                                                                for (UserType r : roleList) {
                                                        %>
                                                        <option value="<%= r.getId() %>"><%= r.getName() %></option>
                                                        <%
                                                                }
                                                            }
                                                        %>
                                                    </select>
                                                    <button class="btn btn-outline-secondary" type="button" data-bs-toggle="modal" data-bs-target="#addRoleModal">
                                                        <span class="fas fa-plus"></span>
                                                    </button>
                                                </div>
                                            </div>

                                            <hr class="my-4 border-200" />

                                            <h6 class="text-900 fw-bold mb-3">Permitted Screens</h6>
                                            <form id="permissionForm">
                                                <div class="d-flex flex-column gap-3 mb-4" id="screensContainer">
                                                    <%
                                                         List<Screen> screenList = (List<Screen>) request.getAttribute("screens");
                                                         if (screenList != null) {
                                                             List<Screen> actualScreens = new java.util.ArrayList<>();
                                                             List<Screen> specialScreens = new java.util.ArrayList<>();
                                                             for (Screen s : screenList) {
                                                                 if (s.getPath().equalsIgnoreCase("/download-reports") || s.getPath().equalsIgnoreCase("/report-logs")) {
                                                                     specialScreens.add(s);
                                                                 } else {
                                                                     actualScreens.add(s);
                                                                 }
                                                             }
                                                             List<Screen> sortedScreens = new java.util.ArrayList<>(actualScreens);
                                                             sortedScreens.addAll(specialScreens);
                                                             for (Screen s : sortedScreens) {
                                                     %>
                                                     <div class="d-flex align-items-center justify-content-between p-2 border rounded border-200">
                                                         <div class="d-flex align-items-center">
                                                             <span class="fs-1 text-primary me-3"><i class="<%= s.getIcon() %>"></i></span>
                                                             <div>
                                                                 <span class="fw-semi-bold d-block text-800"><%= s.getName() %></span>
                                                                 <span class="text-500 fs--2 font-monospace"><%= s.getPath() %></span>
                                                             </div>
                                                         </div>
                                                         <div class="form-check form-switch mb-0">
                                                             <input class="form-check-input permission-switch" type="checkbox" name="screenIds" value="<%= s.getId() %>" id="screen_<%= s.getId() %>">
                                                         </div>
                                                     </div>
                                                     <%
                                                             }
                                                         }
                                                     %>
                                                </div>
                                                <button class="btn btn-primary d-block w-100" type="submit" id="savePermissionsBtn">
                                                    <span class="fas fa-save me-1"></span> Save Permissions
                                                </button>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Modal: Add User -->
                    <div class="modal fade" id="addUserModal" tabindex="-1" aria-labelledby="addUserModalLabel" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content border-0">
                                <div class="modal-header">
                                    <h5 class="modal-title" id="addUserModalLabel"><span class="fas fa-user-plus me-2"></span>Create New User</h5>
                                    <button class="btn-close btn-close-white" type="button" data-bs-dismiss="modal" aria-label="Close"></button>
                                </div>
                                <form id="createUserForm">
                                    <div class="modal-body">
                                        <div class="mb-3">
                                            <label class="form-label" for="username">Username</label>
                                            <input class="form-control" type="text" id="username" name="username" required placeholder="e.g. jsmith" />
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label" for="fullName">Full Name</label>
                                            <input class="form-control" type="text" id="fullName" name="fullName" required placeholder="e.g. John Smith" />
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label" for="email">Email address</label>
                                            <input class="form-control" type="email" id="email" name="email" required placeholder="e.g. john@fintrex.lk" />
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label" for="userTypeId">User Role (User Type)</label>
                                            <select class="form-select" id="userTypeId" name="userTypeId" required>
                                                <%
                                                    if (roleList != null) {
                                                        for (UserType r : roleList) {
                                                %>
                                                <option value="<%= r.getId() %>"><%= r.getName() %></option>
                                                <%
                                                        }
                                                    }
                                                %>
                                            </select>
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label" for="password">Password</label>
                                            <input class="form-control" type="password" id="password" name="password" required placeholder="••••••••" />
                                        </div>
                                    </div>
                                    <div class="modal-footer bg-light">
                                        <button class="btn btn-secondary btn-sm" type="button" data-bs-dismiss="modal">Cancel</button>
                                        <button class="btn btn-primary btn-sm" type="submit">Create User</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <!-- Modal: Edit User -->
                    <div class="modal fade" id="editUserModal" tabindex="-1" aria-labelledby="editUserModalLabel" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content border-0">
                                <div class="modal-header">
                                    <h5 class="modal-title" id="editUserModalLabel"><span class="fas fa-user-edit me-2"></span>Edit User</h5>
                                    <button class="btn-close btn-close-white" type="button" data-bs-dismiss="modal" aria-label="Close"></button>
                                </div>
                                <form id="editUserForm">
                                    <input type="hidden" id="editUserId" name="id" />
                                    <div class="modal-body">
                                        <div class="mb-3">
                                            <label class="form-label" for="editUsername">Username</label>
                                            <input class="form-control" type="text" id="editUsername" disabled readonly />
                                            <small class="text-muted fs--2">Username cannot be changed</small>
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label" for="editFullName">Full Name</label>
                                            <input class="form-control" type="text" id="editFullName" name="fullName" required placeholder="e.g. John Smith" />
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label" for="editEmail">Email address</label>
                                            <input class="form-control" type="email" id="editEmail" name="email" required placeholder="e.g. john@fintrex.lk" />
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label" for="editUserTypeId">User Role (User Type)</label>
                                            <select class="form-select" id="editUserTypeId" name="userTypeId" required>
                                                <%
                                                    if (roleList != null) {
                                                        for (UserType r : roleList) {
                                                %>
                                                <option value="<%= r.getId() %>"><%= r.getName() %></option>
                                                <%
                                                        }
                                                    }
                                                %>
                                            </select>
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label" for="editPassword">New Password (leave blank to keep current)</label>
                                            <input class="form-control" type="password" id="editPassword" name="password" placeholder="••••••••" />
                                        </div>
                                    </div>
                                    <div class="modal-footer bg-light">
                                        <button class="btn btn-secondary btn-sm" type="button" data-bs-dismiss="modal">Cancel</button>
                                        <button class="btn btn-primary btn-sm" type="submit">Save Changes</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <!-- Modal: Add Role -->
                    <div class="modal fade" id="addRoleModal" tabindex="-1" aria-labelledby="addRoleModalLabel" aria-hidden="true">
                        <div class="modal-dialog">
                            <div class="modal-content border-0">
                                <div class="modal-header">
                                    <h5 class="modal-title" id="addRoleModalLabel"><span class="fas fa-plus me-2"></span>Add New User Type (Role)</h5>
                                    <button class="btn-close btn-close-white" type="button" data-bs-dismiss="modal" aria-label="Close"></button>
                                </div>
                                <form id="createRoleForm">
                                    <div class="modal-body">
                                        <div class="mb-3">
                                            <label class="form-label" for="roleName">Role Name</label>
                                            <input class="form-control" type="text" id="roleName" name="name" required placeholder="e.g. AUDITOR" style="text-transform: uppercase;" />
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label" for="roleDesc">Description</label>
                                            <textarea class="form-control" id="roleDesc" name="description" rows="2" placeholder="Describe role capabilities..."></textarea>
                                        </div>
                                    </div>
                                    <div class="modal-footer bg-light">
                                        <button class="btn btn-secondary btn-sm" type="button" data-bs-dismiss="modal">Cancel</button>
                                        <button class="btn btn-dark btn-sm" type="submit">Create Role</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </main>

        <script src="${pageContext.request.contextPath}/vendors/popper/popper.min.js"></script>
        <script src="${pageContext.request.contextPath}/vendors/bootstrap/bootstrap.min.js"></script>
        <script src="${pageContext.request.contextPath}/vendors/anchorjs/anchor.min.js"></script>
        <script src="${pageContext.request.contextPath}/vendors/is/is.min.js"></script>
        <script src="${pageContext.request.contextPath}/vendors/fontawesome/all.min.js"></script>
        <script src="${pageContext.request.contextPath}/vendors/lodash/lodash.min.js"></script>
        <script src="${pageContext.request.contextPath}/vendors/list.js/list.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/theme.js"></script>

        <script>
            // Utility alert toast generator
            function showAlert(message, type = 'success') {
                const container = document.getElementById('alertContainer');
                const toast = document.createElement('div');
                toast.className = `toast align-items-center text-white bg-${type} border-0 show mb-2`;
                toast.setAttribute('role', 'alert');
                toast.setAttribute('aria-live', 'assertive');
                toast.setAttribute('aria-atomic', 'true');
                toast.innerHTML = `
                    <div class="d-flex">
                        <div class="toast-body">
                            ${message}
                        </div>
                        <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
                    </div>
                `;
                container.appendChild(toast);
                setTimeout(() => {
                    toast.classList.remove('show');
                    setTimeout(() => toast.remove(), 500);
                }, 3000);
            }

            // Update user count
            function updateUserCount() {
                const count = Array.from(document.querySelectorAll('#userTableBody tr'))
                                   .filter(row => row.style.display !== 'none').length;
                document.getElementById('userCount').innerText = `${count} Users`;
            }

            // Load and check permissions when a role is selected
            function loadRolePermissions(userTypeId) {
                // Uncheck all first
                document.querySelectorAll('.permission-switch').forEach(cb => cb.checked = false);

                fetch('<%= request.getContextPath() %>/user-management/api/permissions?userTypeId=' + userTypeId)
                    .then(res => res.json())
                    .then(screenIds => {
                        screenIds.forEach(id => {
                            const cb = document.getElementById('screen_' + id);
                            if (cb) cb.checked = true;
                        });
                    })
                    .catch(err => {
                        console.error('Error fetching permissions:', err);
                        showAlert('Error fetching permissions for selected role', 'danger');
                    });
            }

            document.addEventListener('DOMContentLoaded', () => {
                const roleSelect = document.getElementById('roleSelect');
                if (roleSelect && roleSelect.value) {
                    loadRolePermissions(roleSelect.value);
                }

                // Handle role selection change
                roleSelect.addEventListener('change', (e) => {
                    loadRolePermissions(e.target.value);
                });

                // User Table Search Filter
                const searchInput = document.getElementById('userSearchInput');
                if (searchInput) {
                    searchInput.addEventListener('input', function(e) {
                        const query = e.target.value.toLowerCase();
                        document.querySelectorAll('#userTableBody tr').forEach(row => {
                            const text = row.innerText.toLowerCase();
                            row.style.display = text.includes(query) ? '' : 'none';
                        });
                        updateUserCount();
                    });
                }

                // Update count on startup
                updateUserCount();

                // Save Permissions Form
                document.getElementById('permissionForm').addEventListener('submit', (e) => {
                    e.preventDefault();
                    const userTypeId = roleSelect.value;
                    const checkedIds = Array.from(document.querySelectorAll('.permission-switch:checked')).map(cb => cb.value);

                    const formData = new URLSearchParams();
                    formData.append('userTypeId', userTypeId);
                    checkedIds.forEach(id => formData.append('screenIds', id));

                    fetch('<%= request.getContextPath() %>/user-management/api/permissions', {
                        method: 'POST',
                        body: formData
                    })
                    .then(res => res.json())
                    .then(data => {
                        if (data.success) {
                            showAlert(data.message, 'success');
                        } else {
                            showAlert(data.message, 'danger');
                        }
                    })
                    .catch(err => {
                        console.error(err);
                        showAlert('Error saving permissions', 'danger');
                    });
                });

                // Create User Form Submission
                document.getElementById('createUserForm').addEventListener('submit', (e) => {
                    e.preventDefault();
                    const form = e.target;
                    const formData = new URLSearchParams(new FormData(form));

                    fetch('<%= request.getContextPath() %>/user-management/api/users', {
                        method: 'POST',
                        body: formData
                    })
                    .then(res => res.json())
                    .then(data => {
                        if (data.success) {
                            showAlert(data.message, 'success');
                            // Reload list of users
                            location.reload();
                        } else {
                            showAlert(data.message, 'danger');
                        }
                    })
                    .catch(err => {
                        console.error(err);
                        showAlert('Error creating user', 'danger');
                    });
                });

                // Create Role Form Submission
                document.getElementById('createRoleForm').addEventListener('submit', (e) => {
                    e.preventDefault();
                    const form = e.target;
                    const formData = new URLSearchParams(new FormData(form));

                    fetch('<%= request.getContextPath() %>/user-management/api/user-types', {
                        method: 'POST',
                        body: formData
                    })
                    .then(res => res.json())
                    .then(data => {
                        if (data.success) {
                            showAlert(data.message, 'success');
                            location.reload();
                        } else {
                            showAlert(data.message, 'danger');
                        }
                    })
                    .catch(err => {
                        console.error(err);
                        showAlert('Error creating role', 'danger');
                    });
                });

                // Populate Edit User Modal
                document.querySelectorAll('.edit-user-btn').forEach(btn => {
                    btn.addEventListener('click', function() {
                        document.getElementById('editUserId').value = this.getAttribute('data-id');
                        document.getElementById('editUsername').value = this.getAttribute('data-username');
                        document.getElementById('editFullName').value = this.getAttribute('data-fullname');
                        document.getElementById('editEmail').value = this.getAttribute('data-email');
                        document.getElementById('editUserTypeId').value = this.getAttribute('data-role-id');
                        document.getElementById('editPassword').value = '';
                    });
                });

                // Edit User Form Submission
                document.getElementById('editUserForm').addEventListener('submit', function(e) {
                    e.preventDefault();
                    const form = this;
                    const formData = new URLSearchParams(new FormData(form));

                    fetch('<%= request.getContextPath() %>/user-management/api/users/update', {
                        method: 'POST',
                        body: formData
                    })
                    .then(res => res.json())
                    .then(data => {
                        if (data.success) {
                            showAlert(data.message, 'success');
                            location.reload();
                        } else {
                            showAlert(data.message, 'danger');
                        }
                    })
                    .catch(err => {
                        console.error(err);
                        showAlert('Error updating user', 'danger');
                    });
                });
            });
        </script>
    </body>
</html>
<%-- Touch JSP for JSPF compile v8 --%>
