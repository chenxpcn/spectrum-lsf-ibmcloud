provider "ibm" {
  version            = "~> 0.17"
  softlayer_username = "${var.iaas_username}"
  softlayer_api_key  = "${var.ibmcloud_iaas_api_key}"
  ibmcloud_api_key   = "${var.ibmcloud_api_key}"
}
