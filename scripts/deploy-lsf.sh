#!/bin/bash
LOG_FILE=/root/logs/deployer.log
INSTALL_PACKAGE_URI=$1
CLUSTER_NAME=$2

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

cd /opt/ibm/lsf_installer/playbook

LOG "Modify lsf-config.yml"
sed -i 's/my_cluster_name: myCluster/my_cluster_name: ${var.cluster_name}/' lsf-config.yml

LOG "Modify lsf-inventory"
sed -i '/\[LSF_Servers\]/a\lsf-slave' lsf-inventory

LOG "Perform pre-install checking"
ansible-playbook -i lsf-inventory lsf-config-test.yml>/root/logs/lsf-config-test.log
result=`cat /root/logs/lsf-config-test.log|grep 'failed='|sed -n 's/^.*failed=//;p'|grep '[1-9]'`
if [ ! -z "$result" ]
then
    LOG "Found error in config test, please check /root/logs/lsf-config-test.log"
    exit -1
fi
ansible-playbook -i lsf-inventory lsf-predeploy-test.yml>/root/logs/lsf-predeploy-test.log
result=`cat /root/logs/lsf-predeploy-test.log|grep 'failed='|sed -n 's/^.*failed=//;p'|grep '[1-9]'`
if [ ! -z "$result" ]
then
    LOG "Found error in pre-deploy test, please check /root/logs/lsf-predeploy-test.log"
    exit -1
fi

LOG "Install LSF"
ansible-playbook -i lsf-inventory lsf-deploy.yml>/root/logs/lsf-deploy.log


LOG "All set."
