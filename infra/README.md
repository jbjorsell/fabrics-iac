# Fabric Infrastructure as Code (Terraform)

Complete Terraform setup for managing Microsoft Fabric environments with separate bootstrap and application layers.

## Structure

```
terraform/
├── 00-bootstrap/              # State storage infrastructure
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── providers.tf
└── 01-fabric/                 # Fabric application infrastructure
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── providers.tf           # With remote backend config
    ├── environments/
    │   ├── dev.tfvars
    │   └── prod.tfvars
    └── modules/
        ├── fabric-capacity/
        └── fabric-workspace/
```

## Deployment Order

### 1. Bootstrap (One-time setup)

Creates the Azure Storage backend for Terraform state.

```bash
cd terraform/00-bootstrap

# Create terraform.tfvars from example
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars:
# - Set your subscription_id
# - Set globally unique state_storage_account_name

# Deploy
terraform init
terraform plan
terraform apply
```

**Important:** Note the outputs - you'll need `storage_account_name` for step 2.

### 2. Fabric Infrastructure

Creates Fabric capacity, workspaces, notebooks, and lakehouses.

```bash
cd terraform/01-fabric

# Update providers.tf with storage_account_name from bootstrap output

# Create terraform.tfvars
echo 'subscription_id = "your-subscription-id"' > terraform.tfvars

# Update environment files
# Edit environments/dev.tfvars and environments/prod.tfvars:
# - Add your Azure AD object IDs to administrators
# - Adjust resource names as needed

# Initialize with remote backend
terraform init

# Deploy dev environment
terraform plan -var-file=environments/dev.tfvars
terraform apply -var-file=environments/dev.tfvars

# Deploy prod environment
terraform plan -var-file=environments/prod.tfvars
terraform apply -var-file=environments/prod.tfvars
```

## What Gets Created

### 00-bootstrap

- Resource group for Terraform state
- Storage account (with versioning enabled)
- Blob container for state files

### 01-fabric

- Azure Resource Group (per environment)
- Fabric Capacity (F2 for dev, F8 for prod)
- Fabric Workspace
- Notebooks (DataIngestion, DataTransformation)
- Lakehouses (RawData, ProcessedData)

## Team Collaboration

### First Time Setup (New Team Member)

1. Get access to Azure subscription
2. Install Terraform: `brew install terraform`
3. Clone repo
4. Run in `01-fabric`: `terraform init`
5. Done - state is synced from Azure

### State Locking

Azure Storage automatically handles locking. If someone else is running Terraform, you'll wait for the lock to be released.

### Best Practices

1. **Always plan first:** `terraform plan` before apply
2. **Small changes:** Incremental changes are safer
3. **Communicate:** Let team know before major infrastructure changes
4. **Review outputs:** Always review plan before applying

## Troubleshooting

### Stuck Lock

If a Terraform lock gets stuck (e.g., crashed process):

```bash
terraform force-unlock <LOCK_ID>
```

### Update Backend Config

If you need to change storage account name, update `01-fabric/providers.tf` and run:

```bash
terraform init -migrate-state -reconfigure
```

## Cleanup

To destroy environments:

```bash
# Destroy fabric infrastructure first
cd terraform/01-fabric
terraform destroy -var-file=environments/dev.tfvars

# Then destroy bootstrap (if needed)
cd terraform/00-bootstrap
terraform destroy
```

**Warning:** Destroying bootstrap deletes the state storage. Only do this if you're completely done with the infrastructure.
