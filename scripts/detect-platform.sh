#!/bin/bash

# Script para detectar automaticamente a plataforma Docker adequada
# Usado para configurar DOCKER_PLATFORM baseado no ambiente atual

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
            # Default para amd64 se não conseguir detectar
            echo "linux/amd64"
            ;;
    esac
}

# Se executado diretamente, mostrar a plataforma
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    echo "Plataforma detectada: $(detect_platform)"
fi