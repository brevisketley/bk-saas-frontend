# BK Corp Club SaaS — Swarm Control Plane

## End state
A customer can discover an EA, purchase a subscription, receive an automatically issued licence, activate the MT5 EA, remain continuously validated, be protected from account/device/IP/session sharing, renew/revoke the licence, and be managed through the dashboard. Leads can enter the dashboard, be vetted, queued for outreach and tracked through conversion without this chat acting as the operating system.

## Shared architecture
Frontend: `brevisketley/bk-saas-frontend`
Backend: `brevisketley/bk-saas-backend`
Backend runtime: Render `bk-saas-backend` in `Brevis's workspace`

## Swarm lanes
- Architecture/controller: dependency graph and release gates.
- Frontend: customer/admin/rep UX and API integration.
- Backend: API/database/licence/payment lifecycle.
- EA: MT5 licensing client and actual EA integration; never alter trading strategy.
- Security/Red team: attempt bypasses and sharing attacks.
- QA: automated/integration/regression testing.
- DevOps: Render, secrets, migrations, monitoring/recovery.
- Commerce/growth: payment provisioning, lead workflow, campaign conversion.

## Verified completion rule
Built != deployed != tested != production verified. Only production-verified evidence marks a release gate green.

## Critical release gates
- [ ] Live backend smoke tests.
- [ ] 1-5 activation success and 6th rejection.
- [ ] Shared MQL5 account/different device rejection.
- [ ] Device/broker/IP/session mismatch rejection.
- [ ] Heartbeat and expiry/revocation verified.
- [ ] First real `.mq5` EA integrated and compiled; current repo only exposes a compiled `.ex5` artifact.
- [ ] Remaining EAs rolled out.
- [ ] Safe database migration workflow.
- [ ] Automated security/API regression tests.
- [ ] Payment -> licence -> email -> activation idempotency.
- [ ] Dashboard licence management verified.
- [ ] Dashboard lead intake/vetting/outreach/conversion workflow verified.
- [ ] Marketing funnel connected to measurable conversion.

## Execution loop
Inspect full state -> choose highest-value unresolved dependency -> build in parallel -> cross-review -> red-team -> fix -> test -> deploy -> verify -> update state/handoff/queue -> restart from beginning. Do not stop after a single task or declare completion from code presence alone.
