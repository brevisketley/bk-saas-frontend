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


## 2026-11-11 — Additional frontend release gates

- [ ] Customer/admin authenticated browser tests pass.
- [ ] All four EA SVG covers load and map to the correct product.
- [ ] Presets, broker referrals, support tickets and email templates function end-to-end.
- [ ] Admin-only controls remain hidden from customers and enforced by backend authorization.
- [ ] Protected EA download path never exposes raw storage URLs to customer responses.
- [ ] Payment checkout state is accurately represented; no claim of commercial readiness before live payment configuration.


## 2026-11-11 — Legal, consent and MT5 onboarding gates

- [ ] Legal entity, registration/address and privacy contact verified and published.
- [ ] Terms, Privacy and Refund pages reviewed by qualified counsel for South Africa and target markets.
- [ ] Required checkout checkbox tested in a browser and records consent if required by the chosen checkout flow.
- [ ] All policy links resolve on desktop and mobile.
- [ ] MT5 illustrated guide assets load; written steps and exact URL remain readable when images are blocked.
- [ ] Production payment provider configured and end-to-end tested before enabling live checkout.
