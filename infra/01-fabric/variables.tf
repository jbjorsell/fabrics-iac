variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
}

variable "azure_devops_org_name" {
  description = "Azure DevOps organization name (e.g., contoso)"
  type        = string
}

variable "azure_devops_project_name" {
  description = "Azure DevOps project name"
  type        = string
  default     = null
}

variable "azure_devops_repo_name" {
  description = "Azure DevOps repository name to create/sync"
  type        = string
  default     = null
}

variable "azure_devops_branch_name" {
  description = "Branch name to sync with"
  type        = string
  default     = "main"
}

variable "azure_devops_directory" {
  description = "Directory at repo root to map the Fabric workspace into (must start with /)"
  type        = string
  default     = "/Fabric"
}
