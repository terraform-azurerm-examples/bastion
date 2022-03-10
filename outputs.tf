output "admin_username" {
  value     = var.admin_username
  sensitive = true
}

output "windows_server_admin_password" {
  value     = local.windows_server_admin_password
  sensitive = true
}

output "rdp_to_windows_server" {
  value = "az network bastion rdp --name ${var.bastion_name} --resource-group ${var.resource_group_name} --target-resource-id ${module.windows.id}"
}

output "user_ssh_to_linux_server" {
  value = "az network bastion ssh --name ${var.bastion_name} --resource-group ${var.resource_group_name} --target-resource-id ${module.linux.id} --auth-type AAD"
}

output "admin_ssh_to_linux_server" {
  value = "az network bastion ssh --name ${var.bastion_name} --resource-group ${var.resource_group_name} --target-resource-id ${module.linux.id} --username ${var.admin_username} --auth-type ssh-key --ssh-key ${local.admin_ssh_private_key_file}"
}

output "tunnel_to_linux_server" {
  value = "az network bastion tunnel --name ${var.bastion_name} --resource-group ${var.resource_group_name} --target-resource-id ${module.linux.id} --resource-port 8080 --port 8080"
}

output "example_secret_powershell" {
  value = "Connect-AzAccount -Identity | Out-Null; Get-AzKeyVaultSecret -Name sql -VaultName ${azurerm_key_vault.bastion.name} -AsPlainText"
}

output "example_secret_cli" {
  value = "az login --identity --allow-no-subscriptions --output none; az keyvault secret show --name sql --vault-name bastion-7283ac36-kv --query value --output tsv"
}