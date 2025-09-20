# Makefile para gerenciar o ambiente BigData
# Uso: make <comando>

.PHONY: help start stop restart status clean logs build install check health test backup restore

# Carregar variáveis do .env se existir, mas permitir override
ifneq ($(wildcard .env),)
    include .env
    export
endif

# Definir variáveis padrão se não definidas (podem ser sobrescritas na linha de comando)
SERVER_IP ?= localhost
AIRFLOW_PORT ?= 8080
SPARK_UI_PORT ?= 8081
MINIO_CONSOLE_PORT ?= 9001
JENKINS_PORT ?= 8082
JUPYTER_PORT ?= 8888
FLOWER_PORT ?= 5555

# Variáveis
COMPOSE_FILE = docker-compose.yml
PROJECT_NAME = bigdata
SERVICES = postgres redis minio airflow-webserver airflow-scheduler airflow-worker spark-master spark-worker-1 spark-worker-2 jupyter jenkins

# Cores para output
GREEN = \033[0;32m
YELLOW = \033[1;33m
RED = \033[0;31m
BLUE = \033[0;34m
NC = \033[0m # No Color

# Verifica se arquivo .env existe
.PHONY: check-env
check-env:
	@if [ ! -f .env ]; then \
		echo "$(RED)⚠️ Arquivo .env não encontrado!$(NC)"; \
		echo "$(YELLOW)📝 Configure as variáveis de ambiente:$(NC)"; \
		echo "   cp env.example .env"; \
		echo "   nano .env"; \
		echo ""; \
		echo "$(BLUE)💡 Edite o IP do servidor e senhas no arquivo .env$(NC)"; \
		exit 1; \
	fi

# Target padrão
.DEFAULT_GOAL := help

## 📋 Comandos Principais

lab: check-env ## 🧪 Inicia ambiente de laboratório (recursos mínimos)
	@echo "$(BLUE)🧪 Iniciando ambiente de laboratório...$(NC)"
	@echo "$(YELLOW)💾 Recursos otimizados: ~6GB RAM, 4 CPUs$(NC)"
	@if groups | grep -q docker; then \
		docker-compose -f docker-compose.lab.yml up -d; \
	else \
		echo "$(YELLOW)⚠️  Usuário não está no grupo docker. Usando sudo...$(NC)"; \
		sudo docker-compose -f docker-compose.lab.yml up -d; \
	fi
	@echo "$(GREEN)✅ Ambiente de laboratório iniciado!$(NC)"
	@echo "$(BLUE)🌐 Acesse:$(NC)"
	@if [ -f .env ]; then \
		. ./.env; \
		echo "  • Airflow:  http://$${SERVER_IP:-localhost}:$${AIRFLOW_PORT:-8080} (admin/admin)"; \
		echo "  • Spark UI: http://$${SERVER_IP:-localhost}:$${SPARK_UI_PORT:-8081}"; \
		echo "  • MinIO:    http://$${SERVER_IP:-localhost}:$${MINIO_CONSOLE_PORT:-9001} (minioadmin/minioadmin123)"; \
		echo "  • Jupyter:  http://$${SERVER_IP:-localhost}:$${JUPYTER_PORT:-8888}"; \
	else \
		echo "  • Airflow:  http://localhost:8080 (admin/admin)"; \
		echo "  • Spark UI: http://localhost:8081"; \
		echo "  • MinIO:    http://localhost:9001 (minioadmin/minioadmin123)"; \
		echo "  • Jupyter:  http://localhost:8888"; \
	fi

stop-lab: ## 🛑 Para ambiente de laboratório
	@echo "$(YELLOW)🛑 Parando ambiente de laboratório...$(NC)"
	@if groups | grep -q docker; then \
		docker-compose -f docker-compose.lab.yml down; \
	else \
		sudo docker-compose -f docker-compose.lab.yml down; \
	fi

minimal: check-env ## 🔬 Ambiente mínimo (4GB RAM, 2 CPUs)
	@echo "$(BLUE)🔬 Iniciando ambiente mínimo...$(NC)"
	@echo "$(YELLOW)💾 Ultra otimizado: ~4GB RAM, 2 CPUs$(NC)"
	@if groups | grep -q docker; then \
		docker-compose -f docker-compose.minimal.yml up -d; \
	else \
		sudo docker-compose -f docker-compose.minimal.yml up -d; \
	fi
	@echo "$(GREEN)✅ Ambiente mínimo iniciado!$(NC)"
	@echo "$(BLUE)🌐 Acesse:$(NC)"
	@if [ -f .env ]; then \
		. ./.env; \
		echo "  • Airflow:  http://$${SERVER_IP:-localhost}:$${AIRFLOW_PORT:-8080} (admin/admin)"; \
		echo "  • Jupyter:  http://$${SERVER_IP:-localhost}:$${JUPYTER_PORT:-8888}"; \
		echo "  • MinIO:    http://$${SERVER_IP:-localhost}:$${MINIO_CONSOLE_PORT:-9001} (minioadmin/minioadmin123)"; \
		echo "  • Spark UI: http://$${SERVER_IP:-localhost}:4040 (via Jupyter)"; \
	else \
		echo "  • Airflow:  http://localhost:8080 (admin/admin)"; \
		echo "  • Jupyter:  http://localhost:8888"; \
		echo "  • MinIO:    http://localhost:9001 (minioadmin/minioadmin123)"; \
		echo "  • Spark UI: http://localhost:4040 (via Jupyter)"; \
	fi

stop-minimal: ## 🛑 Para ambiente mínimo
	@echo "$(YELLOW)🛑 Parando ambiente mínimo...$(NC)"
	@if groups | grep -q docker; then \
		docker-compose -f docker-compose.minimal.yml down; \
	else \
		sudo docker-compose -f docker-compose.minimal.yml down; \
	fi

stop-all: ## 🛑 Para TODOS os containers (todos os ambientes)
	@echo "$(RED)🛑 Parando TODOS os containers BigData...$(NC)"
	@echo "$(YELLOW)📦 Parando ambiente completo...$(NC)"
	@if groups | grep -q docker; then \
		docker-compose down 2>/dev/null || true; \
	else \
		sudo docker-compose down 2>/dev/null || true; \
	fi
	@echo "$(YELLOW)🧪 Parando ambiente lab...$(NC)"
	@if groups | grep -q docker; then \
		docker-compose -f docker-compose.lab.yml down 2>/dev/null || true; \
	else \
		sudo docker-compose -f docker-compose.lab.yml down 2>/dev/null || true; \
	fi
	@echo "$(YELLOW)🔬 Parando ambiente minimal...$(NC)"
	@if groups | grep -q docker; then \
		docker-compose -f docker-compose.minimal.yml down 2>/dev/null || true; \
	else \
		sudo docker-compose -f docker-compose.minimal.yml down 2>/dev/null || true; \
	fi
	@echo "$(YELLOW)🧹 Removendo containers órfãos...$(NC)"
	@if groups | grep -q docker; then \
		docker container prune -f 2>/dev/null || true; \
	else \
		sudo docker container prune -f 2>/dev/null || true; \
	fi
	@echo "$(GREEN)✅ Todos os containers BigData foram parados!$(NC)"

help: ## 📖 Mostra esta ajuda
	@echo "$(BLUE)🚀 Ambiente BigData - Comandos Disponíveis$(NC)"
	@echo "================================================"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "$(GREEN)%-15s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(YELLOW)💡 Comandos essenciais:$(NC)"
	@echo "  make pre-check # Verificação rápida dos requisitos"
	@echo "  make check     # Verificação completa do servidor"
	@echo "  make start     # Inicia todo o ambiente"
	@echo "  make status    # Verifica status dos serviços"
	@echo "  make logs      # Mostra logs de todos os serviços"
	@echo "  make stop      # Para o ambiente"

start: check-env ## 🚀 Inicia todo o ambiente BigData
	@echo "$(BLUE)🚀 Iniciando ambiente BigData...$(NC)"
	@if groups | grep -q docker; then \
		./scripts/start.sh; \
	else \
		echo "$(YELLOW)⚠️  Usuário não está no grupo docker. Usando sudo temporariamente...$(NC)"; \
		echo "$(YELLOW)💡 Para evitar usar sudo, faça logout/login após a instalação do Docker$(NC)"; \
		sudo ./scripts/start.sh; \
	fi

stop: ## 🛑 Para todos os serviços
	@echo "$(YELLOW)🛑 Parando ambiente BigData...$(NC)"
	@./scripts/stop.sh

restart: ## 🔄 Reinicia todo o ambiente
	@echo "$(YELLOW)🔄 Reiniciando ambiente BigData...$(NC)"
	@make stop
	@sleep 5
	@make start

status: ## 📊 Verifica status dos serviços
	@./scripts/status.sh

ps-all: ## 📋 Lista containers de TODOS os ambientes
	@echo "$(BLUE)📋 Containers de todos os ambientes BigData:$(NC)"
	@echo "$(YELLOW)🏭 Ambiente Completo:$(NC)"
	@if groups | grep -q docker; then \
		docker-compose ps 2>/dev/null || echo "  Nenhum container rodando"; \
	else \
		sudo docker-compose ps 2>/dev/null || echo "  Nenhum container rodando"; \
	fi
	@echo ""
	@echo "$(YELLOW)🧪 Ambiente Lab:$(NC)"
	@if groups | grep -q docker; then \
		docker-compose -f docker-compose.lab.yml ps 2>/dev/null || echo "  Nenhum container rodando"; \
	else \
		sudo docker-compose -f docker-compose.lab.yml ps 2>/dev/null || echo "  Nenhum container rodando"; \
	fi
	@echo ""
	@echo "$(YELLOW)🔬 Ambiente Minimal:$(NC)"
	@if groups | grep -q docker; then \
		docker-compose -f docker-compose.minimal.yml ps 2>/dev/null || echo "  Nenhum container rodando"; \
	else \
		sudo docker-compose -f docker-compose.minimal.yml ps 2>/dev/null || echo "  Nenhum container rodando"; \
	fi

## 🔧 Comandos de Desenvolvimento

build: ## 🏗️ Build das imagens customizadas
	@echo "$(BLUE)🏗️ Building imagens customizadas...$(NC)"
	@docker-compose build --no-cache jenkins

pull: ## ⬇️ Atualiza todas as imagens
	@echo "$(BLUE)⬇️ Atualizando imagens...$(NC)"
	@docker-compose pull

rebuild: ## 🔨 Rebuild completo (pull + build)
	@make pull
	@make build

## 📊 Monitoramento e Logs

logs: ## 📋 Mostra logs de todos os serviços
	@if groups | grep -q docker; then \
		docker-compose logs -f; \
	else \
		sudo docker-compose logs -f; \
	fi

logs-airflow: ## 📋 Logs específicos do Airflow
	@if groups | grep -q docker; then \
		docker-compose logs -f airflow-webserver airflow-scheduler airflow-worker; \
	else \
		sudo docker-compose logs -f airflow-webserver airflow-scheduler airflow-worker; \
	fi

logs-spark: ## 📋 Logs específicos do Spark
	@if groups | grep -q docker; then \
		docker-compose logs -f spark-master spark-worker-1 spark-worker-2; \
	else \
		sudo docker-compose logs -f spark-master spark-worker-1 spark-worker-2; \
	fi

ps: ## 📋 Lista containers em execução
	@if groups | grep -q docker; then \
		docker-compose ps; \
	else \
		sudo docker-compose ps; \
	fi

top: ## 📊 Mostra uso de recursos
	@if groups | grep -q docker; then \
		docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"; \
	else \
		sudo docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"; \
	fi

## 🔍 Comandos de Diagnóstico

health: ## 🏥 Verifica saúde dos serviços
	@echo "$(BLUE)🏥 Verificando saúde dos serviços...$(NC)"
	@for service in $(SERVICES); do \
		echo -n "$$service: "; \
		if groups | grep -q docker; then \
			if docker-compose ps $$service | grep -q "Up"; then \
				echo "$(GREEN)✅ Running$(NC)"; \
			else \
				echo "$(RED)❌ Down$(NC)"; \
			fi; \
		else \
			if sudo docker-compose ps $$service | grep -q "Up"; then \
				echo "$(GREEN)✅ Running$(NC)"; \
			else \
				echo "$(RED)❌ Down$(NC)"; \
			fi; \
		fi; \
	done

check: ## 🔍 Verifica se o servidor está pronto para rodar o projeto
	@echo "$(BLUE)🔍 Verificando se o servidor está pronto...$(NC)"
	@echo "================================================"
	
	@echo "$(BLUE)� 1. Verificando dependências...$(NC)"
	@if command -v docker >/dev/null 2>&1; then \
		echo "$(GREEN)✅ Docker encontrado: $$(docker --version)$(NC)"; \
	else \
		echo "$(RED)❌ Docker não encontrado. Instale com: curl -fsSL https://get.docker.com | sh$(NC)"; \
		exit 1; \
	fi
	@if command -v docker-compose >/dev/null 2>&1; then \
		echo "$(GREEN)✅ Docker Compose encontrado: $$(docker-compose --version)$(NC)"; \
	else \
		echo "$(RED)❌ Docker Compose não encontrado. Instale seguindo: https://docs.docker.com/compose/install/$(NC)"; \
		exit 1; \
	fi
	
	@echo "$(BLUE)💾 2. Verificando recursos do sistema...$(NC)"
	@TOTAL_RAM=$$(free -m | awk 'NR==2{print $$2}'); \
	echo "  • RAM Total: $${TOTAL_RAM}MB"; \
	if [ $$TOTAL_RAM -lt 3000 ]; then \
		echo "$(RED)⚠️  RAM insuficiente (mínimo 3GB). Atual: $${TOTAL_RAM}MB$(NC)"; \
	elif [ $$TOTAL_RAM -lt 6000 ]; then \
		echo "$(YELLOW)💡 RAM adequada para ambiente mínimo. Use: make minimal$(NC)"; \
	elif [ $$TOTAL_RAM -lt 10000 ]; then \
		echo "$(YELLOW)💡 RAM adequada para ambiente lab. Use: make lab$(NC)"; \
	else \
		echo "$(GREEN)✅ RAM suficiente para ambiente completo$(NC)"; \
	fi
	
	@CPU_CORES=$$(nproc); \
	echo "  • CPU Cores: $${CPU_CORES}"; \
	if [ $$CPU_CORES -lt 2 ]; then \
		echo "$(RED)⚠️  CPU insuficiente (mínimo 2 cores)$(NC)"; \
	elif [ $$CPU_CORES -lt 4 ]; then \
		echo "$(YELLOW)💡 CPU adequada para ambiente mínimo$(NC)"; \
	else \
		echo "$(GREEN)✅ CPU adequada$(NC)"; \
	fi
	
	@DISK_FREE=$$(df -h . | awk 'NR==2{print $$4}' | sed 's/G//'); \
	echo "  • Espaço em Disco: $${DISK_FREE}GB disponível"; \
	if [ "$$(echo "$$DISK_FREE < 5" | bc -l 2>/dev/null || echo 0)" = "1" ]; then \
		echo "$(RED)⚠️  Espaço insuficiente (mínimo 5GB)$(NC)"; \
	else \
		echo "$(GREEN)✅ Espaço em disco adequado$(NC)"; \
	fi
	
	@echo "$(BLUE)� 3. Verificando configuração...$(NC)"
	@if [ -f .env ]; then \
		echo "$(GREEN)✅ Arquivo .env encontrado$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  Arquivo .env não encontrado. Execute: cp .env.example .env$(NC)"; \
	fi
	
	@if command -v docker-compose >/dev/null 2>&1; then \
		if docker-compose config >/dev/null 2>&1; then \
			echo "$(GREEN)✅ docker-compose.yml válido$(NC)"; \
		else \
			echo "$(RED)❌ docker-compose.yml inválido$(NC)"; \
			exit 1; \
		fi; \
	fi
	
	@echo "$(BLUE)🐳 4. Verificando Docker...$(NC)"
	@if docker info >/dev/null 2>&1; then \
		echo "$(GREEN)✅ Docker daemon rodando$(NC)"; \
	else \
		echo "$(RED)❌ Docker daemon não está rodando. Inicie com: sudo systemctl start docker$(NC)"; \
		exit 1; \
	fi
	
	@echo ""
	@if [ -f .env ]; then \
		echo "$(GREEN)🎉 Servidor está pronto para rodar o projeto!$(NC)"; \
		echo "$(BLUE)💡 Comandos recomendados:$(NC)"; \
		TOTAL_RAM=$$(free -m | awk 'NR==2{print $$2}'); \
		if [ $$TOTAL_RAM -lt 6000 ]; then \
			echo "  • make minimal    (para seu hardware)"; \
		elif [ $$TOTAL_RAM -lt 10000 ]; then \
			echo "  • make lab        (recomendado para seu hardware)"; \
		else \
			echo "  • make start      (ambiente completo)"; \
		fi; \
	else \
		echo "$(YELLOW)📋 Próximos passos para finalizar a configuração:$(NC)"; \
		echo "  1. cp .env.example .env"; \
		echo "  2. nano .env  # Edite as configurações"; \
		echo "  3. make check  # Verifique novamente"; \
		echo "  4. make minimal/lab/start  # Inicie o ambiente"; \
	fi

pre-check: ## ⚡ Verificação rápida dos requisitos mínimos
	@echo "$(BLUE)⚡ Verificação rápida...$(NC)"
	@command -v docker >/dev/null 2>&1 && echo "$(GREEN)✅ Docker$(NC)" || echo "$(RED)❌ Docker$(NC)"
	@command -v docker-compose >/dev/null 2>&1 && echo "$(GREEN)✅ Docker Compose$(NC)" || echo "$(RED)❌ Docker Compose$(NC)"
	@[ -f .env ] && echo "$(GREEN)✅ .env$(NC)" || echo "$(YELLOW)⚠️  .env (execute: cp .env.example .env)$(NC)"
	@TOTAL_RAM=$$(free -m | awk 'NR==2{print $$2}'); \
	if [ $$TOTAL_RAM -ge 3000 ]; then \
		echo "$(GREEN)✅ RAM: $${TOTAL_RAM}MB$(NC)"; \
	else \
		echo "$(RED)❌ RAM: $${TOTAL_RAM}MB (mínimo 3GB)$(NC)"; \
	fi
	@docker info >/dev/null 2>&1 && echo "$(GREEN)✅ Docker rodando$(NC)" || echo "$(RED)❌ Docker parado$(NC)"

## 🧪 Comandos de Teste

test: ## 🧪 Executa testes de integração
	@echo "$(BLUE)🧪 Executando testes de integração...$(NC)"
	@make test-minio
	@make test-spark
	@make test-airflow

test-minio: ## 🧪 Testa conexão com MinIO
	@echo "$(YELLOW)Testando MinIO...$(NC)"
	@docker-compose exec -T minio mc ls myminio/ >/dev/null 2>&1 && \
		echo "$(GREEN)✅ MinIO OK$(NC)" || \
		echo "$(RED)❌ MinIO falha$(NC)"

test-spark: ## 🧪 Testa cluster Spark
	@echo "$(YELLOW)Testando Spark...$(NC)"
	@docker-compose exec -T spark-master spark-submit --version >/dev/null 2>&1 && \
		echo "$(GREEN)✅ Spark OK$(NC)" || \
		echo "$(RED)❌ Spark falha$(NC)"

test-airflow: ## 🧪 Testa Airflow
	@echo "$(YELLOW)Testando Airflow...$(NC)"
	@if [ -f .env ]; then \
		. ./.env; \
		curl -s "http://$${SERVER_IP:-localhost}:$${AIRFLOW_PORT:-8080}/health" >/dev/null 2>&1 && \
			echo "$(GREEN)✅ Airflow OK$(NC)" || \
			echo "$(RED)❌ Airflow falha$(NC)"; \
	else \
		curl -s "http://localhost:8080/health" >/dev/null 2>&1 && \
			echo "$(GREEN)✅ Airflow OK$(NC)" || \
			echo "$(RED)❌ Airflow falha$(NC)"; \
	fi

## 🗂️ Comandos de Dados

backup: ## 💾 Backup dos dados
	@echo "$(BLUE)💾 Criando backup...$(NC)"
	@mkdir -p backups/$(shell date +%Y%m%d_%H%M%S)
	@docker-compose exec -T postgres pg_dump -U airflow airflow > backups/$(shell date +%Y%m%d_%H%M%S)/airflow_db.sql
	@echo "$(GREEN)✅ Backup criado em backups/$(shell date +%Y%m%d_%H%M%S)/$(NC)"

clean: ## 🧹 Remove containers e volumes (CUIDADO!)
	@echo "$(RED)⚠️  ATENÇÃO: Isso removerá TODOS os dados!$(NC)"
	@read -p "Tem certeza? [y/N]: " -n 1 -r; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo "\n$(YELLOW)🧹 Limpando ambiente...$(NC)"; \
		./scripts/stop.sh --clean; \
	else \
		echo "\n$(GREEN)✅ Operação cancelada$(NC)"; \
	fi

clean-images: ## 🧹 Remove imagens não utilizadas
	@echo "$(YELLOW)🧹 Removendo imagens não utilizadas...$(NC)"
	@docker system prune -f
	@docker image prune -f

## 🔧 Comandos Específicos de Serviços

airflow-shell: ## 🐚 Acessa shell do Airflow
	@docker-compose exec airflow-webserver bash

jupyter-shell: ## 🐚 Acessa shell do Jupyter
	@docker-compose exec jupyter bash

jenkins-shell: ## 🐚 Acessa shell do Jenkins
	@docker-compose exec jenkins bash

minio-shell: ## 🐚 Acessa shell do MinIO
	@docker-compose exec minio bash

## 📦 Comandos de Deploy

install-docker: ## 🐳 Instala Docker e Docker Compose
	@echo "$(BLUE)🐳 Instalando Docker...$(NC)"
	@if command -v docker >/dev/null 2>&1; then \
		echo "$(GREEN)✅ Docker já está instalado$(NC)"; \
	else \
		echo "$(YELLOW)📦 Instalando Docker...$(NC)"; \
		curl -fsSL https://get.docker.com | sh; \
		sudo usermod -aG docker $$USER; \
		echo "$(GREEN)✅ Docker instalado! Faça logout/login para usar sem sudo$(NC)"; \
	fi
	@if command -v docker-compose >/dev/null 2>&1; then \
		echo "$(GREEN)✅ Docker Compose já está instalado$(NC)"; \
	else \
		echo "$(YELLOW)📦 Instalando Docker Compose...$(NC)"; \
		sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$$(uname -s)-$$(uname -m)" -o /usr/local/bin/docker-compose; \
		sudo chmod +x /usr/local/bin/docker-compose; \
		echo "$(GREEN)✅ Docker Compose instalado!$(NC)"; \
	fi

submit-spark: ## ⚡ Submete job Spark de exemplo
	@echo "$(BLUE)⚡ Submetendo job Spark...$(NC)"
	@docker-compose exec spark-master spark-submit \
		--master $${SPARK_MASTER_URL:-spark://spark-master:7077} \
		--executor-memory 1g \
		--executor-cores 1 \
		$${SPARK_APPS_PATH:-/opt/bitnami/spark/apps}/example_spark_minio.py

spark-shell: ## ⚡ Abre Spark shell interativo
	@echo "$(BLUE)⚡ Abrindo Spark shell...$(NC)"
	@docker-compose exec spark-master spark-shell \
		--master $${SPARK_MASTER_URL:-spark://spark-master:7077}

install-deps: ## 📦 Instala dependências adicionais
	@echo "$(BLUE)📦 Instalando dependências adicionais...$(NC)"
	@docker-compose exec airflow-webserver pip install -r /opt/airflow/requirements.txt

## 🌐 Comandos de Rede

get-ip: ## 🌐 Descobre o IP do servidor automaticamente
	@echo "$(BLUE)🌐 Descobrindo IP do servidor...$(NC)"
	@echo "$(YELLOW)📍 IPs disponíveis:$(NC)"
	@echo ""
	@echo "$(GREEN)1. IP Local (localhost):$(NC)"
	@echo "   127.0.0.1"
	@echo ""
	@echo "$(GREEN)2. IP da Interface Principal:$(NC)"
	@MAIN_IP=$$(ip route get 8.8.8.8 2>/dev/null | awk '{print $$7; exit}' || hostname -I | awk '{print $$1}'); \
	echo "   $$MAIN_IP"
	@echo ""
	@echo "$(GREEN)3. Todos os IPs de Rede:$(NC)"
	@ip addr show 2>/dev/null | grep -E 'inet [0-9]' | grep -v '127.0.0.1' | awk '{print "   " $$2}' | cut -d'/' -f1 || \
	ifconfig 2>/dev/null | grep -E 'inet [0-9]' | grep -v '127.0.0.1' | awk '{print "   " $$2}' || \
	echo "   Comando ip/ifconfig não disponível"
	@echo ""
	@echo "$(BLUE)💡 Para configurar no .env:$(NC)"
	@MAIN_IP=$$(ip route get 8.8.8.8 2>/dev/null | awk '{print $$7; exit}' || hostname -I | awk '{print $$1}'); \
	echo "   SERVER_IP=$$MAIN_IP"
	@echo ""
	@echo "$(YELLOW)⚙️  Comandos úteis:$(NC)"
	@echo "   make set-ip IP=SEU_IP_AQUI  # Configura IP automaticamente"

set-ip: ## 🌐 Configura IP no arquivo .env (uso: make set-ip IP=192.168.1.22)
	@if [ -z "$(IP)" ]; then \
		echo "$(RED)❌ Erro: IP não fornecido$(NC)"; \
		echo "$(YELLOW)💡 Uso: make set-ip IP=192.168.1.22$(NC)"; \
		exit 1; \
	fi
	@if [ ! -f .env ]; then \
		echo "$(YELLOW)📝 Criando arquivo .env...$(NC)"; \
		cp .env.example .env; \
	fi
	@echo "$(BLUE)⚙️  Configurando SERVER_IP=$(IP)...$(NC)"
	@sed -i 's/SERVER_IP=.*/SERVER_IP=$(IP)/' .env
	@echo "$(GREEN)✅ IP configurado com sucesso!$(NC)"
	@echo "$(BLUE)💡 Verificar: make ports$(NC)"

auto-ip: ## 🌐 Detecta e configura IP automaticamente
	@echo "$(BLUE)🔍 Detectando IP automaticamente...$(NC)"
	@AUTO_IP=$$(ip route get 8.8.8.8 2>/dev/null | awk '{print $$7; exit}' || hostname -I | awk '{print $$1}'); \
	if [ -n "$$AUTO_IP" ]; then \
		echo "$(GREEN)✅ IP detectado: $$AUTO_IP$(NC)"; \
		echo "$(BLUE)⚙️  Configurando SERVER_IP=$$AUTO_IP...$(NC)"; \
		if [ ! -f .env ]; then \
			echo "$(YELLOW)📝 Criando arquivo .env...$(NC)"; \
			cp .env.example .env; \
		fi; \
		sed -i "s/SERVER_IP=.*/SERVER_IP=$$AUTO_IP/" .env; \
		echo "$(GREEN)✅ IP configurado com sucesso!$(NC)"; \
		echo "$(BLUE)💡 Verificar: make ports$(NC)"; \
	else \
		echo "$(RED)❌ Não foi possível detectar IP automaticamente$(NC)"; \
		echo "$(YELLOW)💡 Use: make get-ip para ver IPs disponíveis$(NC)"; \
		echo "$(YELLOW)💡 Use: make set-ip IP=SEU_IP$(NC)"; \
	fi

ports: ## 🌐 Lista portas utilizadas
	@echo "$(BLUE)🌐 Portas utilizadas pelo ambiente:$(NC)"
	@echo "  • Airflow:     http://$(SERVER_IP):$(AIRFLOW_PORT)"
	@echo "  • Spark UI:    http://$(SERVER_IP):$(SPARK_UI_PORT)" 
	@echo "  • MinIO:       http://$(SERVER_IP):$(MINIO_CONSOLE_PORT)"
	@echo "  • Jenkins:     http://$(SERVER_IP):$(JENKINS_PORT)"
	@echo "  • Jupyter:     http://$(SERVER_IP):$(JUPYTER_PORT)"
	@echo "  • Flower:      http://$(SERVER_IP):$(FLOWER_PORT)"

open: ## 🌐 Abre todas as interfaces web
	@echo "$(BLUE)🌐 Abrindo interfaces web...$(NC)"
	@if [ -f .env ]; then \
		. ./.env; \
		command -v xdg-open >/dev/null 2>&1 && { \
			xdg-open "http://$${SERVER_IP:-localhost}:$${AIRFLOW_PORT:-8080}" & \
			xdg-open "http://$${SERVER_IP:-localhost}:$${SPARK_UI_PORT:-8081}" & \
			xdg-open "http://$${SERVER_IP:-localhost}:$${MINIO_CONSOLE_PORT:-9001}" & \
			xdg-open "http://$${SERVER_IP:-localhost}:$${JENKINS_PORT:-8082}" & \
			xdg-open "http://$${SERVER_IP:-localhost}:$${JUPYTER_PORT:-8888}" & \
			echo "$(GREEN)✅ Interfaces abertas no navegador$(NC)"; \
		} || echo "$(YELLOW)⚠️  xdg-open não disponível. Abra manualmente as URLs listadas em 'make ports'$(NC)"; \
	else \
		command -v xdg-open >/dev/null 2>&1 && { \
			xdg-open "http://localhost:8080" & \
			xdg-open "http://localhost:8081" & \
			xdg-open "http://localhost:9001" & \
			xdg-open "http://localhost:8082" & \
			xdg-open "http://localhost:8888" & \
			echo "$(GREEN)✅ Interfaces abertas no navegador$(NC)"; \
		} || echo "$(YELLOW)⚠️  xdg-open não disponível. Abra manualmente as URLs listadas em 'make ports'$(NC)"; \
	fi

##  Comandos de Informação

info: ## ℹ️ Informações do ambiente
	@echo "$(BLUE)ℹ️  Informações do Ambiente BigData$(NC)"
	@echo "================================================"
	@echo "Projeto: $(PROJECT_NAME)"
	@echo "Compose File: $(COMPOSE_FILE)"
	@echo "Services: $(words $(SERVICES)) serviços"
	@echo ""
	@echo "$(YELLOW)💾 Uso de disco:$(NC)"
	@df -h . | tail -1
	@echo ""
	@echo "$(YELLOW)🐳 Containers:$(NC)"
	@if groups | grep -q docker; then \
		docker-compose ps --format "table {{.Name}}\t{{.State}}\t{{.Ports}}" 2>/dev/null || echo "Nenhum container em execução"; \
	else \
		sudo docker-compose ps --format "table {{.Name}}\t{{.State}}\t{{.Ports}}" 2>/dev/null || echo "Nenhum container em execução"; \
	fi

version: ## 📋 Versões dos componentes
	@echo "$(BLUE)📋 Versões dos Componentes$(NC)"
	@echo "================================================"
	@echo "Docker: $$(docker --version)"
	@echo "Docker Compose: $$(docker-compose --version)"
	@echo ""
	@echo "$(YELLOW)Versões dos Serviços:$(NC)"
	@echo "Airflow: $$(docker-compose exec -T airflow-webserver airflow version 2>/dev/null || echo 'N/A')"
	@echo "Spark: $$(docker-compose exec -T spark-master spark-submit --version 2>&1 | head -1 || echo 'N/A')"
	@echo "PostgreSQL: $$(docker-compose exec -T postgres psql --version 2>/dev/null || echo 'N/A')"

## 🏃‍♂️ Comandos Rápidos

quick-start: check ## ⚡ Start rápido (com verificações)
	@make start

dev: ## 👨‍💻 Modo desenvolvedor (com logs)
	@make start
	@make logs

prod: ## 🏭 Modo produção (em background)
	@make start
	@echo "$(GREEN)✅ Ambiente iniciado em modo produção$(NC)"
	@echo "$(BLUE)💡 Use 'make status' para verificar os serviços$(NC)"

requirements: ## 📋 Mostra requisitos de sistema
	@echo "$(BLUE)📋 Requisitos de Sistema$(NC)"
	@echo "================================================"
	@echo "$(YELLOW)🏭 Ambiente Completo (Produção):$(NC)"
	@echo "  • RAM: 10-12GB"
	@echo "  • CPU: 6-8 cores"
	@echo "  • Disk: 20GB"
	@echo "  • Serviços: Todos (Airflow + Spark + MinIO + Jenkins + Jupyter)"
	@echo ""
	@echo "$(YELLOW)🔬 Ambiente Mínimo (4GB):$(NC)"
	@echo "  • RAM: 3-4GB"
	@echo "  • CPU: 2 cores"
	@echo "  • Disk: 5-8GB"
	@echo "  • Serviços: Airflow Standalone + Jupyter/Spark Local + MinIO"
	@echo ""
	@echo "$(YELLOW)🧪 Ambiente Laboratório:$(NC)"
	@echo "  • RAM: 6-8GB"
	@echo "  • CPU: 4 cores"
	@echo "  • Disk: 10-15GB"
	@echo "  • Serviços: Airflow + Spark + MinIO + Jupyter (sem Jenkins)"
	@echo ""
	@echo "$(GREEN)💡 Recomendação:$(NC)"
	@echo "  • Para máquinas fracas: make minimal"
	@echo "  • Para aprendizado: make lab"
	@echo "  • Para desenvolvimento: make start"
	@echo "  • Para produção: make prod"

## 🎯 Comandos Específicos por Serviço

# PostgreSQL
start-postgres: ## 🐘 Inicia apenas PostgreSQL
	@echo "$(BLUE)🐘 Iniciando PostgreSQL...$(NC)"
	@docker-compose up -d postgres
	@sleep 3
	@make health-postgres

stop-postgres: ## 🐘 Para PostgreSQL
	@echo "$(BLUE)🐘 Parando PostgreSQL...$(NC)"
	@docker-compose stop postgres

restart-postgres: ## 🐘 Reinicia PostgreSQL
	@echo "$(BLUE)🐘 Reiniciando PostgreSQL...$(NC)"
	@make stop-postgres
	@sleep 2
	@make start-postgres

logs-postgres: ## 🐘 Logs do PostgreSQL
	@echo "$(BLUE)🐘 Logs do PostgreSQL:$(NC)"
	@docker-compose logs -f postgres

shell-postgres: ## 🐘 Shell no PostgreSQL
	@echo "$(BLUE)🐘 Conectando ao PostgreSQL...$(NC)"
	@docker-compose exec postgres psql -U airflow -d airflow

health-postgres: ## 🐘 Verifica saúde do PostgreSQL
	@echo -n "$(BLUE)🐘 PostgreSQL: $(NC)"
	@if docker-compose ps postgres 2>/dev/null | grep -q "Up"; then \
		if docker-compose exec -T postgres pg_isready -U airflow >/dev/null 2>&1; then \
			echo "$(GREEN)✅ Healthy$(NC)"; \
		else \
			echo "$(YELLOW)⚠️  Starting$(NC)"; \
		fi; \
	else \
		echo "$(RED)❌ Down$(NC)"; \
	fi

# Redis
start-redis: ## 📮 Inicia apenas Redis
	@echo "$(BLUE)📮 Iniciando Redis...$(NC)"
	@docker-compose up -d redis
	@sleep 2
	@make health-redis

stop-redis: ## 📮 Para Redis
	@echo "$(BLUE)📮 Parando Redis...$(NC)"
	@docker-compose stop redis

restart-redis: ## 📮 Reinicia Redis
	@echo "$(BLUE)📮 Reiniciando Redis...$(NC)"
	@make stop-redis
	@sleep 2
	@make start-redis

logs-redis: ## 📮 Logs do Redis
	@echo "$(BLUE)📮 Logs do Redis:$(NC)"
	@docker-compose logs -f redis

shell-redis: ## 📮 Shell no Redis
	@echo "$(BLUE)📮 Conectando ao Redis...$(NC)"
	@docker-compose exec redis redis-cli

health-redis: ## 📮 Verifica saúde do Redis
	@echo -n "$(BLUE)📮 Redis: $(NC)"
	@if docker-compose ps redis 2>/dev/null | grep -q "Up"; then \
		if docker-compose exec -T redis redis-cli ping >/dev/null 2>&1; then \
			echo "$(GREEN)✅ Healthy$(NC)"; \
		else \
			echo "$(YELLOW)⚠️  Starting$(NC)"; \
		fi; \
	else \
		echo "$(RED)❌ Down$(NC)"; \
	fi

# MinIO
start-minio: ## 🗂️ Inicia apenas MinIO
	@echo "$(BLUE)🗂️ Iniciando MinIO...$(NC)"
	@docker-compose up -d minio
	@sleep 3
	@make health-minio

stop-minio: ## 🗂️ Para MinIO
	@echo "$(BLUE)🗂️ Parando MinIO...$(NC)"
	@docker-compose stop minio

restart-minio: ## 🗂️ Reinicia MinIO
	@echo "$(BLUE)🗂️ Reiniciando MinIO...$(NC)"
	@make stop-minio
	@sleep 2
	@make start-minio

logs-minio: ## 🗂️ Logs do MinIO
	@echo "$(BLUE)🗂️ Logs do MinIO:$(NC)"
	@docker-compose logs -f minio

shell-minio: ## 🗂️ Shell no MinIO
	@echo "$(BLUE)🗂️ Conectando ao MinIO...$(NC)"
	@docker-compose exec minio sh

health-minio: ## 🗂️ Verifica saúde do MinIO
	@echo -n "$(BLUE)🗂️ MinIO: $(NC)"
	@if docker-compose ps minio 2>/dev/null | grep -q "Up"; then \
		if timeout 5 curl -s http://$(SERVER_IP):$(MINIO_CONSOLE_PORT)/minio/health/live > /dev/null 2>&1; then \
			echo "$(GREEN)✅ Healthy$(NC)"; \
		else \
			echo "$(YELLOW)⚠️  Starting$(NC)"; \
		fi; \
	else \
		echo "$(RED)❌ Down$(NC)"; \
	fi

open-minio: ## 🗂️ Abre interface do MinIO
	@echo "$(BLUE)🗂️ Abrindo MinIO Console...$(NC)"
	@command -v xdg-open >/dev/null 2>&1 && xdg-open "http://$(SERVER_IP):$(MINIO_CONSOLE_PORT)" || echo "$(YELLOW)⚠️  Abra: http://$(SERVER_IP):$(MINIO_CONSOLE_PORT)$(NC)"

# Airflow
start-airflow: ## ✈️ Inicia todos os serviços do Airflow
	@echo "$(BLUE)✈️ Iniciando Airflow (dependências incluídas)...$(NC)"
	@make start-postgres
	@make start-redis
	@sleep 5
	@docker-compose up -d airflow-webserver airflow-scheduler airflow-worker
	@sleep 10
	@make health-airflow

stop-airflow: ## ✈️ Para todos os serviços do Airflow
	@echo "$(BLUE)✈️ Parando Airflow...$(NC)"
	@docker-compose stop airflow-webserver airflow-scheduler airflow-worker

restart-airflow: ## ✈️ Reinicia Airflow
	@echo "$(BLUE)✈️ Reiniciando Airflow...$(NC)"
	@make stop-airflow
	@sleep 3
	@make start-airflow

logs-airflow-webserver: ## ✈️ Logs do Airflow Webserver
	@echo "$(BLUE)✈️ Logs do Airflow Webserver:$(NC)"
	@docker-compose logs -f airflow-webserver

logs-airflow-scheduler: ## ✈️ Logs do Airflow Scheduler
	@echo "$(BLUE)✈️ Logs do Airflow Scheduler:$(NC)"
	@docker-compose logs -f airflow-scheduler

logs-airflow-worker: ## ✈️ Logs do Airflow Worker
	@echo "$(BLUE)✈️ Logs do Airflow Worker:$(NC)"
	@docker-compose logs -f airflow-worker

shell-airflow: ## ✈️ Shell no Airflow
	@echo "$(BLUE)✈️ Conectando ao Airflow...$(NC)"
	@docker-compose exec airflow-webserver bash

health-airflow: ## ✈️ Verifica saúde do Airflow
	@echo "$(BLUE)✈️ Verificando Airflow:$(NC)"
	@echo -n "  • Webserver: "
	@if docker-compose ps airflow-webserver 2>/dev/null | grep -q "Up"; then \
		if timeout 10 curl -s http://$(SERVER_IP):$(AIRFLOW_PORT)/health > /dev/null 2>&1; then \
			echo "$(GREEN)✅ Healthy$(NC)"; \
		else \
			echo "$(YELLOW)⚠️  Starting$(NC)"; \
		fi; \
	else \
		echo "$(RED)❌ Down$(NC)"; \
	fi
	@echo -n "  • Scheduler: "
	@if docker-compose ps airflow-scheduler 2>/dev/null | grep -q "Up"; then \
		echo "$(GREEN)✅ Running$(NC)"; \
	else \
		echo "$(RED)❌ Down$(NC)"; \
	fi
	@echo -n "  • Worker: "
	@if docker-compose ps airflow-worker 2>/dev/null | grep -q "Up"; then \
		echo "$(GREEN)✅ Running$(NC)"; \
	else \
		echo "$(RED)❌ Down$(NC)"; \
	fi \
		echo "$(RED)❌ Down$(NC)"; \
	fi

open-airflow: ## ✈️ Abre interface do Airflow
	@echo "$(BLUE)✈️ Abrindo Airflow...$(NC)"
	@command -v xdg-open >/dev/null 2>&1 && xdg-open "http://$(SERVER_IP):$(AIRFLOW_PORT)" || echo "$(YELLOW)⚠️  Abra: http://$(SERVER_IP):$(AIRFLOW_PORT)$(NC)"

# Spark
start-spark: ## ⚡ Inicia cluster Spark
	@echo "$(BLUE)⚡ Iniciando Spark cluster...$(NC)"
	@docker-compose up -d spark-master spark-worker-1 spark-worker-2
	@sleep 5
	@make health-spark

stop-spark: ## ⚡ Para cluster Spark
	@echo "$(BLUE)⚡ Parando Spark cluster...$(NC)"
	@docker-compose stop spark-master spark-worker-1 spark-worker-2

restart-spark: ## ⚡ Reinicia cluster Spark
	@echo "$(BLUE)⚡ Reiniciando Spark cluster...$(NC)"
	@make stop-spark
	@sleep 3
	@make start-spark

logs-spark-master: ## ⚡ Logs do Spark Master
	@echo "$(BLUE)⚡ Logs do Spark Master:$(NC)"
	@docker-compose logs -f spark-master

logs-spark-worker: ## ⚡ Logs dos Spark Workers
	@echo "$(BLUE)⚡ Logs dos Spark Workers:$(NC)"
	@docker-compose logs -f spark-worker-1 spark-worker-2

shell-spark: ## ⚡ Shell no Spark Master
	@echo "$(BLUE)⚡ Conectando ao Spark Master...$(NC)"
	@docker-compose exec spark-master bash

health-spark: ## ⚡ Verifica saúde do Spark
	@echo "$(BLUE)⚡ Verificando Spark:$(NC)"
	@echo -n "  • Master: "
	@if docker-compose ps spark-master 2>/dev/null | grep -q "Up"; then \
		if timeout 5 curl -s http://$(SERVER_IP):$(SPARK_UI_PORT) > /dev/null 2>&1; then \
			echo "$(GREEN)✅ Healthy$(NC)"; \
		else \
			echo "$(YELLOW)⚠️  Starting$(NC)"; \
		fi; \
	else \
		echo "$(RED)❌ Down$(NC)"; \
	fi
	@echo -n "  • Workers: "
	@if docker-compose ps spark-worker-1 spark-worker-2 | grep -q "Up.*Up"; then \
		echo "$(GREEN)✅ Running$(NC)"; \
	else \
		echo "$(RED)❌ Down$(NC)"; \
	fi

open-spark: ## ⚡ Abre interface do Spark
	@echo "$(BLUE)⚡ Abrindo Spark UI...$(NC)"
	@command -v xdg-open >/dev/null 2>&1 && xdg-open "http://$(SERVER_IP):$(SPARK_UI_PORT)" || echo "$(YELLOW)⚠️  Abra: http://$(SERVER_IP):$(SPARK_UI_PORT)$(NC)"

# Jupyter
start-jupyter: ## 📓 Inicia Jupyter
	@echo "$(BLUE)📓 Iniciando Jupyter...$(NC)"
	@docker-compose up -d jupyter
	@sleep 5
	@make health-jupyter

stop-jupyter: ## 📓 Para Jupyter
	@echo "$(BLUE)📓 Parando Jupyter...$(NC)"
	@docker-compose stop jupyter

restart-jupyter: ## 📓 Reinicia Jupyter
	@echo "$(BLUE)📓 Reiniciando Jupyter...$(NC)"
	@make stop-jupyter
	@sleep 2
	@make start-jupyter

logs-jupyter: ## 📓 Logs do Jupyter
	@echo "$(BLUE)📓 Logs do Jupyter:$(NC)"
	@docker-compose logs -f jupyter

shell-jupyter: ## 📓 Shell no Jupyter
	@echo "$(BLUE)📓 Conectando ao Jupyter...$(NC)"
	@docker-compose exec jupyter bash

health-jupyter: ## 📓 Verifica saúde do Jupyter
	@echo -n "$(BLUE)📓 Jupyter: $(NC)"
	@if docker-compose ps jupyter 2>/dev/null | grep -q "Up"; then \
		if timeout 5 curl -s http://$(SERVER_IP):$(JUPYTER_PORT) > /dev/null 2>&1; then \
			echo "$(GREEN)✅ Healthy$(NC)"; \
		else \
			echo "$(YELLOW)⚠️  Starting$(NC)"; \
		fi; \
	else \
		echo "$(RED)❌ Down$(NC)"; \
	fi

open-jupyter: ## 📓 Abre interface do Jupyter
	@echo "$(BLUE)📓 Abrindo Jupyter...$(NC)"
	@echo "$(YELLOW)💡 Use a senha: jupyter$(NC)"
	@command -v xdg-open >/dev/null 2>&1 && xdg-open "http://$(SERVER_IP):$(JUPYTER_PORT)" || echo "$(YELLOW)⚠️  Abra: http://$(SERVER_IP):$(JUPYTER_PORT)$(NC)"

# Jenkins  
start-jenkins: ## 🏗️ Inicia Jenkins
	@echo "$(BLUE)🏗️ Iniciando Jenkins...$(NC)"
	@docker-compose up -d jenkins
	@sleep 10
	@make health-jenkins

stop-jenkins: ## 🏗️ Para Jenkins
	@echo "$(BLUE)🏗️ Parando Jenkins...$(NC)"
	@docker-compose stop jenkins

restart-jenkins: ## 🏗️ Reinicia Jenkins
	@echo "$(BLUE)🏗️ Reiniciando Jenkins...$(NC)"
	@make stop-jenkins
	@sleep 3
	@make start-jenkins

logs-jenkins: ## 🏗️ Logs do Jenkins
	@echo "$(BLUE)🏗️ Logs do Jenkins:$(NC)"
	@docker-compose logs -f jenkins

shell-jenkins: ## 🏗️ Shell no Jenkins
	@echo "$(BLUE)🏗️ Conectando ao Jenkins...$(NC)"
	@docker-compose exec jenkins bash

health-jenkins: ## 🏗️ Verifica saúde do Jenkins
	@echo -n "$(BLUE)🏗️ Jenkins: $(NC)"
	@if docker-compose ps jenkins 2>/dev/null | grep -q "Up"; then \
		if timeout 10 curl -s http://$(SERVER_IP):$(JENKINS_PORT) > /dev/null 2>&1; then \
			echo "$(GREEN)✅ Healthy$(NC)"; \
		else \
			echo "$(YELLOW)⚠️  Starting$(NC)"; \
		fi; \
	else \
		echo "$(RED)❌ Down$(NC)"; \
	fi

open-jenkins: ## 🏗️ Abre interface do Jenkins
	@echo "$(BLUE)🏗️ Abrindo Jenkins...$(NC)"
	@command -v xdg-open >/dev/null 2>&1 && xdg-open "http://$(SERVER_IP):$(JENKINS_PORT)" || echo "$(YELLOW)⚠️  Abra: http://$(SERVER_IP):$(JENKINS_PORT)$(NC)"

## 🔧 Comandos de Troubleshooting por Serviço

# Reset específico por serviço (remove dados/configurações)
reset-postgres: ## 🐘 Reset completo do PostgreSQL (REMOVE DADOS!)
	@echo "$(RED)⚠️  ATENÇÃO: Isso irá REMOVER TODOS OS DADOS do PostgreSQL!$(NC)"
	@read -p "Tem certeza? Digite 'yes' para confirmar: " confirm && [ "$$confirm" = "yes" ] || exit 1
	@echo "$(BLUE)🐘 Resetando PostgreSQL...$(NC)"
	@make stop-postgres
	@docker-compose rm -f postgres
	@docker volume rm bigdata_postgres_data 2>/dev/null || true
	@echo "$(GREEN)✅ PostgreSQL resetado$(NC)"

reset-minio: ## 🗂️ Reset completo do MinIO (REMOVE DADOS!)
	@echo "$(RED)⚠️  ATENÇÃO: Isso irá REMOVER TODOS OS DADOS do MinIO!$(NC)"
	@read -p "Tem certeza? Digite 'yes' para confirmar: " confirm && [ "$$confirm" = "yes" ] || exit 1
	@echo "$(BLUE)🗂️ Resetando MinIO...$(NC)"
	@make stop-minio
	@docker-compose rm -f minio
	@docker volume rm bigdata_minio_data 2>/dev/null || true
	@echo "$(GREEN)✅ MinIO resetado$(NC)"

reset-airflow: ## ✈️ Reset completo do Airflow (REMOVE LOGS/CONFIGS!)
	@echo "$(RED)⚠️  ATENÇÃO: Isso irá REMOVER logs e configurações do Airflow!$(NC)"
	@read -p "Tem certeza? Digite 'yes' para confirmar: " confirm && [ "$$confirm" = "yes" ] || exit 1
	@echo "$(BLUE)✈️ Resetando Airflow...$(NC)"
	@make stop-airflow
	@docker-compose rm -f airflow-webserver airflow-scheduler airflow-worker
	@docker volume rm bigdata_airflow_logs 2>/dev/null || true
	@echo "$(GREEN)✅ Airflow resetado$(NC)"

# Rebuild específico por serviço
rebuild-postgres: ## 🐘 Rebuild do PostgreSQL
	@echo "$(BLUE)🐘 Rebuild do PostgreSQL...$(NC)"
	@make stop-postgres
	@docker-compose rm -f postgres
	@docker-compose pull postgres
	@make start-postgres

rebuild-minio: ## 🗂️ Rebuild do MinIO
	@echo "$(BLUE)🗂️ Rebuild do MinIO...$(NC)"
	@make stop-minio
	@docker-compose rm -f minio
	@docker-compose pull minio
	@make start-minio

rebuild-airflow: ## ✈️ Rebuild do Airflow
	@echo "$(BLUE)✈️ Rebuild do Airflow...$(NC)"
	@make stop-airflow
	@docker-compose rm -f airflow-webserver airflow-scheduler airflow-worker
	@docker-compose pull apache/airflow
	@make start-airflow

rebuild-spark: ## ⚡ Rebuild do Spark
	@echo "$(BLUE)⚡ Rebuild do Spark...$(NC)"
	@make stop-spark
	@docker-compose rm -f spark-master spark-worker-1 spark-worker-2
	@docker-compose pull bitnami/spark
	@make start-spark

rebuild-jupyter: ## 📓 Rebuild do Jupyter
	@echo "$(BLUE)📓 Rebuild do Jupyter...$(NC)"
	@make stop-jupyter
	@docker-compose rm -f jupyter
	@docker-compose pull jupyter/all-spark-notebook
	@make start-jupyter

# Debug específico por serviço
debug-postgres: ## 🐘 Debug do PostgreSQL
	@echo "$(BLUE)🐘 Debug do PostgreSQL:$(NC)"
	@echo "$(YELLOW)📊 Status do container:$(NC)"
	@docker-compose ps postgres
	@echo "$(YELLOW)🔍 Últimos logs:$(NC)"
	@docker-compose logs --tail=20 postgres
	@echo "$(YELLOW)🩺 Teste de conexão:$(NC)"
	@docker-compose exec postgres pg_isready -U airflow || echo "$(RED)❌ PostgreSQL não está respondendo$(NC)"

debug-minio: ## 🗂️ Debug do MinIO
	@echo "$(BLUE)🗂️ Debug do MinIO:$(NC)"
	@echo "$(YELLOW)📊 Status do container:$(NC)"
	@docker-compose ps minio
	@echo "$(YELLOW)🔍 Últimos logs:$(NC)"
	@docker-compose logs --tail=20 minio
	@echo "$(YELLOW)🩺 Teste de conectividade:$(NC)"
	@curl -I http://$(SERVER_IP):$(MINIO_CONSOLE_PORT)/minio/health/live 2>/dev/null || echo "$(RED)❌ MinIO não está respondendo$(NC)"

debug-airflow: ## ✈️ Debug completo do Airflow
	@echo "$(BLUE)✈️ Debug do Airflow:$(NC)"
	@echo "$(YELLOW)📊 Status dos containers:$(NC)"
	@docker-compose ps airflow-webserver airflow-scheduler airflow-worker
	@echo "$(YELLOW)🔍 Logs do Webserver:$(NC)"
	@docker-compose logs --tail=10 airflow-webserver
	@echo "$(YELLOW)🔍 Logs do Scheduler:$(NC)"
	@docker-compose logs --tail=10 airflow-scheduler
	@echo "$(YELLOW)🩺 Teste de conectividade:$(NC)"
	@curl -I http://$(SERVER_IP):$(AIRFLOW_PORT)/health 2>/dev/null || echo "$(RED)❌ Airflow webserver não está respondendo$(NC)"

debug-spark: ## ⚡ Debug do Spark
	@echo "$(BLUE)⚡ Debug do Spark:$(NC)"
	@echo "$(YELLOW)📊 Status dos containers:$(NC)"
	@docker-compose ps spark-master spark-worker-1 spark-worker-2
	@echo "$(YELLOW)🔍 Logs do Master:$(NC)"
	@docker-compose logs --tail=10 spark-master
	@echo "$(YELLOW)🩺 Teste de conectividade:$(NC)"
	@curl -I http://$(SERVER_IP):$(SPARK_UI_PORT) 2>/dev/null || echo "$(RED)❌ Spark UI não está respondendo$(NC)"

# Verificação de dependências
check-deps-airflow: ## ✈️ Verifica dependências do Airflow
	@echo "$(BLUE)✈️ Verificando dependências do Airflow:$(NC)"
	@echo -n "$(YELLOW)PostgreSQL: $(NC)"
	@make health-postgres
	@echo -n "$(YELLOW)Redis: $(NC)"
	@make health-redis
	@echo "$(YELLOW)Recomendação: Inicie dependências com 'make start-postgres start-redis'$(NC)"

check-deps-spark: ## ⚡ Verifica dependências do Spark
	@echo "$(BLUE)⚡ Verificando dependências do Spark:$(NC)"
	@echo "$(YELLOW)ℹ️  Spark não tem dependências obrigatórias, mas funciona melhor com MinIO$(NC)"
	@echo -n "$(YELLOW)MinIO (opcional): $(NC)"
	@make health-minio

# Status consolidado por serviço
status-database: ## 🗄️ Status de todos os bancos de dados
	@echo "$(BLUE)🗄️ Status dos bancos de dados:$(NC)"
	@make health-postgres
	@make health-redis

status-storage: ## 🗂️ Status dos sistemas de armazenamento
	@echo "$(BLUE)🗂️ Status do armazenamento:$(NC)"
	@make health-minio

status-compute: ## ⚡ Status dos sistemas de computação
	@echo "$(BLUE)⚡ Status da computação:$(NC)"
	@make health-spark
	@make health-jupyter

status-orchestration: ## ✈️ Status da orquestração
	@echo "$(BLUE)✈️ Status da orquestração:$(NC)"
	@make health-airflow
	@make health-jenkins

## 💾 Comandos de Backup/Restore por Serviço

# Backup PostgreSQL
backup-postgres: ## 🐘 Backup do PostgreSQL
	@echo "$(BLUE)🐘 Fazendo backup do PostgreSQL...$(NC)"
	@mkdir -p ./backups/postgres
	@docker-compose exec postgres pg_dump -U airflow airflow > ./backups/postgres/airflow_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "$(GREEN)✅ Backup salvo em ./backups/postgres/$(NC)"

restore-postgres: ## 🐘 Restore do PostgreSQL
	@echo "$(BLUE)🐘 Listando backups disponíveis:$(NC)"
	@ls -la ./backups/postgres/ 2>/dev/null || echo "$(YELLOW)⚠️  Nenhum backup encontrado$(NC)"
	@echo "$(YELLOW)💡 Para restaurar: docker-compose exec postgres psql -U airflow -d airflow < ./backups/postgres/ARQUIVO.sql$(NC)"

# Backup MinIO
backup-minio: ## 🗂️ Backup dos dados do MinIO
	@echo "$(BLUE)🗂️ Fazendo backup do MinIO...$(NC)"
	@mkdir -p ./backups/minio
	@docker run --rm -v bigdata_minio_data:/data -v $(PWD)/backups/minio:/backup alpine tar czf /backup/minio_data_$(shell date +%Y%m%d_%H%M%S).tar.gz -C /data .
	@echo "$(GREEN)✅ Backup salvo em ./backups/minio/$(NC)"

restore-minio: ## 🗂️ Restore dos dados do MinIO
	@echo "$(BLUE)🗂️ Listando backups disponíveis:$(NC)"
	@ls -la ./backups/minio/ 2>/dev/null || echo "$(YELLOW)⚠️  Nenhum backup encontrado$(NC)"
	@echo "$(RED)⚠️  Para restaurar um backup específico:$(NC)"
	@echo "$(YELLOW)1. Pare o MinIO: make stop-minio$(NC)"
	@echo "$(YELLOW)2. Execute: docker run --rm -v bigdata_minio_data:/data -v $(PWD)/backups/minio:/backup alpine tar xzf /backup/ARQUIVO.tar.gz -C /data$(NC)"
	@echo "$(YELLOW)3. Inicie o MinIO: make start-minio$(NC)"

# Backup Airflow
backup-airflow: ## ✈️ Backup das configurações do Airflow
	@echo "$(BLUE)✈️ Fazendo backup do Airflow...$(NC)"
	@mkdir -p ./backups/airflow
	@tar czf ./backups/airflow/airflow_configs_$(shell date +%Y%m%d_%H%M%S).tar.gz ./airflow/dags ./airflow/plugins ./airflow/config 2>/dev/null || true
	@docker run --rm -v bigdata_airflow_logs:/logs -v $(PWD)/backups/airflow:/backup alpine tar czf /backup/airflow_logs_$(shell date +%Y%m%d_%H%M%S).tar.gz -C /logs . 2>/dev/null || true
	@echo "$(GREEN)✅ Backup salvo em ./backups/airflow/$(NC)"

restore-airflow: ## ✈️ Restore das configurações do Airflow
	@echo "$(BLUE)✈️ Listando backups disponíveis:$(NC)"
	@ls -la ./backups/airflow/ 2>/dev/null || echo "$(YELLOW)⚠️  Nenhum backup encontrado$(NC)"
	@echo "$(RED)⚠️  Para restaurar configurações:$(NC)"
	@echo "$(YELLOW)tar xzf ./backups/airflow/airflow_configs_TIMESTAMP.tar.gz$(NC)"
	@echo "$(RED)⚠️  Para restaurar logs:$(NC)"
	@echo "$(YELLOW)docker run --rm -v bigdata_airflow_logs:/logs -v $(PWD)/backups/airflow:/backup alpine tar xzf /backup/airflow_logs_TIMESTAMP.tar.gz -C /logs$(NC)"

# Backup completo de um serviço
full-backup-postgres: ## 🐘 Backup completo PostgreSQL (dados + volume)
	@echo "$(BLUE)🐘 Backup completo do PostgreSQL...$(NC)"
	@mkdir -p ./backups/postgres
	@make backup-postgres
	@docker run --rm -v bigdata_postgres_data:/data -v $(PWD)/backups/postgres:/backup alpine tar czf /backup/postgres_volume_$(shell date +%Y%m%d_%H%M%S).tar.gz -C /data .
	@echo "$(GREEN)✅ Backup completo salvo em ./backups/postgres/$(NC)"

full-backup-minio: ## 🗂️ Backup completo MinIO
	@echo "$(BLUE)🗂️ Backup completo do MinIO...$(NC)"
	@make backup-minio

full-backup-airflow: ## ✈️ Backup completo Airflow
	@echo "$(BLUE)✈️ Backup completo do Airflow...$(NC)"
	@make backup-airflow
	@make backup-postgres  # Airflow usa PostgreSQL

# Backup de todo o ambiente
backup-all: ## 💾 Backup completo de todo o ambiente
	@echo "$(BLUE)💾 Fazendo backup completo do ambiente...$(NC)"
	@make full-backup-postgres
	@make full-backup-minio  
	@make full-backup-airflow
	@echo "$(YELLOW)📋 Salvando configurações do ambiente...$(NC)"
	@mkdir -p ./backups/environment
	@cp .env ./backups/environment/env_$(shell date +%Y%m%d_%H%M%S).backup 2>/dev/null || true
	@cp docker-compose*.yml ./backups/environment/ 2>/dev/null || true
	@echo "$(GREEN)✅ Backup completo finalizado em ./backups/$(NC)"

# Comandos de informação sobre backups
list-backups: ## 💾 Lista todos os backups disponíveis
	@echo "$(BLUE)💾 Backups disponíveis:$(NC)"
	@echo "$(YELLOW)📂 PostgreSQL:$(NC)"
	@ls -la ./backups/postgres/ 2>/dev/null || echo "  Nenhum backup"
	@echo "$(YELLOW)📂 MinIO:$(NC)"  
	@ls -la ./backups/minio/ 2>/dev/null || echo "  Nenhum backup"
	@echo "$(YELLOW)📂 Airflow:$(NC)"
	@ls -la ./backups/airflow/ 2>/dev/null || echo "  Nenhum backup"
	@echo "$(YELLOW)📂 Environment:$(NC)"
	@ls -la ./backups/environment/ 2>/dev/null || echo "  Nenhum backup"

clean-old-backups: ## 💾 Remove backups antigos (>7 dias)
	@echo "$(BLUE)💾 Removendo backups antigos...$(NC)"
	@find ./backups -name "*.sql" -mtime +7 -delete 2>/dev/null || true
	@find ./backups -name "*.tar.gz" -mtime +7 -delete 2>/dev/null || true
	@find ./backups -name "*.backup" -mtime +7 -delete 2>/dev/null || true
	@echo "$(GREEN)✅ Backups antigos removidos$(NC)"