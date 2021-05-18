// Tags
locals {
  common_tags = {
    owner              = "assareh"
    se-region          = "AMER - West E2 - R2"
    purpose            = "Demo Terraform and Consul"
    ttl                = "-1"   #hours
    terraform          = "true" # true/false
    hc-internet-facing = "true" # true/false
  }
}

variable "cluster_name" {
  description = "HCS Cluster name"
}

variable "managed_application_name" {
  description = "HCS Managed Application name"
}

variable "resource_group_name" {
  description = "HCS Resource Group name"
}
