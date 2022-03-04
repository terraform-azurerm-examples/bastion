# export ARM_THREEPOINTZERO_BETA=true

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.97"
    }
  }
}

provider "azurerm" {
  features {

    resource_group {
      prevent_deletion_if_contains_resources = true
    }

    key_vault {
      // This setting is not recommended for production key vaults
      purge_soft_delete_on_destroy = true
    }
  }

  storage_use_azuread = true
}
