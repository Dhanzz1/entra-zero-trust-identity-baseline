output "break_glass_exclude_group_id" {
  description = "Object ID of the original break-glass exclusion group. The CA policies use local.emergency_exclusion_group_ids, which holds both groups."
  value       = azuread_group.break_glass_exclude.object_id
}