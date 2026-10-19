#!/usr/bin/env bash
set -e

echo "Instalando dependências para o Terraform..."
sudo apt-get update -y && sudo apt-get install -y gnupg software-properties-common curl

echo "Adicionando chave GPG da HashiCorp..."
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

echo "Adicionando repositório oficial da HashiCorp..."
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

echo "Instalando Terraform..."
sudo apt-get update -y && sudo apt-get install -y terraform

echo "Terraform instalado com sucesso! Versão:"
terraform -version