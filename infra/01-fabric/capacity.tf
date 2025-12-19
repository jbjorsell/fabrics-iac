data "azurerm_subscription" "current" {}
data "azuread_user" "current" {
  object_id = data.azurerm_client_config.current.object_id
}

resource "azapi_resource" "fabric_capacity" {
  type      = "Microsoft.Fabric/capacities@2023-11-01"
  name      = local.capacity_name
  location  = local.location
  parent_id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${azurerm_resource_group.fabric.name}"

  body = {
    sku = {
      name = local.sku_name
      tier = "Fabric"
    }
    properties = {
      administration = {
        members = [] # Will add admin via portal after creation
      }
    }
  }

  tags = local.common_tags
}
