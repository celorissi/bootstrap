#!/usr/bin/env bash
set -e

echo "Atualizando pacotes e instalando Python e ferramentas de venv..."
sudo apt-get update -y
sudo apt-get install -y python3 python3-pip python3-venv python3-dev build-essential

echo "Criando um diretório padrão para ambientes virtuais (~/.venvs)..."
mkdir -p ~/.venvs

echo "Python e suporte a venv configurados com sucesso!"