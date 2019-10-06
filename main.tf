locals {
  master_ssh_key_file_name = "lsf-master-ssh-key"
  slave_ssh_key_file_name = "lsf-slave-ssh-key"
}

resource "ibm_compute_ssh_key" "local_ssh_key" {
  label      = "local_ssh_key"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "null_resource" "create_master_ssh_key" {
  provisioner "local-exec" {
    command = "if [ ! -f '${local.master_ssh_key_file_name}' ]; then ssh-keygen  -f ${local.master_ssh_key_file_name} -N ''; fi"
  }
}

resource "null_resource" "create_slave_ssh_key" {
  provisioner "local-exec" {
    command = "if [ ! -f '${local.slave_ssh_key_file_name}' ]; then ssh-keygen  -f ${local.slave_ssh_key_file_name} -N ''; fi"
  }
}

resource "null_resource" "copy_master_private_key" {
  connection {
    type        = "ssh"
    user        = "root"
    host        = "${ibm_compute_vm_instance.lsf-master.ipv4_address}"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "file" {
    source      = "${local.master_ssh_key_file_name}"
    destination = "/root/.ssh/id_rsa"
  }

  provisioner "file" {
    source      = "${local.master_ssh_key_file_name}.pub"
    destination = "/root/.ssh/id_rsa.pub"
  }

  provisioner "file" {
    source      = "${local.slave_ssh_key_file_name}.pub"
    destination = "/root/.ssh/slave.pub"
  }

  provisioner "remote-exec" {
    inline   = [
      "chmod 600 /root/.ssh/id_rsa",
      "chmod 644 /root/.ssh/id_rsa.pub",
      "cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys",
      "cat /root/.ssh/slave.pub >> /root/.ssh/authorized_keys",
      "echo ${var.remote_console_public_ssh_key} >> /root/.ssh/authorized_keys"
    ]
  }

  depends_on = ["ibm_compute_vm_instance.lsf-master", "null_resource.create_master_ssh_key", "null_resource.create_slave_ssh_key"]
}

resource "null_resource" "copy_slave_private_key" {
  connection {
    type        = "ssh"
    user        = "root"
    host        = "${ibm_compute_vm_instance.lsf-slave.ipv4_address}"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "file" {
    source      = "${local.slave_ssh_key_file_name}"
    destination = "/root/.ssh/id_rsa"
  }

  provisioner "file" {
    source      = "${local.slave_ssh_key_file_name}.pub"
    destination = "/root/.ssh/id_rsa.pub"
  }

  provisioner "file" {
    source      = "${local.master_ssh_key_file_name}.pub"
    destination = "/root/.ssh/master.pub"
  }

  provisioner "remote-exec" {
    inline  = [
      "chmod 600 /root/.ssh/id_rsa",
      "chmod 644 /root/.ssh/id_rsa.pub",
      "cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys",
      "cat /root/.ssh/master.pub >> /root/.ssh/authorized_keys",
    ]
  }

  depends_on = ["ibm_compute_vm_instance.lsf-slave", "null_resource.create_master_ssh_key", "null_resource.create_slave_ssh_key"]
}

resource "ibm_compute_vm_instance" "lsf-master" {
  hostname             = "lsf-master"
  domain               = "${var.domain_name}"
  os_reference_code    = "REDHAT_7_64"
#  image_id             = 2459122
  datacenter           = "${var.data_center}"
  network_speed        = "${var.master_network_speed}"
  hourly_billing       = true
  private_network_only = false
  cores                = "${var.master_cores}"
  memory               = "${var.master_memory}"
  disks                = ["${var.master_disk}"]
  local_disk           = false
  public_vlan_id       = "${var.public_vlan_id}"
  private_vlan_id      = "${var.private_vlan_id}"
  ssh_key_ids          = ["${ibm_compute_ssh_key.local_ssh_key.id}"]
  post_install_script_uri = "${var.scripts_path_uri}/post-install-master.sh"
  user_metadata        = "#!/bin/bash\nexport installer_uri=${var.installer_uri}\nexport slave_ip=${ibm_compute_vm_instance.lsf-slave.ipv4_address_private}\nexport domain_name=${var.domain_name}\n"
}

resource "ibm_compute_vm_instance" "lsf-slave" {
  hostname             = "lsf-slave"
  domain               = "${var.domain_name}"
  os_reference_code    = "REDHAT_7_64"
#  image_id             = 2459122
  datacenter           = "${var.data_center}"
  network_speed        = "${var.slave_network_speed}"
  hourly_billing       = true
  private_network_only = false
  cores                = "${var.slave_cores}"
  memory               = "${var.slave_memory}"
  disks                = ["${var.slave_disk}"]
  local_disk           = false
  public_vlan_id       = "${var.public_vlan_id}"
  private_vlan_id      = "${var.private_vlan_id}"
  ssh_key_ids          = ["${ibm_compute_ssh_key.local_ssh_key.id}"]
#  post_install_script_uri = "${var.scripts_path_uri}/post-install-slave.sh"
}

resource "null_resource" "set_slave_hosts_file" {
  connection {
    type        = "ssh"
    user        = "root"
    host        = "${ibm_compute_vm_instance.lsf-slave.ipv4_address}"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "remote-exec" {
    inline  = [
      "echo \"${ibm_compute_vm_instance.lsf-master.ipv4_address_private} lsf-master.${var.domain_name} lsf-master\" >> /etc/hosts"
    ]
  }

  depends_on = ["ibm_compute_vm_instance.lsf-master", "ibm_compute_vm_instance.lsf-slave"]
}

resource "null_resource" "install_lsf" {
  connection {
    type        = "ssh"
    user        = "root"
    host        = "${ibm_compute_vm_instance.lsf-master.ipv4_address}"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "remote-exec" {
    inline  = [
      "mkdir -p /root/installer",
      "mkdir -p /var/www/html",
      "wget -nv -nH -c --no-check-certificate -O /root/installer/deploy-lsf.sh ${var.scripts_path_uri}/deploy-lsf.sh",
      "wget -nv -nH -c --no-check-certificate -O /var/www/html/provisioning.sh ${var.scripts_path_uri}/provisioning.sh",
      "wget -nv -nH -c --no-check-certificate -O /root/installer/config-lsf-master.sh ${var.scripts_path_uri}/config-lsf-master.sh",
      "wget -nv -nH -c --no-check-certificate -O /root/installer/capture-image.sh ${var.scripts_path_uri}/capture-image.sh",
      "wget -nv -nH -c --no-check-certificate -O /root/installer/capture-image.py ${var.scripts_path_uri}/capture-image.py",
      ". /root/installer/deploy-lsf.sh ${var.installer_uri} ${var.cluster_name} ${var.lsfadmin_password}"
    ]
  }

  depends_on = ["null_resource.set_slave_hosts_file", "null_resource.copy_slave_private_key", "null_resource.copy_master_private_key"]
}

resource "null_resource" "config_slave" {
  connection {
    type        = "ssh"
    user        = "root"
    host        = "${ibm_compute_vm_instance.lsf-slave.ipv4_address}"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "remote-exec" {
    inline  = [
      "mkdir -p /root/installer",
      "wget -nv -nH -c --no-check-certificate -O /root/installer/config-lsf-slave.sh ${var.scripts_path_uri}/config-lsf-slave.sh",
      ". /root/installer/config-lsf-slave.sh ${var.cluster_name}"
    ]
  }

  depends_on = ["null_resource.install_lsf"]
}

resource "null_resource" "config_master" {
  connection {
    type        = "ssh"
    user        = "root"
    host        = "${ibm_compute_vm_instance.lsf-master.ipv4_address}"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "remote-exec" {
    inline  = [
      ". /root/installer/config-lsf-master.sh ${var.cluster_name} ${var.iaas_username} ${var.ibmcloud_iaas_api_key} ${var.scripts_path_uri} ${ibm_compute_vm_instance.lsf-master.ipv4_address_private} ${var.slave_cores} ${var.slave_memory} ${var.image_name} ${var.data_center} ${var.private_vlan_number}",
      ". /root/installer/capture-image.sh ${var.iaas_username} ${var.ibmcloud_iaas_api_key} ${ibm_compute_vm_instance.lsf-slave.id} ${var.image_name} ${ibm_compute_vm_instance.lsf-slave.ipv4_address_private}"
    ]
  }

  depends_on = ["null_resource.install_lsf", "null_resource.config_slave"]
}

