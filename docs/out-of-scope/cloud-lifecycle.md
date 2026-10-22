# Cloud lifecycle automation: designed, not built

Joiner, mover and leaver is the procedural side of what this repo does declaratively: access granted on purpose and removed reliably. These are my design notes for a cloud-only version. None of it is built.

## What I'd have built

- A cloud-only onboarding function (PowerShell and Microsoft Graph): create the user, assign the licence group, and set the user attributes the dynamic group rules use.
- An offboarding function: disable the account, revoke sessions and remove group memberships, with no hybrid AD dependency.
- A minimal approval flow (Azure Automation or Logic Apps).
- The logic running in an Azure Automation account, authenticating to Graph with a system-assigned managed identity.

## Related work

[manage-user-loa](https://github.com/Dhanzz1/manage-user-loa) is a PowerShell module I built for leave-of-absence automation in hybrid AD and Exchange Online (`Start-UserLOA` and `End-UserLOA`). It:

- disables and re-enables the AD account
- moves the user into and out of a leave OU, saving the original OU for the return
- hides and restores the user in the Global Address List
- grants and removes the manager's mailbox `FullAccess` and `SendAs`
- sets and removes out-of-office, with before-and-after summaries for ticket notes

That's hybrid and Exchange-focused; the design above is cloud-only and Graph-focused. They solve related problems and share no code.

## Why this matters

**Threat:** Manual joiner, mover and leaver processes leave orphaned accounts, lingering access and inconsistent offboarding.
**Trade-off:** Automation needs approval and audit steps, so it can't be used to provision or elevate access quietly.
**Exception handling:** Human approval steps, and a managed identity with least-privilege Graph permissions.
