#!/bin/bash
mkdir -p /root/logs
LOG_FILE=/root/logs/post-install-master.log

function LOG()
{
    echo -e `date` "$1" >> "$LOG_FILE"
}

LOG "Start post-install script for master node ..."

if [ ! -f /root/user_metadata ]
then
    LOG "Retrieve user meta data"
    wget --no-check-certificate -O /root/user_metadata https://api.service.softlayer.com/rest/v3/SoftLayer_Resource_Metadata/UserMetadata.txt
fi

if [ -f /root/user_metadata ]
then
    LOG "Get user metadata"
    cat /root/user_metadata >> $LOG_FILE
    . /root/user_metadata
else
    LOG "ERROR -- not found user meta data"
    exit -1
fi

LOG_FILE=/root/logs/post-install-master.log

if [ ! -z "$slave_ip" -a ! -z "$domain_name" ]
then
    LOG "set lsf-slave ip to /etc/hosts"
    echo "$slave_ip lsf-slave.$domain_name lsf-slave" >> /etc/hosts
fi

LOG "install yum-utils"
yum -y install yum-utils >> $LOG_FILE

LOG "Complete post-install script for master node."
