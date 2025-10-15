#!/bin/bash

# Update the system
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Git
sudo apt-get install -y git	

sudo apt-get install -y amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

# Install Docker
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Add the 'ubuntu' and 'ssm-user' to the Docker group
sudo usermod -aG docker ubuntu
sudo usermod -aG docker ssm-user
id ubuntu ssm-user
sudo newgrp docker

# Enable and start Docker
sudo systemctl enable docker.service
sudo systemctl start docker.service

# Install Docker Compose v2
sudo mkdir -p /usr/local/lib/docker/cli-plugins
sudo curl -SL https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Add swap space
sudo dd if=/dev/zero of=/swapfile bs=128M count=32
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo "/swapfile swap swap defaults 0 0" | sudo tee -a /etc/fstab

DIR=/home/ubuntu
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_NAME=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/tags/instance/Name)
cd "$DIR" || exit 1
# A better solution would be downloading artifacts from S3 instead of a git repo, 
# but this is sufficient for this task and their wasn't criteria that allows me to use S3
git clone https://github.com/artyomprima-cloud/Dataforest.git

if [ "$INSTANCE_NAME" = "nginx" ]; then
  cp -r "$DIR"/Dataforest/nginx .
  rm -rf ./Dataforest
  cd "$DIR"/nginx || exit 1
  sed -i "s/PHPFPM_HOST:.*/PHPFPM_HOST: ${private_ip}/" docker-compose.yml
fi

if [ "$INSTANCE_NAME" = "php" ]; then
  cp -r "$DIR"/Dataforest/php .
  rm -rf ./Dataforest
  cd "$DIR"/php || exit 1
fi

sudo docker compose up -d
