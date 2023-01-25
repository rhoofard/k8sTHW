resource "null_resource" "set-cluster" {
    provisioner "local-exec" {
        command = "kubectl config set-cluster kubernetes-the-hard-way --certificate-authority=/Users/rhoofard/bootcamp/chapter7/k8sTHW/playbooks/ca.pem --embed-certs=true --server=https://${var.lb_ip}:6443"
    }
}

resource "null_resource" "set-credentials" {
    provisioner "local-exec" {
        command = "kubectl config set-credentials admin --client-certificate=/Users/rhoofard/bootcamp/chapter7/k8sTHW/playbooks/admin.pem --client-key=/Users/rhoofard/bootcamp/chapter7/k8sTHW/playbooks/admin-key.pem"
    }
    depends_on = [
      null_resource.set-cluster
    ]
}

resource "null_resource" "set-context" {
    provisioner "local-exec" {
        command = "kubectl config set-context kubernetes-the-hard-way --cluster=kubernetes-the-hard-way --user=admin "
    }
    depends_on = [
      null_resource.set-credentials
    ]
}

resource "null_resource" "use-context" {
    provisioner "local-exec" {
        command = "kubectl config use-context kubernetes-the-hard-way"
    }
    depends_on = [
      null_resource.set-context
    ]
}