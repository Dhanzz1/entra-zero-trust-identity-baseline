# 02 Conditional Access

## Purpose

Conditional Access is the centre of this baseline: identity and risk signals come together here as allow or block. Device signals are designed but out of scope (see ADR-006). Every policy comes from one reusable Terraform module, so each one is consistent, parameterised and reviewable as code.

## What's in code

The module is [`terraform/modules/conditional-access-policy`](../terraform/modules/conditional-access-policy/). [`terraform/conditional-access.tf`](../terraform/conditional-access.tf) calls it four times:

- **CA001 Block legacy authentication:** removes the main MFA-bypass route.
- **CA002 Require MFA for all users:** baseline strong authentication.
- **CA003 Block high-risk sign-ins:** Entra ID Protection (P2) blocks sign-ins scored high risk.
- **CA004 High user-risk remediation:** Entra ID Protection (P2) requires MFA and a secure password change for high-risk users. Deployed in report-only, which is where it stays for this release.

Every policy excludes both emergency exclusion groups. CA001 to CA003 are enforced. CA004 is evaluated but not enforced, so it doesn't block or remediate.

The module's inputs are documented in the [module README](../terraform/modules/conditional-access-policy/README.md).

## Why this matters

**Threat:** Stolen credentials, legacy protocols that skip MFA, compromised sessions, and users flagged as high risk.

**Trade-off:** Stricter access can break legacy clients, and risk controls can false-positive. Report-only evaluation and the emergency exclusions reduce that risk.

**Exception handling:** Both emergency exclusion groups are excluded from every policy. A legacy line-of-business need would get a scoped, documented exclusion. Guests are excluded from CA004 because they can't change their home-tenant password here. Guest access is controlled by Teams, Microsoft 365 group and SharePoint sharing membership, not by a Conditional Access policy. I originally built a guest policy (`ZT-Restrict-Guest-Access`) and removed it; the reasons are in ADR-004.

## Related ADRs

[ADR-001](../docs/adr/adr-001-block-legacy-auth.md) (block legacy auth), [ADR-002](../docs/adr/adr-002-break-glass-exclusion.md) (break-glass), [ADR-003](../docs/adr/adr-003-compliance-risk-based.md) (risk-based access), [ADR-004](../docs/adr/adr-004-guest-access-boundary.md) (guest access boundary), [ADR-005](../docs/adr/adr-005-user-risk-remediation.md) (high user-risk remediation).
