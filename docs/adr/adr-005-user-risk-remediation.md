# ADR 005: High user risk: self-remediation, not hard block

This ADR follows the structure in [ADR 000](./adr-000-template.md).

## Status

Accepted

## Context

User risk means Microsoft Entra ID Protection has evidence that a user's identity may be compromised. A hard block can stop an attacker, but it also gives a legitimate user no recovery path without administrator intervention.

Microsoft recommends user-risk remediation for high user risk: require successful MFA and a secure password change. Passwordless users follow a different remediation path: Microsoft Entra revokes sessions and requires reauthentication. Users must be registered for MFA before they can self-remediate; otherwise, they are blocked and need administrator help.

Reference:

- Microsoft Learn: Configure and enable risk policies: https://learn.microsoft.com/en-us/entra/id-protection/howto-identity-protection-configure-risk-policies

## Decision

Deploy `ZT-High-User-Risk-Remediation` as a report-only Conditional Access policy:

- user risk: `high`
- grant controls: `mfa` and `passwordChange`
- grant operator: `AND`
- state: `enabledForReportingButNotEnforced`
- exclusions: both break-glass exclusion groups and guest/external users

Admins are deliberately in scope for this reference context. At the target size of roughly 100-500 users, self-remediation applies to everyone, and a phishing-resistant admin policy, were one added, would stack on top without changing this policy. At enterprise scale, admin user risk would usually route to a security-team investigation and recovery path instead of automatic self-remediation.

Guests are excluded because they cannot change their home-tenant password in this tenant. The pattern is: guests receive authentication and risk controls they can satisfy, and are excluded from password or device controls they cannot satisfy.

## Consequences

- **Positive:** Gives compromised users a recovery path instead of only blocking access.
- **Positive:** Aligns this release with Microsoft's user-risk remediation guidance.
- **Positive:** Keeps CA004 in report-only, so the policy is evaluated without risking a lockout loop for a user who is not registered for MFA and so cannot self-remediate. Promotion to enforced is cut from this release, not pending observation.
- **Negative:** Requires MFA registration before users can self-remediate.
- **Negative:** Requires Entra ID P2 / ID Protection licensing.

## Alternatives Considered

- **Block high user risk:** rejected because it creates an administrator-dependent recovery path for legitimate users.
- **Exclude admins from CA004:** rejected for this reference context; admin-specific hardening is out of scope for this release and would stack on top.
- **Create a service-account exclusion group now:** rejected because no service accounts exist in the lab tenant. A production scale-up would add a service-account exclusion group and migrate automation to managed identities or workload identity controls.
