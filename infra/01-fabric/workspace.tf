resource "fabric_workspace" "main" {
  display_name = local.workspace_name
  capacity_id  = azapi_resource.fabric_capacity.id
}

resource "fabric_notebook" "data_ingestion" {
  display_name = "DataIngestion"
  workspace_id = fabric_workspace.main.id
}

resource "fabric_notebook" "data_transformation" {
  display_name = "DataTransformation"
  workspace_id = fabric_workspace.main.id
}

resource "fabric_lakehouse" "raw_data" {
  display_name = "RawData"
  workspace_id = fabric_workspace.main.id
}

resource "fabric_lakehouse" "processed_data" {
  display_name = "ProcessedData"
  workspace_id = fabric_workspace.main.id
}
