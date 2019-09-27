#!/bin/bash
mkdir -p /root/logs
LOG_FILE=/root/logs/config-lsf-slave.log

function LOG()
{
    echo -e `date` "$1" >> "$LOG_FILE"
}

LOG "Start config LSF slave node ..."

LOG "add rc_account to .bash_profile"
sed -i 's/EGO_GETCONF=lim/EGO_GET_CONF=lim/' /opt/ibm/lsfsuite/lsf/conf/ego/lsf-demo/kernel/ego.conf

LOG "add rc_account to .bash_profile"
echo "export rc_account=lsf-demo-dynamic-host">>/root/.bash_profile

LOG "Complete config LSF slave node."
