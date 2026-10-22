# 01 Identity Baseline

**Status:** Accounts and groups are in Terraform. Emergency access is tested with live sign-ins. The tenant settings below were set in the portal. See the [evidence index](../docs/screenshots.md#control-evidence-index).

## Purpose

This module sets the starting controls for the baseline: emergency access, baseline user grouping, password reset, password protection, group naming and licence assignment.

Zero Trust starts with identity. Every later control (Conditional Access, device requirements, app access, privilege governance) assumes users, groups, recovery paths and authentication settings are known and controlled.

This folder documents the design. The Terraform lives in the repo's [`terraform/`](../terraform/) folder.

## In Terraform

| Resource | Purpose | File |
| --- | --- | --- |
| Two cloud-only break-glass accounts | Emergency tenant access when normal controls or Conditional Access block admin access | [break-glass.tf](../terraform/break-glass.tf) |
| `CA-BreakGlass-Exclude` and `CA-BreakGlass-Exclude-RoleAssignable` groups | Both excluded from all four Conditional Access policies | [break-glass.tf](../terraform/break-glass.tf) |
| `All-Members-Dynamic` dynamic group | Rule-based membership for baseline targeting and group-based licensing | [identity-baseline.tf](../terraform/identity-baseline.tf) |

## Configured in the portal

I set these in the portal because the azuread 2.x provider doesn't manage them. I didn't capture screenshots, so I haven't listed them as tested.

| Setting | What it does | Portal path |
| --- | --- | --- |
| Self-service password reset (SSPR) | Lets users recover access through approved methods, reducing helpdesk load and weak manual recovery | Entra admin centre, Protection, Password reset |
| Password protection | Custom banned-password terms and smart lockout, to reduce password guessing and weak tenant-specific passwords | Entra admin centre, Protection, Authentication methods, Password protection |
| Group naming policy | Naming rules for Microsoft 365 groups to reduce unmanaged sprawl (doesn't apply to security groups) | Entra admin centre, Groups, Naming policy |
| Group-based licensing | Assigns EMS E5 / Entra ID P2 to `All-Members-Dynamic` | Entra admin centre, Groups, All-Members-Dynamic, Licenses |

## Why this matters

**Threat:** Weak password reset, poor password protection, unmanaged group creation and inconsistent licensing weaken every later Zero Trust control.

**Trade-off:** A strict baseline makes controls consistent, but can disrupt users if recovery methods, naming rules, dynamic membership and licensing aren't checked by a person first.

**Exception handling:** The break-glass accounts and both exclusion groups are the emergency exception path.

## Outputs

Terraform runs from the repo's [`terraform/`](../terraform/) root, not from this folder.

| Output | Description |
| --- | --- |
| `break_glass_exclude_group_id` | Object ID of the original `CA-BreakGlass-Exclude` group. The Conditional Access policies don't read this output; they use a local list of both exclusion groups in [break-glass.tf](../terraform/break-glass.tf). |
