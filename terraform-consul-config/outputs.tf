output "vm-token" {
  sensitive = true
  value     = consul_acl_token.vm.id
}

output "web-token" {
  sensitive = true
  value     = consul_acl_token.web.id
}
