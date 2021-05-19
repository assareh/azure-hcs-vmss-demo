resource "tls_private_key" "hashidemos" {
  algorithm = "RSA"
}

# needed for consul tokens
data "terraform_remote_state" "consul" {
  backend = "remote"

  config = {
    organization = var.organization_name
    workspaces = {
      name = var.consul_workspace_name
    }
  }
}

provider "hcs" {}

# when possible better to use provider data source instead of remote state
data "hcs_cluster" "default" {
  resource_group_name      = var.hcs_resource_group_name
  managed_application_name = var.managed_application_name

  cluster_name = var.cluster_name
}

provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "hashidemos" {
  name = var.demo_resource_group_name
}

data "azurerm_subnet" "hashidemos" {
  name                 = "internal"
  virtual_network_name = "main"
  resource_group_name  = data.azurerm_resource_group.hashidemos.name
}

data "template_file" "service" {
  template = file("${path.module}/templates/web-server.json")
  vars = {
    acl_token = data.terraform_remote_state.consul.outputs.web-token
  }
}

data "template_cloudinit_config" "this" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/templates/userdata.yaml", {
      acl_token   = data.terraform_remote_state.consul.outputs.vm-token
      consul_conf = data.hcs_cluster.default.consul_config_file
      ca_file     = data.hcs_cluster.default.consul_ca_file
      web_service = base64encode(data.template_file.service.rendered)
    })
  }
}

data "azurerm_image" "packer" {
  name                = var.vm_image_name
  resource_group_name = data.azurerm_resource_group.hashidemos.name
}

resource "azurerm_linux_virtual_machine_scale_set" "main" {
  name                            = "${var.prefix}-vmss"
  resource_group_name             = data.azurerm_resource_group.hashidemos.name
  location                        = data.azurerm_resource_group.hashidemos.location
  sku                             = "Standard_B1s"
  instances                       = 1
  admin_username                  = "azureuser"
  disable_password_authentication = true

  source_image_id = data.azurerm_image.packer.id

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.hashidemos.public_key_openssh
  }

  custom_data = data.template_cloudinit_config.this.rendered

  identity {
    type = "SystemAssigned"
  }

  network_interface {
    name    = "example"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = data.azurerm_subnet.hashidemos.id
    }
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}

#################
## Bastion host #
#################
resource "azurerm_public_ip" "bastion_ip" {
  name                = "${var.prefix}-bastion-ip"
  location            = data.azurerm_resource_group.hashidemos.location
  resource_group_name = data.azurerm_resource_group.hashidemos.name
  allocation_method   = "Dynamic"
  tags                = local.common_tags
}

resource "azurerm_network_security_group" "bastion_nsg" {
  name                = "${var.prefix}-nsg"
  location            = data.azurerm_resource_group.hashidemos.location
  resource_group_name = data.azurerm_resource_group.hashidemos.name
  tags                = local.common_tags

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "bastion_nic" {
  name                = "${var.prefix}-nic"
  location            = data.azurerm_resource_group.hashidemos.location
  resource_group_name = data.azurerm_resource_group.hashidemos.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "${var.prefix}-nic"
    subnet_id                     = data.azurerm_subnet.hashidemos.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "bastion_nic_nsg" {
  network_interface_id      = azurerm_network_interface.bastion_nic.id
  network_security_group_id = azurerm_network_security_group.bastion_nsg.id
}

resource "azurerm_virtual_machine" "bastion_vm" {
  name                          = "${var.prefix}-bastion-vm"
  location                      = data.azurerm_resource_group.hashidemos.location
  resource_group_name           = data.azurerm_resource_group.hashidemos.name
  network_interface_ids         = [azurerm_network_interface.bastion_nic.id]
  vm_size                       = "Standard_B2s"
  delete_os_disk_on_termination = true
  tags                          = local.common_tags

  identity {
    type = "SystemAssigned"
  }

  storage_os_disk {
    name              = "OsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "${var.prefix}-bastion-vm"
    admin_username = "azureuser"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = tls_private_key.hashidemos.public_key_openssh
    }
  }
}