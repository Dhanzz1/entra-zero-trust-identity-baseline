# Uses the current `az login` session, so no secrets live in code.
# CI would use OIDC workload identity federation (see the README's next steps).
provider "azuread" {}