# provider "azurerm" {
#   features {}
# }

# # Resource Group
# resource "azurerm_resource_group" "rg" {
#   name     = "ResourceGroupByRAFIQ-1"
#   location = "Southeast Asia"
# }

# # Virtual Network
# resource "azurerm_virtual_network" "main_vnet" {
#   name                = "vnet-for-all-resource"
#   address_space       = ["10.0.0.0/16"]
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
# }

# # Subnet for VM
# resource "azurerm_subnet" "vm_subnet" {
#   name                 = "subnet-vm"
#   resource_group_name  = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.main_vnet.name
#   address_prefixes     = ["10.0.1.0/24"]
# }

# # Subnet for AKS
# resource "azurerm_subnet" "aks_subnet" {
#   name                 = "subnet-aks"
#   resource_group_name  = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.main_vnet.name
#   address_prefixes     = ["10.0.2.0/24"]
# }

# # Public IP
# resource "azurerm_public_ip" "vm_public_ip" {
#   name                = "VM-rgRafiq1-forJenkinsandAKS-ip"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   allocation_method   = "Static"
#   sku                 = "Standard"
# }

# # Network Security Group
# resource "azurerm_network_security_group" "vm_nsg" {
#   name                = "vm-nsg"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
# }

# # Allow SSH
# resource "azurerm_network_security_rule" "allow_ssh" {
#   name                        = "AllowSSH"
#   priority                    = 100
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = "22"
#   source_address_prefix       = "*"
#   destination_address_prefix  = "*"
#   resource_group_name         = azurerm_resource_group.rg.name
#   network_security_group_name = azurerm_network_security_group.vm_nsg.name
# }

# # Allow Jenkins
# resource "azurerm_network_security_rule" "allow_jenkins" {
#   name                        = "AllowJenkins"
#   priority                    = 110
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = "8080"
#   source_address_prefix       = "*"
#   destination_address_prefix  = "*"
#   resource_group_name         = azurerm_resource_group.rg.name
#   network_security_group_name = azurerm_network_security_group.vm_nsg.name
# }

# # NIC
# resource "azurerm_network_interface" "vm_nic" {
#   name                = "vm-jenkins-nic"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name

#   ip_configuration {
#     name                          = "internal"
#     subnet_id                     = azurerm_subnet.vm_subnet.id
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
#   }
# }

# # Associate NSG with NIC
# resource "azurerm_network_interface_security_group_association" "vm_nic_nsg" {
#   network_interface_id      = azurerm_network_interface.vm_nic.id
#   network_security_group_id = azurerm_network_security_group.vm_nsg.id
# }

# # Linux Virtual Machine
# resource "azurerm_linux_virtual_machine" "jenkins_vm" {
#   name                = "VM-rgRafiq1-forJenkinsandAKS"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   size                = "Standard_D2s_v3"
#   admin_username      = "azureuser"

#   network_interface_ids = [
#     azurerm_network_interface.vm_nic.id
#   ]

#   admin_ssh_key {
#     username   = "azureuser"
#     public_key = file("/home/rafiq/Desktop/publickeyforazurevm/id_rsa.pub")
#   }

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Premium_LRS"
#   }

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "ubuntu-24_04-lts"
#     sku       = "server"
#     version   = "latest"
#   }

#   secure_boot_enabled = true
#   vtpm_enabled        = true

#   zone = "3"
# }

# output "vm_public_ip" {
#   value = azurerm_public_ip.vm_public_ip.ip_address
# }