module "azure-networking" {
  source = "./modules/azure-networking"
  azure_region = var.azure_region
}
module "certs" {
  source = "./modules/certs"
  vnet_name = module.azure-networking.vnet_name
  subnet_name = module.azure-networking.subnet_name
  nsg_name = module.azure-networking.nsg_name
  lb_name = module.azure-networking.lb_name
  lb_ip = module.azure-networking.lb_ip
  controller_0_ip = module.azure-networking.controller_0_ip
  controller_1_ip = module.azure-networking.controller_1_ip
  controller_2_ip = module.azure-networking.controller_2_ip
  worker_0_ip = module.azure-networking.worker_0_ip
  worker_1_ip = module.azure-networking.worker_1_ip
  controller_ips = [module.azure-networking.controller_0_ip,
                    module.azure-networking.controller_1_ip,
                    module.azure-networking.controller_2_ip]
  worker_ips = [module.azure-networking.worker_0_ip,
                module.azure-networking.worker_1_ip]
}