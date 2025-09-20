#!/bin/bash

# Script para inicializar todo o ambiente BigData
# Executa os containers em ordem correta e aguarda que estejam prontos

set -e

echo "🚀 Iniciando ambiente BigData integrado..."
echo "================================================"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para print colorido
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar se Docker e Docker Compose estão instalados
check_dependencies() {
    print_status "Verificando dependências..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker não está instalado!"
        print_warning "Execute: make install-docker"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose não está instalado!"
        print_warning "Execute: make install-docker"
        exit 1
    fi
    
    # Verificar se o usuário está no grupo docker
    if ! groups | grep -q docker; then
        print_warning "Usuário não está no grupo docker. Alguns comandos podem precisar de sudo."
        print_warning "Para corrigir: sudo usermod -aG docker \$USER && logout/login"
        DOCKER_CMD="sudo docker"
        COMPOSE_CMD="sudo docker-compose"
    else
        DOCKER_CMD="docker"
        COMPOSE_CMD="docker-compose"
    fi
    
    print_success "Dependências verificadas!"
}

# Criar diretórios necessários
create_directories() {
    print_status "Criando diretórios necessários..."
    
    mkdir -p data/input data/output data/temp
    mkdir -p logs/airflow logs/spark logs/jupyter logs/jenkins
    
    # Configurar permissões para Airflow
    sudo chown -R 1000:0 airflow/ 2>/dev/null || true
    sudo chown -R 1000:0 logs/airflow/ 2>/dev/null || true
    
    print_success "Diretórios criados!"
}

# Configurar variáveis de ambiente
setup_environment() {
    print_status "Configurando variáveis de ambiente..."
    
    # Criar arquivo .env se não existir
    if [ ! -f .env ]; then
        cat > .env << EOF
# Airflow
AIRFLOW_UID=1000
AIRFLOW_GID=0

# PostgreSQL
POSTGRES_USER=airflow
POSTGRES_PASSWORD=airflow
POSTGRES_DB=airflow

# MinIO
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin123

# Spark
SPARK_MASTER_URL=spark://spark-master:7077
SPARK_WORKER_MEMORY=2G
SPARK_WORKER_CORES=2

# Jenkins
JENKINS_ADMIN_USER=admin
JENKINS_ADMIN_PASSWORD=admin
EOF
        print_success "Arquivo .env criado!"
    else
        print_warning "Arquivo .env já existe, mantendo configurações atuais"
    fi
}

# Função para aguardar serviço estar pronto
wait_for_service() {
    local service_name=$1
    local url=$2
    local max_attempts=30
    local attempt=1
    
    print_status "Aguardando $service_name estar pronto..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f -s "$url" > /dev/null 2>&1; then
            print_success "$service_name está pronto!"
            return 0
        fi
        
        echo -n "."
        sleep 10
        ((attempt++))
    done
    
    print_error "$service_name não ficou pronto após 5 minutos"
    return 1
}

# Inicializar serviços principais
start_infrastructure() {
    print_status "Iniciando serviços de infraestrutura..."
    
    # Iniciar PostgreSQL e Redis primeiro
    $COMPOSE_CMD up -d postgres redis
    
    # Aguardar PostgreSQL estar pronto
    print_status "Aguardando PostgreSQL..."
    sleep 20
    
    # Iniciar MinIO
    $COMPOSE_CMD up -d minio
    wait_for_service "MinIO" "http://localhost:9000/minio/health/live"
    
    # Configurar MinIO
    $COMPOSE_CMD up -d minio-client
    sleep 10
    
    print_success "Infraestrutura iniciada!"
}

# Inicializar Airflow
start_airflow() {
    print_status "Inicializando Airflow..."
    
    # Inicializar banco de dados do Airflow
    $COMPOSE_CMD up airflow-init
    
    # Iniciar serviços do Airflow
    $COMPOSE_CMD up -d airflow-webserver airflow-scheduler airflow-worker airflow-flower
    
    wait_for_service "Airflow" "http://localhost:8080/health"
    
    print_success "Airflow iniciado!"
}

# Inicializar Spark
start_spark() {
    print_status "Inicializando cluster Spark..."
    
    $COMPOSE_CMD up -d spark-master spark-worker-1 spark-worker-2
    
    wait_for_service "Spark Master" "http://localhost:8081"
    
    print_success "Cluster Spark iniciado!"
}

# Inicializar Jupyter
start_jupyter() {
    print_status "Inicializando Jupyter Notebook..."
    
    $COMPOSE_CMD up -d jupyter
    
    wait_for_service "Jupyter" "http://localhost:8888"
    
    print_success "Jupyter Notebook iniciado!"
}

# Inicializar Jenkins
start_jenkins() {
    print_status "Inicializando Jenkins..."
    
    $COMPOSE_CMD up -d jenkins
    
    wait_for_service "Jenkins" "http://localhost:8082"
    
    print_success "Jenkins iniciado!"
}

# Mostrar status final
show_status() {
    echo
    echo "================================================"
    print_success "🎉 Ambiente BigData iniciado com sucesso!"
    echo "================================================"
    echo
    echo "📊 Serviços disponíveis:"
    echo "   • Airflow:     http://localhost:8080   (admin/admin)"
    echo "   • Spark UI:    http://localhost:8081"
    echo "   • MinIO:       http://localhost:9001   (minioadmin/minioadmin123)"
    echo "   • Jenkins:     http://localhost:8082   (admin/admin)"
    echo "   • Jupyter:     http://localhost:8888   (sem senha)"
    echo "   • Flower:      http://localhost:5555   (monitoramento Celery)"
    echo
    echo "📁 Diretórios compartilhados:"
    echo "   • ./data/           - Dados compartilhados"
    echo "   • ./airflow/dags/   - DAGs do Airflow"
    echo "   • ./spark/apps/     - Aplicações Spark"
    echo "   • ./jupyter/notebooks/ - Notebooks Jupyter"
    echo
    echo "🔧 Comandos úteis:"
    echo "   • Parar tudo:       make stop"
    echo "   • Ver logs:         make logs"
    echo "   • Status:           make health"
    echo "   • Reiniciar:        make restart"
    echo
}

# Função principal
main() {
    cd "$(dirname "$0")/.."
    
    check_dependencies
    create_directories
    setup_environment
    start_infrastructure
    start_airflow
    start_spark
    start_jupyter
    start_jenkins
    show_status
}

# Executar função principal
main "$@"