# VNet for Function App
resource "azurerm_virtual_network" "vnet" {
  name                = var.Virtual_Network_Name
  address_space       = var.Vnet_Adrress_Space
  location            = var.Location
  resource_group_name = var.Resource_Grp_Name
}


# Subnet for Function App
resource "azurerm_subnet" "subnet_function" {
  name                 = var.Subnet_Function_Name
  resource_group_name  = var.Resource_Grp_Name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.Subnet_Function_Address_Prefixes
  service_endpoints    = ["Microsoft.Web"]
  delegation {
    name = var.Subnet_Function_Delegation_Name
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# Subnet for Web App
resource "azurerm_subnet" "subnet_webapp" {
  name                 = var.Subnet_Webapp_Name
  resource_group_name  = var.Resource_Grp_Name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.Subnet_Webapp_Address_Prefixes
  #service_endpoints    = ["Microsoft.Web"]
  delegation {
    name = var.Subnet_Webapp_Delegation_Name
    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# Subnet for for adding  Private Endpoint 
resource "azurerm_subnet" "subnet_for_pvt_endpnt" {
  name                 = var.Subnet_for_Pvt_Endpnt_Name
  resource_group_name  = var.Resource_Grp_Name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.Subnet_for_Pvt_Endpnt_Adss_Pfx
}