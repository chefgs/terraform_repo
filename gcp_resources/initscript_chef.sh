#!/bin/bash
mkdir -p /data/installers
mkdir -p /data/chef_cookbooks
cd /data/installers/
rm -rf /data/cookbooks/*
outfile='/var/log/userdata.out'
# Install wget
if [ ! -f /bin/wget ] ; then
yum install wget -y >> $outfile
fi

# Install Chef client v14
if [ ! -f /bin/chef-client ] ; then
echo "Installing chef client" >> $outfile
wget https://packages.chef.io/files/stable/chef/14.3.37/el/7/chef-14.3.37-1.el7.x86_64.rpm >> $outfile
rpm -i chef-14*.rpm >> $outfile
fi

# Install git
if [ ! -f /bin/git ] ; then
yum install git -y >> $outfile
fi

# Clone Chef cookbook repo
cd /data/chef_cookbooks
echo "Cookbook Repo cloning" >> $outfile 
git clone https://github.com/chefgs/cookbooks.git >> $outfile

echo "Executing chef-client" >> $outfile
cd /data/chef_cookbooks
chef-client -z -o apache >> /var/log/chefrun.out
