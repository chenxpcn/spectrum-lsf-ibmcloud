resource "ibm_compute_vm_instance" "vm1" {
  hostname             = "vm1"
  domain               = "example.com"
#  os_reference_code    = "CENTOS_7_64"
  image_id             = 2459122
  datacenter           = "dal13"
  network_speed        = 100
  hourly_billing       = true
  private_network_only = no
  cores                = 2
  memory               = 4096
  disks                = [25]
  local_disk           = false
  public_vlan_id       = 2317207
  private_vlan_id      = 2317209
}
