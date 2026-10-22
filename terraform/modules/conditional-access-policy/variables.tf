variable "display_name" {
  description = "Display name for the conditional access policy."
  type        = string
}

variable "state" {
  description = "Policy state: enabledForReportingButNotEnforced, enabled, or disabled."
  type        = string
  default     = "enabledForReportingButNotEnforced" # report-only first
}

variable "included_users" {
  description = "Users the policy applies to (e.g. [\"All\"] or [\"GuestsOrExternalUsers\"])."
  type        = list(string)
  default     = ["All"]
}

variable "included_roles" {
  description = "Directory role template IDs the policy applies to."
  type        = list(string)
  default     = []
}

variable "included_group_object_ids" {
  description = "Group object IDs included in the policy."
  type        = list(string)
  default     = []
}

variable "excluded_users" {
  description = "Users excluded from the policy, e.g. [\"GuestsOrExternalUsers\"]."
  type        = list(string)
  default     = []
}

variable "excluded_group_object_ids" {
  description = "Group object IDs excluded from the policy (e.g. the break-glass exclusion groups)."
  type        = list(string)
  default     = []
}

variable "client_app_types" {
  description = "Client app types the policy targets, e.g. [\"all\"] or [\"exchangeActiveSync\", \"other\"]."
  type        = list(string)
  default     = ["all"]
}

variable "built_in_controls" {
  description = "Built-in grant controls. Empty is valid when an authentication strength is supplied."
  type        = list(string)
  default     = []
}

variable "grant_operator" {
  description = "Grant control operator, e.g. OR or AND."
  type        = string
  default     = "OR"
}

variable "sign_in_risk_levels" {
  description = "Sign-in risk levels the policy targets, e.g. [\"low\", \"medium\", \"high\"]."
  type        = list(string)
  default     = []
}

variable "user_risk_levels" {
  description = "User risk levels the policy targets, e.g. [\"high\"]."
  type        = list(string)
  default     = []
}

variable "included_applications" {
  description = "Cloud apps/resources the policy targets. Use [\"All\"] for all cloud apps, [\"Office365\"] for the Microsoft 365 suite, or application IDs for specific apps."
  type        = list(string)
  default     = ["All"]
}

variable "excluded_applications" {
  description = "Cloud apps/resources excluded from the policy. Use [\"Office365\"] to exclude the Microsoft 365 collaboration suite, or application IDs for specific apps."
  type        = list(string)
  default     = []
}

variable "platforms_included" {
  description = "Device platforms included in the policy. Empty means no platform condition."
  type        = list(string)
  default     = []
}

variable "included_locations" {
  description = "Named locations included in the policy. Empty means no location condition."
  type        = list(string)
  default     = []
}

variable "excluded_locations" {
  description = "Named locations excluded from the policy. Empty means no location condition."
  type        = list(string)
  default     = []
}

variable "authentication_strength_policy_id" {
  description = "Authentication strength policy ID for grant controls. Null means no authentication strength requirement."
  type        = string
  default     = null
}

variable "sign_in_frequency_hours" {
  description = "Optional sign-in frequency session control in hours. Null omits the session control."
  type        = number
  default     = null
}
