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
