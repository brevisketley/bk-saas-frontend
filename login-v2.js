(() => {
  'use strict';
  const API = 'https://bk-saas-backend.onrender.com';
  const byId = (id) => document.getElementById(id);
  const form = byId('loginForm');
  const button = byId('submit');
  const message = byId('message');
  const status = byId('status');
  const email = byId('email');
  const password = byId('password');
  const remember = byId('rememberDetails');
  const show = (text, ok = false) => {
    if (!message) return;
    message.textContent = text;
    message.className = 'message ' + (ok ? 'success' : 'error');
    message.style.display = 'block';
  };
  if (!form || !button || !message || !status || !email || !password || !remember) {
    if (status) status.textContent = 'Login initialisation error — refresh this page';
    console.error('[BK Login] Required login form element missing');
    return;
  }
  status.textContent = 'Sign-in is ready';
  // Do not restore a session token into a persistent store unless the user opted in.
  try {
    const savedEmail = localStorage.getItem('bk_saved_email');
    if (savedEmail) email.value = savedEmail;
    remember.checked = localStorage.getItem('bk_remember_login') === '1';
    if (remember.checked && localStorage.getItem('saas_token')) {
      status.textContent = 'Checking your saved secure session…';
      fetch(API + '/auth/me', {
        headers: {
          Authorization: 'Bearer ' + localStorage.getItem('saas_token'),
          'x-tenant-domain': localStorage.getItem('saas_tenant_domain') || 'bkcorp'
        },
        cache: 'no-store'
      }).then(async response => {
        if (!response.ok) throw new Error('Saved session expired');
        const data = await response.json();
        if (!data || !data.user) throw new Error('Saved session is invalid');
        const role = String(data.user.role || '').toLowerCase();
        window.location.replace(role === 'admin' ? '/admin/' : role === 'rep' ? '/rep-dashboard/' : '/dashboard/');
      }).catch(() => {
        ['saas_token','saas_tenant_id','saas_tenant_domain'].forEach(key => localStorage.removeItem(key));
        status.textContent = 'Sign-in is ready — please sign in again';
      });
    } else {
      // Clear stale persistent auth from earlier sessions when remember-me is disabled.
      ['saas_token','saas_tenant_id','saas_tenant_domain'].forEach(key => localStorage.removeItem(key));
    }
  } catch (_) {}
  remember.addEventListener('change', () => {
    try {
      if (remember.checked) localStorage.setItem('bk_remember_login', '1');
      else {
        localStorage.removeItem('bk_remember_login');
        ['saas_token','saas_tenant_id','saas_tenant_domain'].forEach(key => localStorage.removeItem(key));
      }
    } catch (_) {}
  });
  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    event.stopPropagation();
    if (button.disabled) return;
    button.disabled = true;
    button.textContent = 'Signing in…';
    message.style.display = 'none';
    status.textContent = 'Contacting BK licensing service…';
    try {
      const response = await fetch(API + '/auth/login', {
        method: 'POST',
        mode: 'cors',
        cache: 'no-store',
        headers: { 'Content-Type': 'application/json', 'x-tenant-domain': 'bkcorp' },
        body: JSON.stringify({ email: email.value.trim(), password: password.value })
      });
      const data = await response.json().catch(() => ({}));
      if (!response.ok) throw new Error(data.error || 'Sign-in failed (' + response.status + ')');
      if (!data.token || !data.user) throw new Error('The licensing service returned an incomplete login response');
      const persistent = remember.checked;
      try {
        ['saas_token','saas_tenant_id','saas_tenant_domain'].forEach(key => {
          localStorage.removeItem(key);
          sessionStorage.removeItem(key);
        });
        localStorage.setItem('bk_remember_login', persistent ? '1' : '0');
        localStorage.setItem('bk_saved_email', email.value.trim());
        const store = persistent ? localStorage : sessionStorage;
        store.setItem('saas_token', data.token);
        store.setItem('saas_tenant_id', data.user.tenantId || '');
        store.setItem('saas_tenant_domain', 'bkcorp');
        if (persistent) localStorage.setItem('bk_user', JSON.stringify(data.user));
        else sessionStorage.setItem('bk_user', JSON.stringify(data.user));
      } catch (storageError) {
        throw new Error('Browser storage is unavailable. Enable site storage and try again.');
      }
      show('Sign-in successful. Opening your dashboard…', true);
      status.textContent = persistent ? 'Secure session saved on this computer' : 'Signed in for this browser session only';
      const role = String(data.user.role || '').toLowerCase();
      window.location.replace(role === 'admin' ? '/admin/' : role === 'rep' ? '/rep-dashboard/' : '/dashboard/');
    } catch (error) {
      console.error('[BK Login] Sign-in failed:', error);
      const msg = error instanceof TypeError
        ? 'Could not reach the licensing service. Please retry in a moment.'
        : (error.message || 'Unable to sign in. Please try again.');
      show(msg);
      status.textContent = 'Sign-in failed — see the message above';
      button.disabled = false;
      button.textContent = 'Sign In';
    }
  });
  console.info('[BK Login] Version 3 remember-session handler loaded');
})();