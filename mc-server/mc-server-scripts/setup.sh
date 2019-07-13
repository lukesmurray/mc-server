#!/bin/bash
# Set up script run once when the server boots. 
# Installs docker and other necessary scripts
set -ex

echo "installing updates"
sudo yum update -y

echo "installing docker"
sudo amazon-linux-extras install -y docker
sudo systemctl enable --now docker
sudo usermod -a -G docker ec2-user

echo "installing docker-compose"
COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
sudo curl -L https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "installing mcstatus"
sudo yum install -y python-pip
# TODO this is not security friendly but cronjob doens't pick up libraries
# installed with pip install --user <lib>
sudo pip install --upgrade pip mcstatus

echo "starting cron"
sudo systemctl enable --now crond