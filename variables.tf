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
}

variable "domain_name" {
    type = "string"
    description = "domain name"
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

variable "master_cores" {
    type = "string"
    description = "cpu cores on master node"
}

variable "master_memory" {
    type = "string"
    description = "memory in MBytes on master node"
}

variable "master_disk" {
    type = "string"
    description = "disk size in GBytes on master node"
}

variable "master_network_speed" {
    type = "string"
    description = "network speed in Mbps on master node"
}

variable "slave_cores" {
    type = "string"
    description = "cpu cores on slave node"
}

variable "slave_memory" {
    type = "string"
    description = "memory in MBytes on slave node"
}

variable "slave_disk" {
    type = "string"
    description = "disk size in GBytes on slave node"
}

variable "slave_network_speed" {
    type = "string"
    description = "network speed in Mbps on slave node"
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
  type = "image name for dynamic node"
}
