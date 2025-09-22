#!/bin/bash

# Carregar funções comuns
source "$(dirname "$0")/common.sh"

# =================================================================================================
# 🧪 BIGDATA BASIC TESTS SCRIPT
# =================================================================================================
# Testes básicos para o ambiente BigData
# Uso: ./test-basic.sh ou make test-basic
# =================================================================================================

# Contador de testes
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

# Função para executar teste
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    echo -n "  🔍 $test_name... "
    
    if eval "$test_command" >/dev/null 2>&1; then
        echo -e "${SUCCESS} PASS"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${ERROR} FAIL"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Função para executar teste com saída verbosa
run_test_verbose() {
    local test_name="$1"
    local test_command="$2"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    echo -e "  🔍 Testando: ${CYAN}$test_name${NC}"
    
    if eval "$test_command"; then
        echo -e "  ${SUCCESS} PASS: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${ERROR} FAIL: $test_name"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    echo ""
}

# Função para testar configuração do ambiente
test_environment_setup() {
    show_section "Configuração do Ambiente" "📋"
    
    run_test "Arquivo .env existe" "[ -f .env ]"
    run_test "Docker está rodando" "docker info"
    run_test "Docker Compose disponível" "[ -n \"$DOCKER_CMD\" ]"
    run_test "Makefile válido" "make --dry-run help"
}

# Função para testar comandos básicos
test_basic_commands() {
    show_section "Comandos Básicos" "🚀"
    
    run_test_verbose "Comando pre-check" "make pre-check"
    run_test_verbose "Validação Docker Compose" "$DOCKER_CMD config"
    run_test "Comando help" "make help"
}

# Função para testar inicialização do ambiente
test_environment_startup() {
    show_section "Inicialização do Ambiente" "🐳"
    
    echo -e "  ${INFO} Iniciando ambiente de laboratório (pode demorar)..."
    if timeout 300 make lab >/dev/null 2>&1; then
        echo -e "  ${SUCCESS} Ambiente de laboratório iniciado"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        
        # Aguardar serviços ficarem prontos
        echo -e "  ${INFO} Aguardando serviços ficarem prontos..."
        sleep 30
        
        # Testar comandos de status
        run_test_verbose "Comando status" "make status"
        run_test_verbose "Verificação de saúde" "make health"
        
        # Testar serviços específicos
        test_individual_services
        
        echo -e "  ${INFO} Limpando ambiente..."
        make clean >/dev/null 2>&1 || true
        
    else
        echo -e "  ${ERROR} Falha ao iniciar ambiente de laboratório"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
}

# Função para testar serviços individuais
test_individual_services() {
    show_section "Serviços Individuais" "🔍"
    
    # Carregar configurações
    load_env_if_exists
    
    # URLs dos serviços
    local jupyter_url=$(get_service_url "jupyter")
    local minio_url=$(get_service_url "minio")
    
    # Teste Jupyter
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    if curl -f "$jupyter_url" >/dev/null 2>&1; then
        echo -e "  ${SUCCESS} Jupyter respondendo"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${WARNING} Jupyter não responde (pode ser normal)"
    fi
    
    # Teste MinIO
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    if curl -f "$minio_url" >/dev/null 2>&1; then
        echo -e "  ${SUCCESS} MinIO respondendo"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${WARNING} MinIO não responde (pode ser normal)"
    fi
}

# Função para mostrar resultados dos testes
show_test_results() {
    show_section "Resultados dos Testes" "📊"
    
    echo -e "  Total de Testes: ${CYAN}$TESTS_TOTAL${NC}"
    echo -e "  Aprovados:       ${GREEN}$TESTS_PASSED${NC}"
    echo -e "  Reprovados:      ${RED}$TESTS_FAILED${NC}"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo ""
        echo -e "  ${SUCCESS} ${GREEN}🎉 Todos os testes básicos passaram!${NC}"
        echo -e "  ${INFO} O ambiente BigData está pronto para desenvolvimento."
        return 0
    else
        echo ""
        echo -e "  ${ERROR} ${RED}❌ Alguns testes falharam.${NC}"
        echo -e "  ${WARNING} Verifique os problemas acima antes de prosseguir."
        return 1
    fi
}

# Função principal
main() {
    # Inicialização comum
    common_init
    
    # Header
    show_header "🧪 BigData Basic Tests" "Testes básicos para o ambiente BigData"
    
    # Executar testes
    test_environment_setup
    test_basic_commands
    test_environment_startup
    
    # Mostrar resultados
    show_test_results
    local exit_code=$?
    
    exit $exit_code
}

# Executar função principal
main "$@"