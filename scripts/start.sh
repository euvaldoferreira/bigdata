#!/bin/bash

# Carregar funções comuns
source "$(dirname "$0")/common.sh"

# =================================================================================================
# 🚀 BIGDATA START SCRIPT
# =================================================================================================
# Script para iniciar o ambiente BigData
# Uso: ./start.sh ou make start
# =================================================================================================

# Função para validar variáveis obrigatórias
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
        echo -e "${ERROR} Erro: As seguintes variáveis obrigatórias não estão definidas no .env:"
        printf "   - %s\n" "${missing_vars[@]}"
        echo ""
        echo -e "${INFO} Configure essas variáveis no arquivo .env antes de continuar."
        echo "   Exemplo:"
        echo -e "   ${CYAN}AIRFLOW_ADMIN_PASSWORD=sua_senha_segura${NC}"
        echo -e "   ${CYAN}MINIO_ROOT_PASSWORD=sua_senha_minio${NC}"
        echo -e "   ${CYAN}JENKINS_ADMIN_PASSWORD=sua_senha_jenkins${NC}"
        exit 1
    fi
}

# Função para iniciar os serviços
start_services() {
    show_section "Iniciando Serviços" "${CONTAINER}"
    
    echo -e "  ${INFO} Iniciando containers..."
    $COMPOSE_CMD up -d
    
    echo -e "  ${INFO} Aguardando inicialização..."
    sleep 10
    
    echo -e "  ${SUCCESS} Ambiente iniciado com sucesso!"
}

# Função para mostrar URLs de acesso após inicialização
show_startup_urls() {
    show_section "Serviços Disponíveis" "🌐"
    
    # URLs principais
    echo -e "  🌐 Airflow:     ${CYAN}$(get_service_url "airflow")${NC}"
    echo -e "  🌐 Jupyter:     ${CYAN}$(get_service_url "jupyter")${NC}"
    echo -e "  🌐 MinIO:       ${CYAN}$(get_service_url "minio")${NC}"
    echo -e "  🌐 Spark UI:    ${CYAN}$(get_service_url "spark")${NC}"
    echo -e "  🌐 Spark Local: ${CYAN}$(get_service_url "spark-local")${NC}"
    echo -e "  🌐 Jenkins:     ${CYAN}$(get_service_url "jenkins")${NC}"
    echo -e "  🌐 Flower:      ${CYAN}$(get_service_url "flower")${NC}"
}

# Função principal
main() {
    # Inicialização comum
    common_init
    
    # Header
    show_header "🚀 BigData Environment Startup" "Iniciando o ambiente BigData completo"
    
    # Validações
    validate_required_vars
    
    # Iniciar serviços
    start_services
    
    # Mostrar URLs
    show_startup_urls
    
    # Dicas finais
    show_section "Credenciais" "🔐"
    echo -e "  ${INFO} Credenciais configuradas no arquivo .env"
    
    show_useful_commands
}

# Executar função principal
main "$@"