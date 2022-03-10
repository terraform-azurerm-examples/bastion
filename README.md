# Azure Bastion with native client access to AAD authenticated servers

This example configuration creates a small Azure Bastion environment using Terraform.

The environment includes a Windows 2022 Azure Edition server and an Ubuntu 20.04 server. Both have the AAD extensions configured and some basic Azure tools installed.

Terraform will output a set of commands you can then use to connect using native SSH and RDP clients.

## Lab

The full lab for Azure Bastion using native clients and AAD authentication is <https://azurecitadel.com/vm/bastion>.

## Pre-requirements

You will need

* to be Owner on an Azure subscription
* an [SSH key pair](https://docs.microsoft.com/en-gb/azure/virtual-machines/linux/mac-create-ssh-keys#create-an-ssh-key-pair), e.g.:
  * It will use `~/.ssh/id_rsa.pub` by default

## Create resources

May be run from [Cloud Shell](https://shell.azure.com).

1. Clone the repo

    ```shell
    git clone https://github.com/terraform-azurerm-examples/bastion
    ```

1. Change directory

    ```shell
    cd bastion
    ```

1. Initialise

    ```shell
    terraform init
    ```

1. Create a terraform.tfvars

    _Optional_. You may override the default variable values in variables.tf or add in additional AAD object IDs for the Virtual Machine Administrator/User Login roles on the resource group. See variables.tf for details.

    If a windows password is not specified for the admin account then one will be generated and stored in the key vault along with the private key for the SSH key pair. All access should be via AAD authentication, so these credentials are intended for break glass scenarios.

1. Plan

    ```shell
    terraform plan
    ```

1. Apply

    ```shell
    terraform apply
    ```

    Terraform will start to create the resources and will then display the outputs. The resources take about 20 minutes to deploy.

## Example outputs

```shell
admin_ssh_to_linux_server = "az network bastion ssh --name bastion --resource-group bastion --target-resource-id <linux_vmid> --username azureadmin --auth-type ssh-key --ssh-key ~/.ssh/id_rsa"
admin_username = <sensitive>
example_secret_cli = "az login --identity --allow-no-subscriptions --output none; az keyvault secret show --name sql --vault-name bastion-<uniq>-kv --query value --output tsv"
example_secret_powershell = "Connect-AzAccount -Identity | Out-Null; Get-AzKeyVaultSecret -Name sql -VaultName bastion-<uniq>-kv -AsPlainText"
rdp_to_windows_server = "az network bastion rdp --name bastion --resource-group bastion --target-resource-id <windows_vmid>"
tunnel_to_linux_server = "az network bastion tunnel --name bastion --resource-group bastion --target-resource-id <linux_vmid> --resource-port 80 --port 80"
user_ssh_to_linux_server = "az network bastion ssh --name bastion --resource-group bastion --target-resource-id <linux_vmid> --auth-type AAD"
windows_server_admin_password = <sensitive>
```
