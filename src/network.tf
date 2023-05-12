locals {
  split_vnet_id       = split("/", var.azure_virtual_network.data.infrastructure.id)
  vnet_name           = element(local.split_vnet_id, length(local.split_vnet_id) - 1)
  vnet_resource_group = element(local.split_vnet_id, index(local.split_vnet_id, "resourceGroups") + 1)
  cidr                = var.network.auto ? utility_available_cidr.cidr.result : var.network.cidr
}

data "azurerm_virtual_network" "lookup" {
  name                = local.vnet_name
  resource_group_name = local.vnet_resource_group
}

data "azurerm_subnet" "lookup" {
  for_each             = toset(data.azurerm_virtual_network.lookup.subnets)
  name                 = each.key
  virtual_network_name = local.vnet_name
  resource_group_name  = local.vnet_resource_group
}

resource "utility_available_cidr" "cidr" {
  from_cidrs = data.azurerm_virtual_network.lookup.address_space
  used_cidrs = flatten([for subnet in data.azurerm_subnet.lookup : subnet.address_prefixes])
  mask       = 28
}

resource "azurerm_subnet" "main" {
  name                 = var.md_metadata.name_prefix
  resource_group_name  = local.vnet_resource_group
  virtual_network_name = local.vnet_name
  address_prefixes     = [local.cidr]
  service_endpoints = [
    "Microsoft.Sql",
    "Microsoft.Storage"
  ]
}

resource "azurerm_mssql_virtual_network_rule" "main" {
  name      = "${var.md_metadata.name_prefix}-vnet-rule"
  server_id = azurerm_mssql_server.main.id
  subnet_id = azurerm_subnet.main.id
}

resource "azurerm_mssql_firewall_rule" "main" {
  name             = "${var.md_metadata.name_prefix}-firewall-rule"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0" # allows access to azure services https://docs.microsoft.com/rest/api/sql/firewallrules/createorupdate
  end_ip_address   = "0.0.0.0"
}
