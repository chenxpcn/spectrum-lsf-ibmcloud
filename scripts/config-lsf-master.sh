#!/bin/bash
# mkdir -p /root/logs
LOG_FILE=/root/logs/config-lsf-master.log
CLUSTER_NAME=$1
SL_USER=$2
SL_APIKEY=$3
REMOTE_SCRIPT_PATH=$4
MASTER_IP_ADDR=$5
SLAVE_CORES=$6
SLAVE_MEMORY=$7
IMAGE_NAME=$8
DATA_CENTER=$9
PRIVATE_VLAN_NUMBER=${10}

function LOG()
{
    echo -e `date` "$1" >> "$LOG_FILE"
}

LOG "Start config LSF master node ..."

LOG "RC configuration directory is $LSF_ENVDIR/resource_connector/softlayer/conf"

LOG "Set provioning.sh"
sed -i 's/\[MASTER-IP-ADDRESS\]/'$MASTER_IP_ADDR'/' /var/www/html/provisioning.sh
sed -i 's/\[CLUSTER-NAME\]/'$CLUSTER_NAME'/' /var/www/html/provisioning.sh

LOG "Modify $LSF_ENVDIR/lsf.cluster.$CLUSTER_NAME"
sed -i '/Begin Parameters/a\LSF_HOST_ADDR_RANGE=*.*.*.*' $LSF_ENVDIR/lsf.cluster.$CLUSTER_NAME

LOG "Modify $LSF_ENVDIR/resource_connector/softlayer/conf/credentials"
sed -i 's/^softlayer_access_user_name =.\+/softlayer_access_user_name = '$SL_USER'/; s/softlayer_secret_api_key =.\+/softlayer_secret_api_key = '$SL_APIKEY'/' $LSF_ENVDIR/resource_connector/softlayer/conf/credentials

LOG "Modify $LSF_ENVDIR/resource_connector/softlayer/conf/softlayerprov_config.json"
NEW_VALUE=`echo "$LSF_ENVDIR/resource_connector/softlayer/conf/credentials"|sed 's#\/#\\\/#g'`
sed -i 's/\( \+"SOFTLAYER_CREDENTIAL_FILE": "\).\+\,/\1'$NEW_VALUE'"\,/' $LSF_ENVDIR/resource_connector/softlayer/conf/softlayerprov_config.json

LOG "Modify $LSF_ENVDIR/resource_connector/softlayer/conf/softlayerprov_templates.json"
sed -i 's/"maxNumber": [0-9]\+\,/"maxNumber": 10\,/' $LSF_ENVDIR/resource_connector/softlayer/conf/softlayerprov_templates.json
sed -i 's/"ncpus": \["Numeric"\, ".\+"/"ncpus": \["Numeric"\, "'$SLAVE_CORES'"/' $LSF_ENVDIR/resource_connector/softlayer/conf/softlayerprov_templates.json
sed -i 's/"mem": \["Numeric"\, ".\+"/"mem": \["Numeric"\, "'$SLAVE_MEMORY'"/' $LSF_ENVDIR/resource_connector/softlayer/conf/softlayerprov_templates.json
sed -i 's/"softlayercomp"/"softlayerhost"/' $LSF_ENVDIR/resource_connector/softlayer/conf/softlayerprov_templates.json
sed -i 's/"imageId": ".\+",/"imageId": "'$IMAGE_NAME'",/' $LSF_ENVDIR/resource_connector/softlayer/conf/softlayerprov_templates.json
sed -i 's/"datacenter": ".\+"\,/"datacenter": "'$DATA_CENTER'"\,/' $LSF_ENVDIR/resource_connector/softlayer/conf/softlayerprov_templates.json
sed -i 's/"vlanNumber": ".\+"\,/"vlanNumber": "'$PRIVATE_VLAN_NUMBER'"\,/' $LSF_ENVDIR/resource_connector/softlayer/conf/softlayerprov_templates.json
sed -i 's/"privateNetworkOnlyFlag": false\,/"privateNetworkOnlyFlag": true\,/' $LSF_ENVDIR/resource_connector/softlayer/conf/softlayerprov_templates.json
sed -i 's/"postProvisionURL": ".\+"\,/"postProvisionURL": "http:\/\/'$MASTER_IP_ADDR'\/provisioning.sh"\,/' $LSF_ENVDIR/resource_connector/softlayer/conf/softlayerprov_templates.json

LOG "Modify $LSF_ENVDIR/lsbatch/$CLUSTER_NAME/configdir/lsb.modules"
sed -i 's/#schmod_demand/schmod_demand/' $LSF_ENVDIR/lsbatch/$CLUSTER_NAME/configdir/lsb.modules

LOG "Modify $LSF_ENVDIR/lsbatch/$CLUSTER_NAME/configdir/lsb.queues"
sed -i '/QUEUE_NAME \+= normal/a\RC_HOSTS = softlayerhost' $LSF_ENVDIR/lsbatch/$CLUSTER_NAME/configdir/lsb.queues
sed -i '/RC_HOSTS = softlayerhost/a\RC_ACCOUNT = lsf-demo-dynamic-host' $LSF_ENVDIR/lsbatch/$CLUSTER_NAME/configdir/lsb.queues

LOG "Modify $LSF_ENVDIR/lsf.conf"
echo LSB_RC_EXTERNAL_HOST_FLAG=\"softlayerhost\">>$LSF_ENVDIR/lsf.conf
echo LSF_REG_FLOAT_HOSTS=Y>>$LSF_ENVDIR/lsf.conf
echo LSF_DYNAMIC_HOST_WAIT_TIME=60>>$LSF_ENVDIR/lsf.conf
echo LSF_DYNAMIC_HOST_TIMEOUT=10m>>$LSF_ENVDIR/lsf.conf
echo LSB_RC_EXTERNAL_HOST_IDLE_TIME=10>>$LSF_ENVDIR/lsf.conf

LOG "Modify $LSF_ENVDIR/lsf.shared"
sed -i 's/#\( \+\)softlayerhost/ \1softlayerhost/' $LSF_ENVDIR/lsf.shared

LOG "Disable master node as compute node"
badmin hclose lsf-master>>$LOG_FILE

LOG "Restart the LSF daemons"
echo y>/root/installer/all_yes
echo y>>/root/installer/all_yes
lsadmin limrestart</root/installer/all_yes>>$LOG_FILE
lsadmin resrestart</root/installer/all_yes>>$LOG_FILE
badmin mbdrestart</root/installer/all_yes>>$LOG_FILE


LOG "Complete config LSF master node."
