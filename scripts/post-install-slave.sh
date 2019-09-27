#!/bin/bash
EGO_GETCONF=lim
LOG_FILE=/root/logs/post-install.log

function LOG()
{
    echo -e `date` "$1" >> "$LOG_FILE"
}

LOG "Start post-install script for slave node ..."

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
# else
#     LOG "ERROR -- not found user meta data"
#     exit -1
fi

LOG "Complete post-install script for slave node."
