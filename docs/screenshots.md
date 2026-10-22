# Screenshots

Screenshots from my lab tenant (`dhanzlabs.com`), taken between July and August 2026. Each caption says what the image shows. Dates are only the ones visible in the image; "not shown" means none is visible. Older images show one exclusion group; the Session 2 images show both.

## Control evidence index

| Control | Configuration | Test | Result | Date visible | Notes |
|---|---|---|---|---|---|
| CA001 Block legacy authentication | [Policy list](screenshots/ca-policy-list.png); [code](../terraform/conditional-access.tf) | [What If setup](screenshots/ca001-legacy-auth-what-if-setup.png), [result](screenshots/ca001-legacy-auth-what-if-result.png) | What If: blocked | Not shown | No live legacy-client sign-in attempted |
| CA002 Require MFA | [Detail](screenshots/ca002-require-mfa-detail.png), [impact](screenshots/ca002-require-mfa-policy-impact.png); [code](../terraform/conditional-access.tf) | [Test sign-in](screenshots/ca002-test-sign-in.png) | Live: [registration prompt](screenshots/ca002-mfa-prompt-1.png), [Authenticator setup](screenshots/ca002-mfa-prompt-2.png) | Not shown | Shows the registration flow |
| CA003 Block high-risk sign-ins | [Detail](screenshots/ca003-block-high-risk-signins-detail.png); [code](../terraform/conditional-access.tf) | [What If setup](screenshots/ca003-high-signin-risk-what-if-setup.png), [result](screenshots/ca003-high-signin-risk-what-if-result.png) | What If: blocked | Not shown | No real high-risk sign-in in the lab |
| CA004 Remediate high user risk | [Detail](screenshots/ca004-high-user-risk-remediation-detail.png), [exclusions](screenshots/ca004-high-user-risk-remediation-exclusions.png); [code](../terraform/conditional-access.tf) | [What If setup](screenshots/ca004-high-user-risk-what-if-setup.png), [result](screenshots/ca004-high-user-risk-what-if-result.png) | What If: matched in report-only | Not shown | Report-only by design |
| Emergency accounts and passkeys | [Accounts](screenshots/break-glass-accounts.png); [code](../terraform/break-glass.tf) | [What If setup](screenshots/break-glass-what-if-setup.png), [result](screenshots/break-glass-what-if-result.png) | Live: [passkey sign-in](screenshots/v1-01-emergency-passkey-signin.png), [auth detail](screenshots/v1-18-emergency-signin-auth-details.png) | Sign-ins 20 Jul and 15 Aug 2026 | Passkeys set up in the portal |
| Dual exclusion groups | [Role-assignable group](screenshots/session2-role-assignable-exclusion-properties.png), [original group members](screenshots/session2-legacy-exclusion-members.png), [role-assignable members](screenshots/session2-role-assignable-exclusion-members.png); [code](../terraform/conditional-access.tf) | [What If result](screenshots/session2-emergency-exclusion-what-if.png) | No policy applies | Not shown | |
| PIM: Conditional Access Administrator | [Settings](screenshots/v1-02-pim-role-activation-settings.png), [eligible assignment](screenshots/v1-03-pim-eligible-assignment.png) | [Activation request](screenshots/v1-04-pim-activation-justification.png) | Live: [active until expiry](screenshots/v1-05-pim-active-assignment-expiry.png), [audit](screenshots/v1-06-pim-activation-audit-entry.png), [after expiry](screenshots/v1-07-pim-post-expiry-no-active-role.png) | 27 Jul 2026 | One role, one test admin; MFA prompt not captured |
| Sentinel: emergency-account sign-in | [Rules enabled](screenshots/v1-08-sentinel-analytics-rules-enabled.png); [code](../terraform/detections/rules.tf) | [BG1 logs](screenshots/v1-09-emergency-bg1-signin-logs.png), [BG2 logs](screenshots/v1-10-emergency-bg2-signin-logs.png) | Fired: [alert](screenshots/v1-11-emergency-account-alert.png) | 15 Aug 2026 | Interactive sign-ins |
| Sentinel: exclusion group change | [Rule target](screenshots/v1-17-protected-group-rule-target.png), [group](screenshots/v1-19-exclusion-group-properties.png); [code](../terraform/detections/rules.tf) | [Canary query](screenshots/v1-14-protected-group-query-canary-validation.png) | Fired: [queue](screenshots/v1-12-protected-group-membership-alerts.png), [canary events](screenshots/v1-13-protected-group-alert-detail.png), [real change](screenshots/session2-role-assignable-membership-alert.png) | 15 and 16 Aug 2026 | Group IDs passed in at apply time, not stored in the repo |
| Sentinel: password-spray indicator | [Rules enabled](screenshots/v1-08-sentinel-analytics-rules-enabled.png); [code](../terraform/detections/rules.tf) | [Query run](screenshots/v1-20-password-spray-query-validation.png) | Query runs; never fired | Not shown | No spray in the lab, and I didn't simulate one |
| Log ingestion lag | [Export code](../terraform/detections/main.tf) | [SigninLogs](screenshots/v1-15-signinlogs-ingestion-lag.png), [AuditLogs](screenshots/v1-16-auditlogs-ingestion-lag.png) | Sign-in max 2 min, audit max 7 min | Not shown | Lab sample |

I set SSPR, password protection, the group naming policy and group licensing in the portal and didn't capture screenshots of them. The dynamic group is [in code](../terraform/identity-baseline.tf).

## Conditional Access

![Conditional Access policy list](screenshots/ca-policy-list.png)
*CA001 to CA003 are On, and CA004 `ZT-High-User-Risk-Remediation` is Report-only.*

![CA001 What If: internal user legacy client](screenshots/ca001-legacy-auth-what-if-setup.png)
![CA001 What If result: legacy client blocked](screenshots/ca001-legacy-auth-what-if-result.png)
*What If for an internal user on a legacy client: CA001 blocks it. CA002 also shows because it covers all users.*

![CA002 Require MFA: policy detail](screenshots/ca002-require-mfa-detail.png)
*The MFA policy with its grant control, taken before I added the second exclusion group.*

![CA002 Require MFA: policy impact](screenshots/ca002-require-mfa-policy-impact.png)
*Policy impact view: recent sign-in outcomes for the MFA policy.*

![CA003 Block high-risk sign-ins: policy detail](screenshots/ca003-block-high-risk-signins-detail.png)
*Blocks high sign-in risk (Entra ID Protection, P2).*

![CA003 What If: high sign-in risk condition](screenshots/ca003-high-signin-risk-what-if-setup.png)
![CA003 What If result: high risk blocked](screenshots/ca003-high-signin-risk-what-if-result.png)
*What If for a high-risk sign-in: CA003 blocks access. CA002 also shows because it covers all users.*

![CA004 High user-risk remediation: policy detail](screenshots/ca004-high-user-risk-remediation-detail.png)
*High user risk requires MFA and a secure password change. Deployed in report-only mode.*

![CA004 High user-risk remediation: exclusions](screenshots/ca004-high-user-risk-remediation-exclusions.png)
*Excludes guests, external users and the original break-glass group (taken before the second group was added).*

![CA004 What If: high user risk condition](screenshots/ca004-high-user-risk-what-if-setup.png)
![CA004 What If result: report-only match](screenshots/ca004-high-user-risk-what-if-result.png)
*What If for a high-risk user: CA004 matches in report-only, so it would require MFA and a password change if enforced.*

No real high-risk user appeared in the lab, so there are no report-only logs for CA004, and I didn't fake one.

## Live sign-in

![MFA prompt triggered by CA](screenshots/ca002-mfa-prompt-1.png)
![MFA prompt continued](screenshots/ca002-mfa-prompt-2.png)
![Test sign-in](screenshots/ca002-test-sign-in.png)
*A test user signs in and CA002 sends them through MFA registration.*

## Identity baseline

![Break-glass accounts](screenshots/break-glass-accounts.png)
*The two emergency accounts. Their Global Admin role is assigned in [code](../terraform/break-glass.tf).*

![Break-glass What If setup](screenshots/break-glass-what-if-setup.png)
![Break-glass What If result](screenshots/break-glass-what-if-result.png)
*What If for an emergency account: none of the repo's policies apply.*

![Emergency-account passkey sign-in](screenshots/v1-01-emergency-passkey-signin.png)
*Successful synced-passkey sign-in for an emergency account on 20 Jul 2026, using NordPass.*

## Redaction notes

Tenant IDs, subscription IDs, source IPs and credential IDs are redacted. Lab UPNs on `dhanzlabs.com`, user and group object IDs, and the password manager name (NordPass) are visible on purpose: they aren't secrets, and the tenant was a disposable lab.

## Privileged Identity Management

I set up PIM in the portal for Conditional Access Administrator on a test admin (`admin_test@dhanzlabs.com`). Eligibility and activation happened on 27 Jul 2026.

![PIM role activation settings](screenshots/v1-02-pim-role-activation-settings.png)
*One-hour maximum activation, MFA required on activation, justification required.*

![PIM eligible assignment](screenshots/v1-03-pim-eligible-assignment.png)
*Permanent eligible assignment for the test admin, created 27 Jul 2026 at 20:25. Eligible, not active.*

![PIM activation justification](screenshots/v1-04-pim-activation-justification.png)
*One-hour activation request with a justification. The reason mentions CA004 promotion, which I later dropped from scope.*

![PIM active assignment with expiry](screenshots/v1-05-pim-active-assignment-expiry.png)
*Role active, ending 27 Jul 2026 at 21:31.*

![PIM successful activation audit](screenshots/v1-06-pim-activation-audit-entry.png)
*Audit log entry for the activation at 20:31, with the same justification.*

![PIM after expiry](screenshots/v1-07-pim-post-expiry-no-active-role.png)
*After the hour, the role no longer shows in active assignments (screenshot undated).*

## Session 2 emergency exclusion evidence

![Role-assignable emergency exclusion group properties](screenshots/session2-role-assignable-exclusion-properties.png)
*The second exclusion group, `CA-BreakGlass-Exclude-RoleAssignable` (`7c149300-122f-4277-b894-78b93a53fe60`), with Entra role assignment enabled.*

![Original exclusion group members](screenshots/session2-legacy-exclusion-members.png)
![Role-assignable exclusion group members](screenshots/session2-role-assignable-exclusion-members.png)
*BG1 and BG2 are in both groups. All four policies exclude both groups in [code](../terraform/conditional-access.tf).*

![Session 2 emergency-account exclusion evaluation](screenshots/session2-emergency-exclusion-what-if.png)
*What If for BG1: all four policies show under "Policies that will not apply", reason "Users and groups".*

![Session 2 exclusion membership alert](screenshots/session2-role-assignable-membership-alert.png)
*The membership rule fired on 16 Aug 2026 at 19:42 when BG1 was added to the role-assignable group. This was a real change, separate from the 15 Aug canary test.*

## Sentinel detections

![Sentinel analytics rules enabled](screenshots/v1-08-sentinel-analytics-rules-enabled.png)
*The three analytics rules from [`rules.tf`](../terraform/detections/rules.tf), enabled in the workspace.*

![BG1 sign-in logs](screenshots/v1-09-emergency-bg1-signin-logs.png)
![BG2 sign-in logs](screenshots/v1-10-emergency-bg2-signin-logs.png)
*Interactive sign-ins for both emergency accounts on 15 Aug 2026. These are the events the rule picked up.*

![Emergency-account alert](screenshots/v1-11-emergency-account-alert.png)
*The alert the rule raised. Both accounts' sign-ins appear in its related events. `ConditionalAccessStatus` is `notApplied`, as expected for excluded accounts.*

![Passkey authentication detail](screenshots/v1-18-emergency-signin-auth-details.png)
*KQL on `AuthenticationDetails` for an emergency-account sign-in on 15 Aug 2026: `Passkey (synced)`, succeeded.*

![Protected-group membership alerts](screenshots/v1-12-protected-group-membership-alerts.png)
*Alert queue after testing: one emergency-account alert and three membership alerts.*

![Protected-group alert detail](screenshots/v1-13-protected-group-alert-detail.png)
*Related events for one membership alert: the add and the remove. For the canary test I added a disposable user to a temporary group, then removed them. The canary user never joined a real exclusion group, and I deleted the canary group afterwards.*

![Protected-group query validation](screenshots/v1-14-protected-group-query-canary-validation.png)
*The detection query run directly against the canary group before I pointed it at the real groups.*

![Password-spray query validation](screenshots/v1-20-password-spray-query-validation.png)
*The password-spray query runs cleanly. The lab only had 8 sign-ins in the four-hour window, so it never reached the threshold (10 or more failures across 3 or more users from one IP in 10 minutes). I didn't simulate a spray.*

![SigninLogs ingestion lag](screenshots/v1-15-signinlogs-ingestion-lag.png)
![AuditLogs ingestion lag](screenshots/v1-16-auditlogs-ingestion-lag.png)
*Ingestion lag measured with `ingestion_time()`: SigninLogs averaged 1.5 min (max 2) over 8 events; AuditLogs averaged 3.4 min (max 7) over 78. Measured on a nine-user lab tenant.*

![Exclusion group properties](screenshots/v1-19-exclusion-group-properties.png)
*The original exclusion group, `CA-BreakGlass-Exclude` (ID starting `e50632b9`).*

![Deployed rule configuration](screenshots/v1-17-protected-group-rule-target.png)
*The membership rule runs every 5 minutes over a 15-minute lookback, which covers the 7-minute audit lag. The overlap can raise duplicate alerts. The protected group IDs are passed in at apply time, so they aren't in the repo.*
