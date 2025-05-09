output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "subnet_function_name" {
  value = azurerm_subnet.subnet_function.name
}

output "subnet_webapp_name" {
  value = azurerm_subnet.subnet_webapp.name
}

output "subnet_for_pvt_endpnt_name" {
  value = azurerm_subnet.subnet_for_pvt_endpnt.name
}

output "function_app_name" {
  value = azurerm_linux_function_app.func_app.name
}

output "web_app_name" {
  value = azurerm_linux_web_app.web_app.name
}

output "function_app_private_endpoint_ip" {
  description = "Private IP address assigned to the Function App's Private Endpoint"
  value       = azurerm_private_endpoint.func_app_pvt_endpnt.private_service_connection[0].private_ip_address
}
