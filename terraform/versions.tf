terraform {
  required_version = ">= 1.7"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.50"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    # azurerm is declared only in the detections root. This root needs no Azure
    # subscription, which keeps Stage 1 free of extra dependencies.
  }
}