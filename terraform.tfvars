# (required) Enter your IBM IaaS Infrastructure full username, you can get this using: https://control.bluemix.net/account/user/profile
# iaas_username = "IBM1111111"
iaas_username = ""

# (required) Enter your IBM IaaS Infrastructure API key, you can get this using: https://control.bluemix.net/account/user/profile
ibmcloud_iaas_api_key = ""

# (required) Enter your IBM Cloud API Key, you can get your IBM Cloud API key using: https://console.bluemix.net/iam#/apikeys
ibmcloud_api_key = ""

# (required) public ssh key for remote console that used to control the master node
# remote_console_public_ssh_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCpfjveuUdG2Rra13c2THzsIqhNohHRBsQPR4tlX+D+Bg2mXfT9+Vq9d4kXglE2+HeFIjo1UadjAdfCfBN4gRvL9DAmSJC3yS9pi4NbrAIILsvI8E33CaGt52xij/PpIOX1/TscPZgfmX/+rW6tpAE4BM5bUq09wAMmKOoM59rq8bjo9sk4wb4xq28Ztae4hCmVVR5h9iZ/hZK/0ukZeapG7XP0ZKFR71RozNoBHZ8Df4Bw163CCHMFNmQlTK8OvPHqjuZzMGFh/FCKmqorrefixAjRaNUHjflOAWVloUO9+w0tUmdMMt9+aErQ6e+b2l950FP3uEfa4Bci7bmCGj2d "
remote_console_public_ssh_key = ""

# (required) LSF cluster name
# cluster_name = "lsf-demo"
cluster_name = ""

# (optional) uri of scripts folder
# scripts_path_uri = "https://raw.githubusercontent.com/chenxpcn/spectrum-lsf-ibmcloud/master/scripts"

# (required) uri of installer package
# installer_uri = "http://<http_server_ip>/suite/lsfsent10.2.0.8-x86_64.bin"
installer_uri = ""

# (required) password for user lsfadmin
# lsfadmin_password = "password"
lsfadmin_password = ""

# (required) domain name for master node and slave node
# domain_name = "demo.cloud"
domain_name = ""

# (required) data center where master node and slave node will be provisioned
# data_center = "dal13"
data_center = ""

# (required) public vlan id for master node
# public_vlan_id = "2317207"
public_vlan_id = ""

# (required) private vlan id for both master node and private node
# private_vlan_id = "2317209"
private_vlan_id = ""

# (required) cpu cores for master node
# master_cores = "4"
master_cores = ""

# (required) memory in MBytes on master node
# master_memory = "32768"
master_memory = ""

# (required) disk size in GBytes on master node
# master_disk = "100"
master_disk = ""

# (required) network speed in Mbps on master node
# master_network_speed = "100"
master_network_speed = ""

# (required) cpu cores for slave node
# slave_cores = "2"
slave_cores = ""

# (required) memory in MBytes on slave node
# slave_memory = "4096"
slave_memory = ""

# (required) disk size in GBytes on slave node
# slave_disk = "25"
slave_disk = ""

# (required) network speed in Mbps on slave node
# slave_network_speed = "100"
slave_network_speed = ""
