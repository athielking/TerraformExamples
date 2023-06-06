########################################
# Example 1
# Create Azure Resource Group
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
  name     = "RPM-LunchAndLearn-1"
  location = "East US"
}