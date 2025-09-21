#!/bin/bash
set -e

# Detectar comando docker
CMD=$(command -v docker-compose >/dev/null 2>&1 && echo "docker-compose" || echo "docker compose")

echo "🛑 Parando ambiente BigData..."
$CMD down

echo "✅ Ambiente parado!"
