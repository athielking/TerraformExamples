########################################
# Example 2
#
# Create Azure Resource Group and add
# an Azure App Service
########################################

# Setup Terraform
terraform {
  required_version = ">= 0.12" 
}

# Setup our Azure Provider
provider "azurerm" {
  version = "=1.36.0"
}

# Local Variable Declaration
locals {
    resource_group_name = "TerraformLunchAndLearn"
}

# Create Azure Resource Group
resource "azurerm_resource_group" "rg" {
  name = local.resource_group_name #Utilizing local variables
  location = "East US"
}

# Azure App Service needs a Service Plan.
resource "azurerm_app_service_plan" "app_sp" {
  name = "${local.resource_group_name}-serviceplan"
  # Reference the Terraform Resource Group Object to retrieve properties
  resource_group_name = azurerm_resource_group.rg.name 
  location = azurerm_resource_group.rg.location

  sku {
    tier = "Free"
    size = "F1"
  }
}

# Create the Azure App Service pointing to our other resources
resource "azurerm_app_service" "app_svc" {
  name = "${local.resource_group_name}-appsvc"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  app_service_plan_id = azurerm_app_service_plan.app_sp.id
}