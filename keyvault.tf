// Key Vault

resource "azurerm_key_vault" "bastion" {
  name                = "${var.bastion_name}-${local.uniq}-kv"
  location            = azurerm_resource_group.bastion.location
  resource_group_name = azurerm_resource_group.bastion.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name                   = "standard"
  purge_protection_enabled   = false
  soft_delete_retention_days = 7
  enable_rbac_authorization  = false
}

resource "azurerm_key_vault_access_policy" "current" {
  key_vault_id = azurerm_key_vault.bastion.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  certificate_permissions = [
    "Backup",
    "Create",
    "Delete",
    "DeleteIssuers",
    "Get",
    "GetIssuers",
    "Import",
    "List",
    "ListIssuers",
    "ManageContacts",
    "ManageIssuers",
    "Purge",
    "Recover",
    "Restore",
    "SetIssuers",
    "Update",
  ]

  key_permissions = [
    "Backup",
    "Create",
    "Decrypt",
    "Delete",
    "Encrypt",
    "Get",
    "Import",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Sign",
    "UnwrapKey",
    "Update",
    "Verify",
    "WrapKey",
  ]

  secret_permissions = [
    "Backup",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set",
  ]
}

resource "azurerm_key_vault_secret" "private_ssh_key" {
  depends_on   = [azurerm_key_vault_access_policy.current]
  name         = "${var.linux_server_name}-ssh-private-key"
  value        = file(trimsuffix(var.admin_ssh_public_key_file, ".pub"))
  key_vault_id = azurerm_key_vault.bastion.id
}

resource "azurerm_key_vault_secret" "windows_password" {
  depends_on   = [azurerm_key_vault_access_policy.current]
  name         = "${var.windows_server_name}-password"
  value        = local.windows_server_admin_password
  key_vault_id = azurerm_key_vault.bastion.id
}

resource "azurerm_key_vault_secret" "sql" {
  depends_on   = [azurerm_key_vault_access_policy.current]
  name         = "sql"
  value        = "Server=tcp:myserver.database.windows.net,1433;Database=myDataBase;User ID=mylogin@myserver;Password=myPassword;Trusted_Connection=False;Encrypt=True;"
  content_type = "Example SQL connection string"
  key_vault_id = azurerm_key_vault.bastion.id
}

resource "azurerm_key_vault_access_policy" "linux" {
  key_vault_id = azurerm_key_vault.bastion.id
  tenant_id    = module.linux.identity.tenant_id
  object_id    = module.linux.identity.principal_id

  secret_permissions = [
    "Get",
    "List",
  ]
}

resource "azurerm_key_vault_access_policy" "windows" {
  key_vault_id = azurerm_key_vault.bastion.id
  tenant_id    = module.windows.identity.tenant_id
  object_id    = module.windows.identity.principal_id

  secret_permissions = [
    "Get",
    "List",
  ]
}
