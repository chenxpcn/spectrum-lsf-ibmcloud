#!/bin/bash
mkdir -p /root/logs
LOG_FILE=/root/logs/config-lsf-master.log

function LOG()
{
    echo -e `date` "$1" >> "$LOG_FILE"
}

LOG "Start config LSF master node ..."


LOG "Complete config LSF master node."
