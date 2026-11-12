# BK Corp Club SaaS — Project State

## Purpose
Production frontend + backend EA licensing SaaS for BK Corp Club. The target is an end-to-end customer-to-revenue system, not a frontend mockup.

## Source of Truth
- Frontend: `brevisketley/bk-saas-frontend` / `main`
- Backend: `brevisketley/bk-saas-backend` / `main`
- Production backend Render service: `bk-saas-backend` (`srv-d9or1sks728c73fo351g`)
- Render workspace: `Brevis's workspace` (`tea-d8sshan7f7vs73bg54h0`)
- Production backend URL: `https://bk-saas-backend.onrender.com`
- Render service is allocated exclusively to this EA Licensing/SaaS project.

## Verified architecture findings
- Frontend is React/Vite and contains dashboard, storefront, checkout success/cancel, customer signup, admin dashboard, rep dashboard, settings and API client bundles.
- Backend is a Fastify/Prisma SaaS backend on Render.
- Backend uses PostgreSQL through Prisma.
- Backend contains licensing, checkout/payment, orders, subscriptions, users, products and email infrastructure.
- Shared MT5 licensing client exists in backend repo at `mql5/BKCorpLicense.mqh`.
- Frontend repository contains an `ea-files/` directory, but the currently exposed EA artifact is a compiled `.ex5` (`ff58ca0c-1b6e-406d-95bc-e8ae24bb27bd-V75_EA.ex5`), not production `.mq5` source. A compiled EX5 cannot be safely modified to integrate the licensing client.

## Licensing security architecture implemented in backend
- Five activation slots by default.
- MT5 account binding with one active device per account per licence.
- Broker binding.
- Device fingerprint binding.
- Server-observed public IP/session controls.
- Short-lived hashed session tokens.
- Five-minute heartbeat renewal.
- Deactivation/revocation.
- Protected security-status endpoint.
- Production route guard for setup/legacy/diagnostic routes.
- Production fail-closed secret preflight.

## Current truth about completion
Implemented is not the same as verified. The following are still release gates:
- Live v2 licensing endpoint smoke tests.
- 1-5 activation and sixth rejection tests.
- Account/device/broker/IP/session attack tests.
- Heartbeat expiry/revocation tests.
- First real `.mq5` EA integration and compile/end-to-end test.
- Remaining EA rollout.
- Safe Prisma migration strategy replacing `db push --accept-data-loss`.
- Automated security/API tests.
- Payment -> licence issuance -> email -> activation proof.
- Customer licence management UX verification.
- Lead intake/vetting/outreach/conversion workflow in dashboard.

## Operating rule
Every meaningful change must be tested, cross-reviewed, deployed where applicable, verified, then state/handoff/queue updated. After each material change restart the checklist from the beginning. Only evidence-backed VERIFIED items count as complete.

## Last updated
2026-08-12 — architecture audit continued; actual backend and Render service confirmed; compiled EA artifact found but source remains unavailable; shared swarm control plane established.


## 2026-11-11 — Customer Resource Centre and EA visual system

- Added /resources/ with authenticated My Licences, EA Library, Presets, Brokers and MT5 WebRequest setup sections.
- Added admin controls for creating/uploading presets, updating versions, publishing/drafting, replacing files, archiving/restoring, and editing/enabling/disabling broker records.
- Added customer navigation links from sign-in and the authenticated application shell.
- Added four original SVG covers for BK Corp Club EA, Brevo Quantum EA, Gold Quantum Sniper EA and BTC Quantum Velocity EA. The resource centre uses product-name mapping; the storefront bundle now maps the same covers to its EA cards.
- The customer EA library consumes the backend's protected download proxy URL rather than exposing the raw storage URL in the UI.
- Frontend commits auto-deploy through Render. Confirm the newest storefront bundle/style commits are live before release sign-off.
- Syntax checks passed for the resource page script and modified storefront bundle. Browser-level regression is still required; do not treat syntax validation as end-to-end proof.


## 2026-11-11 — Current Resource Centre deployment status

- Resource Centre is deployed with My Licences, EA Library, Presets, Brokers, MT5 setup, My Account and Support.
- Admin Resource Centre includes preset upload/replace/version/publish/archive, broker editing/enablement, legacy EA private-storage migration, support queue and email-template editing.
- Four original SVG EA covers are integrated into both the customer EA library and storefront product cards.
- The backend stores new .ex5 uploads privately and protects customer downloads with licence entitlement checks. Legacy public copies are not deleted automatically.
- Render shows the latest frontend deployment as live. Syntax checks passed for the Resource Centre script and storefront bundle; authenticated browser regression remains outstanding.
- Production checkout is still unavailable until a live payment provider is configured; do not present the site as commercially ready yet.


## 2026-11-11 — Legal pages and checkout consent

- Added public Terms of Service, Privacy Notice and Refund & Cancellation Policy pages at /terms/, /privacy/ and /refunds/, with links in the storefront and customer Resource Centre.
- Added a required checkout checkbox linking to all three policy pages.
- Added illustrated MT5 WebRequest setup diagrams to the customer Resource Centre and transactional welcome/licence emails.
- Legal pages are intentionally marked as drafts pending the operator's verified legal entity/registration/address, privacy contact and qualified legal review. Do not enable live checkout until these details and applicable jurisdictional terms are confirmed.
- The backend preflight still reports no production payment rail configured; the connected Stripe account is test mode only, and PayFast/Yoco live configuration is not confirmed.


## 2026-11-12 — Branded MT5 licensing endpoint migration

- Added a Render static-site external rewrite for `/license/*` from the public website host to the existing `bk-saas-backend.onrender.com` service. The existing frontend and backend services and database were retained.
- Render frontend deployment for the routing configuration is live.
- Live POST smoke checks were sent through `https://www.bkcorpclub.com` to `/license/activate-v2`, `/license/heartbeat-v2`, and `/license/deactivate-v2`. Backend logs confirm all three requests arrived with host `www.bkcorpclub.com`; each returned HTTP 400 for the deliberately empty test payload. This verifies forwarding and route reachability, not a successful activation using a real test key.
- Existing direct backend access remains available for previously distributed EA builds. No licence records or customer records were deleted or modified.
- Updated the Resource Centre MT5 allowlist instructions, copy button, step-3 setup illustration, and backend-generated licence/customer welcome email instructions to use `https://www.bkcorpclub.com`.
- Updated the shared MQL5 licensing client and the available Gold Quantum Sniper licensed `.mq5` source to use the branded endpoint.
- Release limitation: existing compiled `.ex5` binaries are not automatically changed by source edits. The repository does not contain the source for every distributed EA binary, and no MetaEditor compilation has been completed here. Recompile each affected EA from its corresponding source and upload the rebuilt private `.ex5` before claiming every customer binary has migrated.
- Release limitation: the full frontend CI workflow still has a separate browser regression failure because password recovery reports that Resend delivery is not configured. The dedicated branded proxy test step passed.
