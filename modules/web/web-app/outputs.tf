output "id" {
  value       = azurerm_linux_web_app.this.id
  description = "ID of the web app."
}

output "default_hostname" {
  value       = azurerm_linux_web_app.this.default_hostname
  description = "Default hostname of the web app."
}
