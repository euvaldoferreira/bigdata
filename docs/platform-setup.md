# Configuração de Plataforma Docker

## Visão Geral

O projeto BigData suporta múltiplas arquiteturas Docker através da variável de ambiente `DOCKER_PLATFORM`.

## Plataformas Suportadas

| Ambiente | Plataforma Recomendada | Detecção Automática |
|----------|----------------------|-------------------|
| **GitHub Codespaces** | `linux/amd64` | ✅ Automática |
| **Gitpod** | `linux/amd64` | ✅ Automática |
| **Mac Intel** | `linux/amd64` | ✅ Automática |
| **Mac M1/M2** | `linux/arm64` | ✅ Automática |
| **Windows/Linux** | `linux/amd64` | ✅ Automática |
| **Servidores Linux** | `linux/amd64` | ✅ Automática |

## Configuração Automática

### Detectar e Configurar Automaticamente
```bash
make detect-platform
```

Este comando:
1. 🔍 Detecta automaticamente sua plataforma
2. 📝 Cria/atualiza o arquivo `.env` 
3. ✅ Configura `DOCKER_PLATFORM` adequadamente

### Configuração Manual

Se preferir configurar manualmente, edite o arquivo `.env`:

```bash
# Para Intel/AMD (padrão)
DOCKER_PLATFORM=linux/amd64

# Para Apple Silicon (M1/M2)
DOCKER_PLATFORM=linux/arm64
```

## Como Funciona

### 1. Detecção Automática
O script `scripts/detect-platform.sh` detecta:
- ✅ Se está no GitHub Codespaces (`$CODESPACES`)
- ✅ Se está no Gitpod (`$GITPOD_WORKSPACE_ID`) 
- ✅ Arquitetura do sistema (`uname -m`)

### 2. Configuração nos Docker Compose
Todos os serviços Airflow usam:
```yaml
platform: ${DOCKER_PLATFORM:-linux/amd64}
```

O valor padrão é `linux/amd64` se a variável não estiver definida.

## Solução de Problemas

### Erro "exec format error"
```bash
# Execute para reconfigurar
make detect-platform

# Rebuild das imagens
docker-compose down
docker-compose pull
make start
```

### Mac M1/M2 - Imagens Lentas
```bash
# Configure para ARM64
echo "DOCKER_PLATFORM=linux/arm64" >> .env

# Ou use detecção automática
make detect-platform
```

### GitHub Codespaces - Problemas de Compatibilidade
```bash
# Force AMD64 (recomendado)
echo "DOCKER_PLATFORM=linux/amd64" >> .env
make start
```

## Ambientes de Desenvolvimento

### Setup Inicial Recomendado
```bash
# 1. Clone o repositório
git clone <repo-url>
cd containers

# 2. Configure plataforma automaticamente
make detect-platform

# 3. Inicie o ambiente
make start
```

### Verificar Configuração Atual
```bash
# Ver plataforma detectada
./scripts/detect-platform.sh

# Ver configuração no .env
grep DOCKER_PLATFORM .env
```

## Notas Técnicas

- **Compatibilidade**: ARM64 oferece melhor performance em Mac M1/M2
- **Estabilidade**: AMD64 é mais amplamente testado
- **GitHub Codespaces**: Sempre use AMD64 para compatibilidade
- **Multi-arch**: Docker automaticamente faz pull da imagem correta

## Troubleshooting por Ambiente

### GitHub Codespaces
- ✅ Sempre usar `linux/amd64`
- ✅ Comando `make detect-platform` configura automaticamente
- ❌ ARM64 não é suportado

### Mac M1/M2 
- ✅ Preferir `linux/arm64` para performance
- ✅ `linux/amd64` funciona mas é mais lento
- ✅ Detecção automática escolhe ARM64

### Docker Desktop (Windows/Linux)
- ✅ Sempre `linux/amd64`
- ✅ Configuração automática funciona perfeitamente