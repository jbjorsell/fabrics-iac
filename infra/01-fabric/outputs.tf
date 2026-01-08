output "workspace_id" {
  description = "ID of the Fabric workspace"
  value       = fabric_workspace.main.id
}

output "capacity_name" {
  description = "Name of the Fabric capacity"
  value       = azurerm_fabric_capacity.main.name
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.fabric.name
}

output "data_ingestion_notebook_id" {
  description = "ID of the data ingestion notebook"
  value       = fabric_notebook.data_ingestion.id
}
