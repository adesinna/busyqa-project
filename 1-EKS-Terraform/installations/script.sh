#!/bin/bash

# Install AWS CLI
sudo apt-get update -y
sudo apt install unzip -y

# Kill the process with PID 3155 if it is running
sudo kill -9 3155

curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure AWS CLI
read -p "Enter your AWS Access Key ID: " aws_access_key_id
read -p "Enter your AWS Secret Access Key: " aws_secret_access_key

aws configure set aws_access_key_id "$aws_access_key_id"
aws configure set aws_secret_access_key "$aws_secret_access_key"
aws configure set default.region us-west-2
aws configure set default.output_format json

# Install latest kubectl binary (eks of 1.3)
LATEST_KUBECTL_VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${LATEST_KUBECTL_VERSION}/bin/linux/arm64/kubectl"
curl -LO "https://dl.k8s.io/release/${LATEST_KUBECTL_VERSION}/bin/linux/arm64/kubectl.sha256"

# Verify the binary with sha256
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
kubectl version --short --client

# Install eksctl
ARCH=arm64
PLATFORM=$(uname -s)_$ARCH

curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"

# (Optional) Verify checksum
curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check

tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz

sudo mv /tmp/eksctl /usr/local/bin

# Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform -y
terraform -version

echo "AWS CLI setup, kubectl, eksctl, and Terraform installation completed."

exit
