locals {
  # Maps the sku tier to the sku name
  dtu_map = {
    "Basic"    = "BasicPool"
    "Standard" = "StandardPool"
    "Premium"  = "PremiumPool"
  }
  # Maps the sku tier to the sku name
  vcore_map = {
    "GP_Gen5" = "GeneralPurpose"
    "GP_Fsv2" = "GeneralPurpose"
    "GP_DC"   = "GeneralPurpose"
    "BC_Gen5" = "BusinessCritical"
    "BC_DC"   = "BusinessCritical"
  }
  # Maps the sku tier to the sku family (family only needed for vCore)
  family_map = {
    "GP_Gen5" = "Gen5"
    "GP_Fsv2" = "Fsv2"
    "GP_DC"   = "DC"
    "BC_Gen5" = "Gen5"
    "BC_DC"   = "DC"
  }
  # Maps the DTU count in basic tier to static storage volume
  basic_dtu_map = {
    "50"   = "4.8828125"
    "100"  = "9.765625"
    "200"  = "19.5312500"
    "300"  = "29.296875"
    "400"  = "39.0625"
    "800"  = "78.125"
    "1200" = "117.1875"
    "1600" = "156.25"
  }
}

resource "azurerm_resource_group" "main" {
  name     = var.md_metadata.name_prefix
  location = var.azure_virtual_network.specs.azure.region
  tags     = var.md_metadata.default_tags
}

resource "random_password" "master_password" {
  length  = 16
  special = true
}

resource "azurerm_mssql_server" "main" {
  name                         = var.md_metadata.name_prefix
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = var.server.version
  administrator_login          = var.server.admin_login
  administrator_login_password = random_password.master_password.result
  minimum_tls_version          = "1.2"
  tags                         = var.md_metadata.default_tags

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_mssql_elasticpool" "main" {
  name                = var.md_metadata.name_prefix
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  server_name         = azurerm_mssql_server.main.name
  max_size_gb         = var.elasticpool.tier == "Basic" ? local.basic_dtu_map[var.elasticpool.capacity] : var.elasticpool.max_size
  zone_redundant      = var.elasticpool.tier == "Premium" || var.elasticpool.tier == "BusinessCritical" ? var.elasticpool.zone_redundant : false
  tags                = var.md_metadata.default_tags

  sku {
    name     = var.elasticpool.model == "DTU" ? local.dtu_map[var.elasticpool.tier] : var.elasticpool.tier
    tier     = var.elasticpool.model == "vCore" ? local.vcore_map[var.elasticpool.tier] : var.elasticpool.tier
    family   = var.elasticpool.model == "vCore" ? local.family_map[var.elasticpool.tier] : null
    capacity = var.elasticpool.capacity
  }

  per_database_settings {
    min_capacity = var.database.min_capacity
    max_capacity = var.database.max_capacity
  }

  depends_on = [module.azure_storage_account]
}
