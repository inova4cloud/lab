# Terraform Multi-Project Lab Repository

This repository contains multiple Terraform lab projects that share the same Azure environment model and common provider/backend templates.

## Repository Layout

```text
.
├── shared/
│   ├── backend.tf
│   └── providers.tf
└── lab/
   ├── 01/
   └── 02/
```

### shared/

- `backend.tf`: Terraform Cloud backend template.
- `providers.tf`: Shared Azure provider configuration.

### lab/01/

Purpose:
Deploy a VM-based lab behind a load balancer.

Main resources:
- Resource Group
- Virtual Network and Subnet
- Network Security Group
- Public IP and Load Balancer
- Network Interfaces
- Linux Virtual Machines

Project files:
- `main.tf`
- `variables.tf`
- `terraform.tfvars`
- `outputs.tf`
- `cloud-init.yaml`
- `backend.tf`
- `providers.tf`

### lab/02/

Purpose:
Deploy a private Linux Web App test environment with private connectivity validation.

Main resources:
- Resource Group
- App Service Plan
- Linux Web App
- Virtual Network and Subnets
- Private Endpoint
- Private DNS Zone (`privatelink.azurewebsites.net`)
- Azure Bastion Host
- Private jumpbox VM for in-VNet testing

Project files:
- `main.tf`
- `variables.tf`
- `terraform.tfvars`
- `terraform.tfvars.example`
- `outputs.tf`
- `backend.tf`
- `providers.tf`

## Working with a Project

1. Change directory to the project folder:
  - `cd lab/01`
  - `cd lab/02`
2. Initialize Terraform:
  - `terraform init -reconfigure`
3. Validate and review changes:
  - `terraform validate`
  - `terraform plan`
4. Apply changes:
  - `terraform apply -auto-approve`

## lab/02 Private Web App Test Flow

1. Apply Terraform in `lab/02`.
2. Open Azure Bastion and connect to the jumpbox VM.
3. From the jumpbox, verify DNS and HTTP reachability:
  - `nslookup <webapp-name>.azurewebsites.net`
  - `curl -I https://<webapp-name>.azurewebsites.net`
4. Confirm the hostname resolves to a private endpoint IP.

## Creating a New Lab Project

1. Create a new folder under `lab/` (for example, `lab/03`).
2. Copy `backend.tf` and `providers.tf` from `shared/`.
3. Add project-specific `main.tf`, `variables.tf`, `terraform.tfvars`, and `outputs.tf`.
4. Set a unique Terraform Cloud workspace in the project `backend.tf`.
5. Run `terraform init -reconfigure` in the new project folder.

## Backend and Azure Scope

- Terraform Cloud organization: `inova7cloud`
- Recommendation: use one workspace per project to avoid state conflicts.
- Azure provider context is shared, but resources are isolated by each project's naming and state.