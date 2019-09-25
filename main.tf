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
  network_speed        = 100
  hourly_billing       = true
  private_network_only = false
  cores                = 4
  memory               = 32768
  disks                = [100]
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
  network_speed        = 100
  hourly_billing       = true
  private_network_only = false
  cores                = 2
  memory               = 4096
  disks                = [25]
  local_disk           = false
  public_vlan_id       = "${var.public_vlan_id}"
  private_vlan_id      = "${var.private_vlan_id}"
  ssh_key_ids          = ["${ibm_compute_ssh_key.local_ssh_key.id}"]
  post_install_script_uri = "${var.scripts_path_uri}/post-install-slave.sh"
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

resource "null_resource" "set_deployer" {
  connection {
    type        = "ssh"
    user        = "root"
    host        = "${ibm_compute_vm_instance.lsf-master.ipv4_address}"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "remote-exec" {
    inline  = [
      "mkdir -p /root/installer",
      "wget -nv -nH -c --no-check-certificate -O /root/installer/deploy-lsf.sh ${var.scripts_path_uri}/deploy-lsf.sh",
      ". /root/installer/deploy-lsf.sh ${var.installer_uri} ${var.cluster_name}"
    ]
  }

  depends_on = ["null_resource.set_slave_hosts_file"]
}
