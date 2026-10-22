# Architecture

## Reference context
I designed this for a cloud-first organisation of about 100 to 500 users in Australia, with Entra ID P2, no on-premises AD, and moderate risk tolerance. Device management is out of scope, so no device licensing is assumed (see [what I left out](../README.md#what-i-left-out-and-why)). Every trade-off in the ADRs is sized against this context. A larger enterprise would likely want stricter admin recovery, service-account isolation and a formal exception process.

## Design principles
The baseline follows the three Zero Trust principles. Device trust is part of the model, but this release doesn't implement it.
- **Verify explicitly.** Every access decision uses identity and risk signals (Conditional Access and Identity Protection). Device state would feed the same decision, but no device signal is collected here.
- **Least privilege.** Both emergency accounts and my deploying admin account held standing Global Admin. The admin account was a lab shortcut I'd move to PIM next. Day-to-day admin is designed around PIM: I set up Conditional Access Administrator as an eligible, just-in-time role for a test admin in the portal ([screenshots](screenshots.md#privileged-identity-management)). A Sentinel rule alerts on every interactive emergency-account sign-in.
- **Assume breach.** Legacy authentication and high-risk sign-ins are blocked, and three Sentinel rules are deployed as code, including one that watches the emergency exclusion groups for membership changes.

## Identity-first control map
| Zero Trust pillar | NIST 800-207 alignment | Controls | Modules | In this release |
|-------------------|------------------------|----------|---------|-----------------|
| Identity | Policy engine / policy decision point | Conditional Access, MFA, risk-based access, emergency access, PIM | 01, 02, 09 | Yes (PIM done in the portal, not in code) |
| Devices | Device trust as a policy input | Intune compliance, Autopilot, update rings | 03, 04, 05 | No, out of scope |
| Threat protection | Continuous diagnostics | Defender for Endpoint, ASR | 06 | No, out of scope |
| Detection and response | Monitoring and analytics | Sentinel, KQL analytics | 07 | Yes |
| Automation and governance | Policy administration | Cloud lifecycle automation, admin governance | 08, 09 | Admin governance only; module 08 isn't built |

I kept the device and threat-protection rows on purpose. They show where device trust would plug into this control plane; [the README](../README.md#what-i-left-out-and-why) says why it doesn't here.

## Conditional Access at the centre
Conditional Access is the decision point: identity, device and session risk come together there as allow or block. Everything else in scope feeds it. The identity baseline supplies users and groups, Identity Protection supplies risk, and admin governance supplies the privileged-access exceptions. Device state is the input this release doesn't supply.

All four policies come from one reusable Terraform module. The module's inputs only ever get added to, so a "require compliant device" control could be added later without changing the existing policies.

| Policy | Intent | Key controls |
|--------|--------|--------------|
| Block legacy authentication | Remove the biggest MFA-bypass route | Block legacy client app types |
| Require MFA (all users) | Baseline strong authentication | Grant: require MFA; exclude break-glass |
| Block high-risk sign-ins | Stop compromised credentials | Sign-in risk high: block (P2) |
| High user-risk remediation | Let high-risk users recover safely | User risk high: MFA and secure password change (report-only, P2) |

## How the modules fit together
In the order I built them:
1. **01 identity-baseline** comes first. The emergency exclusion groups feed Conditional Access; the dynamic group drives licensing.
2. **02 conditional-access** uses both exclusion groups. Security Defaults must be off before it runs.
3. **07 sentinel** uses the tenant-wide Entra log export. It watches the emergency accounts' interactive sign-ins and any membership change to the exclusion groups.
4. **09 administrative-governance** is the privileged-access model: PIM for day-to-day admin, standing Global Admin for the two emergency accounts.

Modules **03 device-compliance** and **06 defender-endpoint** would have fed a "require compliant device" signal back into 02. That's out of scope; see [the README](../README.md#what-i-left-out-and-why).

## Admin and break-glass model
Two cloud-only break-glass accounts hold permanent Global Admin. They're deliberately not PIM-eligible, so role activation can never block them in an emergency. They're excluded from the repo's Conditional Access policies, and they still meet Microsoft's mandatory portal MFA with synced passkeys I tested on each account. A Sentinel rule alerts on their interactive sign-ins. Non-interactive sign-ins are collected, but no rule uses them yet.

Day-to-day admin moves to PIM: eligible assignment, just-in-time activation, MFA and justification. I configured and tested this in the portal for Conditional Access Administrator on a test admin ([screenshots](screenshots.md#privileged-identity-management)).

## Hybrid identity
This lab is cloud-only. A tenant with on-premises AD would also need to choose an authentication method: password hash sync is the simplest and most resilient default; pass-through authentication and AD FS add on-premises dependencies and only make sense for specific requirements.
