variable "onmicrosoft_domain" {
  description = "Domain for the break-glass UPNs. Microsoft recommends the tenant's onmicrosoft.com domain; this lab used dhanzlabs.com."
  type        = string
  # No default, so Terraform won't run without a value and can't create the
  # users on the wrong domain by accident.
}