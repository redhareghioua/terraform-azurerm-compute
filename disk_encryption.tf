resource "azurerm_disk_encryption_set" "main" {
  name                = "health-data-hub"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = coalesce(var.location, data.azurerm_resource_group.vm.location)
  key_vault_key_id    = azurerm_key_vault_key.disk_encryption_4096.id

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_key_vault_access_policy" "disk_encryption" {
  key_vault_id = var.disk_encryption_key_vault_id
  tenant_id    = azurerm_disk_encryption_set.main.identity.0.tenant_id
  object_id    = azurerm_disk_encryption_set.main.identity.0.principal_id
  key_permissions = [
    "get",
    "wrapkey",
    "unwrapkey",
  ]
}

resource "azurerm_key_vault_access_policy" "disk_encryption_group_operator" {
  key_vault_id = var.disk_encryption_key_vault_id

  tenant_id = data.azurerm_subscription.current.tenant_id
  object_id = var.ad_group_deploiement_id
  key_permissions = [
    "get",
    "list",
    "update",
    "recover",
    "create"
  ]
}

resource "azurerm_key_vault_key" "disk_encryption_4096" {
  name         = "disk-encryption-4096"
  key_vault_id = var.disk_encryption_key_vault_id
  key_type     = "RSA"
  key_size     = 4096
  key_opts = [
    "unwrapKey",
    "wrapKey",
  ]
  depends_on = [azurerm_key_vault_access_policy.disk_encryption_group_operator]
}
