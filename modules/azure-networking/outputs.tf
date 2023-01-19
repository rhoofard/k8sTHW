output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "subnet_name" {
  value = azurerm_subnet.subnet.name
}

output "nsg_name" {
  value = azurerm_network_security_group.nsg.name
}

output "lb_name" {
  value = azurerm_lb.lb.name
}

output "lb_ip" {
  value = azurerm_public_ip.lb_public_ip.ip_address
}

output "controller_0_ip" {
  value = azurerm_public_ip.controller_public_ip[0].ip_address
}
output "controller_1_ip" {
  value = azurerm_public_ip.controller_public_ip[1].ip_address
}
output "controller_2_ip" {
  value = azurerm_public_ip.controller_public_ip[2].ip_address
}
output "worker_0_ip" {
  value = azurerm_public_ip.worker_public_ip[0].ip_address
}
output "worker_1_ip" {
  value = azurerm_public_ip.worker_public_ip[1].ip_address
}