# ADR 006: Device management out of scope

This ADR follows the structure in [ADR 000](./adr-000-template.md).

## Status

Accepted. Amended 21 Oct 2026: the device design notes moved out of empty module folders into one document.

## Context

I designed modules 03 to 06 (device compliance, Autopilot, update rings and Defender for Endpoint) as part of this baseline before building any of them. The plan was to define them in Terraform with AzAPI, because AzAPI can reach Azure resources the first-class providers haven't modelled yet.

That doesn't work for Intune. Intune configuration lives in Microsoft Graph, and AzAPI only talks to Azure Resource Manager. They're different APIs with different authentication and resource models, so no AzAPI configuration can reach Intune.

I evaluated three alternative providers:

- `microsoft/msgraph`: public preview at the time
- `deploymenttheory/microsoft365`: community-maintained
- `terraprovider/microsoft365wp`: community-maintained

Each could cover part of the device surface. I didn't adopt any of them.

Every claim in this repo is backed by code or a screenshot. Device configuration built on a preview or community provider, in a lab with no devices to manage, would look like a capability I don't actually have.

## Decision

Device management is out of scope. The repo covers identity and detection.

The design notes for modules 03 to 06 are kept in [docs/out-of-scope/device-management.md](../out-of-scope/device-management.md) rather than as empty module folders, so the repo's top level only shows what's built.

The Conditional Access module's inputs only ever get added to, so a "require compliant device" grant control could be added later without changing the existing policies. That's a property of the design, not a commitment to build it.

## Consequences

- **Positive:** The repo only claims what it can show. Nothing is half-built on a preview provider, and the parts that are set in the portal rather than in code (PIM, the emergency-account passkeys) say so.
- **Positive:** The reasoning is visible. The boundary came from evaluating the provider options, not from running out of time.
- **Positive:** The top level lists only built modules, so the repo reads as finished work.
- **Negative:** The Zero Trust device pillar is designed but not built, so the baseline covers identity and detection rather than the full model. The [threat model](../threat-model.md) records the unmitigated device threat.

## Alternatives considered

- **Adopt `microsoft/msgraph` in public preview:** rejected. Preview schemas can change without notice, which would break the published configuration.
- **Adopt a community-maintained provider:** rejected for this repo, not on its merits. Either could be a good choice elsewhere, but I didn't want to take on that maintenance for a lab.
- **Configure Intune in the portal and document it:** rejected. I did that for PIM, where I configured and tested it ([screenshots](../screenshots.md#privileged-identity-management)). Doing it for four device modules would turn an infrastructure-as-code repo into a screenshot collection.
- **Keep empty module folders for 03 to 06:** my original choice, changed on 21 Oct 2026. Five of nine numbered folders being design-only made the repo look unfinished at first glance. The notes are kept in one document instead.

## What would change this

- A generally available, Microsoft-published Terraform provider for Intune device compliance.
- A device estate to manage. Device compliance policy only means something against enrolled devices, and this was a small lab tenant with none.
