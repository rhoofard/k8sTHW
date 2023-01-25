resource "null_resource" "certs" {
    provisioner "local-exec" {
        command = "ansible-playbook /Users/rhoofard/bootcamp/chapter7/k8sTHW/playbooks/1_certs.yaml -i /Users/rhoofard/bootcamp/chapter7/k8sTHW/hosts.ini"
    }
}

resource "null_resource" "kubeconfig" {
    provisioner "local-exec" {
        command = "ansible-playbook /Users/rhoofard/bootcamp/chapter7/k8sTHW/playbooks/2_kubeconfigs.yaml -i /Users/rhoofard/bootcamp/chapter7/k8sTHW/hosts.ini"
    }
    depends_on = [
      null_resource.certs
    ]
}

resource "null_resource" "encryption" {
    provisioner "local-exec" {
        command = "ansible-playbook /Users/rhoofard/bootcamp/chapter7/k8sTHW/playbooks/3_encryption.yaml -i /Users/rhoofard/bootcamp/chapter7/k8sTHW/hosts.ini"
    }
    depends_on = [
      null_resource.kubeconfig
    ]
}

resource "null_resource" "etcd" {
    provisioner "local-exec" {
        command = "ansible-playbook /Users/rhoofard/bootcamp/chapter7/k8sTHW/playbooks/4_etcd.yaml -i /Users/rhoofard/bootcamp/chapter7/k8sTHW/hosts.ini"
    }
    depends_on = [
      null_resource.encryption
    ]
}

resource "null_resource" "controller_services" {
    provisioner "local-exec" {
        command = "ansible-playbook /Users/rhoofard/bootcamp/chapter7/k8sTHW/playbooks/5_controller_services.yaml -i /Users/rhoofard/bootcamp/chapter7/k8sTHW/hosts.ini"
    }
    depends_on = [
      null_resource.etcd
    ]
}

resource "null_resource" "rbac" {
    provisioner "local-exec" {
        command = "ansible-playbook /Users/rhoofard/bootcamp/chapter7/k8sTHW/playbooks/6_rbac.yaml -i /Users/rhoofard/bootcamp/chapter7/k8sTHW/hosts.ini"
    }
    depends_on = [
      null_resource.controller_services
    ]
}

resource "null_resource" "worker_binaries" {
    provisioner "local-exec" {
        command = "ansible-playbook /Users/rhoofard/bootcamp/chapter7/k8sTHW/playbooks/7_worker_binaries.yaml -i /Users/rhoofard/bootcamp/chapter7/k8sTHW/hosts.ini"
    }
    depends_on = [
      null_resource.rbac
    ]
}

resource "null_resource" "worker_cni" {
    provisioner "local-exec" {
        command = "ansible-playbook /Users/rhoofard/bootcamp/chapter7/k8sTHW/playbooks/8_worker_cni.yaml -i /Users/rhoofard/bootcamp/chapter7/k8sTHW/hosts.ini"
    }
    depends_on = [
      null_resource.worker_binaries
    ]
}

resource "null_resource" "worker_keys" {
    provisioner "local-exec" {
        command = "ansible-playbook /Users/rhoofard/bootcamp/chapter7/k8sTHW/playbooks/9_worker_keys.yaml -i /Users/rhoofard/bootcamp/chapter7/k8sTHW/hosts.ini"
    }
    depends_on = [
      null_resource.worker_cni
    ]
}

resource "null_resource" "worker_services" {
    provisioner "local-exec" {
        command = "ansible-playbook /Users/rhoofard/bootcamp/chapter7/k8sTHW/playbooks/10_worker_services.yaml -i /Users/rhoofard/bootcamp/chapter7/k8sTHW/hosts.ini"
    }
    depends_on = [
      null_resource.worker_keys
    ]
}



