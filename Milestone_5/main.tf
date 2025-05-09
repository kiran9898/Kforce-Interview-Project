
#
# --------------------[ Strorage Account ]-----------------------
#
resource "azurerm_storage_account" "mystorageact" {
  #name                     = "ms01tfstoragename${random_string.suffix.result}"
  name                     = "ms05tfstoragename9ofhap"
  resource_group_name      = var.Resource_Grp_Name
  location                 = var.Location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}


#
# --------------------[ Service Plan for Function App ]-----------------------
#
resource "azurerm_service_plan" "myserviceplan" {
  name                = "MS-05-TF-App-Service-Plan"
  location            = var.Location
  resource_group_name = var.Resource_Grp_Name
  os_type             = "Windows"
  sku_name            = "Y1"
}


#
# --------------------[ Windows function app ]-----------------------
#
resource "azurerm_windows_function_app" "ms05windowsfuntionapp" {
  name                       = "ms05windowsfunctionapp"
  location                   = var.Location
  resource_group_name        = var.Resource_Grp_Name
  service_plan_id            = azurerm_service_plan.myserviceplan.id
  storage_account_name       = azurerm_storage_account.mystorageact.name
  storage_account_access_key = azurerm_storage_account.mystorageact.primary_access_key

  site_config {
    application_stack {
      powershell_core_version = "7.4"
    }
  }

 app_settings = {
    "AzureWebJobsStorage"       = azurerm_storage_account.mystorageact.primary_connection_string
    "FUNCTIONS_WORKER_RUNTIME"  = "powershell"
    "BlobStorageAccount"        = azurerm_storage_account.mystorageact.name
    #"BlobContainer"             = azurerm_storage_container.mycontainer.name
  }

  identity {
    type = "SystemAssigned"
  }

}




# resource "azurerm_function_app_function" "ms05functionappfunction" {
#   name            = "RandomNumberFunction"
#   function_app_id = azurerm_windows_function_app.ms05windowsfuntionapp.id
#   language        = "PowerShell"

#   file {
#     name    = "run.ps1"
#     content = file("${path.module}/generate-string.ps1")
#   }

#   config_json = file("${path.module}/function.json")
# }
