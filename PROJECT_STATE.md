# BK Corp Club SaaS — Project State

## Purpose
This repository is the frontend for the BK Corp Club multi-tenant SaaS / EA licensing platform. The objective is a production-ready frontend + backend licensing system that can authenticate users, manage EA licenses, validate licenses from the EA, enforce activation limits, and operate reliably in production.

## Source of Truth
GitHub repository: `brevisketley/bk-saas-frontend`
Default branch: `main`

The repository currently contains a Vite/React frontend, EA files, a license-manager page, API-related frontend structure, and deployment configuration. The backend implementation and its deployment location must be verified from the current project/repository state before assuming anything is complete.

## Current Known State
- Frontend repository is accessible and writable.
- React + Vite frontend is present.
- `src/api/` is documented as the API client area.
- `src/contexts/` contains authentication context.
- `src/pages/` contains page components.
- `license-manager.html` exists.
- `ea-files/` exists.
- `_redirects` exists for frontend routing/deployment.
- `.env` exists; secrets must never be copied into project documentation or committed in plaintext.

## Primary Objective
Deliver a fully operational EA licensing SaaS platform, not merely a functioning frontend mockup.

The completed system must be verified end-to-end across:
1. Public website / frontend
2. User authentication
3. Tenant/account management
4. License creation and management
5. License activation
6. EA-to-license-server validation
7. MQL5 login/account binding as required by the product specification
8. IP/device/activation controls as required by the product specification
9. Subscription/payment integration when applicable
10. Admin/license-manager functionality
11. Backend API
12. Database/persistence
13. Security and authorization
14. Production deployment
15. Monitoring/error handling
16. End-to-end production testing

## Non-Negotiable Operating Rule
Never mark a feature COMPLETE merely because code exists. A feature is complete only after implementation, integration, testing, failure-path testing where applicable, and verification in the target environment.

## Agent Handoff Rule
Any AI agent working on this project must read `AGENT_RULES.md`, `PROJECT_STATE.md`, `TASK_QUEUE.md`, and `HANDOFF.md` before making changes. After meaningful work it must update the state and handoff files so another agent can continue without relying on chat history.

## Current Status
STATUS: ACTIVE — CONTINUOUS BUILD / VERIFICATION REQUIRED

## Immediate Priority
Audit the existing frontend and identify the actual backend/API/database/deployment architecture. Then continue implementation from the highest-priority incomplete item in `TASK_QUEUE.md`.

## Last Updated
2026-08-12 — shared multi-agent handoff system initialized.
