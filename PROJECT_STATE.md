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
