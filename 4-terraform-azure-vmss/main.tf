resource "random_id" "id" {
  byte_length = 1
  prefix      = "${var.prefix}-"
}

resource "tls_private_key" "this" {
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

data "azurerm_resource_group" "demo" {
  name = var.demo_resource_group_name
}

data "azurerm_subnet" "demo" {
  name                 = "internal"
  virtual_network_name = "main"
  resource_group_name  = data.azurerm_resource_group.demo.name
}

data "template_file" "web" {
  template = file("${path.module}/templates/web-server.json")
  vars = {
    acl_token = data.terraform_remote_state.consul.outputs.web-token
  }
}

data "template_cloudinit_config" "web" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/templates/vmss.yaml", {
      acl_token   = data.terraform_remote_state.consul.outputs.vm-token
      ca_file     = data.hcs_cluster.default.consul_ca_file
      consul_conf = data.hcs_cluster.default.consul_config_file
      web_service = base64encode(data.template_file.web.rendered)
    })
  }
}

data "azurerm_image" "web-server" {
  name                = var.vm_image_name
  resource_group_name = data.azurerm_resource_group.demo.name
}

resource "azurerm_linux_virtual_machine_scale_set" "main" {
  name                            = "${random_id.id.dec}-vmss"
  resource_group_name             = data.azurerm_resource_group.demo.name
  location                        = data.azurerm_resource_group.demo.location
  sku                             = "Standard_B1s"
  instances                       = 3
  admin_username                  = "azureuser"
  disable_password_authentication = true

  source_image_id = data.azurerm_image.web-server.id

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.this.public_key_openssh
  }

  custom_data = data.template_cloudinit_config.web.rendered

  identity {
    type = "SystemAssigned"
  }

  network_interface {
    name    = "example"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = data.azurerm_subnet.demo.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.example.id]
    }
  }

  depends_on = [azurerm_lb_rule.http]

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}

#######
## LB #
#######

resource "azurerm_public_ip" "example" {
  name                = "${random_id.id.dec}-lb-pip"
  location            = data.azurerm_resource_group.demo.location
  resource_group_name = data.azurerm_resource_group.demo.name
  allocation_method   = "Static"
  domain_name_label   = azurerm_public_ip.example.name
}

resource "azurerm_lb" "example" {
  name                = "${random_id.id.dec}-lb"
  location            = data.azurerm_resource_group.demo.location
  resource_group_name = data.azurerm_resource_group.demo.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.example.id
  }
}

resource "azurerm_lb_backend_address_pool" "example" {
  loadbalancer_id = azurerm_lb.example.id
  name            = "${random_id.id.dec}-bap"
}

resource "azurerm_lb_probe" "example" {
  resource_group_name = data.azurerm_resource_group.demo.name
  loadbalancer_id     = azurerm_lb.example.id
  name                = "${random_id.id.dec}-probe"
  protocol            = "Tcp"
  port                = 80
}

resource "azurerm_lb_rule" "http" {
  name                           = "${random_id.id.dec}-rule"
  resource_group_name            = data.azurerm_resource_group.demo.name
  loadbalancer_id                = azurerm_lb.example.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.example.id
  probe_id                       = azurerm_lb_probe.example.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
}

#######
## DB #
#######

resource "azurerm_network_interface" "db_nic" {
  name                = "${random_id.id.dec}-db-nic"
  location            = data.azurerm_resource_group.demo.location
  resource_group_name = data.azurerm_resource_group.demo.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "${random_id.id.dec}-db-nic"
    subnet_id                     = data.azurerm_subnet.demo.id
    private_ip_address_allocation = "dynamic"
  }
}

data "template_file" "db" {
  template = file("${path.module}/templates/db.json")
  vars = {
    acl_token = data.terraform_remote_state.consul.outputs.db-token
  }
}

data "template_cloudinit_config" "db" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/templates/db.yaml", {
      acl_token   = data.terraform_remote_state.consul.outputs.vm-token
      ca_file     = data.hcs_cluster.default.consul_ca_file
      consul_conf = data.hcs_cluster.default.consul_config_file
      db          = base64encode(data.template_file.db.rendered)
    })
  }
}

resource "azurerm_virtual_machine" "db" {
  name                          = "${random_id.id.dec}-db-vm"
  location                      = data.azurerm_resource_group.demo.location
  resource_group_name           = data.azurerm_resource_group.demo.name
  network_interface_ids         = [azurerm_network_interface.db_nic.id]
  vm_size                       = "Standard_B1s"
  delete_os_disk_on_termination = true
  tags                          = local.common_tags

  storage_os_disk {
    name              = "${random_id.id.dec}-db-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    id = data.azurerm_image.web-server.id
  }

  os_profile {
    admin_username = "azureuser"
    computer_name  = "db-vm"
    custom_data    = data.template_cloudinit_config.db.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = tls_private_key.this.public_key_openssh
    }
  }
}

#################
## Bastion host #
#################
resource "azurerm_public_ip" "bastion_ip" {
  name                = "${random_id.id.dec}-bastion-ip"
  location            = data.azurerm_resource_group.demo.location
  resource_group_name = data.azurerm_resource_group.demo.name
  allocation_method   = "Static"
  tags                = local.common_tags
}

resource "azurerm_network_security_group" "bastion_nsg" {
  name                = "${random_id.id.dec}-bastion-nsg"
  location            = data.azurerm_resource_group.demo.location
  resource_group_name = data.azurerm_resource_group.demo.name
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
  name                = "${random_id.id.dec}-bastion-nic"
  location            = data.azurerm_resource_group.demo.location
  resource_group_name = data.azurerm_resource_group.demo.name
  tags                = local.common_tags

  ip_configuration {
    name                          = "${random_id.id.dec}-bastion-nic"
    subnet_id                     = data.azurerm_subnet.demo.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "bastion_nic_nsg" {
  network_interface_id      = azurerm_network_interface.bastion_nic.id
  network_security_group_id = azurerm_network_security_group.bastion_nsg.id
}

resource "azurerm_virtual_machine" "bastion_vm" {
  name                          = "${random_id.id.dec}-bastion-vm"
  location                      = data.azurerm_resource_group.demo.location
  resource_group_name           = data.azurerm_resource_group.demo.name
  network_interface_ids         = [azurerm_network_interface.bastion_nic.id]
  vm_size                       = "Standard_B1s"
  delete_os_disk_on_termination = true
  tags                          = local.common_tags

  storage_os_disk {
    name              = "${random_id.id.dec}-bastion-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  os_profile {
    admin_username = "azureuser"
    computer_name  = "bastion-vm"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = tls_private_key.this.public_key_openssh
    }
  }

  provisioner "file" {
    source      = "files/"
    destination = "/home/azureuser/"

    connection {
      type        = "ssh"
      user        = "azureuser"
      private_key = tls_private_key.this.private_key_pem
      host        = azurerm_public_ip.bastion_ip.ip_address
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y ansible",
      "ansible-playbook helloworld.yaml",
    ]

    connection {
      type        = "ssh"
      user        = "azureuser"
      private_key = tls_private_key.this.private_key_pem
      host        = azurerm_public_ip.bastion_ip.ip_address
    }
  }
}
