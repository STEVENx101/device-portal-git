"use strict";

/* -------------------------------------------------------------------------- */

/*                              Config                                        */

/* -------------------------------------------------------------------------- */
var CONFIG = {
  isNavbarVerticalCollapsed: false,
  theme: 'dark',
  isRTL: false,
  isFluid: false,
  navbarStyle: 'transparent',
  navbarPosition: 'vertical'
};
Object.keys(CONFIG).forEach(function (key) {
  if (localStorage.getItem(key) === null) {
    localStorage.setItem(key, CONFIG[key]);
  }
});

// One-time migration to switch existing users to the new default dark theme
if (!localStorage.getItem('theme_migrated_v1')) {
  localStorage.setItem('theme', 'dark');
  localStorage.setItem('theme_migrated_v1', 'true');
}

if (JSON.parse(localStorage.getItem('isNavbarVerticalCollapsed'))) {
  document.documentElement.classList.add('navbar-vertical-collapsed');
}

if (localStorage.getItem('theme') === 'dark') {
  document.documentElement.classList.add('dark');
}