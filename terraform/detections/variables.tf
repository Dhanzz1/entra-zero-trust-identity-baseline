variable "subscription_id" {
  type        = string
  description = "Lab Azure subscription ID."
  sensitive   = true
}

variable "location" {
  type    = string
  default = "australiaeast"
}

variable "emergency_account_object_ids" {
  type        = list(string)
  description = "Object IDs of the two emergency accounts."
  sensitive   = true

  validation {
    condition     = length(var.emergency_account_object_ids) == 2
    error_message = "Exactly two emergency account object IDs are required."
  }
}

variable "protected_group_object_ids" {
  type        = list(string)
  description = "Emergency exclusion group IDs monitored for membership changes."
  sensitive   = true
}