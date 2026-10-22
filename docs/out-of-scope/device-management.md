# Device management: designed, not built

These are my design notes for the four device modules I planned and then took out of scope. Intune lives in Microsoft Graph, and the provider I'd planned (AzAPI) only talks to Azure Resource Manager. The full reasoning, and the three alternative providers I evaluated, are in [ADR-006](../adr/adr-006-device-management-out-of-scope.md).

## 03 Device compliance

**Purpose:** Make device trust an input to access decisions. Intune compliance policies define a healthy device; Conditional Access then requires one before granting access. This closes the gap where a valid password on an unmanaged or infected device still gets in.

**What I'd have built:**
- A Windows compliance policy: BitLocker, minimum OS version, password complexity, and Microsoft Defender risk score (medium or higher marks the device non-compliant).
- Assignment to dynamic device groups from module 04.
- A "require compliant device" grant control in the Conditional Access module.
- Basic macOS and iOS compliance.

**Threat:** Compromised or unmanaged devices reaching corporate data with valid credentials.
**Trade-off:** Strict compliance can block real users on non-compliant devices; grace periods and clear fix-it guidance soften that.
**Exception handling:** Break-glass accounts, plus scoped, documented exceptions for specific device cases.

## 04 Autopilot

**Purpose:** Zero-touch Windows provisioning, so devices arrive known, compliant and managed from first boot. This is the enrolment foundation for device compliance and Conditional Access.

**What I'd have built:**
- Autopilot deployment profiles (user-driven and self-deploying) and the Enrollment Status Page.
- A device naming convention using group tags.
- Dynamic device groups that receive compliance and Conditional Access policies.
- Win32 apps that must install during the Enrollment Status Page.

**Threat:** Manually built devices with inconsistent security baselines joining the fleet.
**Trade-off:** Enforced provisioning adds setup friction but guarantees a known-good baseline.
**Exception handling:** A documented manual enrolment path for edge cases.

## 05 Update rings

**Purpose:** A staged OS update rollout, so patches land predictably without a risky all-at-once push.

**What I'd have built:**
- At least two update rings (pilot and broad) with different deferrals and deadlines.
- Ring assignment to device groups.
- A documented rollout and deadline strategy.

**Threat:** Unpatched devices exploited through known vulnerabilities.
**Trade-off:** Long deferrals leave devices exposed; short ones risk instability. Rings balance the two.
**Exception handling:** The pilot ring catches regressions before the broad rollout, with a documented pause and rollback path.

## 06 Defender for Endpoint

**Purpose:** Endpoint protection baselines, with device risk fed back into the access decision. Defender supplies the risk score that device compliance and Conditional Access use.

**What I'd have built:**
- The Defender for Endpoint security baseline (standard preset).
- Attack Surface Reduction rules in audit mode first, with a documented path to block mode (see [ADR-003](../adr/adr-003-compliance-risk-based.md)).
- Web protection and firewall policy.
- Onboarding assignment to managed device groups.

**Threat:** Malware, exploit techniques and risky endpoint behaviour reaching corporate resources.
**Trade-off:** Block-mode ASR can break legitimate business tools; auditing first measures the impact before enforcing.
**Exception handling:** Scoped, documented per-rule exclusions; audit data decides when to move to block.
