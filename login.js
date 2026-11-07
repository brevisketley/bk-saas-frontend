(() => {
  'use strict';
  const API = 'https://bk-saas-backend.onrender.com';
  const form = document.getElementById('loginForm');
  const button = document.getElementById('submit');
  const message = document.getElementById('message');
  const status = document.getElementById('status');
  const email = document.getElementById('email');
  const password = document.getElementById('password');
  if (!form || !button || !message || !status || !email || !password) return;
  const show = (text, ok = false) => {
    message.textContent = text;
    message.className = 'message ' + (ok ? 'success' : 'error');
    message.style.display = 'block';
  };
  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    if (button.disabled) return;
    button.disabled = true;
    button.textContent = 'Signing in…';
    message.style.display = 'none';
    status.textContent = 'Connecting to secure licensing service…';
    try {
      const response = await fetch(API + '/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'x-tenant-domain': 'bkcorp' },
        body: JSON.stringify({ email: email.value.trim(), password: password.value })
      });
      const data = await response.json().catch(() => ({}));
      if (!response.ok) throw new Error(data.error || 'Login failed (' + response.status + ')');
      if (!data.token) throw new Error('Authentication service returned no session token');
      localStorage.setItem('saas_token', data.token);
      localStorage.setItem('saas_tenant_id', data.user?.tenantId || '');
      localStorage.setItem('saas_tenant_domain', 'bkcorp');
      localStorage.setItem('bk_user', JSON.stringify(data.user || {}));
      show('Login successful. Opening your dashboard…', true);
      status.textContent = 'Authenticated';
      const role = data.user?.role;
      window.location.assign(role === 'admin' ? '/admin' : role === 'rep' ? '/rep-dashboard' : '/dashboard');
    } catch (error) {
      show(error?.message || 'Unable to sign in. Please try again.');
      status.textContent = 'Sign-in request failed';
      button.disabled = false;
      button.textContent = 'Sign In';
    }
  });
  status.textContent = 'Secure sign-in ready';
})();