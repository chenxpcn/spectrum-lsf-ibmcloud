# Private IP address of VSI

output "private_ip_address" {
  value = "http://${ibm_compute_vm_instance.vm-master.ipv4_address_private}"
}
