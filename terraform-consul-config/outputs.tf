output "vm-token" {
  sensitive = true
  value     = consul_acl_token.vm.id
}

output "web-token" {
  sensitive = true
  value     = consul_acl_token.web.id
}

output "token" {
  value = data.terraform_remote_state.hcs-cluster.outputs.consul_root_token_secret_id
}