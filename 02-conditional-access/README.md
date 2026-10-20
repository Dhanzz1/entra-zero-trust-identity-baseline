# 02 Conditional Access

## Purpose

The Conditional Access policy framework — the central control plane of this baseline, where identity and risk signals converge into an enforceable allow/block. Device signals are designed but out of scope (see ADR-006). Implemented as a single reusable Terraform module so every policy is consistent, parameterised, and reviewable as code.

## What this codifies

Module: `terraform/modules/conditional-access-policy` (inputs: display name, state, users/roles, app scope, excluded groups, client app types, risk levels, grant controls, platform/location placeholders, and optional session controls). Called from `terraform/conditional-access.tf` to produce:

- **Block legacy authentication** — removes the primary MFA-bypass vector.
- **Require MFA for all users** — baseline strong authentication.
- **Block high-risk sign-ins** — Entra ID Protection (P2) blocks sessions scored high risk.
- **High user-risk remediation** — Entra ID Protection (P2) requires MFA plus secure password change for users scored high risk; deployed in report-only mode, which is its final state for this release.

All policies exclude the emergency-exclusion groups — both the legacy group and the role-assignable group are in the active exclusion path. CA001-CA003 are enforced. CA004 is report-only evaluated: it is evaluated without enforcement, so it neither blocks nor remediates, and promotion to enforced is not planned for this release.

## Inputs/Outputs

| Name | Type | Description |
| --- | --- | --- |
| `display_name` | string | Policy name shown in Entra. |
| `state` | string | `enabledForReportingButNotEnforced`, `enabled`, or `disabled`. |
| `included_users` | list(string) | Target users, e.g. `["All"]` or `["GuestsOrExternalUsers"]`. |
| `included_applications` | list(string) | Target cloud apps/resources, e.g. `["All"]`, `["Office365"]`, or application IDs. |
| `excluded_applications` | list(string) | Cloud apps/resources excluded from the policy, e.g. `["Office365"]` for guest collaboration access. |
| `excluded_group_object_ids` | list(string) | Groups excluded (the emergency-exclusion groups — legacy and role-assignable). |
| `excluded_users` | list(string) | Users excluded from the policy, e.g. `["GuestsOrExternalUsers"]` for controls guests cannot satisfy. |
| `client_app_types` | list(string) | e.g. `["all"]` or `["exchangeActiveSync","other"]`. |
| `built_in_controls` | list(string) | Grant controls, e.g. `["block"]` or `["mfa"]`. |
| `grant_operator` | string | Grant-control operator, e.g. `OR` or `AND`. |
| `sign_in_risk_levels` | list(string) | Risk levels targeted, e.g. `["high"]`. |
| `user_risk_levels` | list(string) | User risk levels targeted, e.g. `["high"]`. |
| `policy_id` (output) | string | Object ID of the created policy. |

## Why this matters

Threat: stolen credentials, MFA-bypassing legacy protocols, actively compromised sessions, and users whose identity has been marked high risk.

Trade-off: stricter access can break legacy clients and risk controls can false-positive; mitigated by report-only evaluation and emergency-access exclusions.

Exception handling: both emergency-exclusion groups are excluded from every policy; scoped, documented exceptions are used for any legacy line-of-business need. Guests are excluded from CA004 because they cannot satisfy a home-tenant password change in this tenant. Guest authorization belongs to identity governance — access reviews and entitlement management — rather than to a Conditional Access block. Neither is implemented in this release. Full rationale in ADR-004, including the What If service-dependency limitation that made the original policy unprovable.

## Related ADRs

[ADR-001](../docs/adr/adr-001-block-legacy-auth.md) (block legacy auth), [ADR-002](../docs/adr/adr-002-break-glass-exclusion.md) (break-glass), [ADR-003](../docs/adr/adr-003-compliance-risk-based.md) (risk-based access), [ADR-004](../docs/adr/adr-004-guest-access-boundary.md) (guest access boundary), [ADR-005](../docs/adr/adr-005-user-risk-remediation.md) (high user-risk remediation).
