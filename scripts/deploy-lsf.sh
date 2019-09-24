#!/bin/bash
LOG_FILE=/root/logs/download-extract-deployer.log
INSTALL_PACKAGE_URI=$1

function LOG()
{
    echo -e `date` "$1" >> "$LOG_FILE"
}

LOG "Start to download deployer ..."

mkdir -p /root/installer

LOG "wget -nH -c --no-check-certificate -o $LOG_FILE -O /root/installer/lsfsent-x86_64.bin $INSTALL_PACKAGE_URI"
wget -nv -nH -c --no-check-certificate -o $LOG_FILE -O /root/installer/lsfsent-x86_64.bin $INSTALL_PACKAGE_URI

echo "1" > "/root/installer/select_yes"

LOG "Start to extract deployer ..."
chmod 744 /root/installer/lsfsent-x86_64.bin
/root/installer/lsfsent-x86_64.bin < /root/installer/select_yes

LOG "All set."
