#!/bin/bash

NewRelease_Name=epazote
Rlease_Version=0.4.0
Ops-build_sha=
Release_Name=dill
ops-build_home=/Users/krishnachaitakurnala/releasebranching/ops-build
recipe_folder=yocto/openswitch/meta-distro-openswitch/recipes-ops//vsi

#epazote & 0.4.0 tag is 0.3.0-rc0
#the content of conf file in  master branch needs to be updated, not release branch

#projects_list=ops,ops-aaa-utils,ops-ansible,ops-arpmgrd,ops-broadview,ops-bufmond,ops-build,ops-cfgd,ops-checkmk-agent,ops-classifierd,ops-cli,ops-config-yaml,ops-dhcp-tftp,ops-docs,ops-fand,ops-ft-framework,ops-hw-config,ops-intfd,ops-ipapps,ops-lacpd,ops-ledd,ops-lldpd,ops-mgmt-intf,ops-ntpd,ops-openvswitch,ops-passwd-srv,ops-pmd,ops-portd,ops-powerd,ops-quagga,ops-rbac,ops-restapi,ops-restd,ops-snmpd,ops-stpd,ops-supportability,ops-switchd,ops-switchd-container-plugin,ops-switchd-opennsl-plugin,ops-switchd-p4switch-plugin,ops-sysd,ops-sysmond,ops-tempd,ops-topology-common,ops-topology-lib-vtysh,ops-utils,ops-vland,ops-vsi,ops-webui,ops-l2macd

#S_REPOS=`echo $projects_list | sed -e 's#,# #g'`

#Get a list of all openswitch projects 
projects_list=`ssh -p 29418 review.openswitch.net gerrit ls-projects | grep openswitch | cut -d'/' -f2`

#cd releasebranching

for i in `echo $projects_list`
do
  cd releasebranching/$i
  pwd
  echo " Dealing with project $i "
  srcrev=`grep SRCREV $ops-build_home/$recipe_folder/$i.bb | cut -d'=' -f2 | tr -d '"'`
  echo $srcrev
done

for i in `grep -ri "SRCREV" yocto/openswitch/meta-distro-openswitch/recipes-ops/`
do
  echo "$i"
  temp=0
  project_list[temp]= `echo $i | cut -d'/' -f7 | cut -d'.' -f1`
  sha_list[temp]=`echo $i | cut -d'/' -f7 | cut -d'=' -f2 | tr -d '"'`
  temp=temp+1   
done 


for j in "${project_list[@]}"
do
  for k in "${sha_list[@]}"  
  do
  echo "$j"
  if [ -d "clones/$j" ]; then
     continue
     else
     git clone https://git.openswitch.net/openswitch/$j clones/$j
  fi
  cd /Users/krishnachaitakurnala/work/openswitch/clones/$i
  git pull --rebase origin
  git reset --hard $k
  git tag -a $Release_Version 
  git push origin --tags
  git branch $Release_Name master 
  git push origin release 
  done
done

for i in $(echo $projects_lists)
do
  echo "$i"
  if [ -d "clones/$i" ]; then
     continue
     else
     git clone https://git.openswitch.net/openswitch/$i clones/$i
  fi
done

for i in $(echo $projects_lists)
do
     cd /Users/krishnachaitakurnala/work/openswitch/clones/$i
     git pull --rebase origin
     if [ `git branch -r | grep origin/release`]; then 
        echo "Release Branch already exists."
        git branch --track release origin/release 
        git checkout release 
        git merge master 
        if [ `git ls-files -u | wc -l` -ne 0 ]; then
        temp=0
        echo "Auto merge of master to release branch of repo $i failed"
        list[temp]=$i
        temp=temp+1 
        fi
     else
        git branch release master
        git push origin release 
     fi
     
     git tag -a $Release_tag
     git push origin HEAD:release --tags 
     
     git add -f ft_ct_coverage
     git commit -m"Adding a new config file for measuring lcov based code coverage"
     git review
  fi
done


#list repositories that need merge 
echo "Here are list of repositories that need manual merge"
echo "${list[@]}"
