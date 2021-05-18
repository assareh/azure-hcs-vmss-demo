provider "hcs" {}

data "hcs_cluster" "default" {
  resource_group_name      = var.resource_group_name
  managed_application_name = var.managed_application_name

  cluster_name = var.cluster_name
}

provider "consul" {
  address    = trimprefix(data.hcs_cluster.default.consul_external_endpoint_url, "https://")
  datacenter = "dc1"
  token      = var.consul_root_token_secret_id
}

resource "consul_acl_policy" "vm" {
  name        = "vm"
  datacenters = ["dc1"]
  rules       = <<-RULE
node_prefix "" {
	policy = "write"
}
service_prefix "" {
	policy = "read"
}
    RULE
}

resource "consul_acl_policy" "web" {
  name        = "web"
  datacenters = ["dc1"]
  rules       = <<-RULE
service "web" {
  policy = "write"
}
    RULE
}

resource "consul_acl_role" "vm" {
  name = "vm"

  policies = [
    consul_acl_policy.vm.id
  ]
}

resource "consul_acl_token" "vm" {
  roles = [consul_acl_role.vm.name]
}

resource "consul_acl_token" "web" {
  policies = [consul_acl_policy.web.name]
}
