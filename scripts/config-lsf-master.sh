#!/bin/bash
mkdir -p /root/logs
LOG_FILE=/root/logs/config-lsf-master.log
CLUSTER_NAME=$1
SL_USER=$2
SL_APIKEY=$3

function LOG()
{
    echo -e `date` "$1" >> "$LOG_FILE"
}

LOG "Start config LSF master node ..."

LOG "Modify $LSF_ENVDIR/lsf.cluster.$CLUSTER_NAME"
sed -i '/Begin Parameters/a\LSF_HOST_ADDR_RANGE=*.*.*.*' $LSF_ENVDIR/lsf.cluster.$CLUSTER_NAME

LOG "Modify $LSF_ENVDIR/resource_connector/softlayer/conf/credentials"
sed -i 's/^softlayer_access_user_name =.\+/softlayer_access_user_name = '${SL_USER}'/; s/softlayer_secret_api_key =.\+/softlayer_secret_api_key = '${SL_APIKEY}'/' $LSF_ENVDIR/resource_connector/softlayer/conf/credentials

LOG "Modify $LSF_ENVDIR/resource_connector/softlayer/conf/softlayerprov_config.json"
NEW_VALUE=`echo "$LSF_ENVDIR"|sed 's#\/#\\\/#g'`
sed -i 's/\( \+"SOFTLAYER_CREDENTIAL_FILE": "\).\+\,/\1'$NEW_VALUE'\/resource_connector\/softlayer\/conf\/credentials"\,/' $LSF_ENVDIR/resource_connector/softlayer/conf/softlayerprov_config.json

LOG "Complete config LSF master node."

