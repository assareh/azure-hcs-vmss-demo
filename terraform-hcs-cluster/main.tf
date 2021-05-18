provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "hcs" {
  name     = var.prefix
  location = var.location
  tags     = local.common_tags
}

provider "hcs" {}

data "hcs_consul_versions" "default" {}

data "hcs_plan_defaults" "default" {}

resource "hcs_cluster" "example" {
  resource_group_name      = azurerm_resource_group.hcs.name
  managed_application_name = var.prefix
  email                    = var.email
  cluster_mode             = "Development"
  consul_datacenter        = "dc1"
  consul_external_endpoint = true
  min_consul_version       = data.hcs_consul_versions.default.recommended
  plan_name                = data.hcs_plan_defaults.default.plan_name
  tags                     = local.common_tags
}
