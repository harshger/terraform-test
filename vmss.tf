resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine_scale_set" "web_vmss" {
  name                = "web-vmss"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                = "Standard_B2s"
  instances          = 2
  admin_username     = azurerm_key_vault_secret.vm_admin_username.value
  upgrade_mode = "Automatic"

  admin_ssh_key {
    username   = azurerm_key_vault_secret.vm_admin_username.value
    public_key = tls_private_key.ssh_key.public_key_openssh
  }

  rolling_upgrade_policy {
    max_batch_instance_percent              = 20
    max_unhealthy_instance_percent          = 20
    max_unhealthy_upgraded_instance_percent = 5
    pause_time_between_batches              = "PT0S"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "web-vmss-nic"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                               = true
      subnet_id                             = azurerm_subnet.web_subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.web_backend_pool.id]
    }
  }
}

