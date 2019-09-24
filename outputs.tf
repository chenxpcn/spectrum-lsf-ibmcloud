# Private IP address of VSI

output "master_public_ip_address" {
  value = "http://${ibm_compute_vm_instance.lsf-master.ipv4_address}"
}

output "master_private_ip_address" {
  value = "http://${ibm_compute_vm_instance.lsf-master.ipv4_address_private}"
}

output "slave_public_ip_address" {
  value = "http://${ibm_compute_vm_instance.lsf-slave.ipv4_address}"
}

output "slave_private_ip_address" {
  value = "http://${ibm_compute_vm_instance.lsf-slave.ipv4_address_private}"
}
