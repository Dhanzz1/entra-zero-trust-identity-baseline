# 09 Administrative Governance

**Status:** Emergency access tested with live sign-ins. PIM set up in the portal and tested on a test admin.

## Purpose

Least privilege for administration: standing Global Admin only for the passkey-protected emergency accounts, and just-in-time elevation for everyone else, shown here with Conditional Access Administrator on a test admin.

## What I built

- Two cloud-only **break-glass** accounts with **permanent Global Admin**, deliberately not PIM-eligible. They're excluded from every Conditional Access policy through both `CA-BreakGlass-Exclude` and `CA-BreakGlass-Exclude-RoleAssignable` ([code](../terraform/conditional-access.tf)). Each has its own synced passkey, set up in the portal and tested with a real sign-in, to meet Microsoft's mandatory portal MFA. The accounts and groups are in [`break-glass.tf`](../terraform/break-glass.tf). See [ADR-002](../docs/adr/adr-002-break-glass-exclusion.md).
- A **second, role-assignable exclusion group**, in code, and deployed ([screenshots](../docs/screenshots.md#session-2-emergency-exclusion-evidence)). I kept the original group alongside it.
- **Sentinel monitoring** (module 07): the emergency sign-in alert fired on a real sign-in ([v1-11](../docs/screenshots/v1-11-emergency-account-alert.png)), and the membership rule fired on a canary test on 15 Aug and a real change on 16 Aug. The emergency rule reads interactive sign-ins only ([module 07 limits](../07-sentinel-kql/README.md#limitations)).

## Privileged Identity Management

I set up PIM in the portal for **Conditional Access Administrator** on a test admin (`admin_test@dhanzlabs.com`). [Screenshots v1-02 to v1-07](../docs/screenshots.md#privileged-identity-management) show the activation settings, the eligible assignment, a one-hour activation with justification, the active role with its expiry, the audit entry, and the role gone after expiry. MFA on activation was configured; I didn't capture the prompt. The justification text mentions CA004 promotion, which I later dropped from scope.

Not built: administrative units for delegated management.

## Why this matters

**Threat:** Standing privileged accounts are the highest-value target, and over-provisioned admin rights widen the blast radius.

**Trade-off:** Just-in-time elevation adds a small activation step for admins in exchange for much less standing privilege.

**Exception handling:** The break-glass accounts are the deliberate exception: permanent Global Admin, excluded from Conditional Access, protected by tested passkeys, and monitored by the Sentinel rules in module 07. My deploying admin account also kept standing Global Admin as a lab shortcut; moving it to PIM is the next step.
