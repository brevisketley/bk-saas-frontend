# BK Corp Club SaaS — Task Queue

Last updated: 2026-08-12

## End objective
Production-verified frontend + backend EA licensing and revenue operating system: purchase -> licence issuance -> customer email -> EA activation -> continuous heartbeat/security -> renewal/revocation -> dashboard management, plus lead intake/vetting/outreach/conversion tracking.

## P0 — Architecture reality
- [x] Frontend repository identified.
- [x] Backend repository identified: `brevisketley/bk-saas-backend`.
- [x] Backend Render service identified and exclusive project allocation confirmed.
- [x] PostgreSQL/Prisma backend schema identified.
- [x] Frontend feature/deployment structure audited at repository level.
- [ ] Map every frontend API call to backend endpoint and verify responses.
- [ ] Identify all broken/mock/placeholder flows.

## P0 — Licensing
- [x] Backend v2 activation/heartbeat/deactivation architecture implemented.
- [x] Five activation slots configured.
- [x] MT5 account/device/broker/IP/session controls implemented.
- [x] Shared MT5 licensing client created.
- [ ] Live smoke tests with controlled licence.
- [ ] 1-5 activation and sixth rejection proof.
- [ ] Account-sharing/device/broker/IP/session attack tests.
- [ ] Heartbeat expiry/revocation/deactivation proof.
- [ ] Actual production `.mq5` source integration. Current frontend repo contains only a compiled `.ex5` artifact, which cannot be safely edited for source integration.
- [ ] Compile and end-to-end test first real EA.
- [ ] Roll out licensing core to remaining EAs.

## P0 — Security
- [ ] Cross-tenant authorization tests.
- [ ] Input/rate-limit/error leakage tests.
- [ ] Production secret/fallback audit.
- [ ] Legacy/setup/diagnostic route verification.
- [ ] Safe Prisma migration workflow replacing `db push --accept-data-loss`.
- [ ] Dependency vulnerability review.
- [ ] Automated security/API regression CI.

## P1 — Commerce
- [ ] Verify production checkout/payment path.
- [ ] Verify payment webhook idempotency.
- [ ] Verify order -> licence issuance exactly once.
- [ ] Verify licence email delivery.
- [ ] Verify customer download/activation instructions.
- [ ] Verify renewal/cancellation/expiry lifecycle.

## P1 — Dashboard / customer operations
- [ ] Verify admin licence manager against live API.
- [ ] Verify customer licence/account experience.
- [ ] Add/verify lead intake.
- [ ] Add lead qualification state machine: new -> vetted -> contacted -> engaged -> qualified -> converted/disqualified.
- [ ] Add follow-up tasks and ownership.
- [ ] Track outreach consent and source.
- [ ] Track lead -> customer -> licence conversion.

## P2 — Growth
- [ ] Connect campaign assets to measurable funnel stages.
- [ ] Create dashboard acquisition/conversion reporting.
- [ ] Add leads to dashboard rather than relying on chat for lead operations.
- [ ] Only activate broader acquisition once the customer/licence workflow is verified.

## Continuous swarm rule
After every material change: inspect full system -> cross-review -> test -> fix -> deploy -> verify -> update PROJECT_STATE/HANDOFF/TASK_QUEUE -> restart at the top. Never mark an item complete without evidence.

## Completion gate
The project is 100% only when all critical P0/P1 release gates are production verified and the full purchase-to-activation-to-management journey works without manual intervention from this chat.
