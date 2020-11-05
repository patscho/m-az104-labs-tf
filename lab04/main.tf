# Configure the Microsoft Azure Provider.
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  subscription_id = "6ed20344-ae69-409f-8400-c0bfc0726f7f"
  features {}
}

# Create resource group
resource "azurerm_resource_group" "az104-04-rg" {
    name = "az104-04-rg"
    location = "westeurope"
    tags = {
        lab = "04"
        training = "az104"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "az104-04-vnet1" {
    name = "az104-04-vnet1"
    location = azurerm_resource_group.az104-04-rg.location
    resource_group_name = azurerm_resource_group.az104-04-rg.name
    address_space = ["10.40.0.0/20"]
    tags = {
        lab = "04"
        training = "az104"
    }
}

#Create virtual subnet
resource "azurerm_subnet" "subnet0" {
  name = "subnet0"
  resource_group_name = azurerm_resource_group.az104-04-rg.name
  virtual_network_name = azurerm_virtual_network.az104-04-vnet1.name
  address_prefixes = ["10.40.0.0/24"]
}
resource "azurerm_subnet" "subnet1" {
  name = "subnet1"
  resource_group_name = azurerm_resource_group.az104-04-rg.name
  virtual_network_name = azurerm_virtual_network.az104-04-vnet1.name
  address_prefixes = ["10.40.1.0/24"]
}

# Create public ip addresses
resource "azurerm_public_ip" "az104-04-pip0" {
  name = "az104-04-pip0"
  resource_group_name = azurerm_resource_group.az104-04-rg.name
  location = azurerm_resource_group.az104-04-rg.location
  allocation_method = "Static"
  sku = "Standard"
}
resource "azurerm_public_ip" "az104-04-pip1" {
  name = "az104-04-pip1"
  resource_group_name = azurerm_resource_group.az104-04-rg.name
  location = azurerm_resource_group.az104-04-rg.location
  allocation_method = "Static"
  sku = "Standard"
}


# Create virtual NIC 0
resource "azurerm_network_interface" "az104-04-nic0" {
  name = "az104-04-nic0"
  location = azurerm_resource_group.az104-04-rg.location
  resource_group_name = azurerm_resource_group.az104-04-rg.name
  ip_configuration {
    name = "ipconfig1"
    subnet_id = azurerm_subnet.subnet0.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.40.0.4"
    public_ip_address_id = azurerm_public_ip.az104-04-pip0.id
  }
  tags = {
      lab = "04"
      training = "az104"
  }
}
resource "azurerm_network_interface" "az104-04-nic1" {
  name = "az104-04-nic1"
  location = azurerm_resource_group.az104-04-rg.location
  resource_group_name = azurerm_resource_group.az104-04-rg.name
  ip_configuration {
    name = "ipconfig1"
    subnet_id = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.40.1.4"
    public_ip_address_id = azurerm_public_ip.az104-04-pip1.id
  }
  tags = {
      lab = "04"
      training = "az104"
  }
}

# Create virtual machine 0
resource "azurerm_windows_virtual_machine" "az104-04-vm0" {
  name = "az104-04-vm0"
  resource_group_name = azurerm_resource_group.az104-04-rg.name
  location = azurerm_resource_group.az104-04-rg.location
  size = "Standard_D2s_v3"
  admin_username = "Student"
  admin_password = "Pa55w.rd1234"
  network_interface_ids = [
    azurerm_network_interface.az104-04-nic0.id,
  ]
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2019-Datacenter"
    version = "latest"
  }
  tags = {
      lab = "04"
      training = "az104"
  }
}

resource "azurerm_windows_virtual_machine" "az104-04-vm1" {
  name = "az104-04-vm1"
  resource_group_name = azurerm_resource_group.az104-04-rg.name
  location = azurerm_resource_group.az104-04-rg.location
  size = "Standard_D2s_v3"
  admin_username = "Student"
  admin_password = "Pa55w.rd1234"
  network_interface_ids = [
    azurerm_network_interface.az104-04-nic1.id,
  ]
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2019-Datacenter"
    version = "latest"
  }
  tags = {
      lab = "04"
      training = "az104"
  }
}


# Create network security group
resource "azurerm_network_security_group" "az104-04-nsg01" {
  name = "az104-04-nsg01"
  resource_group_name = azurerm_resource_group.az104-04-rg.name
  location = azurerm_resource_group.az104-04-rg.location
  tags = {
    lab = "04"
    training = "az104"
  }
}


# Create network security rules
resource "azurerm_network_security_rule" "AllowRDPInBound" {
  name = "AllowRDPInBound"
  priority = 300
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_address_prefix = "*"
  source_port_range = "*"
  destination_address_prefix = "*"
  destination_port_range = "3389"
  resource_group_name = azurerm_resource_group.az104-04-rg.name
  network_security_group_name = azurerm_network_security_group.az104-04-nsg01.name
}


# Create network interface security group associations
resource "azurerm_network_interface_security_group_association" "nsg01-nic0" {
  network_interface_id = azurerm_network_interface.az104-04-nic0.id
  network_security_group_id = azurerm_network_security_group.az104-04-nsg01.id
}
resource "azurerm_network_interface_security_group_association" "nsg01-nic1" {
  network_interface_id = azurerm_network_interface.az104-04-nic1.id
  network_security_group_id = azurerm_network_security_group.az104-04-nsg01.id
}


# Create private DNS zone
resource "azurerm_private_dns_zone" "private_dns" {
  name = "contoso.org"
  resource_group_name = azurerm_resource_group.az104-04-rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "az104-04-vnet1-link" {
  name = "az104-04-vnet1-link"
  resource_group_name = azurerm_resource_group.az104-04-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns.name
  virtual_network_id = azurerm_virtual_network.az104-04-vnet1.id
  registration_enabled = true
  tags = {
    lab = "04"
    training = "az104"
  }
}


resource "azurerm_dns_zone" "pitmaster_com" {
  name = "pitmaster.com"
  resource_group_name = azurerm_resource_group.az104-04-rg.name
  tags = {
    lab = "04"
    training = "az104"
  }
}

resource "azurerm_dns_a_record" "az104-04-vm0" {
  name = "az104-04-vm0"
  zone_name = azurerm_dns_zone.pitmaster_com.name
  resource_group_name = azurerm_resource_group.az104-04-rg.name
  ttl = 3600
  target_resource_id = azurerm_public_ip.az104-04-pip0.id
  tags = {
    lab = "04"
    training = "az104"
  }
}


resource "azurerm_dns_a_record" "az104-04-vm1" {
  name = "az104-04-vm1"
  zone_name = azurerm_dns_zone.pitmaster_com.name
  resource_group_name = azurerm_resource_group.az104-04-rg.name
  ttl = 3600
  target_resource_id = azurerm_public_ip.az104-04-pip1.id
  tags = {
    lab = "04"
    training = "az104"
  }
}
