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
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.7"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 1.12"
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

provider "fabric" {
  use_cli = true
  preview = true
}

# Azure DevOps provider uses environment variables by default:
#   AZDO_ORG_SERVICE_URL, AZDO_PERSONAL_ACCESS_TOKEN
provider "azuredevops" {}
