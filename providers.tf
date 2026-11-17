terraform {
  required_version = ">= 1.17.1"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "RG-Storage"
    storage_account_name = "hubspokestoragemm01"
    container_name       = "tfstate"
    key                  = "landingzone.tfstate"

    use_azuread_auth = true
  }
}

provider "azurerm" {
  features {}
}