#!/bin/bash

# Carregar funções comuns
source "$(dirname "$0")/common.sh"

# =================================================================================================
# 🛑 BIGDATA STOP SCRIPT
# =================================================================================================
# Script para parar o ambiente BigData
# Uso: ./stop.sh ou make stop
# =================================================================================================

# Função para parar os serviços
stop_services() {
    show_section "Parando Serviços" "${CONTAINER}"
    
    echo -e "  ${INFO} Parando containers..."
    $COMPOSE_CMD down
    
    echo -e "  ${SUCCESS} Ambiente parado com sucesso!"
}

# Função principal
main() {
    # Inicialização comum
    common_init
    
    # Header
    show_header "🛑 BigData Environment Shutdown" "Parando o ambiente BigData"
    
    # Parar serviços
    stop_services
    
    # Dicas finais
    show_section "Próximos Passos" "💡"
    echo -e "  ${INFO} Para reiniciar: ${CYAN}make start${NC}"
    echo -e "  ${INFO} Para verificar status: ${CYAN}make status${NC}"
    echo -e "  ${INFO} Para remover volumes: ${CYAN}docker volume prune${NC}"
}

# Executar função principal
main "$@"