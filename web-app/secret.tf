#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault
resource "azurerm_key_vault" "apprstfkeyvalut" {
  name                        = "apprstfkeyvalut"
  location                    = azurerm_resource_group.appgrp.location
  resource_group_name         = azurerm_resource_group.appgrp.name
  enabled_for_disk_encryption = true
  #tenant_id                   = data.azurerm_client_config.current.tenant_id
  tenant_id                   = var.tenant_id # created a new security-rs-grp
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  /* Using RBAC
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
    ]

    storage_permissions = [
      "Get",
    ]
  }
  */
}

data "azurerm_key_vault" "apprstfvault" {
  name                  = "apprstfvault"
  resource_group_name   = "security-grp"
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret
resource "azurerm_key_vault_secret" "vmpassword" {
  name         = "vmpassword"
  value        = var.admin_password
  key_vault_id = data.azurerm_key_vault.apprstfvault.id
}
