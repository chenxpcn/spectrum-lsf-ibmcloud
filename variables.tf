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
variable "master_ssh_key_file" {
    type = "string"
    description = "temporary private key file name for lsf-master"
    default = "lsf-master-ssh-key"
}

variable "slave_ssh_key_file" {
    type = "string"
    description = "temporary private key file name for lsf-slave"
    default = "lsf-slave-ssh-key"
}

variable "domain_name" {
    type = "string"
    description = "domain name"
    default = "demo.cloud"
}

variable "data_center" {
    type = "string"
    description = "data center"
    default = "dal13"
}

variable "public_vlan_id" {
    type = "string"
    description = "public vlan id for master node"
    default = "2317207"
}

variable "private_vlan_id" {
    type = "string"
    description = "private vlan id for both master node and private node"
    default = "2317209"
}

variable "remote_console_public_ssh_key" {
    type = "string"
    description = "public ssh key of remote console for control"
    default = ""
}

variable "post_install_script_uri_master" {
  type = "string"
  description = "uri of post-install script for master node"
}

variable "post_install_script_uri_slave" {
  type = "string"
  description = "uri of post-install script for slave node"
}

variable "installer_uri" {
  type = "string"
  description = "uri of LSF Enterprise Suite installer package"
}

variable "installer_name" {
  type = "string"
  description = "name of LSF Enterprise Suite installer package"
  default = "lsfsent10.2.0.8-x86_64.bin"
}

