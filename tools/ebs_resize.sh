#!/bin/bash

KEY_NAME=
INSTANCE_TYPE="t2.large" # m4.2xlarge
AZ="us-west-2b" 
REGION="us-west-2"
#ROLE_NAME=
VpcId=
SubnetId=
AMI_id= 
#cidr="0.0.0.0/0"
SecurityGroupId=
EBS_VOLUME_SIZE=200
HOSTED_ZONE_ID=


#List of instance id's whose EBS volumes to be attached need to be re-sized
#Give comma separate values of instance id's here
instances=
instances_list=`echo $instances | sed -e 's#,# #g'`

for i in `echo $instances_list`

do
echo $i
instance_state=`aws ec2 describe-instance-status --instance-id $i --query 'InstanceStatuses[*].InstanceState.Name' --output text`
echo $instance_state
#shut down ec2 instance if it is runnning state to detach EBS volume attached to it
if [ "$instance_state" == "running" ]; then
echo $i is in running state
aws ec2 stop-instances --instance-ids $i
aws ec2 wait instance-stopped --instance-ids $i
else 
echo $i is not running
fi
# Get Volume Id attached
volume_id=`aws ec2 describe-instances --instance-ids $i --output text --query Reservations[*].Instances[*].BlockDeviceMappings[1] | awk '{print $5}' | tail -n 1`
aws ec2 detach-volume --volume-id $volume_id
aws ec2 wait volume-available --volume-id $volume_id
  ebs_volume_id=`aws ec2 create-volume --size "$EBS_VOLUME_SIZE" --availability-zone "$AZ" --output text --volume-type "gp2" --query VolumeId`
  # Wait for EBS Volume to be ready
  echo "Waiting for the EVS volume $ebs_volume_id to be ready"
  aws ec2 wait volume-available --volume-ids $ebs_volume_id ;  
  #Step 5
  echo "attach the created EBS Volume to EC2 instance"
  aws ec2 attach-volume --volume-id "$ebs_volume_id" --instance-id $i --device "/dev/sdf" 
  aws ec2 wait volume-in-use --volume-ids $ebs_volume_id ;

aws ec2 start-instances --instance-ids $i
aws ec2 wait instance-running --instance-ids $i 
echo sleeping
sleep 15
PublicIp=`aws ec2 describe-instances --instance-ids $i --query "Reservations[*].Instances[*].PublicIpAddress" --output text`

ssh -o StrictHostKeyChecking=no -i aws ubuntu@$PublicIp "sudo mkfs -t ext4 /dev/xvdf;sudo mount /dev/xvdf /mnt/"
#aws ec2 stop-instances --instance-ids $i
done 


