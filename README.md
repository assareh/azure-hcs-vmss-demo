[HashiCorp Consul Service on Azure](https://www.hashicorp.com/products/consul/service-on-azure)

### Demo Objective
VM Scale Set "web server" nodes are automatically registered with Consul on boot, and automatically removed from Consul when terminated. [Network Infrastructure Automation](https://www.consul.io/docs/nia) can be used to then automatically propogate this catalog to other devices such as load balancers.

### Description
This demo is composed of four terraform modules that should be provisioned in the following order:
1. `terraform-hcs-cluster`
2. `terraform-consul-config`
3. `terraform-vnet-with-peering`
4. `terraform-azure-vmss`

This repo is designed to be used with Terraform Cloud, with each of the modules above getting its own workspace.

Notes:
* Each workspace requires Azure credentials
* The `terraform-consul-config` workspace requires [remote state access](https://www.terraform.io/docs/cloud/workspaces/state.html#remote-state-access-controls) to the `terraform-hcs-cluster` workspace
* The `terraform-azure-vmss` workspace requires [remote state access](https://www.terraform.io/docs/cloud/workspaces/state.html#remote-state-access-controls) to the `terraform-consul-config` workspace
* [Run triggers](https://www.terraform.io/docs/cloud/workspaces/run-triggers.html) can be used to automatically initiate runs in downstream workspaces
* The `terraform-azure-vmss` workspace requires a VM image be present in your Azure resource group. The Packer template for this is in the `packer` folder
