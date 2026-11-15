// Entra ID users

data "azuread_user" "admin" {
  user_principal_name = "Admin@alimalikcloud.uk"
}

data "azuread_user" "app_user" {
  user_principal_name = "App.User@alimalikcloud.uk"
}

data "azuread_user" "auditor" {
  user_principal_name = "Auditor@alimalikcloud.uk"
}


// ADMIN PERMISSIONS

// Contributor on entire subscription

resource "azurerm_role_assignment" "admin_contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"

  principal_id = data.azuread_user.admin.object_id
}

// Key Vault Administrator

resource "azurerm_role_assignment" "admin_kv_admin" {
  scope                = azurerm_key_vault.main_kv.id
  role_definition_name = "Key Vault Administrator"

  principal_id = data.azuread_user.admin.object_id
}

// Storage Blob Data Owner

resource "azurerm_role_assignment" "admin_storage_owner" {
  scope                = azurerm_storage_account.hub_and_spoke_sa.id
  role_definition_name = "Storage Blob Data Owner"

  principal_id = data.azuread_user.admin.object_id
}

// Virtual Machine Administrator Login (Application VM)

resource "azurerm_role_assignment" "admin_app_vm_login" {
  scope                = azurerm_windows_virtual_machine.app_virtual_machine.id
  role_definition_name = "Virtual Machine Administrator Login"

  principal_id = data.azuread_user.admin.object_id
}

// Virtual Machine Administrator Login (Management VM)

resource "azurerm_role_assignment" "admin_management_vm_login" {
  scope                = azurerm_linux_virtual_machine.management_vm.id
  role_definition_name = "Virtual Machine Administrator Login"

  principal_id = data.azuread_user.admin.object_id
}

// Log Analytics Contributor

resource "azurerm_role_assignment" "admin_law_contributor" {
  scope                = azurerm_log_analytics_workspace.law_main.id
  role_definition_name = "Log Analytics Contributor"

  principal_id = data.azuread_user.admin.object_id
}

// Backup Contributor

resource "azurerm_role_assignment" "admin_backup_contributor" {
  scope                = azurerm_recovery_services_vault.rsv_main.id
  role_definition_name = "Backup Contributor"

  principal_id = data.azuread_user.admin.object_id
}


// AUDITOR PERMISSIONS

// Reader on subscription

resource "azurerm_role_assignment" "auditor_reader" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"

  principal_id = data.azuread_user.auditor.object_id
}

// Storage Blob Data Reader

resource "azurerm_role_assignment" "auditor_storage_reader" {
  scope                = azurerm_storage_account.hub_and_spoke_sa.id
  role_definition_name = "Storage Blob Data Reader"

  principal_id = data.azuread_user.auditor.object_id
}

// Log Analytics Reader

resource "azurerm_role_assignment" "auditor_law_reader" {
  scope                = azurerm_log_analytics_workspace.law_main.id
  role_definition_name = "Log Analytics Reader"

  principal_id = data.azuread_user.auditor.object_id
}

// Backup Reader

resource "azurerm_role_assignment" "auditor_backup_reader" {
  scope                = azurerm_log_analytics_workspace.law_main.id
  role_definition_name = "Backup Reader"

  principal_id = data.azuread_user.auditor.object_id
}


// APP USER PERMISSIONS

// Virtual Machine User Login (Application VM)

resource "azurerm_role_assignment" "app_user_vm_login" {
  scope                = azurerm_windows_virtual_machine.app_virtual_machine.id
  role_definition_name = "Virtual Machine User Login"

  principal_id = data.azuread_user.app_user.object_id
}

// Storage Blob Data Contributor

resource "azurerm_role_assignment" "app_user_storage_contributor" {
  scope                = azurerm_storage_account.hub_and_spoke_sa.id
  role_definition_name = "Storage Blob Data Contributor"

  principal_id = data.azuread_user.app_user.object_id
}

// Key Vault Secrets User

resource "azurerm_role_assignment" "app_user_keyvault_secrets" {
  scope                = azurerm_key_vault.main_kv.id
  role_definition_name = "Key Vault Secrets User"

  principal_id = data.azuread_user.app_user.object_id
}