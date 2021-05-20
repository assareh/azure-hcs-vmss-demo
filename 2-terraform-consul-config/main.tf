provider "hcs" {}

# when possible better to use provider data source instead of remote state
data "hcs_cluster" "default" {
  resource_group_name      = var.resource_group_name
  managed_application_name = var.managed_application_name

  cluster_name = var.cluster_name
}

# but remote state is required to fetch the token
data "terraform_remote_state" "hcs-cluster" {
  backend = "remote"

  config = {
    organization = var.organization_name
    workspaces = {
      name = var.hcs_cluster_workspace_name
    }
  }
}

provider "consul" {
  address    = trimprefix(data.hcs_cluster.default.consul_external_endpoint_url, "https://")
  datacenter = "dc1"
  scheme     = "https"
  token      = data.terraform_remote_state.hcs-cluster.outputs.consul_root_token_secret_id
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

resource "consul_acl_policy" "db" {
  name        = "db"
  datacenters = ["dc1"]
  rules       = <<-RULE
service "db" {
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

data "consul_acl_token_secret_id" "vm" {
    accessor_id = consul_acl_token.vm.id
}

resource "consul_acl_token" "web" {
  policies = [consul_acl_policy.web.name]
}

data "consul_acl_token_secret_id" "web" {
    accessor_id = consul_acl_token.web.id
}

resource "consul_acl_token" "db" {
  policies = [consul_acl_policy.db.name]
}

data "consul_acl_token_secret_id" "db" {
    accessor_id = consul_acl_token.db.id
}