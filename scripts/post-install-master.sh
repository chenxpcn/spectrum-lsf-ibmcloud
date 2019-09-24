#!/bin/bash
LOG_FILE=/root/post-install.log

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

if [ ! -z "$slave_ip" -a ! -z "$domain_name" ]
then
    LOG "set lsf-slave ip to /etc/hosts"
    echo "$slave_ip lsf-slave.$domain_name lsf-slave" >> /etc/hosts
fi

LOG "install yum-utils"
yum -y install yum-utils >> $LOG_FILE

mkdir -p /root/installer
LOG "wget -nH -c --no-check-certificate -o $LOG_FILE -O /root/installer/lsfsent-x86_64.bin ${installer_uri}"
wget -nv -nH -c --no-check-certificate -o $LOG_FILE -O /root/installer/lsfsent-x86_64.bin ${installer_uri}
echo "1" > /root/installer/select_yes
chmod 744 /root/installer/lsfsent-x86_64.bin
/root/installer/lsfsent-x86_64.bin < /root/installer/select_yes

LOG "Complete post-install script for master node."
