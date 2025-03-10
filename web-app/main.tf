terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        #version = "4.4.0"
        version = "4.22.0"
    }
  }
}

provider "azurerm" {
  # configuration options
  features {}
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "appgrp" {
  name     = "app-grp"
  #location = local.virtual_network.address_prefixes[0]
  location = local.resource_location
}
