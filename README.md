# Terraform Repository for Multiple Projects

This repository is organized to manage multiple Terraform projects that share the same Azure environment and backend configuration.

## Structure

- `shared/`: Contains common configurations shared across projects.
  - `backend.tf`: Terraform backend configuration (remote in Terraform Cloud).
  - `providers.tf`: Azure provider configuration.

- `lab/`: Directory for individual projects.
  - `01/`: Lab project deploying a load-balanced set of Linux VMs in Azure with network security groups.
    - **Resources**: Resource Group, Virtual Network, Subnet, Network Security Group, Public IP, Load Balancer (with backend pool, probe, and rules), Network Interfaces, and Linux Virtual Machines (configurable count).
    - `main.tf`: Main Terraform configuration.
    - `outputs.tf`: Output definitions.
    - `variables.tf`: Project-specific variables (overrides shared).
    - `terraform.tfvars`: Variable values.
    - `cloud-init.yaml`: Cloud-init configuration for VMs.
    - `backend.tf`: Backend config (same as shared).
    - `providers.tf`: Provider config (same as shared).

## Usage

To work on a project, navigate to its directory (e.g., `cd lab/01`) and run Terraform commands.

For new projects:
1. Create a new directory under `lab/` (e.g., `lab/02`).
2. Copy `backend.tf`, `providers.tf`, and `variables.tf` from `shared/` to the new project directory.
3. Customize `variables.tf` and `terraform.tfvars` as needed.
4. Create `main.tf` and other files for the project.
5. Update the workspace name in `backend.tf` for the new project.

## Shared Backend

All projects use the same Terraform Cloud organization ("inova7cloud"). Each project should have its own workspace to avoid state conflicts.

## Shared Azure Environment

All projects use the same Azure subscription and provider configuration.