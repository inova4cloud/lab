terraform {
  backend "remote" {
    organization = "inova7cloud"

    workspaces {
      name = "azure-lab"
    }
  }
}
