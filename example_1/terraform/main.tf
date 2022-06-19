########################################
# Example 1
# Create Azure Resource Group and storage account
########################################

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.0.2"
    }
  }
}

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "rg" {
  name     = "KMX-DevOpsDays-1"
  location = "East US"
}

resource "azurerm_storage_account" "storage" {
  name = "kmxterraformstorage1"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  account_tier = "Standard"
  account_replication_type = "LRS"
}