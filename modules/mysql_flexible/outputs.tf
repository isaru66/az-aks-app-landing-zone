output "server_id" {
  description = "The ID of the MySQL Flexible Server"
  value       = azurerm_mysql_flexible_server.mysql.id
}

output "server_name" {
  description = "The name of the MySQL Flexible Server"
  value       = azurerm_mysql_flexible_server.mysql.name
}

output "server_fqdn" {
  description = "The FQDN of the MySQL Flexible Server"
  value       = azurerm_mysql_flexible_server.mysql.fqdn
}

output "identity" {
  description = "The identity block of the MySQL Flexible Server"
  value       = azurerm_mysql_flexible_server.mysql.identity
}