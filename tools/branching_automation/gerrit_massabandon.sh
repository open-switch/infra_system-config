#!/bin/bash

#This script would abandon all open changes in all openswitch projects on rel/dill branch
#this script used Gerrit cli and would work only from workstations of administators

#Get a list of all openswitch projects 
projects_list=`ssh -p 29418 review.openswitch.net gerrit ls-projects | grep openswitch`

#echo "List of projects: $projects_list "

for i in `echo $projects_list`
do
echo "working on project $i"
abandon_list=`ssh -p 29418 review.openswitch.net gerrit query "status:open project:$i branch:rel/dill" | egrep '^\ +number' | cut -d' ' -f4-`
   for i in `echo $abandon_list`
      do
      echo "Abandoning https://review.openswitch.net/#/c/$i "
      #ssh -p 29418 review.openswitch.net gerrit review --abandon $i,1
      done
done
