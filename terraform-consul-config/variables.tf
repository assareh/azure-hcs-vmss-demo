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
  description = "HCS Cluster name (the value of var.prefix in terraform-hcs-cluster)"
}

variable "consul_root_token_secret_id" {
  description = "HCS Cluster root token secret ID (consul_root_token_secret_id output in terraform-hcs-cluster)"
}

variable "managed_application_name" {
  description = "HCS Managed Application name (the value of var.prefix in terraform-hcs-cluster)"
}

variable "resource_group_name" {
  description = "HCS Resource Group name (the value of var.prefix in terraform-hcs-cluster)"
}
