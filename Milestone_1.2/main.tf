#
# --------------------[ Client Config ]-----------------------
#

data "azurerm_client_config" "current" {}
#
# --------------------[ Random String ]-----------------------
#
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

#
# --------------------[ Strorage Account ]-----------------------
#
resource "azurerm_storage_account" "mystorageact" {
  #name                     = "ms01tfstoragename${random_string.suffix.result}"
  name                     = "ms0102tfstoragename9ofh"
  resource_group_name      = var.Resource_Grp_Name
  location                 = var.Location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

#
# --------------------[ Service Plan for Function App ]-----------------------
#
resource "azurerm_service_plan" "myserviceplan" {
  name                = "MS-01-02-TF-App-Service-Plan"
  location            = var.Location
  resource_group_name = var.Resource_Grp_Name
  os_type             = "Linux"
  sku_name            = "Y1"
}


#
# --------------------[ Azure Key Vault ]-----------------------
#
resource "azurerm_key_vault" "mykeyvault" {
  name                        = "MS0102TFKeyVault"
  location                    = var.Location
  resource_group_name         = var.Resource_Grp_Name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = false
  soft_delete_retention_days  = 7
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    secret_permissions = ["Get", "Set", "List", "Delete", "Purge"]
  }
}


#
# --------------------[ linux function app ]-----------------------
#
resource "azurerm_linux_function_app" "ms1linuxfuntionapp" {
  name                       = "ms0102linuxfunctionapp"
  location                   = var.Location
  resource_group_name        = var.Resource_Grp_Name
  service_plan_id            = azurerm_service_plan.myserviceplan.id
  storage_account_name       = azurerm_storage_account.mystorageact.name
  storage_account_access_key = azurerm_storage_account.mystorageact.primary_access_key

  site_config {
    application_stack {
      python_version = "3.10"
    }
  }

  app_settings = {
    #"FUNCTIONS_WORKER_RUNTIME" = "python"
    #"WEBSITE_RUN_FROM_PACKAGE" = "https://${azurerm_storage_account.mystorageact.name}.blob.core.windows.net/${azurerm_storage_container.mycontainer.name}/${azurerm_storage_blob.function_code.name}"
    "API_KEY" = "@Microsoft.KeyVault(SecretUri=https://${azurerm_key_vault.mykeyvault.name}.vault.azure.net/secrets/API-KEY/)"
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [azurerm_key_vault.mykeyvault]

}

#
# --------------------[ Kay Vault access Policy ]-----------------------
#

resource "azurerm_key_vault_access_policy" "mykeyvault_a_p" {
  key_vault_id = azurerm_key_vault.mykeyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_linux_function_app.ms1linuxfuntionapp.identity[0].principal_id

  secret_permissions = ["Get"]
}

#
# --------------------[ Key Vault Secret ]-----------------------
#
resource "azurerm_key_vault_secret" "myapikey" {
  name         = "API-KEY"
  value        = var.api_key
  key_vault_id = azurerm_key_vault.mykeyvault.id
  depends_on = [
    azurerm_linux_function_app.ms1linuxfuntionapp
  ]
}

#
# --------------------[ data - role definition ]-----------------------
#
data "azurerm_role_definition" "keyvault_secrets_user" {
  name = "Key Vault Secrets User"
  scope = azurerm_key_vault.mykeyvault.id
}

#
# --------------------[ Role Assignment ]-----------------------
#
resource "azurerm_role_assignment" "funcapp_keyvault_access" {
  scope              = azurerm_key_vault.mykeyvault.id
  role_definition_id = data.azurerm_role_definition.keyvault_secrets_user.id
  principal_id       = azurerm_linux_function_app.ms1linuxfuntionapp.identity[0].principal_id

  depends_on = [azurerm_linux_function_app.ms1linuxfuntionapp]
}

#
# --------------------[ Add]-----------------------
#

resource "azurerm_storage_container" "mycontainer" {
  name                  = "test-functioncode01"
  storage_account_name = azurerm_storage_account.mystorageact.name
  #storage_account_id    = azurerm_storage_account.mystorageact.id
  #container_access_type = "private"
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "function_code" {
  name                   = "function.zip" 
  storage_account_name   = azurerm_storage_account.mystorageact.name
  storage_container_name = azurerm_storage_container.mycontainer.name
  type                   = "Block"
  source                 = "./function-code/function.zip"  
}






