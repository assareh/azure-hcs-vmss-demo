output "db-token" {
  sensitive = true
  value     = data.consul_acl_token_secret_id.db.secret_id
}

output "vm-token" {
  sensitive = true
  value     = data.consul_acl_token_secret_id.vm.secret_id
}

output "web-token" {
  sensitive = true
  value     = data.consul_acl_token_secret_id.web.secret_id
}
