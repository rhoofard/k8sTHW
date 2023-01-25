resource "azurerm_route_table" "kubernetes_routes" {
  resource_group_name = var.resource_group_name
  location = var.azure_region
  name = "kubernetes-routes"
}

resource "azurerm_subnet_route_table_association" "subnet_route_table" {
  subnet_id      = var.subnet_id
  route_table_id = azurerm_route_table.kubernetes_routes.id
}

resource "azurerm_route" "routes" {
  count = 2
  resource_group_name = var.resource_group_name
  name = "kubernetes-route-10-200-${count.index}-0-24"
  route_table_name = azurerm_route_table.kubernetes_routes.name
  address_prefix = "10.200.${count.index}.0/24"
  next_hop_in_ip_address = "10.240.0.2${count.index}"
  next_hop_type = "VirtualAppliance"
}

resource "null_resource" "dns-cluster-addon" {
    provisioner "local-exec" {
        command = "kubectl apply -f https://raw.githubusercontent.com/ivanfioravanti/kubernetes-the-hard-way-on-azure/master/deployments/coredns.yaml"
    }
}