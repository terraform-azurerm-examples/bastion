// Networking

resource "azurerm_virtual_network" "bastion" {
  name                = "bastion"
  location            = azurerm_resource_group.bastion.location
  resource_group_name = azurerm_resource_group.bastion.name
  address_space       = [var.address_space]
}

resource "azurerm_subnet" "vms" {
  name                 = var.subnet_name
  address_prefixes     = [local.vm_subnet_address_prefix]
  virtual_network_name = azurerm_virtual_network.bastion.name
  resource_group_name  = azurerm_resource_group.bastion.name
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  address_prefixes     = [local.bastion_subnet_address_prefix]
  virtual_network_name = azurerm_virtual_network.bastion.name
  resource_group_name  = azurerm_resource_group.bastion.name
}

resource "azurerm_network_security_group" "bastion" {
  name                = "AzureBastionSubnet-nsg"
  location            = azurerm_resource_group.bastion.location
  resource_group_name = azurerm_resource_group.bastion.name

  security_rule {
    name                       = "AllowHttpsInbound"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "Internet"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "443"
  }

  security_rule {
    name                       = "AllowGatewayManagerInbound"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "GatewayManager"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_ranges    = ["443"]
  }

  security_rule {
    name                       = "AllowAzureLoadBalancerInbound"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "AzureLoadBalancer"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_ranges    = ["443"]
  }

  security_rule {
    name                       = "AllowBastionHostCommunication"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_address_prefix      = "VirtualNetwork"
    source_port_range          = "*"
    destination_address_prefix = "VirtualNetwork"
    destination_port_ranges    = ["5701", "8080"]
  }

  security_rule {
    name                       = "AllowSshRdpOutbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "VirtualNetwork"
    destination_port_ranges    = ["22", "3389"]
  }

  security_rule {
    name                       = "AllowAzureCloudOutbound"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "AzureCloud"
    destination_port_range     = "443"
  }

  security_rule {
    name                       = "AllowAzureBastionCommunication"
    priority                   = 120
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_address_prefix      = "VirtualNetwork"
    source_port_range          = "*"
    destination_address_prefix = "VirtualNetwork"
    destination_port_ranges    = ["5701", "8080"]
  }

  security_rule {
    name                       = "AllowGetSessionInformation"
    priority                   = 130
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "Internet"
    destination_port_range     = "80"
  }
}

resource "azurerm_network_security_group" "vms" {
  name                = "${var.subnet_name}-nsg"
  location            = azurerm_resource_group.bastion.location
  resource_group_name = azurerm_resource_group.bastion.name

  security_rule {
    name                       = "AllowSshRdpFromBastion"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_address_prefix      = local.bastion_subnet_address_prefix
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "443"
  }
}

resource "azurerm_subnet_network_security_group_association" "bastion" {
  subnet_id                 = azurerm_subnet.bastion.id
  network_security_group_id = azurerm_network_security_group.bastion.id
}

resource "azurerm_subnet_network_security_group_association" "vms" {
  subnet_id                 = azurerm_subnet.vms.id
  network_security_group_id = azurerm_network_security_group.vms.id
}
