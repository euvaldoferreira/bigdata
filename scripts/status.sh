#!/bin/bash

# Script para monitorar o status dos serviços BigData

# Carregar variáveis do .env se existir
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Definir IP padrão se não estiver no .env
SERVER_IP=${SERVER_IP:-localhost}
AIRFLOW_PORT=${AIRFLOW_PORT:-8080}
SPARK_UI_PORT=${SPARK_UI_PORT:-8081}
MINIO_PORT=${MINIO_PORT:-9000}
MINIO_CONSOLE_PORT=${MINIO_CONSOLE_PORT:-9001}
JENKINS_PORT=${JENKINS_PORT:-8082}
JUPYTER_PORT=${JUPYTER_PORT:-8888}
FLOWER_PORT=${FLOWER_PORT:-5555}

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}$1${NC}"
    echo "================================================"
}

check_service() {
    local service_name=$1
    local url=$2
    local port=$3
    
    if curl -f -s "$url" > /dev/null 2>&1; then
        echo -e "✅ ${GREEN}$service_name${NC} - ONLINE (porta $port)"
    else
        echo -e "❌ ${RED}$service_name${NC} - OFFLINE (porta $port)"
    fi
}

check_container() {
    local container_name=$1
    
    if docker ps --format "table {{.Names}}" | grep -q "$container_name"; then
        echo -e "✅ ${GREEN}$container_name${NC} - RUNNING"
    else
        echo -e "❌ ${RED}$container_name${NC} - STOPPED"
    fi
}

# Ir para diretório do projeto
cd "$(dirname "$0")/.."

clear
print_header "🔍 Status do Ambiente BigData"

echo -e "${YELLOW}Verificando containers...${NC}"
echo
check_container "bigdata_postgres"
check_container "bigdata_redis"
check_container "bigdata_minio"
check_container "bigdata_airflow_webserver"
check_container "bigdata_airflow_scheduler"
check_container "bigdata_airflow_worker"
check_container "bigdata_spark_master"
check_container "bigdata_spark_worker_1"
check_container "bigdata_spark_worker_2"
check_container "bigdata_jupyter"
check_container "bigdata_jenkins"

echo
echo -e "${YELLOW}Verificando serviços web...${NC}"
echo
check_service "Airflow" "http://${SERVER_IP}:${AIRFLOW_PORT}/health" "${AIRFLOW_PORT}"
check_service "Spark Master" "http://${SERVER_IP}:${SPARK_UI_PORT}" "${SPARK_UI_PORT}"
check_service "MinIO" "http://${SERVER_IP}:${MINIO_PORT}/minio/health/live" "${MINIO_PORT}"
check_service "MinIO Console" "http://${SERVER_IP}:${MINIO_CONSOLE_PORT}" "${MINIO_CONSOLE_PORT}"
check_service "Jenkins" "http://${SERVER_IP}:${JENKINS_PORT}" "${JENKINS_PORT}"
check_service "Jupyter" "http://${SERVER_IP}:${JUPYTER_PORT}" "${JUPYTER_PORT}"
check_service "Flower" "http://${SERVER_IP}:${FLOWER_PORT}" "${FLOWER_PORT}"

echo
echo -e "${YELLOW}Uso de recursos...${NC}"
echo
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" 2>/dev/null | head -20

echo
print_header "📊 Links de Acesso"
echo "• Airflow:     http://${SERVER_IP}:${AIRFLOW_PORT}   (admin/admin)"
echo "• Spark UI:    http://${SERVER_IP}:${SPARK_UI_PORT}"
echo "• MinIO:       http://${SERVER_IP}:${MINIO_CONSOLE_PORT}   (minioadmin/minioadmin123)"
echo "• Jenkins:     http://${SERVER_IP}:${JENKINS_PORT}   (admin/admin)"
echo "• Jupyter:     http://${SERVER_IP}:${JUPYTER_PORT}   (sem senha)"
echo "• Flower:      http://${SERVER_IP}:${FLOWER_PORT}"
echo

print_header "🔧 Comandos Úteis"
echo "• Ver logs específicos:    make logs-[serviço]"
echo "• Reiniciar serviço:       make restart-[serviço]" 
echo "• Parar ambiente:          make stop"
echo "• Executar job Spark:      make submit-spark"
echo "• Acessar shell:           make [serviço]-shell"
echo