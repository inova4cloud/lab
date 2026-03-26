# lab/03 - Python Hello World + SQL MOTD on Azure App Service

This lab deploys a Linux App Service plan, a Python Web App, and Azure SQL resources.
The app reads Message Of The Day (MOTD) from a SQL table.

Azure SQL is configured for Microsoft Entra admin and Entra-only authentication.

## Files

- `main.tf`: Azure resources for Resource Group, Service Plan, Linux Web App, SQL Server, SQL Database, and SQL firewall rule
- `variables.tf`: Project variables
- `terraform.tfvars`: Active values
- `outputs.tf`: Web App outputs
- `app/`: Python app that queries MOTD from SQL table

## Required Variables

Set these in `terraform.tfvars` before apply:

- `sql_entra_admin_login`
- `sql_entra_admin_object_id`
- `sql_entra_admin_tenant_id` (optional)

## Deploy Infrastructure

1. `terraform init -reconfigure`
2. `terraform validate`
3. `terraform plan`
4. `terraform apply -auto-approve`

## Deploy App Code

After infrastructure deploy, publish app code from `app/` using Azure CLI.

1. `Compress-Archive -Path .\app\* -DestinationPath .\app.zip`
2. `az webapp deploy --resource-group <rg-name> --name <webapp-name> --src-path .\app.zip --type zip`

Startup command is configured by Terraform:

- `gunicorn --bind=0.0.0.0:$PORT app:app`

## Runtime Behavior

On request to `/`:

1. App reads SQL connection settings from environment variables.
2. App ensures table `dbo.motd` exists.
3. App seeds a default message if table is empty.
4. App returns the most recent MOTD row.

Then browse the output URL from Terraform.
