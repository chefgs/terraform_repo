#!/bin/bash

# Update the package index
sudo yum update -y

# Install Java 11 (required for Jenkins)
sudo amazon-linux-extras install java-openjdk11 -y

# Enable the Jenkins repository
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo

# Import the Jenkins package signing key
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Install Jenkins
sudo yum install jenkins -y

# Start the Jenkins service
sudo systemctl start jenkins

# Enable Jenkins to start on system boot
sudo systemctl enable jenkins

# Print the Jenkins initial admin password
echo "Jenkins initial admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
