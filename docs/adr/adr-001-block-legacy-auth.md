# ADR 001: Block Legacy Authentication

This ADR follows the structure in [ADR 000](./adr-000-template.md).

## Status

Accepted

## Context

Legacy authentication protocols (IMAP, POP, SMTP AUTH, older Office clients) cannot perform modern multi-factor authentication. They are the most common vector for password-spray and credential-stuffing attacks because they silently bypass MFA. Any credible Zero Trust posture must close this gap first.

## Decision

Deploy a Conditional Access policy that blocks legacy-authentication client app types for all users, excluding both break-glass exclusion groups. In a real tenant I'd run it in report-only first to find any remaining legacy clients, then enforce it. The lab had no legacy clients, so I enabled it directly.

## Consequences

- **Positive:** Eliminates the largest MFA-bypass surface and is a prerequisite for the other identity controls to be meaningful.
- **Negative:** Any remaining legacy clients (old mail apps, scripts using basic auth) will break and must be modernised or granted a scoped, documented exception.

## Alternatives Considered

- **Security Defaults:** blocks legacy auth but offers no granularity, exclusions, or report-only staging, and is incompatible with a custom Conditional Access framework.
- **Per-mailbox basic-auth disablement:** narrower and operationally heavier than a tenant-wide CA policy.
