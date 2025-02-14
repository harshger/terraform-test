output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "key_vault_name" {
  value = azurerm_key_vault.vault.name
}

output "key_vault_uri" {
  value = azurerm_key_vault.vault.vault_uri
}

output "sql_server_private_endpoint_ip" {
  value = azurerm_private_endpoint.sqldb.private_service_connection[0].private_ip_address
  description = "The private IP address of the SQL Server private endpoint"
}

output "public_ip_address_to_access" {
  value = azurerm_public_ip.lb_pip.ip_address
}
