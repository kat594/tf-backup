terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.10.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "18bf6d23-f170-4215-be50-32d8ce4d7736" # Uncomment and update as needed
}

# Reference the existing Resource Group
data "azurerm_resource_group" "tfe_rg" {
  name = "rg_npe_ast_dev_westus2_tfe2"
}


######

# # Automation Account
# resource "azurerm_automation_account" "tfe_automation_account" {
#   name                = "tfe-automation-account"
#   location            = data.azurerm_resource_group.tfe_rg.location
#   resource_group_name = data.azurerm_resource_group.tfe_rg.name
#   sku_name            = "Basic"
# }

# # Automation Runbook for Restore Process
# resource "azurerm_automation_runbook" "tfe_restore_runbook" {
#   name                    = "tfe-restore-runbook"
#   resource_group_name     = data.azurerm_resource_group.tfe_rg.name
#   automation_account_name = azurerm_automation_account.tfe_automation_account.name
#   location                = azurerm_automation_account.tfe_automation_account.location
#   log_verbose             = "true"
#   log_progress            = "true"
#   runbook_type            = "PowerShell"
#   description             = "Restores backup from Azure Backup Vault"

#   content = <<EOF
#     # PowerShell script to restore from Backup Vault
#     $vaultName = "tfe-backup-vault-storage"
#     $resourceGroupName = "${data.azurerm_resource_group.tfe_rg.name}"
#     $backupItemName = "tfe-backup-item"
#     $recoveryPointId = "your-recovery-point-id"

#     # Connect to Azure
#     Connect-AzAccount

#     # Get the backup vault
#     $vault = Get-AzBackupVault -ResourceGroupName $resourceGroupName -Name $vaultName

#     # Get the backup item
#     $backupItem = Get-AzBackupItem -VaultId $vault.ID -ItemName $backupItemName

#     # Trigger the restore operation
#     Start-AzBackupRecovery -Item $backupItem -RecoveryPointId $recoveryPointId -RestoreToStagingStorage
# EOF
# }

# # Schedule to run the backup restore process every day at 2 AM UTC
# resource "azurerm_automation_schedule" "tfe_restore_schedule" {
#   name                    = "tfe-daily-restore-schedule"
#   resource_group_name     = data.azurerm_resource_group.tfe_rg.name
#   automation_account_name = azurerm_automation_account.tfe_automation_account.name
#   description             = "Daily backup restore schedule"
#   frequency               = "Day"
#   interval                = 1
#   start_time              = "2025-02-28T02:00:00Z"
# }

# # # Link the schedule to the runbook
# # resource "azurerm_automation_runbook_schedule" "tfe_restore_schedule_link" {
# #   runbook_name             = azurerm_automation_runbook.tfe_restore_runbook.name
# #   resource_group_name      = data.azurerm_resource_group.tfe_rg.name
# #   automation_account_name  = azurerm_automation_account.tfe_automation_account.name
# #   schedule_id              = azurerm_automation_schedule.tfe_restore_schedule.id
# # }

# # # Link the schedule to the runbook
# # resource "azurerm_automation_job_schedule" "tfe_restore_schedule_link" {
# #   resource_group_name     = data.azurerm_resource_group.tfe_rg.name
# #   automation_account_name = azurerm_automation_account.tfe_automation_account.name
# #   schedule_name           = azurerm_automation_schedule.tfe_restore_schedule.name
# #   runbook_name            = azurerm_automation_runbook.tfe_restore_runbook.name

# #   parameters = {
# #     vaultName       = "tfe-backup-vault-storage"
# #     resourceGroup   = data.azurerm_resource_group.tfe_rg.name
# #     backupItemName  = "tfe-backup-item"
# #     recoveryPointId = "your-recovery-point-id"
# #   }
# # }

# # Link the schedule to the runbook
# resource "azurerm_automation_job_schedule" "tfe_restore_schedule_link" {
#   resource_group_name     = data.azurerm_resource_group.tfe_rg.name
#   automation_account_name = azurerm_automation_account.tfe_automation_account.name
#   schedule_name           = azurerm_automation_schedule.tfe_restore_schedule.name
#   runbook_name            = azurerm_automation_runbook.tfe_restore_runbook.name

#   parameters = {
#     vaultname       = "tfe-backup-vault-storage"
#     resourcegroup   = data.azurerm_resource_group.tfe_rg.name
#     backupitemname  = "tfe-backup-item"
#     recoverypointid = "8b6539d05b8b4750b7be781d0ba79049"
#   }
# }


# Data source for existing Automation Account
data "azurerm_automation_account" "tfe_automation_account" {
  name                = "testingautomation"
  resource_group_name = data.azurerm_resource_group.tfe_rg.name
}

# Automation Runbook for Restore Process
resource "azurerm_automation_runbook" "tfe_restore_runbook" {
  name                    = "tfe-restore-runbook-storage"
  resource_group_name     = data.azurerm_resource_group.tfe_rg.name
  automation_account_name = data.azurerm_automation_account.tfe_automation_account.name
  location            = data.azurerm_resource_group.tfe_rg.location
#   location                = data.azurerm_automation_account.tfe_automation_account.location
  log_verbose             = "true"
  log_progress            = "true"
  runbook_type            = "PowerShell"
  description             = "Restores storage backup from Azure Backup Vault"

  content = <<EOF
    # PowerShell script to restore from Backup Vault
    $vaultName = "tfe-backup-vault-storage"
    $resourceGroupName = "${data.azurerm_resource_group.tfe_rg.name}"
    $backupItemName = "tfe-backup-item"
    $recoveryPointId = "your-recovery-point-id"

    # Connect to Azure
    Connect-AzAccount

    # Get the backup vault
    $vault = Get-AzBackupVault -ResourceGroupName $resourceGroupName -Name $vaultName

    # Get the backup item
    $backupItem = Get-AzBackupItem -VaultId $vault.ID -ItemName $backupItemName

    # Trigger the restore operation
    Start-AzBackupRecovery -Item $backupItem -RecoveryPointId $recoveryPointId -RestoreToStagingStorage
EOF
}

# # Schedule to run the backup restore process every day at 2 AM UTC
# resource "azurerm_automation_schedule" "tfe_restore_schedule" {
#   name                    = "tfe-daily-restore-schedule"
#   resource_group_name     = data.azurerm_resource_group.tfe_rg.name
#   automation_account_name = data.azurerm_automation_account.tfe_automation_account.name
#   description             = "Daily backup restore schedule"
#   frequency               = "Day"
#   interval                = 1
#   start_time              = "2025-02-28T02:00:00Z"
# }


# Schedule to run the backup restore process every day at 2 AM UTC
resource "azurerm_automation_schedule" "tfe_restore_schedule" {
  name                    = "tfe-daily-restore-schedule"
  resource_group_name     = data.azurerm_resource_group.tfe_rg.name
  automation_account_name = data.azurerm_automation_account.tfe_automation_account.name
  description             = "Daily backup restore schedule"
  frequency               = "Day"
  interval                = 1
  start_time              = timeadd(timestamp(), "10m") # Ensures the schedule starts at least 10 minutes from now
}


# Link the schedule to the runbook
resource "azurerm_automation_job_schedule" "tfe_restore_schedule_link" {
  resource_group_name     = data.azurerm_resource_group.tfe_rg.name
  automation_account_name = data.azurerm_automation_account.tfe_automation_account.name
  schedule_name           = azurerm_automation_schedule.tfe_restore_schedule.name
  runbook_name            = azurerm_automation_runbook.tfe_restore_runbook.name

  parameters = {
    vaultname       = "tfe-backup-vault-storage"
    resourcegroup   = data.azurerm_resource_group.tfe_rg.name
    backupitemname  = "tfe-backup-item"
    recoverypointid = "8b6539d05b8b4750b7be781d0ba79049"
  }
}
