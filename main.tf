provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "FoundIt_rg"
  location = var.location
}

# Public IP for VM
resource "azurerm_public_ip" "public_ip" {
  name                = "vm-public-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

# Subnets
resource "azurerm_subnet" "public_subnet" {
  name                 = "public-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "private_subnet" {
  name                 = "private-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = "vm-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowServiceRegistry"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8761"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAPIGateway"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8085"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network Interface for VM
resource "azurerm_network_interface" "vm_nic" {
  name                = "vm-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.public_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id  
  }
}

# Associate NSG with Network Interface
resource "azurerm_network_interface_security_group_association" "nsg_association" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

data "azurerm_key_vault" "foundit" {
  name                = "foundit-vault"
  resource_group_name = "foundit"
}

data "azurerm_key_vault_secret" "eureka_service_container" {
  name         = "eurekaservicecontainer"
  key_vault_id = data.azurerm_key_vault.foundit.id
}

data "azurerm_key_vault_secret" "jwt_secret_key" {
  name         = "jwtsecretkey"
  key_vault_id = data.azurerm_key_vault.foundit.id
  
}

data "azurerm_key_vault_secret" "postgres_user" {
  name         = "postgresuser"
  key_vault_id = data.azurerm_key_vault.foundit.id
}

data "azurerm_key_vault_secret" "postgres_password" {
  name         = "postgrespassword"
  key_vault_id = data.azurerm_key_vault.foundit.id
}

data "azurerm_key_vault_secret" "app_password" {
  name         = "apppassword"
  key_vault_id = data.azurerm_key_vault.foundit.id
}

data "azurerm_key_vault_secret" "support_email" {
  name         = "supportemail"
  key_vault_id = data.azurerm_key_vault.foundit.id
}


# Virtual Machine
resource "azurerm_linux_virtual_machine" "vm" { 
  name                  = "FoundIt-vm"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = "Standard_B1s"
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.vm_nic.id]

  admin_ssh_key {
     username   = "adminuser"
     public_key = file("id_rsa.pub")
  }


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18_04-lts-gen2"
    version   = "18.04.202306070"
  }

  # Pass the User Data script to the VM
   custom_data = base64encode(file("${path.root}/userdata.sh"))

}

# Create the .env file content using Key Vault secrets
locals {
  env_content = <<EOT
EUREKA_SERVICE_CONTAINER=${data.azurerm_key_vault_secret.eureka_service_container.value}
JWT_SECRET_KEY=${data.azurerm_key_vault_secret.jwt_secret_key.value}
SUPPORT_EMAIL=${data.azurerm_key_vault_secret.support_email.value}
APP_PASSWORD=${data.azurerm_key_vault_secret.app_password.value}
POSTGRES_USER=${data.azurerm_key_vault_secret.postgres_user.value}
POSTGRES_PASSWORD=${data.azurerm_key_vault_secret.postgres_password.value}
EOT
}

# Copy the updated .env file to the VM
resource "null_resource" "copy_env_file" {
  depends_on = [azurerm_linux_virtual_machine.vm]

   triggers = {
    always_run = timestamp()  # Forces it to run every time
  }

  provisioner "file" {
    content     = local.env_content
    destination = "/home/adminuser/.env"

    connection {
      type        = "ssh"
      user        = "adminuser"
      private_key = file("id_rsa")
      host        = azurerm_linux_virtual_machine.vm.public_ip_address
    }
  }
}
