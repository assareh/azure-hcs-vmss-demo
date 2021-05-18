variable "cluster_name" {
  description = "HCS Cluster name (the value of var.prefix in terraform-hcs-cluster)"
}

variable "consul_workspace_name" {
  description = "Name of the workspace associated with terraform-consul-config"
}

variable "demo_resource_group_name" {
  description = "The name of the Resource Group for demo VMs (this is already created)"
}

variable "hcs_resource_group_name" {
  description = "HCS Resource Group name (the value of var.prefix in terraform-hcs-cluster)"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default     = "West US 2"
}

variable "managed_application_name" {
  description = "HCS Managed Application name (the value of var.prefix in terraform-hcs-cluster)"
}

variable "organization_name" {
  description = "Terraform Cloud organization name"
}

variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "vm_image_name" {
  description = "The name of the VM image to use for the VMSS (this should exist in the demo resource group)"
}

// Tags
locals {
  common_tags = {
    owner              = "assareh"
    se-region          = "AMER - West E2 - R2"
    purpose            = "Demo Terraform and Consul"
    ttl                = "-1"   # hours
    terraform          = "true" # true/false
    hc-internet-facing = "true" # true/false
  }
}
