variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "webapp-rg"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "vnet_address_space" {
  description = "Address space for Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "web_subnet_prefix" {
  description = "Address prefix for web subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "db_subnet_prefix" {
  description = "Address prefix for database subnet"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "vm_admin_username" {
  description = "Admin username for VMs"
  type        = string
  default     = "adminuser"
}

variable "sql_connection_policy" {
  description = "The connection policy the server will use"
  default     = "Default"
  type        = string
}

# variable "sql_admin_login" {
#   description = "Admin login for SQL Server"
#   type        = string
#   default     = "sqladmin"
# }

# variable "sql_admin_password" {
#   description = "Admin password for SQL Server"
#   type        = string
#   sensitive   = true
# }

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "client_id" {
  description = "Azure Service Principal Client ID"
  type        = string
}

variable "client_secret" {
  description = "Azure Service Principal Client Secret"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}