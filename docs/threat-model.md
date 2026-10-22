# Threat Model

## Objectives
A short threat-to-control map for the identity attack surface this baseline covers, plus the device threats I modelled but chose not to control. Each control here exists to counter a named threat.

## Key threat scenarios
MFA bypass through legacy protocols, credential phishing, compromised sessions, high-risk users, non-compliant or infected devices, privileged-account abuse, admin lockout, external oversharing, and break-glass misuse.

## Control mapping
| # | Threat | Vector | Mitigating control | Module | Residual risk |
|---|--------|--------|--------------------|--------|---------------|
| 1 | MFA bypass | Legacy auth (IMAP, POP, SMTP) | Block legacy authentication | 02 | Legacy clients break; would need a scoped exclusion |
| 2 | Credential phishing | Stolen password | Require MFA for all users | 02 | MFA fatigue and token theft (see #3) |
| 3 | Compromised credentials | Risky or anomalous sign-in | Block high-risk sign-ins (Identity Protection) | 02 | Needs P2; risk thresholds need tuning |
| 4 | High-risk user | Identity Protection flags a likely compromised user | High user-risk remediation (MFA and secure password change) | 02 | Report-only, so evaluated but not enforced. Needs P2 and MFA registration |
| 5 | Non-compliant or infected device | Unmanaged endpoint | Require compliant device and Defender risk gating | 03, 06 | **Not mitigated: out of scope.** Designed only |
| 6 | Privileged-account abuse | Standing admin rights | PIM just-in-time, MFA and justification | 09 | Set up in the portal for one role on a test admin; not in code. My deploying admin account kept standing Global Admin as a lab shortcut |
| 7 | Admin lockout | Misconfigured CA policy | Break-glass accounts excluded from the repo's CA; passkeys meet mandatory portal MFA | 09 | Standing Global Admin; both passkeys sit in one password manager (ADR-002); sign-ins monitored by #9 |
| 8 | External oversharing | Over-permissive guest access | Teams, Microsoft 365 group and SharePoint sharing membership | ADR-004 | **Not mitigated by this repo.** Guests are covered by CA001 to CA003; guest authorisation is a documented boundary |
| 9 | Break-glass misuse | Emergency account abused | Sentinel rule alerts on emergency-account sign-in | 07 | Covers interactive sign-ins only; non-interactive sign-ins are collected but no rule uses them yet |

## Residual risk
- **Threat 5** is modelled but not mitigated. Device management is out of scope; see [the README](../README.md#what-i-left-out-and-why).
- **Threat 8** isn't mitigated here. Guests sign in under CA001 to CA003, but guest authorisation, lifecycle and access reviews are a documented boundary (ADR-004).
- **Threat 6** is covered for one role on a test admin ([screenshots](screenshots.md#privileged-identity-management)). Moving more roles, and my own admin account, into PIM is the next step.
- **Standing Global Admin on the break-glass accounts** is an accepted risk. Passkeys are tested and interactive sign-ins are monitored; the reasoning is in ADR-002.
- This is a threat model for a lab tenant, not a full enterprise assessment.
