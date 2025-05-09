


# --------------------[ Strorage Account ]-----------------------
#
resource "azurerm_storage_account" "mystorageact" {
  #name                     = "ms02tfstoragename${random_string.suffix.result}"
  name                     = "ms02tfstoragename9ofhap"
  resource_group_name      = var.Resource_Grp_Name
  location                 = var.Location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}


#
# --------------------[ Service Plan for Function App ]-----------------------
#
resource "azurerm_service_plan" "myserviceplan" {
  name                = "MS-02-TF-App-Service-Plan"
  location            = var.Location
  resource_group_name = var.Resource_Grp_Name
  os_type             = "Linux"
  sku_name            = "Y1"

}

#
# --------------------[ Log Analytics Workspace ]-----------------------
#
resource "azurerm_log_analytics_workspace" "myloganalytics" {
  name                = "MS-02loganalytics-func"
  location            = var.Location
  resource_group_name = var.Resource_Grp_Name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


#
# --------------------[ Log Analytics Workspace ]-----------------------
#
resource "azurerm_application_insights" "myappinsights" {
  name                = "MS-02-application-insights"
  location            = var.Location
  resource_group_name = var.Resource_Grp_Name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.myloganalytics.id
}

#
# --------------------[ linux function app ]-----------------------
#

resource "azurerm_linux_function_app" "ms02linuxfuntionapp" {
  name                       = "ms02linuxfunctionapp"
  location                   = var.Location
  resource_group_name        = var.Resource_Grp_Name
  service_plan_id            = azurerm_service_plan.myserviceplan.id
  storage_account_name       = azurerm_storage_account.mystorageact.name
  storage_account_access_key = azurerm_storage_account.mystorageact.primary_access_key

  site_config {
    application_stack {
      python_version = "3.10"
      #node_version = "18" # Or Python, Java, etc.
    }
  }
  identity {
    type = "SystemAssigned"
  }


  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"              = "python"
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.myappinsights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.myappinsights.connection_string
    #"WEBSITE_RUN_FROM_PACKAGE"              = "1"
  }
}



resource "azurerm_monitor_diagnostic_setting" "mymonitor_diagnostics" {
  name                       = "ms02-diagnostic-setting"
  target_resource_id         = azurerm_linux_function_app.ms02linuxfuntionapp.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.myloganalytics.id

  enabled_log {
    category = "FunctionAppLogs"  
  }

  metric {
    category = "AllMetrics"  
  }
}


