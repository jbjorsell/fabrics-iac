terraform {
  # Restricted by microsoft/fabric
  required_version = ">= 1.11, < 2.0"

  backend "azurerm" {
    key = "fabric.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.56.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.8"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
    fabric = {
      source  = "microsoft/fabric"
      version = "~> 1.7"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azapi" {}

provider "azuread" {}

provider "fabric" {
  # Uses Azure CLI or managed identity authentication
}
