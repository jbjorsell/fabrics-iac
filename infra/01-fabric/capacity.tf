data "azuread_user" "current" {
  object_id = data.azurerm_client_config.current.object_id
}

resource "azurerm_fabric_capacity" "main" {
  name                = local.capacity_name
  resource_group_name = azurerm_resource_group.fabric.name
  location            = local.location

  sku {
    name = local.sku_name
    tier = "Fabric"
  }

  administration_members = [data.azuread_user.current.user_principal_name]

  tags = local.common_tags
}
