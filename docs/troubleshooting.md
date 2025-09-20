# 🚨 Troubleshooting - Soluções de Problemas

## 🔧 Problemas de Instalação

### 1. **Permission denied while trying to connect to Docker daemon**
```bash
# Solução: Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER

# Depois faça logout/login ou:
newgrp docker

# Verificar se funcionou:
groups | grep docker
```

### 2. **Docker Compose command not found**
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install docker-compose-plugin

# CentOS/RHEL
sudo yum install docker-compose-plugin

# Manual (última versão)
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

## ⚡ Problemas de Execução

### 3. **Erro "Port already in use"**
```bash
# Verificar portas ocupadas
sudo netstat -tlnp | grep :8080

# Parar todos os containers
make stop-all

# Ou alterar portas no arquivo .env
nano .env
```

### 4. **Containers não iniciam (recursos insuficientes)**
```bash
# Verificar recursos disponíveis
make requirements

# Usar ambiente mais leve
make minimal  # Em vez de make start
```

## 🛠️ Problemas Específicos do Airflow

### 5. **ModuleNotFoundError: No module named 'airflow'**
```bash
# PROBLEMA: Versão antiga do Airflow em cache/volumes antigos
# SOLUÇÃO: Limpeza completa do Airflow

# Opção 1: Limpeza específica do Airflow (recomendada)
make clean-airflow
make start

# Opção 2: Reset completo do ambiente
make reset-env
make start

# Verificar se funcionou
make health
```

### 6. **Too old Airflow version**
```bash
# PROBLEMA: Containers/imagens antigas conflitando
# SOLUÇÃO: Limpeza e rebuild

# 1. Parar tudo
make stop-all

# 2. Limpar imagens antigas
docker images apache/airflow --format "table {{.Repository}}:{{.Tag}}\t{{.ID}}"
docker rmi $(docker images apache/airflow:2.7.0* -q) 2>/dev/null || true

# 3. Fazer pull das novas imagens
make pull

# 4. Iniciar novamente
make start
```

### 7. **Airflow não carrega DAGs**
```bash
# Verificar logs do Airflow
make logs-airflow

# Verificar permissões da pasta dags
ls -la airflow/dags/

# Corrigir permissões
sudo chown -R 1000:0 airflow/dags/
sudo chmod -R 755 airflow/dags/
```

## ⚡ Problemas do Spark

### 8. **Spark Master não conecta Workers**
```bash
# Verificar rede
make debug-network

# Verificar logs
make spark-logs

# Reiniciar cluster
make spark-restart
```

### 9. **Spark UI não acessível**
```bash
# Verificar se o container está rodando
docker-compose ps spark-master

# Verificar logs
make spark-master-logs

# Verificar porta
curl -I http://localhost:8081
```

## 💾 Problemas de Storage

### 10. **MinIO não inicia**
```bash
# Verificar logs
make minio-logs

# Verificar permissões dos volumes
ls -la data/minio/

# Corrigir permissões
sudo chown -R 1000:1000 data/minio/
```

### 11. **Espaço em disco insuficiente**
```bash
# Verificar uso
df -h

# Limpar dados antigos
docker system prune -f

# Remover volumes não utilizados
docker volume prune -f
```

## 🌐 Problemas de Rede

### 12. **Serviços não se comunicam**
```bash
# Verificar rede do Docker
make debug-network

# Testar conectividade
docker-compose exec airflow-webserver ping postgres

# Recriar rede
docker-compose down
docker network prune -f
docker-compose up -d
```

### 13. **DNS não resolve**
```bash
# Verificar /etc/hosts
cat /etc/hosts

# Verificar DNS do Docker
docker-compose exec airflow-webserver nslookup postgres

# Configurar DNS personalizado
echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf
```

## 💾 Comandos de Emergência

### Reset Completo
```bash
# ⚠️ ATENÇÃO: Remove TODOS os dados!
make reset-env
```

### Limpeza Seletiva
```bash
# Apenas Airflow
make clean-airflow

# Apenas imagens
make clean-images

# Apenas volumes
docker volume prune -f
```

### Verificações de Debug
```bash
# Recursos do sistema
make debug-resources

# Status dos serviços
make debug-airflow
make debug-spark

# Variáveis de ambiente
make debug-env
```

## 📞 Como Obter Ajuda

1. **Verifique os logs**: `make logs [serviço]`
2. **Execute diagnósticos**: `make debug-[serviço]`
3. **Consulte a documentação**: [docs/](../docs/)
4. **Abra uma issue**: [GitHub Issues](https://github.com/euvaldoferreira/bigdata/issues)
5. **Participe das discussões**: [GitHub Discussions](https://github.com/euvaldoferreira/bigdata/discussions)

## 🔍 Template para Issues

Quando reportar um problema, inclua:

```
### Ambiente
- OS: [Ubuntu 20.04, CentOS 8, etc.]
- Docker: [versão]
- Docker Compose: [versão]
- RAM disponível: [X GB]

### Problema
Descreva o problema...

### Logs
```
make logs [serviço]
```

### Passos para Reproduzir
1. ...
2. ...
3. ...

### Comportamento Esperado
O que deveria acontecer...
```