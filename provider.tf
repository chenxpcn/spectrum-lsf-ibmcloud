# variables supplied from terraform.tfvars

variable "iaas_username" {
  type = "string"
  description = "sl user name"
}

variable "ibmcloud_iaas_api_key" {
  type = "string"
  description = "sl api key"
}

variable "ibmcloud_api_key" {
  type = "string"
  description = "ic api key"
}

provider "ibm" {
  version            = "~> 0.17"
  softlayer_username = "${var.iaas_username}"
  softlayer_api_key  = "${var.ibmcloud_iaas_api_key}"
  ibmcloud_api_key   = "${var.ibmcloud_api_key}"
}
