data "local_file" "cloudinit" {
  filename = "cloudinit"
}

output "filecontents" {
  value = data.local_file.cloudinit.content
}

resource "azurerm_windows_virtual_machine" "webwinvm" {
  for_each = var.app_environment.production.subnets["websubnet01"].machines
  name                  = each.key
  location              = azurerm_resource_group.appgrp.location
  resource_group_name   = azurerm_resource_group.appgrp.name
  size                  = "Standard_B2s"
  admin_username        = var.admin_username
  #admin_password        = var.admin_password
  admin_password        = azurerm_key_vault_secret.vmpassword.value
  network_interface_ids = [
    azurerm_network_interface.web_int[each.key].id,
  ]

  #availability_set_id               = azurerm_availability_set.appavset.id
  #zone                               = (count.index) + 1

  vm_agent_platform_updates_enabled = true

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "appvm" {
  for_each = var.app_environment.production.subnets["appsubnet01"].machines
  name                = each.key
  resource_group_name = azurerm_resource_group.appgrp.name
  location            = local.resource_location
  size                = "Standard_B1s"
  admin_username      = "linuxadmin"
  admin_password = var.admin_password
  disable_password_authentication = false
  custom_data = data.local_file.cloudinit.content_base64

  network_interface_ids = [
    azurerm_network_interface.app_int[each.key].id,
  ]

    os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
        version   = "latest"
  }
}

