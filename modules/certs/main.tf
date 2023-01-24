
resource "local_file" "ansible_hosts" {
    content  = "[controllers]\n${var.controller_0_ip} ansible_user=kuberoot ansible_ssh_common_args='-o StrictHostKeyChecking=no'\n${var.controller_1_ip} ansible_user=kuberoot ansible_ssh_common_args='-o StrictHostKeyChecking=no'\n${var.controller_2_ip} ansible_user=kuberoot ansible_ssh_common_args='-o StrictHostKeyChecking=no'\n\n[workers]\n${var.worker_0_ip} ansible_user=kuberoot ansible_ssh_common_args='-o StrictHostKeyChecking=no'\n${var.worker_1_ip} ansible_user=kuberoot ansible_ssh_common_args='-o StrictHostKeyChecking=no'\n\n[worker_0]\n${var.worker_0_ip} ansible_user=kuberoot ansible_ssh_common_args='-o StrictHostKeyChecking=no'\n\n[worker_1]\n${var.worker_1_ip} ansible_user=kuberoot ansible_ssh_common_args='-o StrictHostKeyChecking=no'"
    filename = "hosts"
}
resource "local_file" "controller_ips" {
    count = 3
    content  = var.controller_ips[count.index]
    filename = "/tmp/controller_${count.index}_ip"
}
resource "local_file" "worker_ips" {
    count = 2
    content  = var.worker_ips[count.index]
    filename = "/tmp/worker_${count.index}_ip"
}
resource "local_file" "lb_ip" {
    content  = var.lb_ip
    filename = "/tmp/lb_ip"
}
resource "null_resource" "installing_ansible_workers" {
    count = 2
    provisioner "remote-exec" {
        inline = [
        "sudo mkdir /home/${var.ssh_user}/ansible",
        "sudo apt-get update -y",
        "sudo apt-get install ansible -y"
        ]

        connection {
        type        = "ssh"
        user        = var.ssh_user
        private_key = file("${var.private_key_path}")
        host = var.worker_ips[count.index]
        }
    }
}

resource "null_resource" "installing_ansible_controllers" {
    count = 3
    provisioner "remote-exec" {
        inline = [
        "sudo mkdir /home/${var.ssh_user}/ansible",
        "sudo apt-get update -y",
        "sudo apt-get install ansible -y"
        ]

        connection {
        type        = "ssh"
        user        = var.ssh_user
        private_key = file("${var.private_key_path}")
        host = var.controller_ips[count.index]
        }
    }
}
