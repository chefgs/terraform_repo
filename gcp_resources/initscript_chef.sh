#!/bin/bash
mkdir -p /data/chef_cookbooks
rm -rf /data/chef_cookbooks/*
outfile='/var/log/userdata.out'

# Install Chef client v14
if [ ! -f /usr/bin/chef-client ] ; then
echo "Installing chef client" >> $outfile
curl -L https://omnitruck.chef.io/install.sh | sudo bash -s -- -v 15.8.23 >> $outfile
fi

# Install git
if [ ! -f /usr/bin/git ] ; then
yum install git -y >> $outfile
fi

# Clone Chef cookbook repo
cd /data/chef_cookbooks
echo "Cookbook Repo cloning" >> $outfile 
git clone https://github.com/chefgs/cookbooks.git >> $outfile

echo "Executing chef-client" >> $outfile
cd /data/chef_cookbooks
sudo chef-client -z -o apache --chef-license accept >> /var/log/chefrun.out
##
