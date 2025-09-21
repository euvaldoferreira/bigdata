# 🌐 Gerenciamento de Portas

## Visão Geral

O projeto BigData utiliza múltiplas portas para seus serviços. Este documento explica como gerenciar portas de forma flexível para evitar conflitos.

## 🚨 Problema das Portas Fixas

### ❌ Limitações das portas fixas:
- **Conflitos em ambientes compartilhados** (Codespaces, Gitpod)
- **Impossibilidade de múltiplas instâncias** no mesmo host
- **Bloqueios por firewalls corporativos**
- **Conflitos com outros serviços** locais

### ✅ Solução com detecção automática:
- **Detecção inteligente** de portas disponíveis
- **Configuração automática** do arquivo `.env`
- **Verificação de conflitos** antes da execução
- **URLs dinâmicas** baseadas nas portas detectadas

## 🔧 Comandos Disponíveis

### Detecção e Configuração Automática
```bash
# Detecta portas disponíveis e configura automaticamente
make detect-ports
```

**O que faz:**
1. 🔍 Verifica portas disponíveis a partir dos padrões
2. 📝 Atualiza o arquivo `.env` automaticamente
3. 💾 Cria backup do `.env` anterior
4. ✅ Mostra configuração aplicada

### Verificação de Conflitos
```bash
# Verifica se há conflitos de portas
make check-ports
```

**Saída esperada:**
- ✅ `Nenhum conflito de porta encontrado`
- 🚨 `Encontrados X conflitos de porta`

### URLs de Acesso
```bash
# Mostra URLs baseadas na configuração atual
make urls
```

**Exemplo de saída:**
```
🌐 URLs de acesso:
   Airflow:     http://localhost:8080
   MinIO UI:    http://localhost:9001
   Jupyter:     http://localhost:8888
   Spark UI:    http://localhost:8081
   Jenkins:     http://localhost:8082
   Flower:      http://localhost:5555
```

## 📋 Portas Padrão

| Serviço | Porta Padrão | Variável |
|---------|--------------|----------|
| **Airflow Web** | 8080 | `AIRFLOW_PORT` |
| **MinIO API** | 9000 | `MINIO_API_PORT` |
| **MinIO Console** | 9001 | `MINIO_CONSOLE_PORT` |
| **Jupyter** | 8888 | `JUPYTER_PORT` |
| **Spark UI** | 8081 | `SPARK_UI_PORT` |
| **Spark Local UI** | 4040 | `SPARK_LOCAL_UI_PORT` |
| **Jenkins** | 8082 | `JENKINS_PORT` |
| **Flower** | 5555 | `FLOWER_PORT` |

## 🛠️ Configuração Manual

### Configurar Portas Específicas
```bash
# Editar arquivo .env diretamente
nano .env

# Exemplo de configuração personalizada:
AIRFLOW_PORT=8090
JUPYTER_PORT=8889
JENKINS_PORT=8083
```

### Configuração por Ambiente

**Para Desenvolvimento Local:**
```bash
# Usar portas padrão
AIRFLOW_PORT=8080
JUPYTER_PORT=8888
```

**Para GitHub Codespaces:**
```bash
# Detectar automaticamente (recomendado)
make detect-ports
```

**Para Produção:**
```bash
# Usar portas específicas da infraestrutura
AIRFLOW_PORT=80
JUPYTER_PORT=443
```

## 🔄 Fluxo de Trabalho Recomendado

### Setup Inicial
```bash
# 1. Detectar plataforma e portas
make detect-platform
make detect-ports

# 2. Verificar configuração
make check-ports
make urls

# 3. Iniciar ambiente
make start
```

### Resolução de Conflitos
```bash
# Se houver conflitos de porta durante execução:
make stop-all
make detect-ports  # Reconfigura para portas disponíveis
make start
```

### Múltiplas Instâncias
```bash
# Para rodar múltiplas instâncias (ex: dev + testing):

# Instância 1 (pasta projeto1)
cd projeto1
make detect-ports  # Configura portas 8080, 9000, etc.

# Instância 2 (pasta projeto2) 
cd projeto2
make detect-ports  # Configura portas 8081, 9001, etc.
```

## 🚨 Troubleshooting

### Erro "Port already in use"
```bash
# Solução automática
make detect-ports
make start

# Verificação manual
sudo netstat -tlnp | grep :8080
```

### Portas Não Acessíveis
```bash
# Verificar se serviços estão rodando
make status

# Verificar URLs atuais
make urls

# Verificar logs para erros de binding
make logs airflow-webserver
```

### Firewall/Proxy Issues
```bash
# Para ambientes corporativos, configure portas permitidas:
echo "AIRFLOW_PORT=3000" >> .env
echo "JUPYTER_PORT=3001" >> .env
echo "JENKINS_PORT=3002" >> .env
```

## 🔧 Scripts Internos

### `scripts/detect-ports.sh`
Script principal que implementa a lógica de detecção:

```bash
# Uso direto do script
./scripts/detect-ports.sh detect   # Detecta e configura
./scripts/detect-ports.sh check    # Verifica conflitos  
./scripts/detect-ports.sh urls     # Mostra URLs
```

**Algoritmo de detecção:**
1. Tenta porta padrão (ex: 8080)
2. Se ocupada, tenta próxima (8081, 8082...)
3. Testa até 10 portas consecutivas
4. Se não encontrar, mantém a original

## 💡 Boas Práticas

### ✅ Recomendado:
- **Sempre usar `make detect-ports`** em novos ambientes
- **Verificar conflitos** antes de iniciar: `make check-ports`
- **Usar URLs dinâmicas** com `make urls`
- **Backup automático** do `.env` é feito automaticamente

### ❌ Evitar:
- **Hardcoding de portas** em scripts ou documentação
- **Assumir portas específicas** disponíveis
- **Ignorar conflitos** de porta
- **Não testar** em diferentes ambientes

## 🌍 Ambientes Específicos

### GitHub Codespaces
```bash
# Codespaces expõe portas automaticamente
make detect-ports  # Configura portas disponíveis
make start
# URLs serão https://CODESPACE-PORT.githubpreview.dev
```

### Gitpod  
```bash
# Similar ao Codespaces
make detect-ports
make start
# URLs serão https://PORT-WORKSPACE-ID.ws-REGION.gitpod.io
```

### Docker Desktop (Local)
```bash
# Máximo controle sobre portas
make detect-ports  # Ou configure manualmente
make start
# URLs serão http://localhost:PORT
```

### Servidor Linux
```bash
# Configure portas específicas da infraestrutura
nano .env  # Definir portas permitidas
make check-ports
make start
```

## 📚 Documentação Relacionada

- **[Troubleshooting](troubleshooting.md)** - Solução de problemas gerais
- **[Setup Personalizado](setup-personalizado.md)** - Configuração para desenvolvedores
- **[Comandos](commands.md)** - Referência completa do Makefile