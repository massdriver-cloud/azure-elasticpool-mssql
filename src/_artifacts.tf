resource "massdriver_artifact" "mssql_authentication" {
  field    = "mssql_authentication"
  name     = "Azure SQL Server ${var.md_metadata.name_prefix} (${azurerm_mssql_server.main.id})"
  artifact = jsonencode(
    {
      data = {
        infrastructure = {
          ari = azurerm_mssql_server.main.id
        }
        authentication = {
          username = azurerm_mssql_server.main.administrator_login
          password = azurerm_mssql_server.main.administrator_login_password
          hostname = azurerm_mssql_server.main.fully_qualified_domain_name
          port     = 1433
        }
        security = {}
      }
      specs = {
        rdbms = {
          engine  = "Microsoft SQL Server"
          version = azurerm_mssql_server.main.version
        }
      }
    }
  )
}
