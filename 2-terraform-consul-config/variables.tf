variable "cluster_name" {
  description = "HCS Cluster name (the value of var.prefix in terraform-hcs-cluster)"
}

variable "hcs_cluster_workspace_name" {
  description = "Name of the workspace associated with terraform-hcs-cluster"
}

variable "managed_application_name" {
  description = "HCS Managed Application name (the value of var.prefix in terraform-hcs-cluster)"
}

variable "organization_name" {
  description = "Terraform Cloud organization name"
}

variable "resource_group_name" {
  description = "HCS Resource Group name (the value of var.prefix in terraform-hcs-cluster)"
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
