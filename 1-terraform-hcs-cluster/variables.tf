variable "email" {
  description = "My email address"
}

variable "location" {
  description = "The location where the resources are created."
  default     = "West US 2"
}

variable "prefix" {
  description = "Name prefix to add to the resources"
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
    DoNotDelete        = "true" # true/false
  }
}
