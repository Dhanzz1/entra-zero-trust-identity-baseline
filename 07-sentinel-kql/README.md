# 07 Sentinel and KQL

**Status:** Deployed in Terraform. Two of three rules fired on real events.

## Purpose

The "assume breach" layer: detections for identity attacks that the preventive controls don't stop.

## What I deployed

- A **Log Analytics workspace with Microsoft Sentinel**, and a **tenant-wide Entra diagnostic setting** exporting interactive sign-ins, non-interactive sign-ins and audit logs. All in Terraform in [`terraform/detections/`](../terraform/detections/), a separate root with its own state using the `azurerm` provider.
- **Three scheduled analytics rules**, with the KQL in code:
  - **Emergency account sign-in:** fired on a real emergency-account sign-in on 15 Aug 2026.
  - **Protected exclusion group membership changed:** fired on a canary test on 15 Aug 2026, and on a real change on 16 Aug when I added BG1 to the role-assignable group ([screenshots](../docs/screenshots.md#session-2-emergency-exclusion-evidence)).
  - **Password-spray indicator:** the query runs cleanly; there was no spray in the lab, and I didn't simulate one.
- A **1 GB daily ingestion cap** on the workspace.

The rule names start with `ZTLZ`, the project's original name (Zero Trust Landing Zone). I kept them so they match the screenshots.

## Limitations

These are lab baselines, not production detections: no entity mapping, no allowlists, no assigned owner and no response procedure.

**Timing.** The membership rule runs every 5 minutes over a 15-minute lookback, which covers the 7-minute audit lag but can raise duplicate alerts. The emergency-account rule (5 minutes) and the spray rule (10 minutes) use a lookback equal to their frequency.

**Spray rule noise.** The [spray rule](../terraform/detections/rules.tf) counts every non-zero `ResultType`, including normal interrupts such as 50074 (MFA required) and 50140 ("Keep me signed in"). Several users behind one shared IP could cross the threshold without an attack ([error-code reference](https://learn.microsoft.com/en-us/entra/identity-platform/reference-error-codes)). Production would filter those codes out.

**Measured ingestion lag:** [SigninLogs](../docs/screenshots/v1-15-signinlogs-ingestion-lag.png) averaged 1.5 min (max 2); [AuditLogs](../docs/screenshots/v1-16-auditlogs-ingestion-lag.png) averaged 3.4 min (max 7).

**Interactive sign-ins only.** The emergency-account rule reads `SigninLogs`. Non-interactive sign-ins are exported to the workspace, but no rule uses them yet, so a non-interactive emergency-account sign-in wouldn't alert. The production fix is to `union` both tables in the rule query.

## Not built

Designed but not built: impossible travel, MFA fatigue, PIM role activation and device-compliance anomaly detections, plus a hunting query set.

## Why this matters

**Threat:** Compromise that gets past the preventive controls (stolen tokens, insider misuse, break-glass abuse).

**Trade-off:** Noisy rules cause alert fatigue, so the rules are few and targeted rather than broad.

**Exception handling:** The emergency sign-in alert is the compensating control for the standing Global Admin accounts ([ADR-002](../docs/adr/adr-002-break-glass-exclusion.md)), within the [limits](#limitations) above.
