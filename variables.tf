# variables supplied from terraform.tfvars

############################################################
# for provider.tf
variable "iaas_username" {
  type = "string"
  description = "softlayer user name"
}

variable "ibmcloud_iaas_api_key" {
  type = "string"
  description = "softlayer api key"
}

variable "ibmcloud_api_key" {
  type = "string"
  description = "ibmcloud api key"
}

############################################################
# for main.tf
variable "cluster_name" {
  type = "string"
  description = "lsf cluster name"
  default = "lsf-cluster"
}

variable "domain_name" {
  type = "string"
  description = "domain name"
  default = "lsf.cloud"
}

variable "data_center" {
  type = "string"
  description = "data center"
}

variable "public_vlan_id" {
  type = "string"
  description = "public vlan id for master node"
}

variable "private_vlan_id" {
  type = "string"
  description = "private vlan id for both master node and private node"
}

variable "private_vlan_number" {
  type = "string"
  description = "private vlan number for both master node and slave node"
}

variable "master_cores" {
  type = "string"
  description = "cpu cores on master node"
  default = "4"
}

variable "master_memory" {
  type = "string"
  description = "memory in MBytes on master node"
  default = "32768"
}

variable "master_disk" {
  type = "string"
  description = "disk size in GBytes on master node"
  default = "100"
}

variable "master_network_speed" {
  type = "string"
  description = "network speed in Mbps on master node"
  default = "100"
}

variable "slave_cores" {
  type = "string"
  description = "cpu cores on slave node"
  default = "2"
}

variable "slave_memory" {
  type = "string"
  description = "memory in MBytes on slave node"
  default = "4096"
}

variable "slave_disk" {
  type = "string"
  description = "disk size in GBytes on slave node"
  default = "25"
}

variable "slave_network_speed" {
  type = "string"
  description = "network speed in Mbps on slave node"
  default = "100"
}

variable "remote_console_public_ssh_key" {
  type = "string"
  description = "public ssh key of remote console for control"
}

variable "scripts_path_uri" {
  type = "string"
  description = "uri of scripts folder"
  default = "https://raw.githubusercontent.com/chenxpcn/spectrum-lsf-ibmcloud/master/scripts"
}

variable "installer_uri" {
  type = "string"
  description = "uri of LSF Enterprise Suite installer package"
}

variable "lsfadmin_password" {
  type = "string"
  description = "password for user lsfadmin"
}

variable "image_name" {
  type = "string"
  description = "image name for dynamic node"
  default = "LSFDynamicNodeImage"
}
