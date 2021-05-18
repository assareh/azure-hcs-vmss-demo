output "bastion_ssh_addr" {
  value = <<SSH

    Connect to your virtual machine via SSH:

    $ ssh azureuser@${azurerm_public_ip.bastion_ip.ip_address}
SSH
}

output "private_ip" {
  value = azurerm_network_interface.bastion_nic.private_ip_address
}

output "ssh_private_key" {
  # sensitive = true
  value = tls_private_key.hashidemos.private_key_pem
}

output "vmss_principal_id" {
  value = azurerm_linux_virtual_machine_scale_set.main.identity.0.principal_id
}

output "consul_config_file" {
  value = base64decode(data.hcs_cluster.default.consul_config_file)
}