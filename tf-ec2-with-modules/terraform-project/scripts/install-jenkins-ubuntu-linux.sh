#!/bin/bash

# Update the package index
sudo apt-get update -y

# Install Java 17 (latest stable version required for Jenkins)
sudo apt-get install openjdk-17-jdk -y

# Set JAVA_HOME environment variable
echo "export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64" | sudo tee -a /etc/profile
echo "export PATH=\$JAVA_HOME/bin:\$PATH" | sudo tee -a /etc/profile
source /etc/profile

# Enable the Jenkins repository
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

# Update the package index again
sudo apt-get update -y

# Install Jenkins
sudo apt-get install jenkins -y

# Start the Jenkins service
sudo systemctl start jenkins

# Enable Jenkins to start on system boot
sudo systemctl enable jenkins

# Wait for Jenkins to complete setup
echo "Waiting for Jenkins to complete setup..."
while [ ! -f /var/lib/jenkins/secrets/initialAdminPassword ]; do
  sleep 10
done

# Print the Jenkins initial admin password
echo "Jenkins initial admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword