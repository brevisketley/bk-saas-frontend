# BK Corp Club EA Licensing Frontend — Release Gate

This repository follows the backend release-gate checklist. A frontend gate is GREEN only after the browser/API flow has been executed successfully against the intended backend.

## Frontend gates

- [ ] Customer signup/login E2E
- [ ] Checkout initiation E2E
- [ ] Checkout success/cancel handling
- [ ] Licence display from real backend
- [ ] Download entitlement enforcement
- [ ] Renewal flow
- [ ] Admin customer management
- [ ] Admin licence management
- [ ] Activation/session visibility
- [ ] Error handling for expired/revoked licences
- [ ] API authentication/authorization verified
- [ ] No frontend flow depends on mocked licensing state
- [ ] Production build succeeds
- [ ] Production deployment verified
- [ ] Full frontend regression passes

## Rules

- Do not mark a gate GREEN because a component exists.
- Execute the real API/browser path and capture pass/fail evidence.
- Backend contract changes require frontend regression.
- Do not expand scope while release-critical RED gates remain.


## Additional 2026-11-11 frontend release gates

- [ ] Latest storefront bundle/style deployment is live.
- [ ] All four EA cover SVGs load without 404s.
- [ ] Customer resource centre requires a valid session and handles expired sessions safely.
- [ ] Admin controls are hidden from customer role and backend still enforces admin authorization.
- [ ] Responsive layout, keyboard navigation, contrast and accessible labels tested in browser.
- [ ] Product cards display the correct cover for each EA and preserve pricing/checkout behavior.
- [ ] Protected download flow works with backend entitlements; no raw URL leaks to non-admin API responses.
