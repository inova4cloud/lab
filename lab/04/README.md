# lab/04 - Python Hello World + Application Gateway (HTTPS)

This lab deploys a Linux App Service plan, a Python Web App, and an Azure Application Gateway.

The gateway is internet-facing, terminates TLS on port 443, redirects HTTP to HTTPS, and forwards requests to the App Service backend over HTTPS.

## Files

- `main.tf`: Azure resources for Resource Group, Service Plan, Linux Web App, VNet/Subnet, Public IP, and Application Gateway
- `variables.tf`: Project variables
- `terraform.tfvars`: Active values
- `terraform.tfvars.example`: Example values including HTTPS certificate inputs
- `outputs.tf`: Web App and Application Gateway outputs
- `app/`: Python app

## Required Variables

Set these in `terraform.tfvars` before apply:

- `appgw_ssl_cert_base64` (base64-encoded PFX)
- `appgw_ssl_cert_password` (PFX password)

## Deploy Infrastructure

1. `terraform init -reconfigure`
2. `terraform validate`
3. `terraform plan`
4. `terraform apply -auto-approve`

## Deploy App Code

After infrastructure deploy, publish app code from `app/` using Azure CLI.

1. `Compress-Archive -Path .\app\* -DestinationPath .\app.zip -Force`
2. `az webapp deploy --resource-group <rg-name> --name <webapp-name> --src-path .\app.zip --type zip`

Startup command is configured by Terraform:

- `gunicorn --bind=0.0.0.0:$PORT app:app`

## Validation

1. Open the App Service URL from the `webapp_url` output.
2. Open the Application Gateway URL from the `app_gateway_url` output.
3. Confirm `http://<app-gateway-ip>` redirects to `https://<app-gateway-ip>`.
4. Confirm `https://<app-gateway-ip>` returns the Hello World response.

## Security Notes

- Application Gateway uses predefined TLS policy `AppGwSslPolicy20220101S`.
- App Service enforces minimum TLS 1.2 for both app and SCM endpoints.
