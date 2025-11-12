// 1. Tell Terraform we are using Azure
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }

  // 2. Tell Terraform where to save its "memory" (state file)
  // This uses the storage account we made in Part B
  backend "azurerm" {
    resource_group_name  = "oriax-automation-rg"
    storage_account_name = "oriaxterraformstate" 
    container_name       = "tfstate"
    key                  = "azure-p1-static-site.terraform.tfstate" 
  }
}

// 3. Configure the Azure Provider
provider "azurerm" {
  features {}
}

// 4. Create a Resource Group for this website
resource "azurerm_resource_group" "site_rg" {
  name     = "oriax-prod-site-rg"
  location = "Central India" // <-- Set to your region
}

// 5. Create the Storage Account to host the files
resource "azurerm_storage_account" "site_storage" {
  name                     = "oriaxprodportfoliosite" 
  resource_group_name      = azurerm_resource_group.site_rg.name
  location                 = azurerm_resource_group.site_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  // 6. This is the magic! This enables the "Static website" feature
  static_website {
    index_document     = "index.html"
    error_404_document = "error.html"
  }
}

// 7. Output the final website URL
output "website_endpoint" {
  value = azurerm_storage_account.site_storage.primary_web_endpoint
}

// 8. Output the storage account name for the upload script
output "storage_account_name" {
  value = azurerm_storage_account.site_storage.name
}
output "storage_account_primary_key" {
  value     = azurerm_storage_account.site_storage.primary_access_key
  sensitive = true
}