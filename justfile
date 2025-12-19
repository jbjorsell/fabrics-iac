set shell := ["sh", "-c"]

bootstrap_dir := "terraform/00-bootstrap"
fabric_dir := "terraform/01-fabric"
backend_file := fabric_dir + "/backend.hcl"
outputs_cache := ".just-cache"
bootstrap_tf := "tofu -chdir=" + bootstrap_dir
fabric_tf := "tofu -chdir=" + fabric_dir
arm_sub_id := "ARM_SUBSCRIPTION_ID=$(cat " + outputs_cache + "/subscription_id)"

default:
	@just --list

_cache-outputs:
    @mkdir -p {{outputs_cache}}
    @if [ ! -f {{outputs_cache}}/subscription_id ]; then \
        az account show --query id -o tsv > {{outputs_cache}}/subscription_id 2>/dev/null || echo "" > {{outputs_cache}}/subscription_id; \
    fi

bootstrap-init:
    {{bootstrap_tf}} init -backend=false -reconfigure

bootstrap-sync: _cache-outputs
    {{arm_sub_id}} {{bootstrap_tf}} apply -refresh-only -auto-approve -target=azurerm_resource_group.tfstate -target=azurerm_storage_account.tfstate -target=azurerm_storage_container.tfstate

bootstrap-plan: _cache-outputs
    {{arm_sub_id}} {{bootstrap_tf}} plan

bootstrap-apply: _cache-outputs
    {{arm_sub_id}} {{bootstrap_tf}} apply -auto-approve

backend-config:
    mkdir -p {{fabric_dir}}
    {{bootstrap_tf}} output -json | jq -r '"resource_group_name = \"\(.resource_group_name.value)\"\nstorage_account_name = \"\(.storage_account_name.value)\"\ncontainer_name = \"\(.container_name.value)\""' > {{backend_file}}
    @echo "Created {{backend_file}}"

bootstrap: bootstrap-init bootstrap-apply backend-config fabric-init
    @echo "✓ Bootstrap complete - ready to deploy environments"

sync: bootstrap-init bootstrap-sync backend-config fabric-init
    @echo "✓ Synced to existing infrastructure - ready to deploy environments"

fabric-init: backend-config
    {{fabric_tf}} init -backend-config=backend.hcl

plan env: (_fabric-cmd "plan" env)

apply env: (_fabric-cmd "apply" env)

destroy env: (_fabric-cmd "destroy" env)

dev: (apply "dev")

prod: (apply "prod")

az-login:
    az login

fmt:
    {{bootstrap_tf}} fmt
    {{fabric_tf}} fmt -recursive

validate:
    {{bootstrap_tf}} validate
    {{fabric_tf}} validate

outputs env:
    {{fabric_tf}} output -var-file=environments/{{env}}.tfvars

clean:
    rm -rf {{bootstrap_dir}}/.terraform {{fabric_dir}}/.terraform
    rm -rf {{outputs_cache}}
    rm -f {{backend_file}}

_fabric-cmd cmd env: _cache-outputs
    [ -f {{fabric_dir}}/environments/{{env}}.tfvars ] || { echo "Environment '{{env}}' not found"; exit 1; }
    {{arm_sub_id}} {{fabric_tf}} {{cmd}} -var-file=environments/{{env}}.tfvars