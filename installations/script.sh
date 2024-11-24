#!/bin/bash

# Detect system architecture
ARCH=$(uname -m)

if [ "$ARCH" == "x86_64" ]; then
    AWS_ARCH="x86_64"
    KUBECTL_ARCH="amd64"
    EKSCTL_ARCH="amd64"
elif [ "$ARCH" == "aarch64" ]; then
    AWS_ARCH="aarch64"
    KUBECTL_ARCH="arm64"
    EKSCTL_ARCH="arm64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# Install AWS CLI
sudo apt-get update -y
sudo apt install unzip -y

# Download the correct AWS CLI based on architecture
curl "https://awscli.amazonaws.com/awscli-exe-linux-$AWS_ARCH.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure AWS CLI
read -p "Enter your AWS Access Key ID: " aws_access_key_id
read -p "Enter your AWS Secret Access Key: " aws_secret_access_key
read -p "Enter your AWS Region: " aws_region

aws configure set aws_access_key_id "$aws_access_key_id"
aws configure set aws_secret_access_key "$aws_secret_access_key"
aws configure set default.region "$aws_region"
aws configure set default.output json

# Install latest kubectl binary (for eks v1.3+)
LATEST_KUBECTL_VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${LATEST_KUBECTL_VERSION}/bin/linux/$KUBECTL_ARCH/kubectl"
curl -LO "https://dl.k8s.io/release/${LATEST_KUBECTL_VERSION}/bin/linux/$KUBECTL_ARCH/kubectl.sha256"

# Verify the binary with sha256
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
# Set KUBE_CONFIG_PATH permanently across all sessions
echo 'export KUBE_CONFIG_PATH=~/.kube/config' >> ~/.bashrc
source ~/.bashrc

# Install eksctl
PLATFORM=$(uname -s)_$EKSCTL_ARCH

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