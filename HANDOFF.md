# BK Corp Club SaaS — AI Handoff

## Current state
The architecture audit is no longer blocked: the actual backend has been identified and is deployed on Render.

- Frontend: `brevisketley/bk-saas-frontend`
- Backend: `brevisketley/bk-saas-backend`
- Render service: `srv-d9or1sks728c73fo351g` in `Brevis's workspace`
- Backend URL: `https://bk-saas-backend.onrender.com`
- Backend database: PostgreSQL via Prisma

## Work completed in this loop
- Confirmed backend repository/service from actual project state.
- Confirmed Render service is dedicated to this EA Licensing project.
- Confirmed backend licensing security layer exists: five slots, MT5 account binding, device/broker/IP/session controls, heartbeat and revocation.
- Added backend production preflight and route guard.
- Added cross-repository `PROJECT_CONTROL_PLANE.md` and restructured task queues around a verified end state.
- Audited frontend tree and confirmed dashboard/storefront/checkout/customer/admin/rep assets exist.
- Confirmed `ea-files/` currently contains a compiled `.ex5` artifact, not production `.mq5` source.

## Not production-complete
- Live v2 licensing tests still need evidence.
- Actual `.mq5` source is the EA integration blocker; the compiled EX5 cannot be safely modified to add the shared licensing client.
- Payment -> automatic licence -> email -> activation needs end-to-end proof.
- Dashboard licence manager needs live API verification.
- Lead intake/vetting/outreach/conversion workflow needs implementation/verification so the system can operate without chat as the operating system.
- Safe Prisma migration workflow and automated security tests remain outstanding.

## Execution rule
Continue, don't stall. Work independent lanes in parallel, cross-review, red-team security-sensitive changes, fix failures, deploy and verify, then restart the checklist. Only evidence-backed production verification is COMPLETE.

## Exact next actions
1. Verify latest Render deployment and health.
2. Run controlled v2 endpoint tests and attack tests.
3. Cross-check frontend API client against live backend routes and fix mismatches.
4. Locate actual `.mq5` source outside the current connected GitHub/File Library scope if necessary; document exact blocker.
5. Finish payment/licence provisioning and dashboard verification.
6. Implement lead workflow in the dashboard while licensing gates are being tested.
7. Restart full-system audit after each material change.
