#!/bin/bash
mkdir -p /data/installers
mkdir -p /data/chef_cookbooks
cd /data/installers/
rm -rf /data/cookbooks/*
outfile='/var/log/userdata.out'

# Install Chef client v14
if [ ! -f /bin/chef-client ] ; then
echo "Installing chef client" >> $outfile
curl -L https://omnitruck.chef.io/install.sh | sudo bash >> $outfile
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
chef-client -z -o apache --chef-license accept >> /var/log/chefrun.out
##
