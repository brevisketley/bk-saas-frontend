# BK Corp Club SaaS — Task Queue

Tasks are ordered by business/technical dependency. Agents should execute the highest-priority incomplete task, then re-evaluate the queue rather than stopping simply because one task is finished.

## P0 — Architecture & Reality Audit
- [ ] Inspect the entire frontend codebase and document actual implemented functionality.
- [ ] Identify the backend repository/service used by the frontend.
- [ ] Identify database technology and current schema.
- [ ] Identify deployed frontend URL and deployment provider.
- [ ] Identify deployed backend/API URL and deployment provider.
- [ ] Verify environment-variable configuration without exposing secrets.
- [ ] Map frontend API calls to backend endpoints.
- [ ] Identify broken, mocked, placeholder, or incomplete flows.
- [ ] Record findings in `PROJECT_STATE.md` and `HANDOFF.md`.

## P0 — Core Licensing Platform
- [ ] Authentication and authorization fully verified.
- [ ] Multi-tenant isolation verified.
- [ ] User/account management verified.
- [ ] License creation verified.
- [ ] License status lifecycle verified.
- [ ] License activation endpoint verified.
- [ ] License validation endpoint verified from an EA-compatible client flow.
- [ ] Activation limits enforced server-side.
- [ ] Required MQL5 login/account binding enforced server-side.
- [ ] Required IP/device restrictions enforced server-side where specified.
- [ ] License expiry and suspension behavior verified.
- [ ] Admin/license-manager workflows verified.

## P0 — Security
- [ ] No secrets committed to source control.
- [ ] Authentication tokens handled securely.
- [ ] Authorization enforced server-side, not only in the frontend.
- [ ] Tenant boundaries tested against cross-tenant access.
- [ ] Input validation implemented.
- [ ] Rate limiting / abuse protection assessed and implemented where required.
- [ ] CORS and production security configuration verified.
- [ ] Error responses do not leak sensitive implementation details.

## P1 — Commercial / SaaS Operations
- [ ] Subscription/payment flow verified if part of current scope.
- [ ] License provisioning after payment verified.
- [ ] Subscription cancellation/expiry behavior verified.
- [ ] Customer-facing license/account experience completed.
- [ ] Transactional email requirements identified and implemented where required.

## P1 — Production Readiness
- [ ] Production frontend deployment verified.
- [ ] Production backend deployment verified.
- [ ] Production database connectivity verified.
- [ ] HTTPS and domain configuration verified.
- [ ] Health checks added/verified.
- [ ] Logging and error monitoring verified.
- [ ] Build succeeds from a clean environment.
- [ ] End-to-end smoke test passes.

## P2 — Quality & Optimization
- [ ] Responsive UI audit.
- [ ] UX polish and consistency audit.
- [ ] Performance audit.
- [ ] Accessibility baseline audit.
- [ ] Documentation updated.
- [ ] Automated tests expanded for critical licensing paths.

## Completion Gate
The project is NOT COMPLETE until the critical P0 flows are implemented and verified end-to-end in the production environment, with evidence recorded in `HANDOFF.md` and `PROJECT_STATE.md`.
