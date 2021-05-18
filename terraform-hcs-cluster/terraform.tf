terraform {
  required_version = ">= 0.13.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    hcs = {
      source  = "hashicorp/hcs"
      version = "~> 0.2.0"
    }
  }
}
