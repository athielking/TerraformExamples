########################################
# Example 1
# Create Azure Resource Group
########################################

# Setup Terraform
terraform {
  required_version = ">= 0.12" 
}

# Setup our Azure Provider
provider "azurerm" {
  version = "=1.36.0"
}

# Declare your Azure Resource Group
resource "azurerm_resource_group" "rg" {
  name = "TerraformLunchAndLearn"
  location = "East US"
}