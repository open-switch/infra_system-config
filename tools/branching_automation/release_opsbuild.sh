#!/bin/bash

#The name of Release you are branching for
NewRelease_Name=
Rlease_Version=
Ops-build_sha=
# Last Release name, can be toronto, dill etc
Release_Name=dill

#epazote & 0.4.0 tag is 0.3.0-rc0
#the content of conf file in  master branch needs to be updated, not release branch

cd /Users/krishnachaitakurnala/releasebranching/ops-build
git checkout master
git pull --rebase origin 
git reset --hard $Ops-build_sha

#git tag -a $Release_Version 
#git push origin --tags

git branch $Release_Name master  
git checkout $Release_Name
#Updating Release version and Release name in conf files
sed -i 's/DISTRO_VERSION = ".*"/DISTRO_VERSION = "$Rlease_Version"/' yocto/openswitch/meta-distro-openswitch/conf/distro/openswitch.conf
sed -i 's/DISTRO_CODENAME = ".*"/DISTRO_CODENAME = "$Release_Name"/' yocto/openswitch/meta-distro-openswitch/conf/distro/openswitch.conf
git add .
git commit -m"update DISTRO_VERSION to $Release_tag"
git push origin $Release_Name




