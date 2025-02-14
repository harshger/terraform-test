
### Test to check the connectivity.
### Upload test script in Blob storage container

# Create storage account
resource "azurerm_storage_account" "scripts" {
  name                     = "webapp${random_string.suffix.result}scripts"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create storage account container
resource "azurerm_storage_container" "scripts" {
  name                  = "scripts"
  storage_account_name  = azurerm_storage_account.scripts.name
  container_access_type = "blob"
}

# Upload setup script to blob storage
resource "azurerm_storage_blob" "setup_script" {
  name                   = "setup.sh"
  storage_account_name   = azurerm_storage_account.scripts.name
  storage_container_name = azurerm_storage_container.scripts.name
  type                   = "Block"
  source_content        = templatefile("${path.module}/script/setup.sh", {
    db_user     = azurerm_key_vault_secret.sql_admin_username.value
    db_password = azurerm_key_vault_secret.sql_admin_password.value
    db_server   = azurerm_mssql_server.sql_server.fully_qualified_domain_name
    db_name     = azurerm_mssql_database.sql_db.name
    port        = "80"
  })
}

# Run custom script VMSS extention
resource "azurerm_virtual_machine_scale_set_extension" "custom_script" {
  name                         = "webapp-extension"
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.web_vmss.id
  publisher                    = "Microsoft.Azure.Extensions"
  type                         = "CustomScript"
  type_handler_version        = "2.1"

  settings = jsonencode({
    "fileUris": ["${azurerm_storage_blob.setup_script.url}"]
    "commandToExecute": "bash setup.sh"
  })

  protected_settings = jsonencode({
    "storageAccountName": azurerm_storage_account.scripts.name
    "storageAccountKey": azurerm_storage_account.scripts.primary_access_key
  })

}