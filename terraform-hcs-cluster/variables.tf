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

variable "email" {
  description = "My email address"
}

variable "prefix" {
  description = "Name prefix to add to the resources"
}

variable "region" {
  description = "The region where the resources are created."
  default     = "us-west-2"
}
