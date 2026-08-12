# BK Corp Club SaaS — Architecture & Product Decisions

This file records durable decisions so AI agents do not repeatedly revisit settled choices or accidentally reverse them.

## 2026-08-12

### Shared AI Development Model
GitHub is the shared source of truth for ChatGPT and Claude. Agents must use the state, queue, handoff, rules, and changelog files to coordinate work.

### Completion Standard
A feature is only complete after the appropriate implementation and verification. Source code existing is not proof of operational readiness.

### EA Licensing Scope
The platform is being developed as a SaaS licensing system for BK Corp Club EAs. Licensing, activation, authentication, tenant isolation, and server-side authorization are security-sensitive capabilities.

### Secret Handling
Secrets must not be copied into project state, handoff, changelog, or other documentation.

## Pending Decisions
- Confirm exact backend repository/service.
- Confirm production hosting topology.
- Confirm current database/schema.
- Confirm final payment/subscription provider and integration scope.
- Confirm exact activation/IP/MQL5 binding rules from the current product specification.
