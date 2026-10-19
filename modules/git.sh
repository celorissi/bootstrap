#!/usr/bin/env bash
set -e

echo "Configurando credenciais globais do Git..."
# Substitua pelos seus dados reais ou deixe parametrizado
git config --global user.name "celo.rissi"
git config --global user.email "celo.rissi@gmail.com"
git config --global init.defaultBranch main
git config --global pull.rebase false

echo "Git configurado com sucesso!"