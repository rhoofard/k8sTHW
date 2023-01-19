variable "vnet_name" {}
variable "subnet_name" {}
variable "lb_name" {}
variable "lb_ip" {}
variable "nsg_name" {}
variable "controller_0_ip" {}
variable "controller_1_ip" {}
variable "controller_2_ip" {}
variable "worker_0_ip" {}
variable "worker_1_ip" {}
variable "controller_ips" {
    type = list
    default = []
}
variable "worker_ips" {
    type = list
    default = []
}
variable "ssh_user" {
  default = "kuberoot"
}
variable "private_key_path" {
  default = "~/.ssh/id_rsa"
}