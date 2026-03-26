# lab/03 - Python Hello World on Azure App Service

This lab deploys a Linux App Service plan and a Python Web App using Terraform.

## Files

- `main.tf`: Azure resources for Resource Group, Service Plan, and Linux Web App
- `variables.tf`: Project variables
- `terraform.tfvars`: Active values
- `outputs.tf`: Web App outputs
- `app/`: Python Hello World sample app

## Deploy Infrastructure

1. `terraform init -reconfigure`
2. `terraform validate`
3. `terraform plan`
4. `terraform apply -auto-approve`

## Deploy App Code

After infrastructure deploy, publish app code from `app/` using Azure CLI.

1. `az webapp deploy --resource-group <rg-name> --name <webapp-name> --src-path app --type zip`
2. In Azure Portal, set startup command to:
   - `gunicorn --bind=0.0.0.0:$PORT app:app`

Then browse the output URL from Terraform.
