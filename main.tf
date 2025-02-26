resource "azurerm_resource_group" "tfe_rg" {
  name     = "tfe-resource-groupss"
  location = "West US 2"
}

resource "azurerm_storage_account" "tfe_sa" {
  name                     = "tfestorageaccountsss"
  resource_group_name      = azurerm_resource_group.tfe_rg.name
  location                 = azurerm_resource_group.tfe_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "tfe_container" {
  name                  = "contentssss"
  storage_account_name  = azurerm_storage_account.tfe_sa.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "tfe_blob" {
  name                   = "my-awesome-contentssss"
  storage_account_name   = azurerm_storage_account.tfe_sa.name
  storage_container_name = azurerm_storage_container.tfe_container.name
  type                   = "Block"
  source                 = "./some-local-file.zip"
}


resource "azurerm_data_protection_backup_vault" "tfe_vault" {
  name                = "tfe-backup-vault"
  resource_group_name = azurerm_resource_group.tfe_rg.name
  location            = azurerm_resource_group.tfe_rg.location
  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "tfe_role" {
  scope                = azurerm_storage_account.tfe_sa.id
  role_definition_name = "Storage Account Backup Contributor"
  principal_id         = azurerm_data_protection_backup_vault.tfe_vault.identity[0].principal_id
}

resource "azurerm_data_protection_backup_policy_blob_storage" "tfe_policy" {
  name                                   = "tfe-backup-policy"
  vault_id                               = azurerm_data_protection_backup_vault.tfe_vault.id
  operational_default_retention_duration = "P30D"
}

resource "azurerm_data_protection_backup_instance_blob_storage" "tfe_backup_instance" {
  name               = "tfe-backup-instance"
  vault_id           = azurerm_data_protection_backup_vault.tfe_vault.id
  location           = azurerm_resource_group.tfe_rg.location
  storage_account_id = azurerm_storage_account.tfe_sa.id
  backup_policy_id   = azurerm_data_protection_backup_policy_blob_storage.tfe_policy.id

  depends_on = [azurerm_role_assignment.tfe_role]
}
