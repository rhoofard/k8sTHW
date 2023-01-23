resource "azurerm_lb_probe" "lb_probe" {
    resource_group_name = var.resource_group_name
    loadbalancer_id = var.lb_id
    name            = "kubernetes-apiserver-probe"
    port            = 6443
    protocol        = "Tcp"
}

resource "azurerm_lb_rule" "lb_rule" {
  resource_group_name = var.resource_group_name
  loadbalancer_id                = var.lb_id
  name                           = "kubernetes-apiserver-rule"
  protocol                       = "Tcp"
  frontend_port                  = 6443
  backend_port                   = 6443
  frontend_ip_configuration_name = "kubernetes-lb-public-ip"
  backend_address_pool_ids = [var.backend_pool_id]
  probe_id = azurerm_lb_probe.lb_probe.id
}