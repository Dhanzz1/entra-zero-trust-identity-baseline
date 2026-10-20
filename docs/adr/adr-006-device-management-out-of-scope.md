# ADR 006: Device management out of scope

This ADR follows the structure in [ADR 000](./adr-000-template.md).

## Status

Accepted

## Context

Modules 03 through 06 — device compliance, Autopilot, update rings, and Defender for Endpoint — were
designed as part of this baseline before any of them was built. The plan was to define them in
Terraform using AzAPI, on the reasoning that AzAPI can reach Azure resources the first-class providers
have not yet modelled.

That reasoning does not hold for Intune. Intune configuration is exposed through Microsoft Graph.
AzAPI targets Azure Resource Manager. They are different APIs with different authentication and
different resource models, and no amount of AzAPI configuration reaches a Graph endpoint. The planned
approach was not merely awkward; it was structurally impossible.

Three alternative providers were evaluated:

- `microsoft/msgraph` — public preview at the time of evaluation
- `deploymenttheory/microsoft365` — community-maintained
- `terraprovider/microsoft365wp` — community-maintained

Each could express some part of the device-management surface. None was adopted.

This repository's stated standard is that controls are defined as code and claims are paired with the
artefact that licenses them. A device-management area configured through a preview or
community-maintained provider, in a lab, with no production usage behind it, would produce
configuration that looks like evidence of a capability without being one.

## Decision

Device management is **out of scope** for this repository. Modules 03 through 06 are not implemented,
and the repository's scope is identity and detection.

The four directories are retained with their design notes rather than deleted. A documented scope
boundary is evidence of a decision; a missing directory is evidence of nothing.

The Conditional Access module's variable surface is frozen and additive, so a "require compliant
device" grant condition could be expressed against it without restructuring the existing policies.
That is a property of the design, not a commitment to build it.

## Consequences

- **Positive:** The repository claims only what it can show. Nothing is half-built behind a preview
  provider, and the controls that rest on portal configuration rather than code — PIM, the
  emergency-account passkeys — are labelled as such where they are claimed.
- **Positive:** The reasoning is legible. A reader can see that the boundary was reached by evaluating
  a provider landscape, not by running out of time.
- **Negative:** The Zero Trust device pillar is documented and not implemented, so the baseline
  covers identity and detection rather than the full model. `docs/threat-model.md` records the
  unmitigated device threat rather than hiding it.
- **Negative:** All four directories contain design notes and no implementation, which a reader who
  skips this record could mistake for abandoned work.

## Alternatives Considered

- **Adopt `microsoft/msgraph` in public preview** — rejected. A preview provider's resource schema can
  change without a major version, which would make the published configuration wrong at some
  unannounced future date, in a repository whose whole argument is that its claims stay true.
- **Adopt a community-maintained provider** — rejected for this repository rather than on its merits.
  Either candidate may be a sound choice elsewhere; neither is a foundation this project can support,
  and adopting one would import a maintenance obligation the scope does not justify.
- **Configure Intune in the portal and document it as portal-managed** — rejected. That pattern is
  used for PIM, where the control was genuinely configured and exercised during the licensed lab
  window, with [published historical evidence](../screenshots.md#privileged-identity-management) for Conditional Access Administrator on a test admin. Repeating it across four
  modules would turn an infrastructure-as-code repository into a screenshot collection.
- **Delete the four directories** — rejected. Removing them would erase the decision along with the
  scope, leaving no record that the boundary was reached deliberately.

## What would change this assessment

Recorded so the reasoning can be re-examined on its merits, not as planned work:

- A generally available, Microsoft-published Terraform provider covering Intune device compliance.
- A device estate to manage, which a disposable single-user lab tenant is not — device compliance
  policy is only meaningful against enrolled devices.
