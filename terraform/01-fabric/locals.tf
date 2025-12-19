locals {
  # Naming convention
  resource_prefix = "fabric-iac-${var.environment}"

  # Common settings for all environments
  location = "swedencentral"
  sku_name = "F2"

  # Resource names (same pattern for all environments)
  rg_name        = "rg-${local.resource_prefix}"
  capacity_name  = "fab${var.environment}cap01" # No hyphens - required by API
  workspace_name = "ws-${local.resource_prefix}"

  # Common tags applied to all resources
  common_tags = {
    Environment = var.environment
  }

}
