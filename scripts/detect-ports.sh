#!/bin/bash

# Script para detectar portas disponíveis automaticamente
# Usado para evitar conflitos em diferentes ambientes

# Função para encontrar próxima porta disponível
find_available_port() {
    local start_port=$1
    local max_attempts=${2:-10}
    local current_port=$start_port
    
    for ((i=0; i<max_attempts; i++)); do
        if ! nc -z localhost $current_port 2>/dev/null; then
            echo $current_port
            return 0
        fi
        ((current_port++))
    done
    
    # Se não encontrou porta disponível, retorna a original
    echo $start_port
}

# Detectar portas disponíveis para cada serviço
detect_ports() {
    echo "🔍 Detectando portas disponíveis..."
    
    # Portas padrão preferenciais
    AIRFLOW_PORT=$(find_available_port 8080)
    MINIO_API_PORT=$(find_available_port 9000)
    MINIO_CONSOLE_PORT=$(find_available_port 9001)
    JUPYTER_PORT=$(find_available_port 8888)
    SPARK_UI_PORT=$(find_available_port 8081)
    SPARK_LOCAL_UI_PORT=$(find_available_port 4040)
    JENKINS_PORT=$(find_available_port 8082)
    FLOWER_PORT=$(find_available_port 5555)
    
    echo "✅ Portas detectadas:"
    echo "   Airflow:     $AIRFLOW_PORT"
    echo "   MinIO API:   $MINIO_API_PORT"
    echo "   MinIO UI:    $MINIO_CONSOLE_PORT"
    echo "   Jupyter:     $JUPYTER_PORT"
    echo "   Spark UI:    $SPARK_UI_PORT"
    echo "   Spark Local: $SPARK_LOCAL_UI_PORT"
    echo "   Jenkins:     $JENKINS_PORT"
    echo "   Flower:      $FLOWER_PORT"
}

# Configurar portas no .env
configure_ports() {
    local env_file=${1:-.env}
    
    echo "📝 Configurando portas no $env_file..."
    
    # Criar backup se arquivo existir
    if [ -f "$env_file" ]; then
        cp "$env_file" "${env_file}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Atualizar ou adicionar portas no .env
    for var in AIRFLOW_PORT MINIO_API_PORT MINIO_CONSOLE_PORT JUPYTER_PORT SPARK_UI_PORT SPARK_LOCAL_UI_PORT JENKINS_PORT FLOWER_PORT; do
        local value=$(eval echo \$$var)
        if grep -q "^$var=" "$env_file" 2>/dev/null; then
            sed -i "s/^$var=.*/$var=$value/" "$env_file"
        else
            echo "$var=$value" >> "$env_file"
        fi
    done
    
    echo "✅ Portas configuradas em $env_file"
}

# Verificar se há conflitos
check_port_conflicts() {
    echo "🔍 Verificando conflitos de portas..."
    
    local conflicts=0
    local ports=($(grep "_PORT=" .env 2>/dev/null | cut -d= -f2))
    
    for port in "${ports[@]}"; do
        if nc -z localhost $port 2>/dev/null; then
            echo "⚠️  Porta $port está ocupada"
            ((conflicts++))
        fi
    done
    
    if [ $conflicts -eq 0 ]; then
        echo "✅ Nenhum conflito de porta encontrado"
    else
        echo "🚨 Encontrados $conflicts conflitos de porta"
        echo "💡 Execute 'make detect-ports' para reconfigurar"
    fi
    
    return $conflicts
}

# Mostrar URLs de acesso
show_access_urls() {
    if [ -f .env ]; then
        source .env
        echo "🌐 URLs de acesso:"
        echo "   Airflow:     http://localhost:${AIRFLOW_PORT:-8080}"
        echo "   MinIO UI:    http://localhost:${MINIO_CONSOLE_PORT:-9001}"
        echo "   Jupyter:     http://localhost:${JUPYTER_PORT:-8888}"
        echo "   Spark UI:    http://localhost:${SPARK_UI_PORT:-8081}"
        echo "   Jenkins:     http://localhost:${JENKINS_PORT:-8082}"
        echo "   Flower:      http://localhost:${FLOWER_PORT:-5555}"
    fi
}

# Se executado diretamente
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    case "${1:-detect}" in
        detect)
            detect_ports
            configure_ports
            ;;
        check)
            check_port_conflicts
            ;;
        urls)
            show_access_urls
            ;;
        *)
            echo "Uso: $0 [detect|check|urls]"
            echo "  detect - Detecta e configura portas disponíveis"
            echo "  check  - Verifica conflitos de portas"
            echo "  urls   - Mostra URLs de acesso"
            ;;
    esac
fi