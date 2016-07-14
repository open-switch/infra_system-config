#!/bin/bash

#This is a script to delete a git branch from all projects using Gerrit REST API
#Gerrit REST API needs http username and password of user for authentication, 
#this is different from user/pass we use to login to gerrit, it can be found in your settings tab
# https://review.openswitch.net/#/settings/http-password

http_user=
http_password=

#Git branch name to be deleted
branch_name=

#provide comma delimeted list of projects you want to delete branch from
projects_list=ops-aaa-utils,ops-ansible,ops-arpmgrd,ops-broadview,ops-bufmond,ops-cfgd,ops-checkmk-agent,ops-classifierd,ops-cli,ops-config-yaml,ops-dhcp-tftp,ops-docs,ops-fand,ops-ft-framework,ops-hw-config,ops-intfd,ops-ipapps,ops-lacpd,ops-ledd,ops-lldpd,ops-mgmt-intf,ops-ntpd,ops-openvswitch,ops-passwd-srv,ops-pmd,ops-portd,ops-powerd,ops-quagga,ops-rbac,ops-restapi,ops-restd,ops-snmpd,ops-stpd,ops-supportability,ops-switchd,ops-switchd-container-plugin,ops-switchd-opennsl-plugin,ops-switchd-p4switch-plugin,ops-sysd,ops-sysmond,ops-tempd,ops-topology-common,ops-topology-lib-vtysh,ops-utils,ops-vland,ops-vsi,ops-webui,ops-l2macd

S_REPOS=`echo $projects_list | sed -e 's#,# #g'`

for i in $S_REPOS
do
  echo " Dealing with project $i "
  #We would need to url encode certain parts if url's for rest calls to work
  curl -X DELETE --digest --user $http_user:$http_password https://review.openswitch.net/a/projects/openswitch%2F$i/branches/$branch_name
done