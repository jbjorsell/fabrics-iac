# Azure DevOps repo + Fabric Git sync

# Create an Azure DevOps Project (inside your organization)
resource "azuredevops_project" "fabric" {
  name               = local.ado_project_name
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"
}

# Create an empty Git repository in that project
resource "azuredevops_git_repository" "fabric_repo" {
  project_id = azuredevops_project.fabric.id
  name       = local.ado_repo_name

  initialization {
    init_type = "Clean"
  }
}

# Connect Fabric Workspace to the Azure DevOps repository
resource "fabric_workspace_git" "sync" {
  workspace_id            = fabric_workspace.main.id
  initialization_strategy = "PreferWorkspace"

  git_provider_details = {
    git_provider_type = "AzureDevOps"
    organization_name = var.azure_devops_org_name
    project_name      = azuredevops_project.fabric.name
    repository_name   = azuredevops_git_repository.fabric_repo.name
    branch_name       = var.azure_devops_branch_name
    directory_name    = var.azure_devops_directory
  }

  # Use the current user identity for Git (Automatic)
  git_credentials = {
    source = "Automatic"
  }
}
