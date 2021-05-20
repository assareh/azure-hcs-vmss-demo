output "bastion_ssh_addr" {
  value = "ssh azureuser@${azurerm_public_ip.bastion_ip.ip_address}"
}

output "lb_http_addr" {
  value = "http://${azurerm_public_ip.example.ip_address}"
}

output "ssh_private_key" {
  # sensitive = true
  value = tls_private_key.this.private_key_pem
}

output "vmss_principal_id" {
  value = azurerm_linux_virtual_machine_scale_set.main.identity.0.principal_id
}
