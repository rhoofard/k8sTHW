resource "azurerm_resource_group" "rg" {
  location = var.azure_region
  name     = "test-ryanh-k8thw-rg"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "kubernetes-vnet"
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.240.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "kubernetes-subnet"
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.240.0.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "kubernetes-nsg"
  location            = azurerm_virtual_network.vnet.location
  resource_group_name = azurerm_virtual_network.vnet.resource_group_name

  security_rule {
    name                       = "kubernetes-allow-ssh"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "kubernetes-allow-api-server"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_public_ip" "lb_public_ip" {
  name                = "kubernetes-lb-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "lb" {
  name                = "kubernetes-lb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "kubernetes-lb-public-ip"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "kubernetes-lb-pool"
}

resource "azurerm_availability_set" "controller_availability_set" {
  name                = "controller-as"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
//controller nodes
resource "azurerm_public_ip" "controller_public_ip" {
  count = 3
  name                = "controller-${count.index}-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}
resource "azurerm_network_interface" "controller_nic" {
  count = 3
  name                = "controller-${count.index}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    public_ip_address_id = azurerm_public_ip.controller_public_ip[count.index].id
    private_ip_address = "10.240.0.1${count.index}"
    //gateway_load_balancer_frontend_ip_configuration_id = azurerm_lb.lb.frontend_ip_configuration[0].id
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "controller_pool_association" {
  count = 3
  network_interface_id    = azurerm_network_interface.controller_nic[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_pool.id
}

resource "azurerm_virtual_machine" "controllers" {
  count = 3
  name                  = "controller-${count.index}"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.controller_nic[count.index].id]
  vm_size               = "Standard_DS1_v2"
  availability_set_id = azurerm_availability_set.controller_availability_set.id
  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "controller-${count.index}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name = "controller-${count.index}"
    admin_username = "kuberoot"
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = file("~/.ssh/id_rsa.pub")
      path = "/home/kuberoot/.ssh/authorized_keys"
    }
  }
}
//workers
resource "azurerm_availability_set" "worker_availability_set" {
  name                = "worker-as"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_public_ip" "worker_public_ip" {
  count = 2
  name                = "worker-${count.index}-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}
resource "azurerm_network_interface" "worker_nic" {
  count = 2
  name                = "worker-${count.index}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    public_ip_address_id = azurerm_public_ip.worker_public_ip[count.index].id
    private_ip_address = "10.240.0.2${count.index}"
    //gateway_load_balancer_frontend_ip_configuration_id = azurerm_lb.lb.frontend_ip_configuration[0].id
  }
}

resource "azurerm_virtual_machine" "workers" {
  count = 2
  name                  = "worker-${count.index}"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.worker_nic[count.index].id]
  vm_size               = "Standard_DS1_v2"
  availability_set_id = azurerm_availability_set.worker_availability_set.id
  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "worker-${count.index}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name = "worker-${count.index}"
    admin_username = "kuberoot"
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = file("~/.ssh/id_rsa.pub")
      path = "/home/kuberoot/.ssh/authorized_keys"
    }
  }
  tags = {
    pod-cidr = "10.200.${count.index}.0/24"
  }
}