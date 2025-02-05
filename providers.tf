terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.17.0"  // Pinning to specific minor version for stability
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    virtual_machine {
      delete_os_disk_on_deletion = true
    }
    api_management {
      purge_soft_delete_on_destroy = true
    }
  }
  subscription_id = "16ae6f44-2b54-4372-9d8c-54c8431ad26d"
  use_oidc       = true
}