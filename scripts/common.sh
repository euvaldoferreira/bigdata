#!/bin/bash

# =================================================================================================
# 🛠️  BIGDATA COMMON FUNCTIONS LIBRARY
# =================================================================================================
# Arquivo de funções comuns reutilizáveis para todos os scripts do projeto BigData
# Use: source scripts/common.sh
# =================================================================================================

# Cores para output (reutilizadas em todos os scripts)
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export RED='\033[0;31m'
export BLUE='\033[0;34m'
export CYAN='\033[0;36m'
export PURPLE='\033[0;35m'
export WHITE='\033[1;37m'
export NC='\033[0m' # No Color

# Símbolos comuns
export SUCCESS="✅"
export ERROR="❌"
export WARNING="⚠️"
export INFO="ℹ️"
export ROCKET="🚀"
export GEAR="⚙️"
export NETWORK="🌐"
export CONTAINER="🐳"
export VOLUME="💿"
export LOGS="📋"

# =================================================================================================
# 🔍 FUNÇÕES DE DETECÇÃO E VERIFICAÇÃO
# =================================================================================================

# Função para verificar se um comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Função para verificar se o usuário tem permissões docker
setup_docker_commands() {
    if groups | grep -q docker; then
        export DOCKER_CMD="docker"
        export COMPOSE_CMD="docker-compose"
    else
        export DOCKER_CMD="sudo docker"
        export COMPOSE_CMD="sudo docker-compose"
    fi
    
    # Detectar se docker-compose é plugin ou standalone
    if command_exists docker && docker compose version >/dev/null 2>&1; then
        export COMPOSE_CMD="${DOCKER_CMD} compose"
    elif command_exists docker-compose; then
        if [ "$DOCKER_CMD" = "sudo docker" ]; then
            export COMPOSE_CMD="sudo docker-compose"
        else
            export COMPOSE_CMD="docker-compose"
        fi
    fi
}

# Função para verificar se Docker está rodando
check_docker_running() {
    setup_docker_commands
    
    if ! $DOCKER_CMD info >/dev/null 2>&1; then
        echo -e "${RED}${ERROR} Docker não está rodando ou sem permissões adequadas${NC}"
        echo -e "${YELLOW}💡 Tente: sudo systemctl start docker${NC}"
        return 1
    fi
    return 0
}

# Função para detectar arquitetura/plataforma
detect_platform() {
    # Verificar se estamos no GitHub Codespaces
    if [ -n "$CODESPACES" ]; then
        echo "linux/amd64"
        return
    fi
    
    # Verificar se estamos no Gitpod
    if [ -n "$GITPOD_WORKSPACE_ID" ]; then
        echo "linux/amd64"
        return
    fi
    
    # Detectar arquitetura do sistema
    ARCH=$(uname -m)
    case $ARCH in
        x86_64|amd64)
            echo "linux/amd64"
            ;;
        arm64|aarch64)
            echo "linux/arm64"
            ;;
        *)
            echo "linux/amd64"  # Default
            ;;
    esac
}

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
    
    echo $start_port  # Se não encontrou, retorna a original
}

# =================================================================================================
# 📁 FUNÇÕES DE ARQUIVO E CONFIGURAÇÃO
# =================================================================================================

# Função para carregar .env com tratamento de erro
load_env_file() {
    local env_file="${1:-.env}"
    
    if [ -f "$env_file" ]; then
        # Carregar apenas linhas válidas (não comentários nem vazias)
        set -a  # Exportar automaticamente
        source <(grep -E '^[A-Z_][A-Z0-9_]*=' "$env_file" | grep -v '^#')
        set +a
        echo -e "${SUCCESS} ${GREEN}Arquivo $env_file carregado${NC}"
        return 0
    else
        echo -e "${WARNING} ${YELLOW}Arquivo $env_file não encontrado. Usando valores padrão.${NC}"
        return 1
    fi
}

# Função para validar variáveis obrigatórias
validate_required_vars() {
    local required_vars=("$@")
    local missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            missing_vars+=("$var")
        fi
    done
    
    if [ ${#missing_vars[@]} -gt 0 ]; then
        echo -e "${ERROR} ${RED}Erro: As seguintes variáveis obrigatórias não estão definidas:${NC}"
        printf "   ${RED}- %s${NC}\n" "${missing_vars[@]}"
        echo -e "${INFO} ${BLUE}Configure-as no arquivo .env${NC}"
        return 1
    fi
    
    return 0
}

# =================================================================================================
# 🌐 FUNÇÕES DE URL E REDE
# =================================================================================================

# Função para detectar protocolo baseado em configurações globais
detect_protocol() {
    local protocol="http"
    
    # Verificar configurações globais de HTTPS
    if [ "${USE_HTTPS:-false}" = "true" ] || [ "${SSL_ENABLED:-false}" = "true" ]; then
        protocol="https"
    fi
    
    # Se estiver rodando em ambiente de produção (domain específico), provavelmente usa HTTPS
    if [ ! -z "${DOMAIN}" ] && [ "${DOMAIN}" != "localhost" ] && [ "${DOMAIN}" != "127.0.0.1" ]; then
        protocol="https"
    fi
    
    echo "$protocol"
}

# Função para verificar se um serviço específico tem HTTPS habilitado
check_service_https() {
    local service=$1
    local has_https=false
    
    case "$service" in
        "airflow")
            if [ "${AIRFLOW_HTTPS:-false}" = "true" ] || [ ! -z "${AIRFLOW_SSL_CERT}" ]; then
                has_https=true
            fi
            ;;
        "minio")
            if [ "${MINIO_HTTPS:-false}" = "true" ] || [ ! -z "${MINIO_SSL_CERT}" ]; then
                has_https=true
            fi
            ;;
        "jenkins")
            if [ "${JENKINS_HTTPS:-false}" = "true" ] || [ ! -z "${JENKINS_SSL_CERT}" ]; then
                has_https=true
            fi
            ;;
        "jupyter")
            if [ "${JUPYTER_HTTPS:-false}" = "true" ] || [ ! -z "${JUPYTER_SSL_CERT}" ]; then
                has_https=true
            fi
            ;;
    esac
    
    echo "$has_https"
}

# Função para obter porta específica de um serviço
get_service_port() {
    local service=$1
    local port=""
    
    case "$service" in
        "airflow")
            port="${AIRFLOW_PORT:-8080}"
            ;;
        "minio")
            port="${MINIO_CONSOLE_PORT:-9001}"
            ;;
        "jenkins")
            port="${JENKINS_PORT:-8082}"
            ;;
        "jupyter")
            port="${JUPYTER_PORT:-8888}"
            ;;
        "spark")
            port="${SPARK_UI_PORT:-8081}"
            ;;
        "spark-local")
            port="${SPARK_LOCAL_UI_PORT:-4040}"
            ;;
        "flower")
            port="${FLOWER_PORT:-5555}"
            ;;
        "redis")
            port="${REDIS_PORT:-6379}"
            ;;
        "postgres")
            port="${POSTGRES_PORT:-5432}"
            ;;
    esac
    
    echo "$port"
}

# Função para obter path de proxy reverso de um serviço
get_service_proxy_path() {
    local service=$1
    local path=""
    
    if [ "${USE_REVERSE_PROXY:-false}" = "true" ]; then
        case "$service" in
            "airflow") path="/airflow" ;;
            "minio") path="/minio" ;;
            "jenkins") path="/jenkins" ;;
            "jupyter") path="/jupyter" ;;
            "spark") path="/spark" ;;
            "flower") path="/flower" ;;
        esac
    fi
    
    echo "$path"
}

# Função para construir URL com verificação de portas padrão
build_url_with_port() {
    local protocol=$1
    local host=$2
    local port=$3
    local path=${4:-""}
    
    local url="${protocol}://${host}"
    
    # Adicionar porta apenas se não for porta padrão
    if [ "$protocol" = "https" ] && [ "$port" != "443" ] && [ "$port" != "" ]; then
        url="${url}:${port}"
    elif [ "$protocol" = "http" ] && [ "$port" != "80" ] && [ "$port" != "" ]; then
        url="${url}:${port}"
    fi
    
    # Adicionar path se especificado
    if [ ! -z "$path" ]; then
        url="${url}${path}"
    fi
    
    echo "$url"
}

# Função para determinar protocolo e host baseado em configurações
get_service_url() {
    local service=$1
    local port=${2:-""}
    local path=${3:-""}
    
    # Obter protocolo baseado em configurações globais
    local protocol=$(detect_protocol)
    local host="${SERVER_HOST:-${SERVER_IP:-localhost}}"
    
    # Verificar se o serviço específico tem HTTPS habilitado
    if [ "$(check_service_https "$service")" = "true" ]; then
        protocol="https"
    fi
    
    # Obter porta específica do serviço se não fornecida
    if [ -z "$port" ]; then
        port=$(get_service_port "$service")
    fi
    
    # Se estiver usando proxy reverso em produção, ajustar configurações
    if [ ! -z "${DOMAIN}" ] && [ "${DOMAIN}" != "localhost" ] && [ "${DOMAIN}" != "127.0.0.1" ]; then
        host="${DOMAIN}"
        
        # Com proxy reverso, usar portas padrão e paths específicos
        if [ "${USE_REVERSE_PROXY:-false}" = "true" ]; then
            path=$(get_service_proxy_path "$service")
            
            # Com proxy reverso, usar portas padrão
            if [ "$protocol" = "https" ]; then
                port="443"
            else
                port="80"
            fi
        fi
    fi
    
    # Construir URL usando função auxiliar
    build_url_with_port "$protocol" "$host" "$port" "$path"
}

# =================================================================================================
# 🐳 FUNÇÕES DOCKER ESPECÍFICAS
# =================================================================================================

# Função para verificar status de um container
check_container_status() {
    local container_name=$1
    
    setup_docker_commands
    
    if $DOCKER_CMD ps --format "{{.Names}}" | grep -q "^${container_name}$"; then
        local status=$($DOCKER_CMD ps --format "{{.Status}}" --filter "name=^${container_name}$")
        if echo "$status" | grep -q "Up"; then
            echo "running"
            return 0
        else
            echo "unhealthy"
            return 1
        fi
    else
        echo "stopped"
        return 2
    fi
}

# Função para verificar se um serviço BigData está rodando
check_bigdata_service() {
    local service_name=$1
    local port=$2
    local description=$3
    
    setup_docker_commands
    
    # Verificar se o container está rodando
    if $DOCKER_CMD ps --format "table {{.Names}}\t{{.Status}}" | grep -q "bigdata_${service_name}"; then
        local status=$($DOCKER_CMD ps --format "{{.Status}}" --filter "name=bigdata_${service_name}")
        if echo "$status" | grep -q "Up"; then
            echo -e "  ${SUCCESS} ${GREEN}${service_name}${NC} - ${GREEN}Running${NC} ($status)"
            if [ ! -z "$port" ]; then
                # Extrair nome do serviço (primeira parte antes do _)
                local service_type=$(echo "$service_name" | sed 's/_.*$//')
                local url=$(get_service_url "$service_type" "$port")
                echo -e "     ${NETWORK} $url"
            fi
            if [ ! -z "$description" ]; then
                echo -e "     🔗 $description"
            fi
            return 0
        else
            echo -e "  ${ERROR} ${RED}${service_name}${NC} - ${RED}Not healthy${NC} ($status)"
            return 1
        fi
    else
        echo -e "  ⭕ ${YELLOW}${service_name}${NC} - ${YELLOW}Not running${NC}"
        return 2
    fi
}

# Função para verificar conectividade da rede BigData
check_bigdata_network() {
    setup_docker_commands
    
    echo -e "\n${BLUE}${NETWORK} Conectividade de Rede:${NC}"
    
    if $DOCKER_CMD network ls | grep -q "bigdata"; then
        echo -e "  ${SUCCESS} ${GREEN}Rede 'bigdata'${NC} - Criada"
        
        # Listar containers na rede
        local containers_in_network=$($DOCKER_CMD network inspect bigdata --format='{{range .Containers}}{{.Name}} {{end}}' 2>/dev/null)
        if [ ! -z "$containers_in_network" ]; then
            echo -e "  📡 Containers conectados: ${CYAN}$containers_in_network${NC}"
        fi
        return 0
    else
        echo -e "  ${ERROR} ${RED}Rede 'bigdata'${NC} - Não encontrada"
        return 1
    fi
}

# Função para verificar volumes BigData
check_bigdata_volumes() {
    setup_docker_commands
    
    echo -e "\n${BLUE}${VOLUME} Volumes Docker:${NC}"
    
    local bigdata_volumes=$($DOCKER_CMD volume ls --format "{{.Name}}" | grep containers)
    if [ ! -z "$bigdata_volumes" ]; then
        echo -e "  📁 Volumes BigData encontrados:"
        echo "$bigdata_volumes" | while read volume; do
            local size=$($DOCKER_CMD system df -v | grep "$volume" | awk '{print $3}' | head -1)
            echo -e "     📦 ${CYAN}$volume${NC} ${size:+($size)}"
        done
        return 0
    else
        echo -e "  ${INFO} Nenhum volume BigData encontrado"
        return 1
    fi
}

# =================================================================================================
# 📊 FUNÇÕES DE LOGGING E MONITORAMENTO
# =================================================================================================

# Função para verificar logs recentes de erros
check_service_logs() {
    local service_name=$1
    local time_period=${2:-"5m"}
    
    setup_docker_commands
    
    if $DOCKER_CMD ps --format "{{.Names}}" | grep -q "bigdata_${service_name}"; then
        local error_count=$($DOCKER_CMD logs --since="$time_period" "bigdata_${service_name}" 2>&1 | grep -i "error\|fail\|exception" | wc -l)
        if [ "$error_count" -gt 0 ]; then
            echo -e "  ${WARNING} ${YELLOW}$service_name${NC} - $error_count erro(s) nos últimos $time_period"
            return 1
        else
            echo -e "  ${SUCCESS} ${GREEN}$service_name${NC} - Sem erros recentes"
            return 0
        fi
    else
        echo -e "  ${INFO} ${service_name} - Container não está rodando"
        return 2
    fi
}

# =================================================================================================
# 🚀 FUNÇÕES DE OUTPUT E INTERFACE
# =================================================================================================

# Função para exibir header padronizado
show_header() {
    local title="$1"
    local subtitle="$2"
    
    echo -e "${BLUE}${title}${NC}"
    echo -e "${BLUE}$(printf '=%.0s' $(seq 1 ${#title}))${NC}"
    if [ ! -z "$subtitle" ]; then
        echo -e "${subtitle}\n"
    else
        echo ""
    fi
}

# Função para exibir seção
show_section() {
    local title="$1"
    local icon="$2"
    
    echo -e "\n${BLUE}${icon} ${title}:${NC}"
}

# Função para exibir mensagem de sucesso
show_success() {
    local message="$1"
    echo -e "  ${SUCCESS} ${GREEN}${message}${NC}"
}

# Função para exibir mensagem de erro
show_error() {
    local message="$1"
    echo -e "  ${ERROR} ${RED}${message}${NC}"
}

# Função para exibir mensagem de aviso
show_warning() {
    local message="$1"
    echo -e "  ${WARNING} ${YELLOW}${message}${NC}"
}

# Função para exibir mensagem de informação
show_info() {
    local message="$1"
    echo -e "  ${INFO} ${message}"
}

# Função para exibir comando com formatação
show_command() {
    local command="$1"
    echo -e "  ${CYAN}${command}${NC}"
}

# Função para exibir URL com formatação
show_url() {
    local url="$1"
    local description="$2"
    if [ ! -z "$description" ]; then
        echo -e "  🌐 ${description}: ${CYAN}${url}${NC}"
    else
        echo -e "  🌐 ${CYAN}${url}${NC}"
    fi
}

# Função para exibir comandos úteis
show_useful_commands() {
    show_section "Comandos Úteis" "📚"
    echo -e "  make start     - Iniciar ambiente"
    echo -e "  make stop      - Parar ambiente"
    echo -e "  make status    - Verificar status dos serviços"
    echo -e "  make logs      - Ver logs dos serviços"
    echo -e "  make health    - Verificar saúde dos serviços"
    echo -e "  make ps-all    - Listar todos os containers"
}

# =================================================================================================
# 🔧 FUNÇÕES DE SETUP E INICIALIZAÇÃO
# =================================================================================================

# Função de inicialização comum para todos os scripts
common_init() {
    # Configurar comandos Docker
    setup_docker_commands
    
    # Carregar .env se existir
    load_env_file
    
    # Verificar se Docker está rodando
    if ! check_docker_running; then
        exit 1
    fi
    
    return 0
}

# Função para executar teste padronizado
run_test() {
    local test_name="$1"
    local test_command="$2"
    local verbose="${3:-false}"
    
    if [ "$verbose" = "true" ]; then
        echo -e "  🔍 Testando: ${CYAN}$test_name${NC}"
        
        if eval "$test_command"; then
            show_success "PASS: $test_name"
            return 0
        else
            show_error "FAIL: $test_name"
            return 1
        fi
    else
        echo -n "  🔍 $test_name... "
        
        if eval "$test_command" >/dev/null 2>&1; then
            echo -e "${SUCCESS} PASS"
            return 0
        else
            echo -e "${ERROR} FAIL"
            return 1
        fi
    fi
}

# Função para configurar git com práticas recomendadas
setup_git_config() {
    local user_name="${1:-}"
    
    show_info "Configurando Git com práticas recomendadas..."
    
    git config core.hooksPath .githooks 2>/dev/null || true
    git config commit.template .gitmessage 2>/dev/null || true
    git config pull.rebase true 2>/dev/null || true
    
    if [ ! -z "$user_name" ]; then
        show_info "Configurando usuário: $user_name"
    fi
    
    show_success "Git configurado com sucesso"
}

# =================================================================================================
# 📝 EXEMPLO DE USO
# =================================================================================================

# Para usar essas funções em outros scripts:
# 
# #!/bin/bash
# source "$(dirname "$0")/common.sh"
# 
# # Inicialização comum
# common_init
# 
# # Usar funções
# show_header "Meu Script" "Descrição do script"
# check_bigdata_service "airflow_webserver" "8080" "Airflow UI"
# show_useful_commands

# =================================================================================================
# 🏁 FIM DO ARQUIVO COMMON.SH
# =================================================================================================