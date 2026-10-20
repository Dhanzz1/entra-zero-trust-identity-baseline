# Changelog

All notable changes to this project are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project aims to follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

> **Status: archived lab.** Scope is an identity and detection baseline, evidenced between July and
> August 2026 in a trial tenant. The owner reports expired trial licences; no expiry date is asserted,
> and current operation is unverified. Device management is out of scope
> (ADR-006). Control statuses use the fixed meanings defined in the [README](README.md#control-status).

## [1.0.2] - 2026-10-20 - Rename

### Changed
- Renamed from "Azure Entra Zero Trust Landing Zone" to "Entra Zero Trust Identity Baseline". In Azure, a landing zone is the platform foundation (management groups, subscriptions, policy, networking); this repository is an identity baseline. The old GitHub URL redirects.
- README: added Engineering practices section and a hardening backlog under Known limitations.

## [1.0.1] - 2026-10-11 - Close-out

### Changed
- README opening rewritten to lead with what was built and the evidence, and to mark the repository
  as an archived lab with historical, dated evidence.
- CA001 and CA003 relabelled **Enabled; What If tested**, a new status in the README vocabulary.
  Their published evidence is What If evaluation, not a live triggering event.
- Published the 16 Aug 2026 19:42 add-member alert, distinct from the 15 Aug canary test. Its truncated
  `Group.ObjectID` newValue begins `7c`, consistent with the role-assignable exclusion group, not exact
  target verification. Published group properties, memberships and exclusion evaluation from Session 2.
- Threat 8 (external oversharing) restated as not mitigated by this repository, matching ADR-004.
- Sanitisation statement corrected: `dhanzlabs.com` lab UPNs, user/group object IDs and the NordPass name
  remain visible. Tenant IDs, subscription IDs, source IPs and credential identifiers are not visible in
  the published images. Existing redactions are preserved.
- Published PIM v1-02 to v1-07 under their existing names: Conditional Access Administrator for a test
  admin is **Portal-managed and evidenced**. MFA is configured; later active-list absence is not an
  access-denial test. Removed stale pending-evidence claims from governance, architecture and threats.
- Identity-baseline status now separates code-defined accounts/groups, evidenced emergency access and
  manual tenant settings without public evidence. Added a control-by-control evidence index.

### Fixed
- Group naming policy described as applying to Microsoft 365 groups only, per Microsoft's naming-policy documentation.
- Rule-overlap wording: only the membership rule's lookback exceeds its frequency.
- Conditional Access module README no longer claims the module guarantees an emergency-access path.
- Assumptions no longer suggest AzAPI for Graph-hosted tenant settings, which contradicted ADR-006.
- CI runs backend-disabled `init` and `validate` independently for both roots; Terraform is pinned to
  1.15.7, matching local validation. Public CI does not run plan/apply.
- AuditLogs owns the observed 7-minute maximum; SigninLogs has a 2-minute maximum.
- Passkeys and PIM are portal-managed; only two rules monitor emergency access. The spray rule is tenant-wide.

### Documented
- Password-spray rule limitation: it counts every non-zero `ResultType`, including MFA interrupts and
  the 50140 “Keep me signed in” interrupt, per [Microsoft's error-code reference](https://learn.microsoft.com/en-us/entra/identity-platform/reference-error-codes). No positive-event test is claimed.

## [1.0.0] - 2026-08-24 — Identity and detection baseline, terminal release

### Added
- **Sentinel detections as code (module 07):** Log Analytics workspace, tenant-scoped Entra
  diagnostic export, and three scheduled analytics rules — emergency-account sign-in,
  protected-exclusion-group membership change, and a password-spray indicator.
- **Role-assignable parallel emergency-exclusion group:** a second, role-assignable group added
  alongside the legacy exclusion group. Both are excluded from all four Conditional Access policies
  and both are monitored by the membership-change detection.
- **ADR-006** — device management placed out of scope for v1.0.

### Changed
- Retired phase vocabulary repository-wide in favour of the six fixed control statuses defined in
  the README.
- Modules 03–06 restated as out of scope for v1.0 citing ADR-006, rather than planned.
- Module 08 restated as linked work, not deferred scope.
- Terraform prerequisite corrected to `>= 1.7` to match `versions.tf`.
- Entra diagnostic export extended to include non-interactive user sign-ins.
  `NonInteractiveUserSignInLogs` was enabled on 22 August 2026; no rows were observed in the
  queried 14-day window as of 23 August.

### Deferred
- **CA004 remains Report-only evaluated.** Promotion to enforced is cut from this release, not
  pending observation.
- **Legacy exclusion-group retirement.** The legacy group stays in the active exclusion path; both
  groups are excluded and monitored. Retirement is deliberately deferred.
- **Non-interactive sign-in detection.** `NonInteractiveUserSignInLogs` was enabled on 22 August
  2026; no rows were observed in the queried 14-day window as of 23 August. The emergency-account
  rule evaluates interactive sign-ins only. Production delta: `union` both tables in the rule query.

## [0.1.0] - 2026-07-05 — Identity baseline + Conditional Access

First public release. The identity baseline and the Conditional Access framework are deployed to a live lab tenant and evidenced with sanitised screenshots.

### Added
- **Identity baseline (module 01):** cloud-only tenant hardening, a dynamic all-members group, and two break-glass Global Administrator accounts with a dedicated exclusion group.
- **Conditional Access as reusable Terraform (module 02):** a single parameterised module renders every CA policy. Shipped policies:
  - **CA001** — Block legacy authentication *(enabled)*
  - **CA002** — Require MFA for all users, break-glass excluded *(enabled)*
  - **CA003** — Block high-risk sign-ins via Entra ID Protection / P2 *(enabled)*
  - **CA004** — Remediate high user risk with MFA + secure password change *(report-only, pending observation)*
- **Decision records:** ADR-001 (block legacy auth), ADR-002 (break-glass exclusion + the safe Security-Defaults-off sequence), ADR-003 (risk-based access), ADR-004 (guest access boundary), ADR-005 (high user-risk remediation).
- **Design docs:** architecture overview, threat model, assumptions & limitations, and a reference-context section that anchors every trade-off to a ~100–500-user, cloud-first, AU-based tenant.
- **Evidence:** sanitised What If results and live sign-in screenshots for CA001–CA004 and the break-glass accounts.

### Changed
- Reframed the guest-access control: replaced the original `ZT-Restrict-Guest-Access` Conditional Access policy with the high-user-risk remediation policy (CA004). Guest authorization moves to collaboration membership and is out of scope for this release — full rationale in ADR-004, including the What If service-dependency limitation that made the original policy unprovable.
- Froze the Conditional Access module at its final variable surface (additive only), so later work adds module calls without editing the module.

### Security
- No secrets, tenant identifiers, or Terraform state in the repository. State, `*.tfvars`, plan files, and provider schema are gitignored. Screenshots are sanitised (tenant and subscription IDs cropped); everything was built in a disposable developer tenant.

[1.0.2]: https://github.com/Dhanzz1/entra-zero-trust-identity-baseline/releases/tag/v1.0.2
[1.0.1]: https://github.com/Dhanzz1/entra-zero-trust-identity-baseline/releases/tag/v1.0.1
[1.0.0]: https://github.com/Dhanzz1/entra-zero-trust-identity-baseline/releases/tag/v1.0.0
[0.1.0]: https://github.com/Dhanzz1/entra-zero-trust-identity-baseline/releases/tag/v0.1.0
