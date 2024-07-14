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
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Habilitar e iniciar o serviço Kubelet
sudo systemctl enable kubelet
sudo systemctl start kubelet

# Desabilitar swap (requisito do Kubernetes)
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Inicializar Kubernetes no nó master, se necessário
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Aguardar a conclusão do kubeadm init
sleep 240

# Configurar kubeconfig local
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Aplicar o plugin Flannel CNI
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# Gerar comando de junção para nós de trabalho
sudo kubeadm token create --print-join-command > /joincluster.sh

# Tornar o script de junção executável
sudo chmod +x /joincluster.sh
