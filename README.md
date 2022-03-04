# Azure Bastion with native client access to AAD authenticated servers

This example configuration creates a small example bastion environment using Terraform.

The environment includes a Windows 2022 Azure Edition server and an Ubuntu 20.04 server. Both have the AAD extensions configured.

This page also has instructions for accessing the servers using the use of native Windows RDP and SSH tools from Windows, and how to use the bastion tunnel for ssh and scp access from linux.

Overview:

1. Create the example environment using Terraform
1. Access the Windows 2022 and Ubuntu 20.04 servers using native RDP and SSH tools, with AAD authentication

## Pre-requirements

You will need

* to be Owner on an Azure subscription
* an [SSH key pair](https://docs.microsoft.com/azure/virtual-machines/linux/mac-create-ssh-keys)

## Create resources

May be run from [Cloud Shell](https://shell.azure.com).

1. Clone the repo

    ```shell
    git clone https://github.com/terraform-azurerm-examples/bastion-native-client-via-aad bastion
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

    Optional.

    Feel free to override the default variable values in variables.tf or add in additional AAD object IDs for the Virtual Machine Administrator/User Login roles on the resource group.

1. Plan

    ```shell
    terraform plan
    ```

1. Apply

    ```shell
    terraform apply
    ```

    The resources will take about 20 minutes to deploy.

## Resources created

| **Resource Type** | **Default Name** | **Notes** |
|---|---|
| Resource group | bastion | |
| Virtual Network | bastion | 172.19.76.0/25, split into two /26 subnets for VMs and Azure Bastion |
| Bastion | bastion | Standard SKU |
| SSH Key | ubuntu-ssh-public-key | ~/.ssh/|
| VM | ubuntu | Ubuntu 20.04 with AAD and Azure tools |
| VM | windows | Windows 2022 Server Azure Edition with AAD and Azure tools |
| Key Vault | bastion-############-kv | Secrets: windows password, private SSH key |

## RDP

The command to initiate an RDP session is shown in the Terraform output.

1. Show `terraform output`

    ```shell
    terraform output
    ```

    or

    ```shell
    terraform output rdp_to_windows_server
    ```

    Example output:

    ```shell
    az network bastion rdp --name bastion --resource-group bastion --target-resource-id <vmid>
    ```

    Copy the command.

1. Authenticate

    The RDP command only works from Windows. You'll need the [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli-windows) installed at the OS level.

    ```shell
    az login
    ```

    Check you are in the right subscription. (This is your "current context".)

    ```shell
    az account show
    ```

    > If not then [change subscription](https://docs.microsoft.com/en-us/cli/azure/manage-azure-subscriptions-azure-cli#change-the-active-subscription).

1. RDP

    Run the command you copied earlier.

    ```shell
    az network bastion rdp --name bastion --resource-group bastion --target-resource-id <vmid>
    ```

    You will be prompted to authenticate using your AAD credentials.

    ![authenticate]/images/authenticate.png)

    If you have Virtual Machine Administrator Login or Virtual Machine User Login then the RDP session will open.

    ![rdp]/images/rdp.png)

## SSH

## Tunnelling
