#!/bin/bash

# Script para parar todos os serviços do ambiente BigData

set -e

echo "🛑 Parando ambiente BigData..."
echo "================================================"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Ir para diretório do projeto
cd "$(dirname "$0")/.."

# Verificar se há containers rodando
if [ "$(docker-compose ps -q)" ]; then
    print_status "Parando todos os serviços..."
    
    # Parar todos os serviços
    docker-compose down
    
    print_success "Todos os serviços foram parados!"
else
    print_warning "Nenhum serviço está rodando"
fi

# Opção para limpar volumes (apenas se especificado)
if [ "$1" = "--clean" ] || [ "$1" = "-c" ]; then
    print_warning "Removendo volumes e dados persistentes..."
    
    read -p "Tem certeza que deseja remover TODOS os dados? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker-compose down -v
        docker system prune -f
        print_status "Volumes removidos!"
    else
        print_status "Volumes mantidos"
    fi
fi

echo
print_success "🏁 Ambiente BigData parado com sucesso!"
echo
echo "💡 Para iniciar novamente: make start"
echo "💡 Para limpar todos os dados: make clean"