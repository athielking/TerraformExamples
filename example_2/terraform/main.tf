########################################
# Example 2
#
# Create Azure Resource Group and add
# an Azure App Service
########################################

# Setup Terraform
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.0.2"
    }
  }
}

# Setup our Azure Provider
provider "azurerm" {
  features {}
}

# Local Variable Declaration
locals {
    resource_group_name = "RPM-LunchAndLearn-2"
}

# Create Azure Resource Group
resource "azurerm_resource_group" "rg" {
  name = local.resource_group_name #Utilizing local variables
  location = "East US"
}

# Azure App Service needs a Service Plan.
resource "azurerm_service_plan" "app_sp" {
  name                = "${azurerm_resource_group.rg.name}-sp"
  # Reference the Terraform Resource Group Object to retrieve properties
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Windows"
  sku_name            = "B1"
}

# Create the Azure Web App
resource "azurerm_windows_web_app" "app_svc" {
  name                = "${azurerm_resource_group.rg.name}-api"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.app_sp.id
  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE = "1"
    ASPNETCORE_ENVIRONMENT   = "Production"
  }

  site_config {    
    application_stack {
      current_stack  = "dotnet"
      dotnet_version = "v6.0"
    }
  }
}