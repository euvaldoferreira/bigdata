#!/bin/bash

# Carregar funções comuns
source "$(dirname "$0")/common.sh"

# =================================================================================================
# 📊 BIGDATA STATUS SCRIPT
# =================================================================================================
# Script para verificar status completo do ambiente BigData
# Uso: ./status.sh ou make status
# =================================================================================================

# Função para verificar recursos do sistema
check_system_resources() {
    show_section "Recursos do Sistema" "💾"
    
    # Verificar uso de memória pelos containers
    if command_exists docker; then
        local memory_usage=$($DOCKER_CMD stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" 2>/dev/null | grep bigdata)
        if [ ! -z "$memory_usage" ]; then
            echo -e "  📊 Uso de recursos pelos containers BigData:"
            echo "$memory_usage" | while read line; do
                echo -e "     ${CYAN}$line${NC}"
            done
        else
            echo -e "  ${INFO} Nenhum container BigData consumindo recursos"
        fi
    fi
}

# Função para verificar logs recentes de todos os serviços
check_all_service_logs() {
    show_section "Status dos Logs" "${LOGS}"
    
    # Lista de serviços para verificar
    local services=("postgres" "redis" "minio" "airflow_webserver" "airflow_scheduler" "spark_master" "jupyter")
    
    for service in "${services[@]}"; do
        check_service_logs "$service"
    done
}

# Função para exibir URLs de acesso
show_access_urls() {
    show_section "URLs de Acesso" "🔗"
    echo -e "  🌐 Airflow:  ${CYAN}$(get_service_url "airflow")${NC} (admin/admin)"
    echo -e "  🌐 Spark UI: ${CYAN}$(get_service_url "spark")${NC}"
    echo -e "  🌐 MinIO:    ${CYAN}$(get_service_url "minio")${NC} (minioadmin/minioadmin123)"
    echo -e "  🌐 Jupyter:  ${CYAN}$(get_service_url "jupyter")${NC}"
    echo -e "  🌐 Jenkins:  ${CYAN}$(get_service_url "jenkins")${NC} (admin/admin)"
    echo -e "  🌐 Flower:   ${CYAN}$(get_service_url "flower")${NC}"
}

# Função para mostrar informações sobre HTTPS
show_https_info() {
    # Mostrar informações sobre HTTPS se habilitado
    if [ "${USE_HTTPS:-false}" = "true" ] || [ "${SSL_ENABLED:-false}" = "true" ] || [ ! -z "${DOMAIN}" ]; then
        show_section "Configuração HTTPS" "🔒"
        echo -e "  ${SUCCESS} ${GREEN}HTTPS habilitado${NC}"
        if [ ! -z "${DOMAIN}" ]; then
            echo -e "  🌍 Domínio: ${CYAN}${DOMAIN}${NC}"
        fi
        if [ "${USE_REVERSE_PROXY:-false}" = "true" ]; then
            echo -e "  🔄 Proxy reverso habilitado"
        fi
    else
        show_section "Dica HTTPS" "💡"
        echo -e "  Para habilitar HTTPS, configure no .env:"
        echo -e "  ${CYAN}USE_HTTPS=true${NC}"
        echo -e "  ${CYAN}DOMAIN=seu-dominio.com${NC}"
        echo -e "  ${CYAN}USE_REVERSE_PROXY=true${NC} (opcional)"
    fi
}

# Função principal
main() {
    # Inicialização comum
    common_init
    
    # Header
    show_header "🔍 BigData Environment Status" "Verificação completa do ambiente"
    
    # Status dos serviços
    show_section "Status dos Serviços" "${CONTAINER}"
    
    # Verificar serviços principais
    check_bigdata_service "postgres" "5432"
    check_bigdata_service "redis" "6379"
    check_bigdata_service "minio" "9001" "MinIO Console"
    check_bigdata_service "airflow_webserver" "8080" "Airflow UI"
    check_bigdata_service "airflow_scheduler"
    check_bigdata_service "airflow_worker"
    check_bigdata_service "spark_master" "8081" "Spark Master UI"
    check_bigdata_service "spark_worker_1" "8082" "Spark Worker 1 UI"
    check_bigdata_service "spark_worker_2" "8083" "Spark Worker 2 UI"
    check_bigdata_service "jupyter" "8888" "Jupyter Lab"
    check_bigdata_service "jenkins" "8082" "Jenkins UI"
    
    # Verificações adicionais
    check_bigdata_network
    check_bigdata_volumes
    check_system_resources
    check_all_service_logs
    
    # URLs e informações
    show_access_urls
    show_https_info
    show_useful_commands
}

# Executar função principal
main "$@"