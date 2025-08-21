terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "sen-t" {
  name     = "sen-terraform"
  location = "UK South"
  tags = {
    environment = "dev"
  }
}

resource "azurerm_virtual_network" "sen-vn" {
  name                = "sen-virtualnetwork"
  location            = azurerm_resource_group.sen-t.location
  resource_group_name = azurerm_resource_group.sen-t.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "sen-sn" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.sen-t.name
  virtual_network_name = azurerm_virtual_network.sen-vn.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "sen-nsg" {
  name                = "sen-nsg1"
  resource_group_name = azurerm_resource_group.sen-t.name
  location            = azurerm_resource_group.sen-t.location

  tags = {
    environment = "dev"
  }

}

resource "azurerm_network_security_rule" "sen-rule" {
  name                        = "sen-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "[my device public IP for explicit access]/32"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.sen-t.name
  network_security_group_name = azurerm_network_security_group.sen-nsg.name
}

resource "azurerm_subnet_network_security_group_association" "nsg-association" {
  subnet_id                 = azurerm_subnet.sen-sn.id
  network_security_group_id = azurerm_network_security_group.sen-nsg.id
}

resource "azurerm_public_ip" "sen-ip" {
  name                = "publicip1"
  resource_group_name = azurerm_resource_group.sen-t.name
  location            = azurerm_resource_group.sen-t.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "Dev"
  }
}

resource "azurerm_network_interface" "sen-nic" {
  name                = "sen-nic"
  resource_group_name = azurerm_resource_group.sen-t.name
  location            = azurerm_resource_group.sen-t.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sen-sn.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.sen-ip.id
  }

  tags = {
    environment = "dev"
  }
}


resource "azurerm_linux_virtual_machine" "sen-vm" {
  name                = "sen-linux-vm"
  resource_group_name = azurerm_resource_group.sen-t.name
  location            = azurerm_resource_group.sen-t.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
  azurerm_network_interface.sen-nic.id, ]

  custom_data = filebase64("customdata.tpl")

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/sshkey_pub")
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  provisioner "local-exec" {
    command = templatefile ("windows-ssh-script.tpl", {
      hostname = self.public_ip_address
      user = "adminuser"
      identityfile = "~/.ssh/sshkey"
    } )
    interpreter = ["powershell", "-Command"]
  }
} 

output "public_ip_address" {
    value = "${azurerm_linux_virtual_machine.sen-vm.name} : ${azurerm_linux_virtual_machine.sen-vm.public_ip_address}"

}

