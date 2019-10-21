provider "ibm" {
  version            = "~> 0.17"
  iaas_classic_username = "${var.iaas_username}"
  iaas_classic_api_key  = "${var.ibmcloud_iaas_api_key}"
  ibmcloud_api_key   = "${var.ibmcloud_api_key}"
}
