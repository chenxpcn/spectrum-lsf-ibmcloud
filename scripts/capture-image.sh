#!/bin/bash
SL_USER=$1
SL_APIKEY=$2
INSTANCE_ID=$3
IMAGE_NAME=$4
SLAVE_IP=$5
LOG_FILE=/root/logs/capture-image.log

LOG()
{
    echo -e `date` "$1" >> "$LOG_FILE"
}

is_slave_offline() {
    LOG "check whether slave is offline ..."
    max_retry=30
    online='1'
    while [ $max_retry -gt 0 -a $online -eq '1' ]
    do
        sleep 10
        online=`ping $SLAVE_IP -c 1 -q|grep received|cut -d ',' -f 2|cut -d ' ' -f 2`
        max_retry=`expr $max_retry - 1`
    done
}

is_slave_online() {
    LOG "check whether slave is online ..."
    max_retry=60
    online='0'
    while [ $max_retry -gt 0 -a $online -eq '0' ]
    do
        sleep 10
        online=`ping $SLAVE_IP -c 1 -q|grep received|cut -d ',' -f 2|cut -d ' ' -f 2`
        max_retry=`expr $max_retry - 1`
    done
}

LOG "Start to capture the image for slave"

LOG "Install and config python running environment"
easy_install pip
pip install virtualenv
cd /root/installer
virtualenv venv
. ./venv/bin/activate
pip install SoftLayer

LOG "Call to capture the image for slave"
python capture-image.py $SL_USER $SL_APIKEY $INSTANCE_ID "$IMAGE_NAME"

LOG "Check whether capture transaction is completed or not"
is_slave_offline
if [ $online -eq '0' ]
then
    LOG "slave is offline"
    is_slave_online
    if [ $online -eq '1' ]
    then
        LOG "slave is online again, capture transaction complete."
    fi
fi

deactivate

LOG "Capture the image for slave complete."
