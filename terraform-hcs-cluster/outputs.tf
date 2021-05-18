output "consul_private_addr" {
  value = hcs_cluster.example.consul_private_endpoint_url
}

output "consul_public_addr" {
  value = hcs_cluster.example.consul_external_endpoint_url
}

output "consul_ca_file" {
  value = base64decode(hcs_cluster.example.consul_ca_file)
}

output "consul_root_token_secret_id" {
  value = hcs_cluster.example.consul_root_token_secret_id
}

output "vnet_id" {
  value = hcs_cluster.example.vnet_id
}

output "vnet_name" {
  value = hcs_cluster.example.vnet_name
}

output "vnet_resource_group_name" {
  value = hcs_cluster.example.vnet_resource_group_name
}