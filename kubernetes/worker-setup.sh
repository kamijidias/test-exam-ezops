#!/bin/bash
set -e

# Atualizar o índice de pacotes
sudo apt-get update

# Instalar Docker
sudo apt-get install -y docker.io

# Habilitar e iniciar o serviço Docker
sudo systemctl enable docker
sudo systemctl start docker

# Instalar componentes do Kubernetes
sudo apt-get install -y apt-transport-https curl gnupg2

# Criar o diretório para a keyring
sudo mkdir -p /etc/apt/keyrings

# Adicionar a keyring do Kubernetes
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Adicionar o repositório do Kubernetes
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Atualizar o índice de pacotes novamente
sudo apt-get update

# Instalar kubelet, kubeadm e kubectl
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Desabilitar swap (requisito do Kubernetes)
sudo swapoff -a

# Executar o comando de junção para o nó de trabalho
sudo bash /joincluster.sh