provider "azurerm" {
  features {}
}

variable "location" {
  default = "Southeast Asia"
}

variable "resource_group_name" {
  default = "ResourceGroupByRAFIQ-1"
}

resource "azurerm_resource_group" "resource_group_localname" {
  name                  = var.resource_group_name
  location              = var.location
}

resource "azurerm_virtual_network" "vnet_localname" {
  address_space         = ["10.0.0.0/16"]
  name                  = "vnet-for-all-resource"
  location              = azurerm_resource_group.resource_group_localname.location
  resource_group_name   = azurerm_resource_group.resource_group_localname.name
}

resource "azurerm_subnet" "subnet-vm" {
  name = "subnet-vm"
  resource_group_name   = azurerm_resource_group.resource_group_localname.name
  virtual_network_name  = azurerm_virtual_network.vnet_localname.name
  address_prefixes      = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "subnet-aks" {
  name = "subnet-aks"
  resource_group_name   = azurerm_resource_group.resource_group_localname.name
  virtual_network_name  = azurerm_virtual_network.vnet_localname.name
  address_prefixes      = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "vm_public_ip" {
  name                  = "VM-rgRafiq1-JenkinsAKSControll"
  location              = azurerm_resource_group.resource_group_localname.location
  resource_group_name   = azurerm_resource_group.resource_group_localname.name
  allocation_method     = "Static"
  sku                   = "Standard"
}

# Network Security Group
resource "azurerm_network_security_group" "vm_nsg" {
  name                  = "vm-nsg"
  location              = azurerm_resource_group.resource_group_localname.location
  resource_group_name   = azurerm_resource_group.resource_group_localname.name
}

# Allow SSH
resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "AllowSSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.resource_group_localname.name
  network_security_group_name = azurerm_network_security_group.vm_nsg.name
}

# Allow Jenkins
resource "azurerm_network_security_rule" "allow_jenkins" {
  name                        = "AllowJenkins"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8080"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.resource_group_localname.name
  network_security_group_name = azurerm_network_security_group.vm_nsg.name
}

resource "azurerm_network_interface" "vm_nic" {
  name                          = "vms-nic"
  location                      = azurerm_resource_group.resource_group_localname.location
  resource_group_name           = azurerm_resource_group.resource_group_localname.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet-vm.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
  }
}

# Attach NSG to NIC
resource "azurerm_network_interface_security_group_association" "vm_nic_nsg_association" {
  network_interface_id          = azurerm_network_interface.vm_nic.id
  network_security_group_id     = azurerm_network_security_group.vm_nsg.id
  
}


resource "azurerm_linux_virtual_machine" "VM-rafiq1-jenkinsAndAKSControll" {
  name = "VM-rafiq1-jenkinsAndAKSControll"
  resource_group_name = azurerm_resource_group.resource_group_localname.name
  location = azurerm_resource_group.resource_group_localname.location
  size = "Standard_D2s_v3"
  admin_username = "azureuser"

    network_interface_ids = [
        azurerm_network_interface.vm_nic.id
    ]


  custom_data = base64encode(<<-EOF
    #cloud-config

    package_update: true
    package_upgrade: true

    packages:
     - git
     - python3
     - python3-pip
     - openjdk-17-jdk

    runcmd:
        - curl -fsSL https://get.docker.com | sh
        - systemctl enable docker
        - systemctl start docker
        - usermod -aG docker azureuser

        - curl -sL https://aka.ms/InstallAzureCLIDeb | bash
EOF
)


    admin_ssh_key {
      username = "azureuser"
      public_key = file("/home/rafiq/Desktop/publickeyforazurevm/id_rsa.pub")
    }

    os_disk {
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }

    source_image_reference {
      publisher = "Canonical"
      offer = "ubuntu-24_04-lts"
      sku = "server"
      version = "latest"
    }

    secure_boot_enabled = true
    vtpm_enabled = true

    zone = "3"
}

output "vm_public_ip" {
  value = azurerm_public_ip.vm_public_ip.ip_address
}