
resource "azurerm_storage_account" "appgrprstfstore" {
  #count                    = 3
  #name                     = "appgrprstfstore${count.index}"
  name                     = "appgrprstfstore"
  resource_group_name      = azurerm_resource_group.appgrp.name
  location                 = azurerm_resource_group.appgrp.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = local.environment
  }
}

resource "azurerm_storage_container" "scripts" {
  #for_each              = toset([ "data","scripts","logs" ])
  name                 = "scripts"
  #name                  = each.key
  storage_account_id    = azurerm_storage_account.appgrprstfstore.id
  container_access_type = "private"
}

#output "container_name" {
#  value = azurerm_storage_container.scripts["data"].name
#}

/*
// map of values
resource "azurerm_storage_blob" "scripts" {
  for_each = tomap (
    {
      scripts01         = "scripts01.ps1"
      scripts02         = "scripts02.ps1"
      scripts03         = "scripts03.ps1"
    }
  )
  name                   = "${each.key}.ps1"
  storage_account_name   = azurerm_storage_account.appgrprstfstore.name
  storage_container_name = azurerm_storage_container.scripts.name
  type                   = "Block"
  #source                 = "script01.ps1"
  source                  = each.value
}
*/

resource "azurerm_storage_blob" "IISConfig" {
  name                    = "IIS.ps1"
  storage_account_name    = azurerm_storage_account.appgrprstfstore.name
  storage_container_name  = azurerm_storage_container.scripts.name
  type                    = "Block"
  source                  = "IIS.ps1"
}

# Used to execute a script file
resource "azurerm_virtual_machine_extension" "vmextension" {
  name                    = "vmextension"
  #virtual_machine_id      = azurerm_windows_virtual_machine.webwinvm.id
  virtual_machine_id      = azurerm_windows_virtual_machine.webwinvm["webvm01"].id
  publisher               = "Microsoft.Compute"
  type                    = "CustomScriptExtension"
  type_handler_version    = "2.0" 

  settings = <<SETTINGS
    {
        "fileUris": ["https://${azurerm_storage_account.appgrprstfstore.name}.blob.core.windows.net/${azurerm_storage_container.scripts.name}/${azurerm_storage_blob.IISConfig.source}"],
          "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file ${azurerm_storage_blob.IISConfig.source}"
    }
SETTINGS


  tags = {
    environment = "Production"
  }
}

