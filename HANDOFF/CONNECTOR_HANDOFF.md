# BK Corp Club — Connector Handoff

Last updated: 2026-08-14

## Purpose

This file is the shared integration handoff for Claude, ChatGPT, GitHub, Lovable and Render. Every connector/plugin/service that both AI operators may touch must be documented here before it is considered production-ready.

## Active commercial platform

### Whop — ACTIVE
- Role: payments, memberships, subscriptions and entitlement source for BKCorpd.
- API base: `https://api.whop.com/api/v1`
- MCP (Claude): `https://mcp.whop.com/sse`
- MCP (other MCP clients supporting streamable HTTP): `https://mcp.whop.com/mcp`
- Company API key: server-side only; never commit or expose in browser code.
- Webhooks: Whop -> BKCorpd backend/edge function; verify webhook signatures using `WHOP_WEBHOOK_SECRET`.
- Typical events: `membership.activated`, `membership.deactivated`, `payment.succeeded`, `refund.created` as required by the implementation.
- Official docs: https://docs.whop.com/developer/guides/ai_and_mcp

### Shopify — REMOVED / DO NOT REINTRODUCE
Shopify was permanently shut down because the operating cost was not justified. It is not part of the BKCorpd commercial architecture. Any legacy Shopify code, dependency, route, secret or documentation encountered in an active repository must be removed or explicitly quarantined as historical reference.

## Lovable
- BKCorpd remains the existing Lovable project during migration/off-Lovable work.
- Lovable is an AI build surface, not the commercial source of truth.
- Target: GitHub becomes the durable source of truth; Render provides production infrastructure where applicable.
- Lovable GitHub sync is two-way when connected. Do not rename/move/delete a linked repository.
- Lovable project ID: `2bd66034-2e19-424b-b47d-d5c0260b2ab4`.
- Current BKCorpd migration state: Shopify code removed; Whop checkout/webhook architecture active; remaining required values are `VITE_WHOP_CHECKOUT_URL` and, for server-side API calls, `WHOP_API_KEY`.

## Render
- Role: production hosting/backend infrastructure where the BK SaaS stack is deployed.
- Backend must keep all private credentials server-side.
- Never place Whop API keys, webhook secrets, database passwords or OAuth client secrets in frontend source or Git.
- Production configuration belongs in Render environment variables/secrets.
- Deployments should come from the GitHub source of truth after tests/builds pass.

## AI handoff rule

For every future connector/plugin/integration, document:
1. Provider and purpose.
2. Active/inactive status.
3. API/base URL.
4. MCP endpoint(s), if available, separately for Claude and ChatGPT/other clients.
5. Authentication method and exact environment variable names (never the secret values).
6. Required scopes/permissions.
7. Webhook URLs/events and signature verification requirements.
8. Which repository/service owns the integration.
9. Production deployment location.
10. Known blockers and the exact user action required.

No connector is considered complete until both Claude and ChatGPT can understand the same integration contract from this file without relying on conversation history.
