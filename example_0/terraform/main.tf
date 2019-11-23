resource "azurerm_app_service_plan" "app_sp" {
  name = "myappserviceplan"
  resource_group_name = "myresourcegroup"
  sku {
    tier = "Standard"
    size = "S1"
    capacity = "1"
  }
}

# resource "azurerm_app_service_plan" "app_sp" {
#   name = "myappserviceplan"
#   resource_group_name = "myresourcegroup"
#   sku {
#     tier = "Standard"
#     size = "S2"
#     capacity = "3"
#   }
# }