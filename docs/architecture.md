# Architecture

## Reference context
This reference design is anchored to a cloud-first organization with roughly 100-500 users.
It assumes Entra ID P2 licensing, an Australia-based operating context, no on-prem AD dependency, and moderate risk tolerance.
Device management is out of scope for this release, so no device-management entitlement is assumed — see the [scope boundary](../README.md#scope-boundary).
All ADR trade-offs are written against this context; larger enterprises may choose stricter admin recovery, service-account isolation, and more formal exception workflows.

## Design principles
This baseline applies the three Zero Trust tenets. Device trust is a tenet of the model, not a control this release implements:
- **Verify explicitly** — every access decision uses identity and risk signals (Conditional Access + Identity Protection). Device state is a designed input to the same decision point, but no device signal is collected here and no policy consumes one.
- **Least privilege** — standing privilege is limited to two passkey-protected emergency accounts, and a Sentinel analytics rule alerts on their interactive sign-ins. Day-to-day admin is designed around PIM: the Conditional Access Administrator eligible assignment for a test admin, and its activation settings, were portal-managed during the licensed lab window. [The images](screenshots.md#privileged-identity-management) evidence activation and justification; MFA is configured rather than shown challenging.
- **Assume breach** — legacy authentication blocked, high sign-in risk blocked, three Sentinel analytics rules deployed as code, and the emergency-access exclusion groups themselves monitored for membership change.

## Identity-First Control Map
| Zero Trust pillar | NIST 800-207 alignment | Controls | Modules | In this release |
|-------------------|------------------------|----------|---------|-----------------|
| Identity | Policy Engine / Policy Decision Point | Conditional Access, MFA, risk-based access, emergency access, PIM | 01, 02, 09 | Historical evidence — PIM is Portal-managed and evidenced for a test admin, not code-defined |
| Devices | Device trust as a policy input | Intune compliance, Autopilot, update rings | 03, 04, 05 | No — out of scope |
| Threat protection | Continuous diagnostics | Defender for Endpoint, ASR | 06 | No — out of scope |
| Detection & response | Monitoring / analytics | Sentinel, KQL analytics | 07 | Yes |
| Automation & governance | Policy administration | Cloud lifecycle automation, admin governance | 08, 09 | Admin governance only — module 08 is not implemented |

The device and threat-protection rows are retained deliberately. The map is a design artefact: it shows where device trust would attach to this control plane, and the [scope boundary](../README.md#scope-boundary) records why it does not attach here.

## Conditional Access Headline
Conditional Access is the central control plane (Policy Decision Point in Zero Trust terms): it is where identity trust, device trust, and session risk would converge into an enforceable allow/block. Every other module in scope exists to **feed** that decision — identity baseline supplies the principals and baseline groups, Identity Protection supplies risk, and admin governance supplies the privileged-access exceptions. Device state is the input this release does not supply. The policies are rendered from a single reusable Terraform module whose variable surface is frozen and additive, so a "require compliant device" grant condition could be added later without restructuring them:

| Policy | Intent | Key controls |
|--------|--------|--------------|
| Block legacy authentication | Remove the biggest MFA-bypass vector | Block legacy client app types |
| Require MFA (all users) | Baseline strong auth | Grant: require MFA; exclude break-glass |
| Block high-risk sign-ins | Stop compromised credentials | Sign-in risk = high → block (P2) |
| High user-risk remediation | Let high-risk users recover safely | User risk = high → MFA + secure password change (report-only, P2) |

## Module Interaction Notes
Sequencing and dependencies as built:
1. **01 identity-baseline** must exist first — break-glass access and dynamic groups are inputs to downstream Conditional Access and governance work.
2. **02 conditional-access** consumes the break-glass exclusion groups; Security Defaults must be disabled before it can run.
3. **07 sentinel** consumes the tenant-scoped Entra log export, and monitors the emergency accounts' interactive sign-ins and membership changes to the exclusion groups that make them exempt.
4. **09 administrative-governance** supplies the privileged-access model: PIM eligibility for day-to-day admin, and standing Global Administrator confined to the two emergency accounts.

Modules **03 device-compliance** and **06 defender-endpoint** would have fed a "require compliant device" signal back into 02. That path is out of scope for this release; the reasoning is in the [scope boundary](../README.md#scope-boundary).

## Administrative & break-glass model
Two cloud-only break-glass accounts hold **permanent** Global Administrator (deliberately *not* PIM-eligible, so role activation can never be blocked in an emergency). They are excluded from this repository's Conditional Access policies, but still satisfy Microsoft's mandatory portal MFA with separately tested synced passkeys. A Sentinel scheduled analytics rule alerts on interactive sign-ins by either account (module 07); non-interactive sign-ins are collected but no rule evaluates them. Day-to-day admin is designed to move to **PIM** — eligible assignment, just-in-time activation, MFA and justification — which was configured and exercised in the portal rather than defined in code, with [published historical PIM evidence](screenshots.md#privileged-identity-management) for Conditional Access Administrator on a test admin. MFA on activation is configured, not captured challenging; the later active-list absence is not proof of post-expiry access denial.

## Hybrid Identity Notes
This lab is cloud-only, but a production landing zone must choose an authentication method:

### Password Hash Synchronization (PHS)
Simplest and most resilient; passwords (as hashes) sync to Entra, enabling leaked-credential detection and sign-in even if on-prem is down. Recommended default for most modern orgs.

### Pass-Through Authentication (PTA)
Validates passwords against on-prem AD in real time via lightweight agents; no password hashes in the cloud, but requires agent high-availability and adds a dependency on on-prem availability.

### Active Directory Federation Services (AD FS)
Full federated SAML; the most complex and highest-maintenance option. Justified only for specific requirements (e.g. smart-card/cert auth, third-party MFA at the IdP, or existing federation estate). For greenfield, prefer PHS + Conditional Access + Identity Protection.
