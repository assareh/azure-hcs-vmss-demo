terraform {
  required_version = ">= 0.13.0"
  required_providers {
    consul = {
      source  = "hashicorp/consul"
      version = "~> 2.0"
    }
    hcs = {
      source  = "hashicorp/hcs"
      version = "~> 0.2.0"
    }
  }
}
