# Assumptions and Limitations

## Assumptions

- I used one disposable lab tenant (`dhanzlabs.com`). The lab's current status is in [the README](../README.md#status-of-the-lab).
- **Trial licensing:** I used trial Entra ID P2 for risk-based Conditional Access and PIM. The trials have ended. Intune and Defender for Endpoint are out of scope.
- **Local Terraform state.** A real deployment would use a remote backend (Azure Storage) with state locking.
- I authenticated with interactive `az login`. CI/CD would use OIDC workload identity federation instead.

## Limitations

- This is a reference implementation for one lab tenant, not a production-hardened, multi-tenant framework.
- Cloud-only: no hybrid AD, on-premises infrastructure or network security (NSG, firewall).
- Some tenant settings were set in the portal because the azuread 2.x provider doesn't manage them (see below).

## Human review

- Every Terraform plan was reviewed by me before apply.
- I reset BG1's password in the portal, so the password in my local Terraform state is out of date. Both accounts sign in with synced passkeys. In production, emergency credentials shouldn't live in Terraform state; use separately stored FIDO2 keys or certificate-based authentication.
- All figures (ingestion lag, alert counts) come from the lab.

## Identity baseline: what's in Terraform

In code:

- `terraform/break-glass.tf` creates the two cloud-only break-glass accounts and both emergency exclusion groups ([code](../terraform/break-glass.tf)).
- `terraform/identity-baseline.tf` creates the `All-Members-Dynamic` dynamic group.

Set in the portal, because the azuread 2.x provider doesn't manage them. I didn't publish screenshots for these:

- Self-service password reset (SSPR): Entra admin centre, Protection, Password reset.
- Password protection, including a custom banned-password list and smart lockout: Entra admin centre, Protection, Authentication methods, Password protection.
- Group naming policy (Microsoft 365 groups only): Entra admin centre, Groups, Naming policy.
- Group-based licensing, assigning EMS E5 / Entra ID P2 to `All-Members-Dynamic`: Entra admin centre, Groups, All-Members-Dynamic, Licenses.
- Security Defaults: turned off (Entra, Properties, Manage security defaults) so custom Conditional Access can run.

Not built:

- Location-based admin restrictions.
- A guest-specific Conditional Access policy. Guest access is controlled through Teams, Microsoft 365 group and SharePoint sharing membership instead (ADR-004).

These portal settings could move into code once a Microsoft Graph-based provider matures. AzAPI can't do it: it targets Azure Resource Manager, and these settings live in Microsoft Graph (see ADR-006).
