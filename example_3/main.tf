#####################################################################
# Example 3 - Classic Guild Bank End to End
#
# This is an entire Web App Infrastructure deployment
#    - AWS Static Web Front End
#    - Azure App Service
#    - SQL Server Database from Backup
#  
# The following environment variables are required to be set to 
# authenticate to each AWS and Azure Providers
# 
# ARM_CLIENT_ID            
# ARM_CLIENT_SECRET
# ARM_SUBSCRIPTION_ID
# ARM_TENANT_ID
# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY
#
# These additional environment variables are required for the 
# database restore
#
# TF_VAR_db_backup_key
# TF_VAR_db_backup_uri
#####################################################################

# Configure Terraform
terraform {
  required_version = ">= 0.12"

  # Configure the remote backend using an azure storage container 
  backend "azurerm" {
    storage_account_name = "terraformstorage501"
    container_name       = "terraform"
    key                  = "terraform.tfstate"
  }
}

# Setup local variables
locals {
  az_subscription_id = "49c5473a-4747-494e-8cfd-1c6671b3b175"
  dns_name = "test.classicguildbank.com"
  app_name = "TestClassicGuildBank"
  admin_password = "ab4#%5qbhZ@F"

  # IP Addresses allowed to access Sql Server
  allowed_ips = [
    {
      start = "69.14.242.0"
      end = "69.14.242.255"
    }
  ]
  db_backup_uri = var.db_backup_uri
  db_backup_key = var.db_backup_key
}

# Setup our default AWS provider
provider "aws" {
  version = "~> 2.0"
  region = "us-east-2"
}

# Setup additional AWS provider in US-East 1 Region to retrieve
# certificate information
provider "aws" {
  alias ="virginia"
  version = "~> 2.0"
  region = "us-east-1"
}

# Setup Azure Provider
provider "azurerm" {
  version = "=1.36.0"
}

# Use a data resource to pull in existing DNS Information
data "aws_route53_zone" "primary" {
  name = "classicguildbank.com"
}

# Use a data resource to pull in existing certificate info
data "aws_acm_certificate" "cert" {
 provider = "aws.virginia"
 domain = "*.classicguildbank.com"
 statuses = ["ISSUED"]
}

# Create our Azure Resource Group
resource "azurerm_resource_group" "rg" {
  name = "ClassicGuildBankTest"
  location = "East US"
}

# Create the SQL Server
resource "azurerm_sql_server" "db_server" {
  name = lower("${azurerm_resource_group.rg.name}-sql")
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location = "${azurerm_resource_group.rg.location}"
  version = "12.0"
  administrator_login = "terraformadmin"
  administrator_login_password = "${local.admin_password}"
}

# Create a firewall rule to allow azure to access the Sql Server
resource "azurerm_sql_firewall_rule" "db_allow_azure" {
  name = "AllowAzureResources"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  server_name = "${azurerm_sql_server.db_server.name}"
  start_ip_address = "0.0.0.0"
  end_ip_address = "0.0.0.0"
}

# Create firewall rules for each of the IP's we specified above
resource "azurerm_sql_firewall_rule" "allow_ip_block" {
  count = length(local.allowed_ips)
  name = "Allow ${local.allowed_ips[count.index].start}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  server_name = "${azurerm_sql_server.db_server.name}"
  start_ip_address = "${local.allowed_ips[count.index].start}"
  end_ip_address = "${local.allowed_ips[count.index].end}"
}

# Create SQL Database by restoring a backup in azure storage
resource "azurerm_sql_database" "db-restore" {
  name = "${azurerm_resource_group.rg.name}-db"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location = "${azurerm_resource_group.rg.location}"
  server_name = "${azurerm_sql_server.db_server.name}"
  edition = "Basic"
  import {
      storage_uri = "${local.db_backup_uri}"
      storage_key = "${local.db_backup_key}"
      storage_key_type = "StorageAccessKey"
      administrator_login = "terraformadmin"
      administrator_login_password = "${local.admin_password}"
      authentication_type = "SQL"
  }
}

# Create the azure app service plan
resource "azurerm_app_service_plan" "app_sp" {
  name = "${local.app_name}-serviceplan"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location = "${azurerm_resource_group.rg.location}"

  sku {
    tier = "Free"
    size = "F1"
  }
}

# create the Azure App Service
resource "azurerm_app_service" "app_svc" {
  name = local.app_name
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location = "${azurerm_resource_group.rg.location}"
  app_service_plan_id = "${azurerm_app_service_plan.app_sp.id}"

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
    "ASPNETCORE_ENVIRONMENT" = "Production"
    "ClientUrl" = "https://${local.dns_name}/#"
  }
 
  # Configure Connection string from our database we setup earlier
  connection_string {
    name = "ClassicGuildBankDb"
    type = "SQLServer"
    value = "Server=${azurerm_sql_server.db_server.fully_qualified_domain_name};Initial Catalog=${azurerm_resource_group.rg.name}-db;User ID=terraformadmin;Password=${local.admin_password}"
  }

  # Terraform has a known issue with how their CORS block is configured
  # We need to use a provisioner to hook into terraform and execute 
  # an azure CLI script.  We use that to add the CORS origins
  provisioner "local-exec" {
    command = "az webapp cors add --allowed-origins https://${local.dns_name} --name ${local.app_name} --resource-group ${azurerm_resource_group.rg.name} --subscription ${local.az_subscription_id}"
  }
}

# The module resource is defined in the modules folder. It is a self contained
# re-usable piece of terraform infrastructure

# We've wrapped the entire angular static website in a module
module "angular" {
  source = "./modules/services/static-web"

  dns_name = local.dns_name
  certificate_arn = "${data.aws_acm_certificate.cert.arn}"
  route53_zone = "${data.aws_route53_zone.primary.zone_id}"

  # We need to override the AWS provider this module uses because
  # only the US-East 1 region can access SSL certificates
  providers = {
    "aws" = "aws.virginia"
  }
}