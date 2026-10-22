# Conditional Access Policy Sub-Module

## Purpose

A reusable Terraform sub-module that standardises how every Conditional Access policy in this repo is built. Instead of writing each policy by hand, the repo calls this one module with different inputs, so all policies share consistent assignment, exclusion, and control patterns, and the intent of each is expressed as data.

## What this codifies

- **Assignment**: included users, included roles, excluded users, and excluded groups (the break-glass exclusion groups).
- **Conditions**: client app types, sign-in/user risk levels (Entra ID Protection), cloud app include/exclude scope, and future platform/location conditions.
- **Grant controls**: block, MFA, secure password change, or authentication strength, with `OR`/`AND` operator support.
- **State**: report-only vs enabled, so policies can be staged safely before enforcement.

It is consumed by `terraform/conditional-access.tf` to produce the four Conditional Access policies: block legacy auth, require MFA, block high-risk sign-ins, and high user-risk remediation.

## Inputs / Outputs

| Name | Type | Description |
| --- | --- | --- |
| `display_name` | string | Policy name shown in Entra. |
| `state` | string | `enabledForReportingButNotEnforced`, `enabled`, or `disabled`. |
| `included_users` | list(string) | Target users, e.g. `["All"]`. |
| `included_roles` | list(string) | Directory role template IDs targeted by future admin policies. |
| `included_group_object_ids` | list(string) | Group object IDs included in the policy. |
| `excluded_users` | list(string) | User selectors excluded from the policy, e.g. `["GuestsOrExternalUsers"]`. |
| `included_applications` | list(string) | Target cloud apps/resources, e.g. `["All"]`, `["Office365"]`, or application IDs. |
| `excluded_applications` | list(string) | Cloud apps/resources excluded from the policy, e.g. `["Office365"]` for a Microsoft 365 app-scope exception. |
| `excluded_group_object_ids` | list(string) | Groups excluded (the break-glass exclusion groups). |
| `client_app_types` | list(string) | e.g. `["all"]` or `["exchangeActiveSync","other"]`. |
| `built_in_controls` | list(string) | Grant controls, e.g. `["block"]` or `["mfa"]`. |
| `grant_operator` | string | Grant-control operator, e.g. `OR` or `AND`. |
| `sign_in_risk_levels` | list(string) | Risk levels targeted, e.g. `["high"]`. |
| `user_risk_levels` | list(string) | User risk levels targeted, e.g. `["high"]`. |
| `platforms_included` | list(string) | Device platforms for future device policies; empty omits the condition. |
| `included_locations` | list(string) | Named locations included in future location policies; empty omits the condition. |
| `excluded_locations` | list(string) | Named locations excluded from future location policies; empty omits the condition. |
| `authentication_strength_policy_id` | string | Authentication strength policy ID for future admin policies; `null` omits it. |
| `sign_in_frequency_hours` | number | Optional sign-in frequency session control in hours; `null` omits it. |
| `policy_id` (output) | string | Object ID of the created policy. |

## Why this matters

Threat: inconsistent, hand-crafted CA policies drift and leave gaps that attackers exploit.

Trade-off: a shared module trades a little upfront abstraction for consistency, reviewability, and reuse across every policy.

Exception handling: every policy in this repository passes both emergency exclusion groups to the module. The module does not enforce that: `excluded_group_object_ids` defaults to empty, and its precondition only rejects an enabled block-all-users policy with no exclusions. Callers are responsible for the emergency-access path.
