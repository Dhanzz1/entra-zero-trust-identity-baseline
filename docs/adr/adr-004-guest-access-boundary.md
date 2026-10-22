# ADR 004: Guest access boundary: collaboration membership, not Conditional Access

This ADR follows the structure in [ADR 000](./adr-000-template.md).

## Status

Accepted

## Context

The v0.1.0 release originally built and tested `ZT-Restrict-Guest-Access`, a Conditional Access policy intended to block guest users from all apps except Office 365. Evidence testing showed that this was the wrong boundary to prove in a small lab tenant.

Microsoft documents that Microsoft 365 services are deeply integrated: Teams can depend on SharePoint and Exchange, and targeting or excluding individual app groups can behave non-obviously because Conditional Access applies to resources, not client apps. Microsoft also documents special behaviour for "All resources" policies with resource exclusions, including low-privilege Graph and directory scope changes rolling out in stages starting in March 2026. Finally, the What If tool does not test Conditional Access service dependencies, so a clean What If result does not prove that a guest collaboration path works end to end.

References:

- Microsoft Learn: Conditional Access target resources: https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-cloud-apps
- Microsoft Learn: Conditional Access What If tool: https://learn.microsoft.com/en-us/entra/identity/conditional-access/what-if-tool

## Decision

Delete `ZT-Restrict-Guest-Access`. Guest access scope is governed by Teams/Microsoft 365 group membership and SharePoint sharing membership, not by a broad guest-specific Conditional Access block.

Conditional Access remains responsible for authentication, risk, and session controls. Guests stay covered by CA001-CA003 because "All users" includes guests; a separate guest-MFA policy would duplicate CA002. Guest lifecycle and access reviews are out of scope for this release.

## Consequences

- **Positive:** Removes a policy that could not be proven correct with the available evidence boundary.
- **Positive:** Keeps the release focused on identity controls that can be codified and defended clearly.
- **Positive:** Makes guest governance an explicit scope boundary instead of hiding it inside a fragile CA app-exclusion pattern.
- **Negative:** The release ships with one fewer Conditional Access policy.
- **Negative:** Guest authorization is documented as a governance boundary rather than an enforced control.

## Alternatives Considered

- **Keep `ZT-Restrict-Guest-Access` with Office 365 excluded:** rejected because Microsoft 365 service dependencies and All-resources exclusion behaviour made the effective boundary hard to prove.
- **Block all guest access with Conditional Access:** rejected because the project needs to preserve controlled collaboration.
- **Add another guest-specific MFA policy:** rejected because CA002 already covers guests through the all-users assignment.
