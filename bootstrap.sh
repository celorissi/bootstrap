#!/bin/bash

# Interrompe o script em caso de falha em qualquer comando
set -e

echo "=== [1/7] Configurando Hostname e Rede Estática (Netplan) ==="

# Define Hostname
HOSTNAME_ONLY="automation-local"
DOMAIN_NAME="local"
FULL_HOSTNAME="${HOSTNAME_ONLY}.${DOMAIN_NAME}"

hostnamectl set-hostname "$FULL_HOSTNAME"
echo "127.0.0.1 localhost" > /etc/hosts
echo "127.0.1.1 $FULL_HOSTNAME $HOSTNAME_ONLY" >> /etc/hosts

# Identifica a primeira interface física de rede (excluindo lo)
NET_INTERFACE=$(ip -o link show | awk -F': ' '$2 != "lo" {print $2}' | head -n 1)
echo "Interface de rede detectada: $NET_INTERFACE"

cat <<EOF > /etc/netplan/01-netcfg.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    $NET_INTERFACE:
      dhcp4: no
      addresses:
        - 192.168.0.202/24
      routes:
        - to: default
          via: 192.168.0.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 1.1.1.1
EOF

# Ajusta permissões restritas exigidas pelo Netplan
chmod 600 /etc/netplan/01-netcfg.yaml
echo "Aplicando configurações de rede..."
netplan apply || echo "⚠️ Aviso: Netplan aplicado com ressalvas, verifique a conectividade se necessário."


echo "=== [2/7] Atualizando o Sistema Base ==="
apt update && apt upgrade -y


echo "=== [3/7] Configurando Repositório e Instalando o Terraform (HashiCorp) ==="
apt install -y wget gnupg lsb-release
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
apt update
apt install -y terraform


echo "=== [4/7] Instalando Pacotes Essenciais, Python e Ansible ==="
apt install -y \
    curl \
    git \
    net-tools \
    iputils-ping \
    dnsutils \
    bind9-dnsutils \
    bc \
    jq \
    htop \
    tmux \
    unzip \
    ca-certificates \
    software-properties-common \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    ansible


echo "=== [5/7] Instalando Docker Engine ==="
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable --now docker


echo "=== [6/7] Instalando Ferramentas Kubernetes (Kubectl e Kind) ==="
# Kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# Kind
curl -SLo ./kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64
chmod +x ./kind
mv ./kind /usr/local/bin/kind


echo "=== [7/7] Ajustando Permissões e Grupo Docker ==="
# Adiciona os usuários locais comuns ao grupo docker
for user in marcelo ubuntu; do
    if id "$user" &>/dev/null; then
        usermod -aG docker "$user"
        echo "Usuário $user adicionado ao grupo docker."
    fi
done

apt autoremove -y
apt clean

echo ""
echo "────────────────────────────────────────────────────────────"
echo "🎉 BOOTSTRAP DE AUTOMAÇÃO CONCLUÍDO!"
echo "────────────────────────────────────────────────────────────"
echo "• Hostname: $(hostname)"
echo "• IP Estático: 192.168.0.202/24"
echo "• Stack Instalada:"
echo "  - Docker Engine & Docker Compose"
echo "  - Ansible & Terraform (HashiCorp oficial)"
echo "  - Python 3 (pip/venv)"
echo "  - Kubernetes CLI (kubectl & kind)"
echo "────────────────────────────────────────────────────────────"
echo "💡 DICA: Na primeira sessão do usuário, rode 'newgrp docker' ou"
echo "         reinicie a VM para aplicar o grupo Docker sem pedir sudo."
echo "────────────────────────────────────────────────────────────"
