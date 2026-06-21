# provider "azurerm" {
#   features {}
# }

# # Variables are here
# variable "location" {
#   default = "Southeast Asia"
# }

# variable "resource_group_name" {
#   default = "ResourceGroupByRAFIQ"
# }

# variable "vm_name" {
#   default = "dev-vm"
# }

# variable "admin_username" {
#   default = "azureuser"
# }

# # Resource Group
# resource "azurerm_resource_group" "rg" {
#   name     = var.resource_group_name
#   location = var.location
# }

# # Virtual Network
# resource "azurerm_virtual_network" "vnet" {
#   name                = "first-vnet"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   address_space       = ["10.0.0.0/16"]
# }

# # Subnet
# resource "azurerm_subnet" "subnet" {
#   name                 = "public-subnet"
#   resource_group_name  = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes     = ["10.0.1.0/24"]
# }

# # Public IP
# resource "azurerm_public_ip" "pubip" {
#   name                = "vm-public-ip"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   allocation_method   = "Static"
# }

# # NSG
# resource "azurerm_network_security_group" "nsg" {
#   name                = "vm-nsg"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
# }

# # Allow SSH
# resource "azurerm_network_security_rule" "ssh" {
#   name                        = "Allow-SSH"
#   priority                    = 100
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = "22"
#   source_address_prefix       = "*"
#   destination_address_prefix  = "*"
#   resource_group_name         = azurerm_resource_group.rg.name
#   network_security_group_name = azurerm_network_security_group.nsg.name
# }

# # NIC
# resource "azurerm_network_interface" "nic" {
#   name                = "vm-nic"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name

#   ip_configuration {
#     name                          = "internal"
#     subnet_id                     = azurerm_subnet.subnet.id
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = azurerm_public_ip.pubip.id
#   }
# }

# # Attach NSG to NIC
# resource "azurerm_network_interface_security_group_association" "nsg_attach" {
#   network_interface_id      = azurerm_network_interface.nic.id
#   network_security_group_id = azurerm_network_security_group.nsg.id
# }

# # Linux VM
# resource "azurerm_linux_virtual_machine" "vm" {
#   name                = var.vm_name
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   size                = "Standard_B1s"
#   admin_username      = var.admin_username

#   network_interface_ids = [
#     azurerm_network_interface.nic.id
#   ]

#   admin_password                  = "Password1234!"
#   disable_password_authentication = false

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-jammy"
#     sku       = "22_04-lts"
#     version   = "latest"
#   }
# }

# # Output public IP
# output "public_ip" {
#   value = azurerm_public_ip.pubip.ip_address
# }
