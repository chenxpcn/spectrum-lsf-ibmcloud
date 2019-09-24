resource "ibm_compute_ssh_key" "local_ssh_key" {
  label      = "local_ssh_key"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "ibm_compute_ssh_key" "remote_ssh_key" {
  label      = "remote_ssh_key"
  public_key = "${var.remote_console_public_ssh_key}"
}

resource "null_resource" "create_master_ssh_key" {
  provisioner "local-exec" {
    command = "if [ ! -f '${var.master_ssh_key_file}' ]; then ssh-keygen  -f ${var.master_ssh_key_file} -N ''; fi"
  }
}

resource "null_resource" "create_slave_ssh_key" {
  provisioner "local-exec" {
    command = "if [ ! -f '${var.slave_ssh_key_file}' ]; then ssh-keygen  -f ${var.slave_ssh_key_file} -N ''; fi"
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
    source      = "${var.master_ssh_key_file}"
    destination = "/root/.ssh/id_rsa"
  }

  provisioner "file" {
    source      = "${var.master_ssh_key_file}.pub"
    destination = "/root/.ssh/id_rsa.pub"
  }

  provisioner "file" {
    source      = "${var.slave_ssh_key_file}.pub"
    destination = "/root/.ssh/slave.pub"
  }

  provisioner "remote-exec" {
    inline   = [
      "chmod 600 /root/.ssh/id_rsa",
      "chmod 644 /root/.ssh/id_rsa.pub",
      "cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys",
      "cat /root/.ssh/slave.pub >> /root/.ssh/authorized_keys",
    ]
  }

  depends_on = ["null_resource.create_master_ssh_key", "null_resource.create_slave_ssh_key"]
}

resource "null_resource" "copy_slave_private_key" {
  connection {
    type        = "ssh"
    user        = "root"
    host        = "${ibm_compute_vm_instance.lsf-slave.ipv4_address}"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "file" {
    source      = "${var.slave_ssh_key_file}"
    destination = "/root/.ssh/id_rsa"
  }

  provisioner "file" {
    source      = "${var.slave_ssh_key_file}.pub"
    destination = "/root/.ssh/id_rsa.pub"
  }

  provisioner "file" {
    source      = "${var.master_ssh_key_file}.pub"
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

  depends_on = ["null_resource.create_master_ssh_key", "null_resource.create_slave_ssh_key"]
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
  ssh_key_ids          = ["${ibm_compute_ssh_key.local_ssh_key.id}", "${ibm_compute_ssh_key.remote_ssh_key.id}"]
  post_install_script_uri = "${var.post_install_script_uri_master}"
  user_metadata        = "#!/bin/bash\nexport installer_uri=${var.installer_uri}\nexport installer_name=${var.installer_name}\nexport slave_ip=${ibm_compute_vm_instance.lsf-slave.ipv4_address_private}\nexport domain_name=${var.domain_name}\n"
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
  post_install_script_uri = "${var.post_install_script_uri_slave}"
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