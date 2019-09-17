resource "ibm_compute_vm_instance" "vm-master" {
  hostname             = "vm-master"
  domain               = "demo.cloud"
  os_reference_code    = "REDHAT_7_64"
#  image_id             = 2459122
  datacenter           = "dal13"
  network_speed        = 100
  hourly_billing       = true
  private_network_only = false
  cores                = 2
  memory               = 4096
  disks                = [25]
  local_disk           = false
  public_vlan_id       = 2317207
  private_vlan_id      = 2317209
}
