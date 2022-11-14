#!/bin/bash/

# Update controller
sudo apt update -y

# Upgrade controller - may take a while
sudo apt upgrade -y

# Install first dependancy
sudo apt-get install software-properties-common

# Add ansible repo so VM knows where to get Ansible from
sudo apt-add-repository ppa:ansible/ansible

# Update again to be safe
sudo apt update -y

# Installs Ansible on the contoller VM
sudo apt-get install ansible -y
# Note this does not need to be installed on the other machines

# This lets us visualise our directories better
sudo apt-get install tree

# Into /etc
cd /etc

# Into ansible
cd ansible

# Check if install worked and files/folder is there
ls

# Check version
sudo ansible --version