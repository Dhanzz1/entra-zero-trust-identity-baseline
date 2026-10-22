# ADR 002: Break-Glass Exclusion

This ADR follows the structure in [ADR 000](./adr-000-template.md).

## Status

Accepted

## Context

Conditional Access can lock every user, including administrators, out of the tenant if a policy is misconfigured. An emergency-access ("break-glass") path is required. A break-glass account must be excluded from this repository's Conditional Access policies and hold enough privilege to remediate a faulty policy. That exclusion does not bypass Microsoft's mandatory MFA for covered administration portals; the emergency authentication method must satisfy that platform requirement.

## Decision

Provision two cloud-only break-glass accounts that:

- belong to **two** groups, the original exclusion group and a role-assignable second group, **both
  excluded from every Conditional Access policy in this repo**;
- hold **permanent (active) Global Administrator**, deliberately **not** PIM-eligible, so role activation can never be blocked by the very MFA/approval flow that may be failing;
- use synced passkeys, set up in the portal, which satisfy Microsoft's mandatory MFA requirement ([passkey sign-in](../screenshots.md#identity-baseline));
- use independently stored physical FIDO2 keys or certificate-based authentication in production; and
- are monitored by a Sentinel analytics rule that alerts on **interactive** emergency-account sign-ins (module 07).

I deployed the Sentinel workspace and Entra log export on 13 Aug 2026 and the analytics rules on 15 Aug 2026. The rule fired on real emergency-account sign-ins ([alert](../screenshots.md#sentinel-detections)).

The rule reads `SigninLogs` only. Non-interactive sign-ins are collected, but no rule uses them yet ([module 07 limits](../../07-sentinel-kql/README.md#limitations)).

Security Defaults is turned off before Conditional Access is enforced. The exclusion alone doesn't make that safe. Before enforcement, the accounts must also hold active Global Administrator and have a passkey **tested with a real sign-in**. Being excluded from a policy doesn't help if the account can't sign in at all. The staged bootstrap in the [README](../../README.md#deploy-it-yourself) builds this in order.

## Consequences

- **Positive:** Provides a recovery path independent of this repository's Conditional Access policies and PIM. The accounts use passkeys to meet Microsoft's mandatory MFA requirement for administration portals. My first version created the accounts but not the Global Admin assignment. I fixed that once I saw that an exclusion without privilege is only half a fallback.
- **Negative:** Two standing Global Administrators remain high-value targets. The lab's synced passkeys are held in a third-party consumer password manager, so recovering the emergency path depends on a separate SaaS sign-in. That circular dependency is fine for a lab and not for production, where I'd use a hardware FIDO2 key per account, stored separately. The accounts' UPNs are on the custom domain in this lab; in production I'd put them on the `onmicrosoft.com` domain so they don't depend on a custom domain or federation.

## Alternatives Considered

- **PIM-eligible break-glass:** rejected, activation may require MFA/approval that could be unavailable during the incident.
- **Single break-glass account:** rejected, no redundancy if it is lost or compromised.
