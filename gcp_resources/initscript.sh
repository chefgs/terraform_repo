#!/bin/bash
mkdir -p /data/installers
mkdir -p /data/ansible
cd /data/installers/
rm -rf /data/ansible/*
outfile='/var/log/userdata.out'
# Install wget
if [ ! -f /bin/wget ] ; then
yum install wget -y >> $outfile
fi

# Install Ansible
if [ ! -f /bin/ansible ] ; then
echo "Installing Ansible" >> $outfile
yum install ansible -y >> $outfile
fi

# Install git
if [ ! -f /bin/git ] ; then
yum install git -y >> $outfile
fi

