# Initial passwords. Both accounts sign in with passkeys; these only exist to create the users.
resource "random_password" "break_glass" {
  for_each = toset(["bg1", "bg2"])

  length           = 32
  special          = true
  override_special = "!@#$%^&*()-_=+"
}

# The two emergency accounts.
resource "azuread_user" "break_glass" {
  for_each = toset(["bg1", "bg2"])

  user_principal_name   = "${each.key}@${var.onmicrosoft_domain}"
  display_name          = "Break Glass ${upper(each.key)}"
  mail_nickname         = each.key
  password              = random_password.break_glass[each.key].result
  force_password_change = false # emergency accounts must just work
  account_enabled       = true

  # Entra requires usageLocation before a licence can be assigned. These accounts
  # are members of All-Members-Dynamic, which gets its licence through group-based
  # licensing. Managed here so a later apply can't strip it and de-licence them.
  usage_location = "au"
  lifecycle {
    prevent_destroy = true
    ignore_changes  = [password]
  }
}

# Original exclusion group. Both emergency accounts are members, and every
# Conditional Access policy excludes it.
resource "azuread_group" "break_glass_exclude" {
  display_name     = "CA-BreakGlass-Exclude"
  security_enabled = true
  mail_enabled     = false
  members          = [for u in azuread_user.break_glass : u.object_id]
  lifecycle {
    prevent_destroy = true
  }
}

data "azuread_client_config" "current" {}

# Second, role-assignable exclusion group. Only Global Admins, Privileged Role
# Administrators and the group's owners can change its membership, which makes
# the exclusion path harder to tamper with.
resource "azuread_group" "break_glass_exclude_role_assignable" {
  display_name            = "CA-BreakGlass-Exclude-RoleAssignable"
  security_enabled        = true
  mail_enabled            = false
  assignable_to_role      = true
  prevent_duplicate_names = true
  members                 = [for user in azuread_user.break_glass : user.object_id]

  # Lab trade-off: the deploying administrator is an owner. Production should
  # use a deliberately governed owner/PIM model and avoid broad group ownership.
  owners = [data.azuread_client_config.current.object_id]

  lifecycle {
    prevent_destroy = true
  }

}

locals {
  emergency_exclusion_group_ids = [
    azuread_group.break_glass_exclude.object_id,
    azuread_group.break_glass_exclude_role_assignable.object_id,
  ]
}

resource "azuread_directory_role" "global_administrator" {
  display_name = "Global Administrator"
}

resource "azuread_directory_role_assignment" "break_glass_global_administrator" {
  for_each = azuread_user.break_glass

  # Built-in directory role assignments use the role template ID.
  role_id             = azuread_directory_role.global_administrator.template_id
  principal_object_id = each.value.object_id

  # An emergency account that can sign in but holds no privilege is only half a
  # fallback (see ADR-002). Guard the assignment, not just the account: destroying
  # it silently downgrades both break-glass accounts to unprivileged users.
  lifecycle {
    prevent_destroy = true
  }
}
