data "azurerm_client_config" "current" {}

locals {
  vm_subnet_address_prefix      = cidrsubnet(var.address_space, 26 - split("/", var.address_space)[1], 0)
  bastion_subnet_address_prefix = cidrsubnet(var.address_space, 26 - split("/", var.address_space)[1], 1)
  virtual_machine_admins        = distinct(concat([data.azurerm_client_config.current.object_id], var.virtual_machine_admins))
  windows_server_admin_password = coalesce(var.windows_server_admin_password, format("%s!", title(random_pet.vm.id)))
  uniq                          = substr(md5(azurerm_resource_group.bastion.id), 0, 8)
}

resource "random_pet" "vm" {
  length = 2
  keepers = {
    resource_group_id = azurerm_resource_group.bastion.id
  }
}

// Resource group

resource "azurerm_resource_group" "bastion" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_role_assignment" "virtual_machine_admins" {
  for_each             = toset(local.virtual_machine_admins)
  scope                = azurerm_resource_group.bastion.id
  role_definition_name = "Virtual Machine Administrator Login"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "virtual_machine_users" {
  for_each             = toset(var.virtual_machine_users)
  scope                = azurerm_resource_group.bastion.id
  role_definition_name = "Virtual Machine User Login"
  principal_id         = data.azurerm_client_config.current.object_id
}

// Public SSH key

resource "azurerm_ssh_public_key" "linux" {
  name                = "${var.linux_server_name}-ssh-public-key"
  resource_group_name = upper(azurerm_resource_group.bastion.name)
  location            = azurerm_resource_group.bastion.location
  public_key          = file(var.admin_ssh_public_key_file)
}

// Azure Bastion

resource "azurerm_public_ip" "bastion" {
  name                = "${var.bastion_name}-pip"
  resource_group_name = var.resource_group_name
  location            = azurerm_virtual_network.bastion.location

  allocation_method = "Static"
  sku               = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
  name                = var.bastion_name
  resource_group_name = var.resource_group_name
  location            = azurerm_virtual_network.bastion.location

  sku                    = "Standard"
  copy_paste_enabled     = true
  file_copy_enabled      = true
  ip_connect_enabled     = false
  shareable_link_enabled = false
  tunneling_enabled      = true // Required for native client support
  scale_units            = var.scale_units

  ip_configuration {
    name                 = "ipconfig"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}

// Virtual Machines

module "linux" {
  source     = "github.com/terraform-azurerm-modules/terraform-azurerm-aad-linux-vm?ref=v1.0"
  depends_on = [azurerm_subnet.vms]

  name                = var.linux_server_name
  resource_group_name = azurerm_resource_group.bastion.name
  location            = azurerm_resource_group.bastion.location

  subnet_id                 = azurerm_subnet.vms.id
  admin_username            = var.admin_username
  admin_ssh_public_key_file = var.admin_ssh_public_key_file
}

module "windows" {
  source     = "github.com/terraform-azurerm-modules/terraform-azurerm-aad-windows-vm?ref=v1.0"
  depends_on = [azurerm_subnet.vms]

  name                = var.windows_server_name
  resource_group_name = azurerm_resource_group.bastion.name
  location            = azurerm_resource_group.bastion.location

  subnet_id      = azurerm_subnet.vms.id
  admin_username = var.admin_username
  admin_password = local.windows_server_admin_password
}
