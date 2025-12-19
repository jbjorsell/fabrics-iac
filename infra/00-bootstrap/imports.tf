import {
  to = azurerm_resource_group.tfstate
  id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/fabric-iac-tfstate"
}

import {
  to = azurerm_storage_account.tfstate
  id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/fabric-iac-tfstate/providers/Microsoft.Storage/storageAccounts/${local.storage_account_name}"
}

import {
  to = azurerm_storage_container.tfstate
  id = "${azurerm_storage_account.tfstate.id}/blobServices/default/containers/tfstate"
}
