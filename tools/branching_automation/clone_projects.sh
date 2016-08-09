#!/bin/bash

# This script would clone all ops respositories into your local workstation as part of release branching and tagging process 

#projects_list=ops,ops-aaa-utils,ops-ansible,ops-arpmgrd,ops-broadview,ops-bufmond,ops-build,ops-cfgd,ops-checkmk-agent,ops-classifierd,ops-cli,ops-config-yaml,ops-dhcp-tftp,ops-docs,ops-fand,ops-ft-framework,ops-hw-config,ops-intfd,ops-ipapps,ops-lacpd,ops-ledd,ops-lldpd,ops-mgmt-intf,ops-ntpd,ops-openvswitch,ops-passwd-srv,ops-pmd,ops-portd,ops-powerd,ops-quagga,ops-rbac,ops-restapi,ops-restd,ops-snmpd,ops-stpd,ops-supportability,ops-switchd,ops-switchd-container-plugin,ops-switchd-opennsl-plugin,ops-switchd-p4switch-plugin,ops-sysd,ops-sysmond,ops-tempd,ops-topology-common,ops-topology-lib-vtysh,ops-utils,ops-vland,ops-vsi,ops-webui
#S_REPOS=`echo $projects_list | sed -e 's#,# #g'`

#Get a list of all openswitch projects 
projects_list=`ssh -p 29418 review.openswitch.net gerrit ls-projects | grep openswitch`

#Run this script in your user home folder(~)
mkdir -p releasebranching
cd releasebranching
pwd

for i in `echo $projects_list`
do
  echo " cloning $i "
  git clone ssh://kkurnala@review.openswitch.net:29418/$i 
done