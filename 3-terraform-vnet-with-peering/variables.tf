variable "cluster_name" {
  description = "HCS Cluster name (the value of var.prefix in terraform-hcs-cluster)"
}

variable "create_demo_rg" {
  description = "Whether to create the resource group for demo VMs or not. true means create. false means already exists"
  default     = true
}

variable "demo_resource_group_name" {
  description = "The name of the Resource Group for demo VMs (this is already created)"
}

variable "hcs_resource_group_name" {
  description = "HCS Resource Group name (the value of var.prefix in terraform-hcs-cluster)"
}

variable "location" {
  description = "The location where the resources are created."
  default     = "West US 2"
}

variable "managed_application_name" {
  description = "HCS Managed Application name (the value of var.prefix in terraform-hcs-cluster)"
}

// Tags
locals {
  common_tags = {
    owner              = "assareh"
    se-region          = "AMER - West E2 - R2"
    purpose            = "Demo Terraform and Consul"
    ttl                = "-1"    # hours
    terraform          = "true"  # true/false
    hc-internet-facing = "false" # true/false
  }
}
