#!/bin/bash

#This is a script to create a git branch for all projects provided in csv format
#utilizes Gerrit CLI
#This script should be run from a Gerrit Administrators worktation

projects_list=ops-aaa-utils,ops-ansible,ops-arpmgrd,ops-broadview,ops-bufmond,ops-cfgd,ops-checkmk-agent,ops-classifierd,ops-cli,ops-config-yaml,ops-dhcp-tftp,ops-docs,ops-fand,ops-ft-framework,ops-hw-config,ops-intfd,ops-ipapps,ops-lacpd,ops-ledd,ops-lldpd,ops-mgmt-intf,ops-ntpd,ops-openvswitch,ops-passwd-srv,ops-pmd,ops-portd,ops-powerd,ops-quagga,ops-rbac,ops-restapi,ops-restd,ops-snmpd,ops-stpd,ops-supportability,ops-switchd,ops-switchd-container-plugin,ops-switchd-opennsl-plugin,ops-switchd-p4switch-plugin,ops-sysd,ops-sysmond,ops-tempd,ops-topology-common,ops-topology-lib-vtysh,ops-utils,ops-vland,ops-vsi,ops-webui,ops-l2macd

S_REPOS=`echo $projects_list | sed -e 's#,# #g'`

src_branch=
dest_branch=

for i in $S_REPOS
do
  echo " Dealing with project $i "
  ssh -p 29418 review.openswitch.net gerrit create-branch openswitch/$i $dest_branch $src_branch
done