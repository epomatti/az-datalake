terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.56.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

data "azuread_client_config" "current" {}


### Group ###

resource "azurerm_resource_group" "default" {
  name     = "rgmydatalake"
  location = "eastus"
}

### Data Lake ###

resource "azurerm_storage_account" "lake" {
  name                     = "dlsmydatalake789"
  resource_group_name      = azurerm_resource_group.default.name
  location                 = azurerm_resource_group.default.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  // Enable this for Gen2 Hierarchy
  is_hns_enabled           = true
}

resource "azurerm_role_assignment" "adlsv2" {
  scope                = azurerm_storage_account.lake.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azuread_client_config.current.object_id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "default" {
  name               = "myfilesystem001"
  storage_account_id = azurerm_storage_account.lake.id

  depends_on = [
    azurerm_role_assignment.adlsv2
  ]
}
