#!/bin/bash
set -e

# Carregar .env se existir
if [ -f .env ]; then
    source .env
else
    echo "⚠️  Arquivo .env não encontrado. Usando valores padrão."
fi

# Validar variáveis obrigatórias
validate_required_vars() {
    local missing_vars=()
    
    # Verificar se as credenciais estão definidas
    if [ -z "$AIRFLOW_ADMIN_PASSWORD" ]; then
        missing_vars+=("AIRFLOW_ADMIN_PASSWORD")
    fi
    
    if [ -z "$MINIO_ROOT_PASSWORD" ]; then
        missing_vars+=("MINIO_ROOT_PASSWORD")
    fi
    
    if [ -z "$JENKINS_ADMIN_PASSWORD" ]; then
        missing_vars+=("JENKINS_ADMIN_PASSWORD")
    fi
    
    if [ ${#missing_vars[@]} -gt 0 ]; then
        echo "❌ Erro: As seguintes variáveis obrigatórias não estão definidas no .env:"
        printf "   - %s\n" "${missing_vars[@]}"
        echo ""
        echo "💡 Configure essas variáveis no arquivo .env antes de continuar."
        echo "   Exemplo:"
        echo "   AIRFLOW_ADMIN_PASSWORD=sua_senha_segura"
        echo "   MINIO_ROOT_PASSWORD=sua_senha_minio"
        echo "   JENKINS_ADMIN_PASSWORD=sua_senha_jenkins"
        exit 1
    fi
}

# Definir valores padrão se não estiverem no .env
SERVER_IP=${SERVER_IP:-localhost}
AIRFLOW_PORT=${AIRFLOW_PORT:-8080}
JUPYTER_PORT=${JUPYTER_PORT:-8888}
MINIO_CONSOLE_PORT=${MINIO_CONSOLE_PORT:-9001}
SPARK_UI_PORT=${SPARK_UI_PORT:-8081}
SPARK_LOCAL_UI_PORT=${SPARK_LOCAL_UI_PORT:-4040}
JENKINS_PORT=${JENKINS_PORT:-8082}
FLOWER_PORT=${FLOWER_PORT:-5555}

# Usuários padrão (senhas devem estar no .env)
AIRFLOW_ADMIN_USER=${AIRFLOW_ADMIN_USER:-admin}
MINIO_ROOT_USER=${MINIO_ROOT_USER:-minioadmin}
JENKINS_ADMIN_USER=${JENKINS_ADMIN_USER:-admin}

# Validar variáveis obrigatórias
validate_required_vars

# Detectar comando docker
CMD=$(command -v docker-compose >/dev/null 2>&1 && echo "docker-compose" || echo "docker compose")

echo "🚀 Iniciando ambiente BigData..."
$CMD up -d

sleep 10

echo "✅ Ambiente iniciado com sucesso!"
echo ""
echo "🌐 Serviços disponíveis:"
echo "  • Airflow:     http://${SERVER_IP}:${AIRFLOW_PORT}"
echo "  • Jupyter:     http://${SERVER_IP}:${JUPYTER_PORT}"
echo "  • MinIO:       http://${SERVER_IP}:${MINIO_CONSOLE_PORT}"
echo "  • Spark UI:    http://${SERVER_IP}:${SPARK_UI_PORT}"
echo "  • Spark Local: http://${SERVER_IP}:${SPARK_LOCAL_UI_PORT}"
echo "  • Jenkins:     http://${SERVER_IP}:${JENKINS_PORT}"
echo "  • Flower:      http://${SERVER_IP}:${FLOWER_PORT}"
echo ""
echo "🔐 Credenciais configuradas no arquivo .env"
echo "💡 Use 'make status' para verificar o status"
echo "💡 Use 'make logs' para ver os logs"
