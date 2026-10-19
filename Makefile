.PHONY: all docker terraform python git-config

all: git-config docker terraform python
	@echo "=== Bootstrap concluído com sucesso! ==="

git-config:
	@echo "--- Configurando Git ---"
	@bash modules/git.sh

docker:
	@echo "--- Configurando Docker ---"
	@bash modules/docker.sh

terraform:
	@echo "--- Instalando Terraform ---"
	@bash modules/terraform.sh

python:
	@echo "--- Configurando Python e Venv ---"
	@bash modules/python.sh