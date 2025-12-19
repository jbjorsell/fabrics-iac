data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "fabric" {
  name     = local.rg_name
  location = local.location
  tags     = local.common_tags
}
