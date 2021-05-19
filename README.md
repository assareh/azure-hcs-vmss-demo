This demo is composed of four terraform modules that should be provisioned in the following order:
1. `terraform-hcs-cluster`
2. `terraform-consul-config`
3. `terraform-vnet-with-peering`
4. `terraform-azure-vmss`

This repo is designed to be used with Terraform Cloud, with each of the modules above getting their own workspace.

Notes:
* Each requires Azure credentials
* The `terraform-consul-config` workspace requires [remote state access](https://www.terraform.io/docs/cloud/workspaces/state.html#remote-state-access-controls) to the `terraform-hcs-cluster` workspace
* The `terraform-azure-vmss` workspace requires [remote state access](https://www.terraform.io/docs/cloud/workspaces/state.html#remote-state-access-controls) to the `terraform-consul-config` workspace
* [Run triggers](https://www.terraform.io/docs/cloud/workspaces/run-triggers.html) can be used to automatically initiate runs in downstream workspaces
* The `terraform-azure-vmss` workspace requires a packer template be present - TBC
