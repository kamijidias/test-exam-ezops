#!/bin/bash
set -e

# Atualizando o índice de pacotes
sudo apt-get update

# Instalando o Docker
sudo apt-get install -y docker.io

# Habilitando e iniciando o serviço Docker
sudo systemctl enable docker
sudo systemctl start docker

# Instalando os componentes do Kubernetes
sudo apt-get install -y apt-transport-https curl gnupg2
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Habilitando e iniciando o serviço Kubelet
sudo systemctl enable kubelet
sudo systemctl start kubelet

# Desativando a swap (requerido pelo Kubernetes)
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Inicializando o Kubernetes no nó mestre, se necessário
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Aguardando a conclusão do kubeadm init
sleep 240

# Configurando o kubeconfig local
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Aplicando o plugin CNI Flannel
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# Gerando o comando de junção para os nós de trabalho
sudo kubeadm token create --print-join-command > /joincluster.sh

# Tornando o script de junção executável
sudo chmod +x /joincluster.sh