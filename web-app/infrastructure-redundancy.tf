/*
resource "azurerm_availability_set" "appavset" {
  name                = "appavset"
  location            = azurerm_resource_group.appgrp.location
  resource_group_name = azurerm_resource_group.appgrp.name
  
  platform_fault_domain_count   = 3
  platform_update_domain_count  = 3

  tags = {
    environment = local.environment
  }
}
*/

