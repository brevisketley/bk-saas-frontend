# Licensing SaaS Market Launch Plan

Scope: licensing infrastructure for software vendors/developers. This document is unrelated to EA sales, medical projects, and Automaton/Atonamon.

## Positioning

**Core promise:** Turn software sales into an automated entitlement lifecycle: payment -> subscription -> licence -> activation -> heartbeat -> renewal/revocation.

The product should be positioned as a focused licensing control plane for vendors who do not want to build and maintain licensing infrastructure themselves.

## Competitive benchmark

Current category leaders position around:
- Subscription and recurring licensing
- Node/device activation
- Feature entitlements and plan tiers
- Usage metering
- Webhooks and billing integrations
- Customer/self-service portals
- Audit trails and operational visibility
- Developer APIs/SDKs
- Offline/hybrid licensing for more mature deployments

The launch product should win initially on a narrower, easier-to-buy proposition rather than claiming parity with mature enterprise platforms.

## Initial ICP

1. Independent software vendors selling desktop/server applications.
2. SaaS companies that need entitlement enforcement outside their core billing system.
3. Plugin/extension vendors.
4. Trading-platform and automation-software developers who need activation limits and subscription enforcement.
5. Small development teams that need licensing infrastructure without building it internally.

## Buyer pain

- Licence keys are manually created and delivered.
- Subscription status and software access drift apart.
- Shared keys create revenue leakage.
- Developers spend engineering time maintaining licensing infrastructure.
- Cancellation/failed-payment handling is inconsistent.
- There is insufficient audit evidence around activations and entitlement changes.

## Sales message

Do not lead with "another licence-key generator." Lead with:

> **Automate the entire software licensing lifecycle.**
>
> Connect your subscription checkout to licence issuance, activation limits, device/account binding, heartbeat validation and automatic suspension/revocation.

## Launch offer structure

- Free developer evaluation / QA environment.
- Low-friction paid entry tier for small vendors.
- Higher tier for growing vendors needing more products, activations and support.
- Custom/enterprise tier only after the core self-service funnel converts.

Exact prices must be configured from the live commercial pricing decision; marketing copy must never invent prices.

## Acquisition channels — first wave

### 1. High-intent outbound
Target developers/vendors actively discussing:
- software licensing
- license key management
- activation limits
- subscription licensing
- piracy protection
- Stripe licensing automation
- SaaS entitlement management

Use personalised problem-led outreach. Do not bulk-spam.

### 2. Developer SEO
Publish implementation-led pages around:
- how to add subscription licensing to a software product
- licence activation API
- device-bound licensing
- subscription-to-license automation
- Stripe webhook licence provisioning
- licence heartbeat architecture
- preventing licence key sharing

### 3. Technical demo funnel
Create one 5-minute demo showing:
1. Customer purchases subscription.
2. Stripe webhook arrives.
3. Licence is created.
4. Customer activates.
5. Activation slot is recorded.
6. Heartbeat validates access.
7. Cancellation/revocation blocks access.

### 4. Partner channel
Approach software development agencies, plugin developers, SaaS implementation consultants and software marketplaces that can refer vendors needing licensing.

## Conversion funnel

Traffic -> product page -> documentation/demo -> free evaluation -> checkout -> automatic licence -> activation -> retained subscription.

Primary metrics:
- visitor -> signup
- signup -> activated evaluation
- evaluation -> paid
- checkout conversion
- activation success rate
- payment failure rate
- cancellation rate
- MRR
- customer acquisition cost

## Sales operating cadence

Every week:
- Add qualified prospects.
- Run personalised outreach.
- Publish technical proof content.
- Review funnel metrics.
- Interview objections from prospects.
- Convert objections into documentation/content/product fixes.

## Market credibility requirements

Before making enterprise claims, publish:
- API documentation
- security overview
- uptime/operational expectations
- data handling/privacy policy
- terms and refund policy
- incident/support process
- transparent limitations

Never claim enterprise-grade parity until the relevant controls have actually been implemented and tested.
