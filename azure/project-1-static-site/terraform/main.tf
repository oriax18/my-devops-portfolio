// --- Provider & State Config ---
// This block tells Terraform we're using Azure and where to store its "memory".
terraform {
  # We need the 'azurerm' provider to talk to Azure
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }

  # This is the remote backend. It's where Terraform saves its 'state file'.
  # I'm using the 'oriax-automation-rg' storage account we made earlier.
  backend "azurerm" {
    resource_group_name  = "oriax-automation-rg"
    storage_account_name = "oriaxterraformstate" # My unique name for the state storage
    container_name       = "tfstate"
    key                  = "oriax-portfolio.terraform.tfstate" # State file for *this* project
  }
}

// Configure the Azure provider itself.
provider "azurerm" {
  features {}
}


// --- Website Infrastructure ---
// This is the "blueprint" for the actual website resources.

# 1. The main resource group for the website
resource "azurerm_resource_group" "oriax_portfolio_rg" {
  name     = "oriax-portfolio-website-rg"
  location = "Central India"
}

# 2. The storage account that will host the HTML/CSS files
resource "azurerm_storage_account" "oriax_portfolio_storage" {
  # This name has to be globally unique
  name                     = "oriaxprodportfoliosite" # My unique name
  resource_group_name      = azurerm_resource_group.oriax_portfolio_rg.name
  location                 = azurerm_resource_group.oriax_portfolio_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS" # LRS is cheapest and fine for a portfolio

  # This block turns on the static website feature
  static_website {
    index_document     = "index.html"
    error_404_document = "error.html"
  }
}


// --- Outputs ---
// These are values we want Terraform to print out after it's done.

# The main URL for the live website
output "website_url" {
  value = azurerm_storage_account.oriax_portfolio_storage.primary_web_endpoint
}

# The name of the storage account, so our pipeline can upload files to it
output "storage_account_name" {
  value = azurerm_storage_account.oriax_portfolio_storage.name
}

# The master key for the storage account, needed for the upload
output "storage_account_primary_key" {
  value     = azurerm_storage_account.oriax_portfolio_storage.primary_access_key
  sensitive = true # Mark this as sensitive so it doesn't show in logs
}