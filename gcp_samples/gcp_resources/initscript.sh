#!/bin/bash
# Init script will be executed when the intance is created
# This scripts installs wget, ansible and git packages
mkdir -p /data/installers
mkdir -p /data/ansible
mkdir -p /data/playbooks
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

# Clone rpm creation repo
cd /data/playbooks
echo "Creating dummmy rpm" >> $outfile
git clone https://github.com/chefgs/create_dummy_rpm.git >> $outfile
cd create_dummy_rpm
chmod +x create_rpm.sh
./create_rpm.sh spec_file/my-monitoring-agent.spec >> $outfile

# Clone Ansible repo
cd /data/ansible
echo "Playbook Repo cloning" >> $outfile 
git clone https://github.com/chefgs/ansible_playbooks.git >> $outfile

echo "Executing Playbook" >> $outfile
cd /data/ansible/ansible_playbooks/cloud_init_playbook/
ansible-playbook playbook.yml -i ansible/hosts.ini >> /var/log/ansiblerun.out
echo "Completed Executing Metadata Script" >> $outfile
