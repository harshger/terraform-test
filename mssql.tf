resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_private_dns_zone" "sqldb" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "sqldb" {
  name                  = "sqldb-zone-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.sqldb.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}

resource "azurerm_mssql_server" "sql_server" {
  name                         = "webapp-sql-server-${random_string.suffix.result}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = azurerm_key_vault_secret.sql_admin_username.value
  administrator_login_password = azurerm_key_vault_secret.sql_admin_password.value

  public_network_access_enabled = false

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_private_endpoint" "sqldb" {
  name                = "sqldb-endpoint"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.db_subnet.id

  private_service_connection {
    name                           = "sqldb-private-connection"
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    is_manual_connection          = false
    subresource_names            = ["sqlServer"]
  }

  private_dns_zone_group {
    name                 = "sqldb-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.sqldb.id]
  }
}

resource "azurerm_mssql_database" "sql_db" {
  name           = "webapp-db"
  server_id      = azurerm_mssql_server.sql_server.id
  sku_name       = "S0"
  zone_redundant = false
}

# resource "azurerm_mssql_virtual_network_rule" "sql_vnet_rule" {
#   name      = "sql-vnet-rule"
#   server_id = azurerm_mssql_server.sql_server.id
#   subnet_id = azurerm_subnet.db_subnet.id
# }
