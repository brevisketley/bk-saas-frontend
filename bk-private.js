/* BK Corp Club private preview (live site).
 * Until launch only the allow-listed administrator can use the site; everyone else is sent to /coming-soon.html.
 * To reopen the site: remove the <script src="/bk-private.js"> line from the HTML files (or set OPEN = true below).
 * The MT5 licence endpoint (/license/*) and PayFast payments go straight to the backend and are not affected. */
(function () {
  var OPEN = false;
  var ADMINS = ['admin@bkcorpclub.com'];
  var API = 'https://bk-saas-backend.onrender.com';
  if (OPEN) return;

  var path = location.pathname.replace(/\/+$/, '') || '/';
  // Pages anyone may open: sign-in, password reset, legal and the coming-soon page itself.
  var openPage = /^\/(login(\.html|\/index\.html)?|reset-password(\.html)?|coming-soon\.html|legal(\/.*)?)$/.test(path);

  function banner() {
    var add = function () {
      if (document.getElementById('bk-private-banner')) return;
      var b = document.createElement('div');
      b.id = 'bk-private-banner';
      b.setAttribute('role', 'status');
      b.textContent = 'Under construction · Private preview · Admin access only';
      b.style.cssText = 'position:sticky;top:0;z-index:2147483647;width:100%;padding:8px 12px;text-align:center;' +
        'font:600 11px/1.4 ui-monospace,monospace;letter-spacing:.2em;text-transform:uppercase;color:#ffc46b;' +
        'background:rgba(26,18,4,.96);border-bottom:1px solid rgba(255,196,107,.4)';
      document.body.insertBefore(b, document.body.firstChild);
    };
    if (document.body) add(); else document.addEventListener('DOMContentLoaded', add);
  }

  function token() {
    try { return localStorage.getItem('saas_token') || sessionStorage.getItem('saas_token') || ''; } catch (e) { return ''; }
  }
  function clearSession() {
    ['saas_token', 'saas_tenant_id', 'saas_tenant_domain', 'bk_user'].forEach(function (k) {
      try { localStorage.removeItem(k); sessionStorage.removeItem(k); } catch (e) {}
    });
  }
  function deny() {
    clearSession();
    location.replace('/coming-soon.html');
  }

  if (openPage) { banner(); return; }

  // Hide the page until access is confirmed so nothing flashes.
  var hide = document.createElement('style');
  hide.id = 'bk-private-hide';
  hide.textContent = 'html{visibility:hidden!important;background:#030713}';
  document.head.appendChild(hide);

  var t = token();
  if (!t) return deny();

  fetch(API + '/auth/me', { headers: { Authorization: 'Bearer ' + t, 'x-tenant-domain': 'bkcorp' } })
    .then(function (r) { return r.ok ? r.json() : null; })
    .then(function (me) {
      var u = (me && me.user) || {};
      var role = String(u.role || '').toLowerCase();
      var email = String(u.email || '').trim().toLowerCase();
      if ((role === 'admin' || role === 'superadmin') && ADMINS.indexOf(email) >= 0) {
        hide.parentNode && hide.parentNode.removeChild(hide);
        banner();
      } else {
        deny();
      }
    })
    .catch(deny);
})();
