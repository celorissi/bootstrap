#!/usr/bin/env bash
set -e

echo "Instalando pré-requisitos do Docker..."
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg

echo "Adicionando repositório oficial do Docker..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y

echo "Instalando Docker Engine e Docker Compose..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Adicionando usuário atual ao grupo docker..."
sudo usermod -aG docker $USER

echo "Docker instalado! (Nota: reinicie a sessão para usar o Docker sem sudo)"