# 01 Identity Baseline

**Status:** Accounts and groups are code-defined; emergency access is historically **Enabled and tested**. Manual tenant settings were configured during the licensed lab window but have no public evidence. Current operation is unverified. See the [evidence index](../docs/screenshots.md#control-evidence-index).

## Purpose

This module sets the starting controls for the baseline: emergency access, baseline user grouping, password reset expectations, password protection, naming discipline, and licence assignment.

Zero Trust depends on identity first because every later control, including Conditional Access, device requirements, application access, and privilege governance, assumes that users, groups, recovery paths, and authentication settings are known and controlled.

This folder documents the baseline design. Runnable Terraform for this area lives in the repository `terraform/` folder.

## Implemented as code

| Resource | Purpose | Terraform file |
| --- | --- | --- |
| Two cloud-only break-glass accounts | Provides emergency tenant access when normal identity controls or Conditional Access policies block administrative access. | `terraform/break-glass.tf` |
| `CA-BreakGlass-Exclude` and `CA-BreakGlass-Exclude-RoleAssignable` groups | Dual emergency exclusions consumed by all four Conditional Access policies. | [break-glass.tf](../terraform/break-glass.tf) |
| `All-Members-Dynamic` dynamic group | Provides rule-based membership for baseline user targeting and group-based licence assignment. | `terraform/identity-baseline.tf` |

## Configured manually in the historical lab

SSPR, password protection, group naming policy and group-based licensing have no public configuration or operational evidence. Their presence in this design must not be read as **Enabled and tested**. The implementation boundary below concerns the lab's pinned `hashicorp/azuread ~> 2.50`, not every currently available provider or version.

| Setting | What it does | Portal path | Why this is not in Terraform yet |
| --- | --- | --- | --- |
| Self-service password reset (SSPR) | Allows users to recover access through approved password reset methods, reducing helpdesk dependency and weak manual recovery paths. | Entra admin center -> Protection -> Password reset | Portal-managed in this lab under `hashicorp/azuread ~> 2.50`; no public evidence. |
| Password protection | Applies custom banned-password terms and smart lockout settings to reduce password guessing and tenant-specific weak password choices. | Entra admin center -> Protection -> Authentication methods -> Password protection | Portal-managed in this lab under `hashicorp/azuread ~> 2.50`; no public evidence. |
| Group naming policy | Sets naming expectations for Microsoft 365 groups to reduce unmanaged group sprawl. It does not apply to security groups. | Entra admin center -> Groups -> Naming policy | Portal-managed in this lab under `hashicorp/azuread ~> 2.50`; no public evidence. |
| Group-based licensing | Assigns the EMS E5 / Entra ID P2 licence to the `All-Members-Dynamic` group. | Entra admin center -> Groups -> All-Members-Dynamic -> Licenses | Portal-managed in this lab under `hashicorp/azuread ~> 2.50`; no public evidence. |

## Why this matters

Threat: Weak password reset, poor password protection, unmanaged group creation, inconsistent licensing, and legacy or guest sprawl can weaken every later Zero Trust control.

Trade-off: Strict identity baselines improve control consistency but can disrupt users if recovery methods, naming rules, dynamic membership, and licensing are not validated with human review.

Exception handling: Break-glass accounts and both exclusion groups provide the documented exception path for emergency access and downstream Conditional Access exclusions.

## Inputs / Outputs

This documentation area does not run Terraform directly. Terraform is executed from the repository `terraform/` run-root.

Key output consumed by downstream Conditional Access work:

| Output | Description |
| --- | --- |
| `break_glass_exclude_group_id` | The object ID for the `CA-BreakGlass-Exclude` group, used by downstream Conditional Access policies to exclude break-glass access. |
