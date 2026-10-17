# BK Corp Club HQ — Implementation Contract

## Objective
Consolidate project dashboards and CRM operations behind one authenticated HQ, while retaining existing product systems as authoritative sources. This is an implementation contract, not a claim that the HQ is already deployed.

## Deployment boundary
- Existing repository: `brevisketley/bk-saas-frontend`.
- Existing backend: `brevisketley/bk-saas-backend`, which remains licensing-only.
- HQ must not be bolted into the licensing API's domain model. Create a separate HQ API/service boundary or a clearly isolated module only after the data ownership and auth contract is approved.
- Do not expose an HQ page on the public static host until authentication and server-side authorization exist.

## Navigation
1. Overview — verified cash received, open pipeline, overdue actions, integration health.
2. Projects — project registry, owner/agent, state, next deliverable, blocker, evidence.
3. CRM — contacts, companies, deals, consent/suppression, tasks, source and last verified timestamp.
4. Revenue — paid transactions separate from forecasts, refunds, fees, subscriptions and outstanding invoices.
5. Agent HQ — role registry, assigned work, received acknowledgement, execution evidence, sign-off and escalation.
6. Systems — deployments, databases, integrations, last successful check and recovery instructions.
7. Reports — project health, revenue trend and work completed, with source and timestamp.

## Data boundaries and system of record
- Each record carries `project_id`, source system, source record ID, created/updated timestamps and sync status.
- Cross-project access is denied by default. Enforce access in the API/database, never only in the UI.
- Keep authoritative CRM and payment records in their current source systems until an explicit migration with reconciliation is approved.
- Use external IDs and idempotent upserts; never bulk-copy records blindly.
- Store cash received separately from pipeline value. Do not label a forecast as revenue.
- Medical-contact records must carry consent basis, opt-out/suppression status and suppression timestamp. Suppression must win over imported/synced campaign status. No doctor outreach may resume as part of HQ integration.
- Secrets and payment credentials remain in provider secret stores; never in frontend bundles or repository files.

## Minimum entities for the HQ-owned operational layer
- Project(id, name, category, status, owner, priority, source_system, source_url)
- WorkItem(id, project_id, title, status, assignee, due_at, blocker, evidence_url, signed_off_at)
- Agent(id, name, role, active_status, capabilities)
- AgentAssignment(id, work_item_id, agent_id, acknowledged_at, started_at, evidence_url, outcome, signed_off_by)
- Integration(id, project_id, provider, health_status, last_checked_at, last_success_at, recovery_runbook_url)
- SyncRun(id, project_id, source_system, started_at, completed_at, result, records_created, records_updated, records_skipped, error_summary)
- RevenueEvent(id, project_id, source_system, source_event_id, event_type, amount, currency, status, occurred_at, settled_at) with unique(source_system, source_event_id).

CRM contact schemas remain project-specific and are not merged into a universal person table until source-specific consent and ownership rules are mapped.

## API/security requirements
- Single sign-on/session with server-validated identity; no client-only role checks.
- Role-based access plus project membership; deny-by-default.
- Audit logs for access changes, exports, imports, opt-outs and revenue adjustments.
- Pagination, filtering, request limits, schema validation and rate limits.
- Idempotent webhooks and sync jobs with retry/dead-letter visibility.
- No arbitrary code execution or public unauthenticated admin endpoints.
- Export/delete workflows must respect source system and legal retention obligations.

## Build gates
1. Authenticate HQ users and enforce project-scoped authorization.
2. Render project registry from HQ-owned data.
3. Add read-only integration adapters for existing systems.
4. Add deduplication and sync-run audit trails.
5. Add CRM only after each source's field mapping, ownership, consent and suppression semantics are documented.
6. Add revenue adapters; reconcile totals against provider records.
7. Add agent assignment/acknowledgement/evidence/sign-off.
8. Add recovery checks and operational alerts.

## Acceptance criteria
- Cross-project authorization tests prove tenant/project isolation.
- Duplicate sync runs do not duplicate contacts, revenue events or tasks.
- Cash totals reconcile to authoritative provider records and are visibly timestamped.
- Opt-outs remain suppressed after every import, retry and sync.
- Every displayed external datum shows source and last-sync time.
- Every agent task can be traced from assignment to acknowledgement, evidence and sign-off.
- Recovery is demonstrated in a staging environment before production cutover.

## Current status
- [x] Existing licensing frontend and backend identified.
- [x] Existing backend Prisma entities inspected.
- [x] Render free-tier suspension and unsafe service start-command mismatch identified.
- [ ] HQ authentication/API boundary implemented.
- [ ] Project registry implemented.
- [ ] Source adapters and CRM mapping implemented.
- [ ] Revenue reconciliation and agent operations implemented.
- [ ] Automated authorization/suppression/reconciliation tests passed.
- [ ] Production release verified.
