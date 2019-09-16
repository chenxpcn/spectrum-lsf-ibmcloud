# variables supplied from terraform.tfvars

variable "iaas_username" {
  type = "string"
  description = "sl user name"
  default = "n/a"
}

variable "ibmcloud_iaas_api_key" {
  type = "string"
  description = "sl api key"
  default = "n/a"
}

variable "ibmcloud_api_key" {
  type = "string"
  description = "ic api key"
  default = "n/a"
}

provider "ibm" {
  softlayer_username = "${var.iaas_username}"
  softlayer_api_key  = "${var.ibmcloud_iaas_api_key}"
  bluemix_api_key    = "${var.ibmcloud_api_key}"
}
