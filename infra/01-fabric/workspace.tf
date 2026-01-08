# Does not seem to work for fabric trial version 
# data "fabric_capacity" "main" {
#   display_name = azurerm_fabric_capacity.main.name

#   lifecycle {
#     postcondition {
#       condition     = self.state == "Active"
#       error_message = "Fabric Capacity is not in Active state. Please check the Fabric Capacity status."
#     }
#   }
# }

# NOTE: Only fabric trial version
data "fabric_capacity" "main" {
  display_name = "Trial-20260101T063937Z-mb3qLdSpwEisL5_LSz7Atw"
}

resource "fabric_workspace" "main" {
  display_name = local.workspace_name
  capacity_id  = data.fabric_capacity.main.id
}

resource "fabric_notebook" "data_ingestion" {
  display_name = "DataIngestion"
  workspace_id = fabric_workspace.main.id
  format       = "ipynb"

  definition = {
    "notebook-content.ipynb" = {
      source = "${local.notebooks_path}/data_ingestion.ipynb"
    }
  }
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
