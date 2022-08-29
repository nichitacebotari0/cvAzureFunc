terraform {
  backend "azurerm" {
    resource_group_name  = "CVWebsite"
    storage_account_name = "prodstacvwebsite"
    container_name       = "tfstate"
    key                  = "cvAzureFunc.tfstate"
  }

required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version= "~>3.0"
    }
}
}

provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "resource_group" {
  name     = "CVWebsite"
}

resource "azurerm_storage_account" "storage_account" {
  name                     = "prodstacvazurefunc"
  resource_group_name      = "${data.azurerm_resource_group.resource_group.name}"
  location                 = "${data.azurerm_resource_group.resource_group.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "app_service_plan" {
  name                = "prodaspCVAzureFunc"
  resource_group_name = "${data.azurerm_resource_group.resource_group.name}"
  location            = "${data.azurerm_resource_group.resource_group.location}"
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "function_app" {
  name                = "prodafCVAzureFunc"
  resource_group_name = "${data.azurerm_resource_group.resource_group.name}"
  location            = "${data.azurerm_resource_group.resource_group.location}"

  storage_account_name       = azurerm_storage_account.storage_account.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key
  service_plan_id            = azurerm_service_plan.app_service_plan.id

  site_config {}
}

output "function_app_name" {
  value = azurerm_linux_function_app.function_app.name
  description = "Deployed function app name"
}

output "function_app_default_hostname" {
  value = azurerm_linux_function_app.function_app.default_hostname
  description = "Deployed function app hostname"
}