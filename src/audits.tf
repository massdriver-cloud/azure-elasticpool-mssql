module "azure_storage_account" {
  count               = true ? 1 : 0
  source              = "github.com/massdriver-cloud/terraform-modules//azure/storage-account?ref=87cc8c2"
  name                = var.md_metadata.name_prefix
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  kind                = "StorageV2"
  tier                = "Standard"
  replication_type    = "LRS"
  access_tier         = "Hot"
  tags                = var.md_metadata.default_tags
}

resource "azurerm_role_assignment" "main" {
  count                = true ? 1 : 0
  scope                = module.azure_storage_account.account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_mssql_server.main.identity[0].principal_id

  depends_on = [
    azurerm_mssql_server.main
  ]
}

resource "azurerm_mssql_server_extended_auditing_policy" "main" {
  count             = true ? 1 : 0
  server_id         = azurerm_mssql_server.main.id
  storage_endpoint  = module.azure_storage_account.primary_blob_endpoint
  retention_in_days = var.audit.data_protection
}
