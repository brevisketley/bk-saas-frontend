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
  const show = (text, ok = false) => {
    if (!message) return;
    message.textContent = text;
    message.className = 'message ' + (ok ? 'success' : 'error');
    message.style.display = 'block';
  };
  if (!form || !button || !message || !status || !email || !password) {
    if (status) status.textContent = 'Login initialisation error — refresh this page';
    console.error('[BK Login] Required login form element missing');
    return;
  }
  status.textContent = 'Sign-in is ready';
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
      localStorage.setItem('saas_token', data.token);
      localStorage.setItem('saas_tenant_id', data.user.tenantId || '');
      localStorage.setItem('saas_tenant_domain', 'bkcorp');
      localStorage.setItem('bk_user', JSON.stringify(data.user));
      show('Sign-in successful. Opening your dashboard…', true);
      status.textContent = 'Authenticated';
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
  console.info('[BK Login] Version 2 handler loaded');
})();