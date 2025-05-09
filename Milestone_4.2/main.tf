
# Random String Generator
resource "random_id" "storage_suffix" {
  byte_length = 3
}

# Storage Account for Function App
resource "azurerm_storage_account" "function_sa" {
  name                     = "${var.Storage_Account_Name}${random_id.storage_suffix.hex}"
  #name                     = "ms0402funcappstorage${random_id.storage_suffix.hex}"
  resource_group_name      = var.Resource_Grp_Name
  location                 = var.Location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


# App Service Plan (for both apps)
resource "azurerm_service_plan" "app_plan" {
  name                = "ms-04-2-app-service-plan"
  location            = var.Location
  resource_group_name = var.Resource_Grp_Name
  os_type             = "Linux"
  sku_name            = "P1v2"
}

# Function App with VNet Integration
resource "azurerm_linux_function_app" "func_app" {
  name                       = "ms-04-2-func-app"
  resource_group_name        = var.Resource_Grp_Name
  location                   = var.Location
  service_plan_id            = azurerm_service_plan.app_plan.id
  storage_account_name       = azurerm_storage_account.function_sa.name
  storage_account_access_key = azurerm_storage_account.function_sa.primary_access_key
  site_config {
    application_stack {
      python_version = "3.9"
    }
  }
  virtual_network_subnet_id     = azurerm_subnet.subnet_function.id
  https_only                    = true
  public_network_access_enabled = false
}

# Web App
resource "azurerm_linux_web_app" "web_app" {
  name                = "ms-04-2-web-app"
  resource_group_name = var.Resource_Grp_Name
  location            = var.Location
  service_plan_id     = azurerm_service_plan.app_plan.id

  site_config {
    application_stack {
      python_version = "3.9"
    }
    vnet_route_all_enabled = true
  }

  virtual_network_subnet_id = azurerm_subnet.subnet_webapp.id
}

# Adding  DNS Zone for Private Link

resource "azurerm_private_dns_zone" "webapp_dns" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = var.Resource_Grp_Name
}

# Linking the DNS Zone to  Virtual Network
resource "azurerm_private_dns_zone_virtual_network_link" "webapp_dns_link" {
  name                  = "webapp-dns-link"
  resource_group_name   = var.Resource_Grp_Name
  private_dns_zone_name = azurerm_private_dns_zone.webapp_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}



# Updated Private Endpoint using the new subnet
resource "azurerm_private_endpoint" "func_app_pvt_endpnt" {
  name                = "ms-04-2-funcapp-pvt-endpnt"
  location            = var.Location
  resource_group_name = var.Resource_Grp_Name
  subnet_id           = azurerm_subnet.subnet_for_pvt_endpnt.id

  private_service_connection {
    name                           = "ms-04-2-funcapp-psc"
    private_connection_resource_id = azurerm_linux_function_app.func_app.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = var.Private_DNS_Zone_Group_Name
    private_dns_zone_ids = [azurerm_private_dns_zone.webapp_dns.id]
  }
}



# # Automated Function Code in Zip format
# resource "azurerm_storage_blob" "func_blob" {
#   name                   = "ms-04-2-function.zip"
#   storage_account_name   = azurerm_storage_account.function_sa.name
#   storage_container_name = "ms-04-2-zips"
#   type                   = "Block"
#   source_content         = base64encode("""
# import logging
# import azure.functions as func

# def main(req: func.HttpRequest) -> func.HttpResponse:
#     return func.HttpResponse("Hello from private Function App")
# """)
# }

# resource "azurerm_storage_container" "zips" {
#   name                  = "ms-04-2-zips"
#   storage_account_name  = azurerm_storage_account.function_sa.name
#   container_access_type = "private"
# }

# # Output IPs 
# output "function_app_outbound_ip" {
#   value = azurerm_linux_function_app.func_app.outbound_ip_addresses
# }

# output "web_app_outbound_ip" {
#   value = azurerm_linux_web_app.web_app.outbound_ip_addresses
# }
