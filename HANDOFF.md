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


## 2026-11-11 — Latest frontend handoff

- Added /resources/ as a customer resource hub and wired it to the existing backend/authentication model.
- Added the Presets and Brokers admin UI, including preset file replacement/version/visibility/archive controls and broker editing/enablement.
- Added four original SVG EA covers and integrated product-name mapping into the customer EA library and storefront bundle.
- The resource centre is live on the existing Render static-site deployment. The latest storefront bundle and CSS changes are rolling through auto-deploy; check the current deployment before declaring them live.
- Static JavaScript syntax checks passed. Browser-level regression and live customer/admin integration are not yet proven.

### Next actions
1. Verify the latest frontend deployment is live.
2. Open /resources/ after sign-in and test each tab.
3. Test the storefront covers for all four current EAs and confirm mobile layout.
4. Verify the dashboard shortcut does not obscure controls on small screens.
5. Test admin and customer role behavior against the live backend; report exact errors and fix them.


## 2026-11-11 — Current frontend handoff

- The latest frontend deployment is live with the Resource Centre, four EA covers, support ticket UI and admin email-template controls.
- The backend's private EA storage, support-ticket and email-template migrations are live.
- Static syntax checks passed; authenticated browser-level testing has not been performed through this connector session.
- Commercial launch remains blocked by missing live payment credentials and an unverified purchase-to-licence flow.

Next: sign in as customer and admin, verify each Resource Centre tab, migrate legacy EA files, test email templates and support tickets, then validate the complete sandbox purchase flow once a separate test environment/provider is available.


## 2026-11-11 — Legal and MT5 onboarding update

- Added public policy draft pages at /terms/, /privacy/ and /refunds/ and linked them from the storefront and Resource Centre.
- Added required checkout acknowledgement linking to the policy pages.
- Added three illustrated MT5 setup diagrams to the Resource Centre and transactional emails; the email retains the exact server URL https://bk-saas-backend.onrender.com and written instructions for clients that block images.
- Policy pages are drafts, not legal approval. The operator must provide verified legal entity, registration/address and privacy contact details and obtain qualified review before live checkout.
- Production payment remains unconfigured; checkout is not commercially operational.
