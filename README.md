4 workspaces
each requires Azure creds
terraform-consul-config requires remote state access to terraform-hcs-cluster
terraform-azure-vmss requires remote state access to terraform-consul-config
you may wish to configure run triggers
terraform-azure-vmss requires a packer template

1. terraform-hcs-cluster
2. terraform-consul-config
3. terraform-vnet-with-peering
4. terraform-azure-vmss