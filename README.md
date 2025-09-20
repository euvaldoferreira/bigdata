# 🚀 Ambiente BigData Integrado

Este projeto fornece um ambiente completo de Big Data usando Docker, integrando Airflow, MinIO, Jenkins, PySpark e Jupyter Notebook para desenvolvimento e processamento de dados em larga escala.

## 📋 Visão Geral

O ambiente inclui os seguintes serviços integrados:

- **🌊 Apache Airflow 2.7.0**: Orquestração de workflows e pipelines de dados
- **📦 MinIO**: Storage de objetos compatível com S3
- **🔧 Jenkins**: CI/CD para automação de builds e deploys
- **⚡ Apache Spark 3.4.0**: Processamento distribuído de dados
- **📓 Jupyter Notebook**: Desenvolvimento interativo e análise de dados (PySpark)
- **🐘 PostgreSQL 13**: Banco de dados para metadados do Airflow
- **📮 Redis**: Message broker para Celery (Airflow)

## � Configurações Disponíveis

### 🔬 **Ambiente Mínimo** (`make minimal`)
- **Recursos:** 3-4GB RAM, 2 CPUs, 5-8GB disco
- **Serviços:** Airflow Standalone + Jupyter/Spark Local + MinIO + PostgreSQL
- **Ideal para:** Desenvolvimento básico, aprendizado, máquinas com poucos recursos

### 🧪 **Ambiente Lab** (`make lab`) 
- **Recursos:** 6-8GB RAM, 4 CPUs, 10-15GB disco
- **Serviços:** Airflow + Spark Cluster + MinIO + Jupyter + Redis
- **Ideal para:** Laboratório, testes, desenvolvimento intermediário

### 🏭 **Ambiente Completo** (`make start`)
- **Recursos:** 10-12GB RAM, 6-8 cores, 20GB+ disco
- **Serviços:** Todos os serviços incluindo Jenkins e Workers distribuídos
- **Ideal para:** Produção, desenvolvimento avançado

💡 **Use `make requirements` para ver detalhes completos dos recursos.**

💡 **Use `make requirements` para ver detalhes completos dos recursos.**

## ⚙️ Configuração

### 📝 Arquivo de Variáveis de Ambiente

Antes de iniciar o ambiente, configure as variáveis de ambiente:

```bash
# Copie o arquivo de exemplo
cp .env.example .env

# Edite com suas configurações
nano .env
```

**Principais configurações no arquivo `.env`:**

```bash
# IP do servidor (para acesso externo)
SERVER_IP=192.168.1.22

# Senhas personalizadas (ALTERE!)
POSTGRES_PASSWORD=sua_senha_postgres_aqui
AIRFLOW_ADMIN_PASSWORD=sua_senha_airflow_aqui
MINIO_ROOT_PASSWORD=sua_senha_minio_aqui

# Portas (opcional - só mude se houver conflito)
AIRFLOW_PORT=8080
JUPYTER_PORT=8888
MINIO_CONSOLE_PORT=9001
```

⚠️ **Importante:** Sempre altere as senhas padrão em ambientes de produção!

## 🚀 Instalação e Uso

### 1. Clone ou baixe o projeto

```bash
git clone <seu-repositorio>
cd containers
```

### 2. Inicie o ambiente

#### Opção A: Usando Makefile (Recomendado)
```bash
# Ver todos os comandos disponíveis
make help

# Ver requisitos de sistema
make requirements

# Escolher configuração baseada nos seus recursos:
make minimal     # Para 3-4GB RAM (básico)
make lab         # Para 6-8GB RAM (laboratório)  
make start       # Para 10GB+ RAM (completo)

# Verificar status
make status
```

#### Opção B: Usando scripts diretamente
```bash
./scripts/start.sh
```

O sistema irá:
- Verificar dependências
- Criar diretórios necessários
- Configurar variáveis de ambiente
- Inicializar todos os serviços em ordem
- Aguardar que todos estejam prontos

### 3. Acesse os serviços

Após a inicialização completa, os serviços estarão disponíveis em:

| Serviço | URL | Credenciais |
|---------|-----|-------------|
| **Airflow** | http://SERVER_IP:8080 | admin/admin |
| **Spark Master UI** | http://SERVER_IP:8081 | - |
| **MinIO Console** | http://SERVER_IP:9001 | minioadmin/minioadmin123 |
| **Jenkins** | http://SERVER_IP:8082 | admin/admin |
| **Jupyter Notebook** | http://SERVER_IP:8888 | sem senha |
| **Flower (Celery)** | http://SERVER_IP:5555 | - |

📝 **Nota:** Substitua `SERVER_IP` pelo IP configurado no arquivo `.env` (exemplo: 192.168.1.22 ou localhost)

💡 **Dica:** Use `make ports` para ver as URLs exatas configuradas no seu ambiente.

## 📁 Estrutura do Projeto

```
containers/
├── docker-compose.yml          # Configuração completa (produção)
├── docker-compose.minimal.yml  # Configuração mínima (4GB RAM)
├── docker-compose.lab.yml      # Configuração laboratório (6GB RAM)
├── .env                       # Variáveis de ambiente (configurado pelo usuário)
├── .env.example                # Template de variáveis de ambiente
├── Makefile                   # Automação de comandos
├── README.md                  # Este arquivo
├── PARAMETRIZACAO.md          # Documentação de parametrização
├── airflow/                   # Configurações do Airflow
│   ├── dags/                 # DAGs do Airflow
│   ├── plugins/              # Plugins customizados
│   ├── config/               # Configurações
│   └── requirements.txt      # Dependências Python
├── jenkins/                   # Configurações do Jenkins
│   ├── Dockerfile           # Imagem customizada
│   ├── plugins.txt          # Lista de plugins
│   └── init.groovy.d/       # Scripts de inicialização
├── spark/                     # Configurações do Spark
│   ├── apps/                # Aplicações Spark
│   ├── conf/                # Configurações
│   └── data/                # Dados do Spark
├── jupyter/                   # Configurações do Jupyter
│   ├── notebooks/           # Notebooks Jupyter
│   └── config/              # Configurações
├── scripts/                   # Scripts utilitários
│   ├── start.sh             # Inicializar ambiente
│   ├── stop.sh              # Parar ambiente
│   ├── status.sh            # Status dos serviços
│   └── setup-minio.sh       # Configuração do MinIO
├── Makefile                   # Automação de comandos
├── data/                      # Dados compartilhados
└── logs/                      # Logs dos serviços
```

## 🛠️ Comandos Úteis

### 📋 Comandos Principais

```bash
# Ver todos os comandos disponíveis
make help

# Iniciar ambientes
make minimal            # Ambiente mínimo (4GB RAM)
make lab               # Ambiente laboratório (6GB RAM)  
make start             # Ambiente completo (10GB+ RAM)

# Parar ambientes
make stop              # Para o ambiente atual
make stop-minimal      # Para especificamente o ambiente mínimo
make stop-lab          # Para especificamente o ambiente lab
make stop-all          # Para TODOS os containers de todos os ambientes

# Status e monitoramento
make health            # Verifica saúde de todos os serviços
make status            # Status detalhado via script
make ps                # Lista containers do ambiente atual
make ps-all            # Lista containers de TODOS os ambientes
make ports             # Mostra portas e URLs de acesso
```

### 📊 Monitoramento e Logs

```bash
# Logs gerais
make logs              # Ver logs de todos os serviços
make logs-airflow      # Logs específicos do Airflow
make logs-spark        # Logs específicos do Spark
make logs-jupyter      # Logs do Jupyter
make logs-minio        # Logs do MinIO
make logs-jenkins      # Logs do Jenkins

# Recursos
make top               # Uso de recursos dos containers
make info              # Informações do ambiente
make version           # Versões dos componentes
```

### 🔧 Desenvolvimento

```bash
# Acessar shells dos serviços
make airflow-shell     # Acessar shell do Airflow
make spark-shell       # Acessar Spark shell
make jupyter-shell     # Acessar shell do Jupyter
make minio-shell       # Acessar shell do MinIO

# Operações com Spark
make submit-spark      # Submeter job Spark de exemplo

# Reiniciar serviços específicos
make restart-airflow   # Reinicia apenas o Airflow
make restart-spark     # Reinicia cluster Spark
make restart-jupyter   # Reinicia Jupyter
```

### 🧪 Testes e Validação

```bash
# Testes de integração
make test              # Executa todos os testes
make test-airflow      # Testa Airflow
make test-spark        # Testa cluster Spark
make test-minio        # Testa MinIO

# Verificações
make check             # Verifica configuração e dependências
make requirements      # Mostra requisitos de sistema
```

### 🗂️ Manutenção e Dados

```bash
# Backup e restore
make backup            # Fazer backup dos dados
make clean             # Limpar dados (CUIDADO!)
make clean-images      # Remove imagens não utilizadas

# Atualizações
make pull              # Atualiza todas as imagens
make rebuild           # Rebuild completo (pull + build)
```

### 🌐 Comandos de Rede

```bash
# Portas e acesso
make ports             # Lista portas utilizadas
make open              # Abre todas as interfaces web (Linux)

# Exemplo de saída do make ports:
# • Airflow:     http://${SERVER_IP}:8080
# • Spark UI:    http://${SERVER_IP}:8081  
# • MinIO:       http://${SERVER_IP}:9001
# • Jupyter:     http://${SERVER_IP}:8888
```
```

### Gerenciamento do Ambiente (Scripts)

```bash
# Iniciar ambiente completo
./scripts/start.sh

# Verificar status
./scripts/status.sh

# Parar ambiente
./scripts/stop.sh

# Parar e limpar todos os dados
./scripts/stop.sh --clean
```

## 🎯 Comandos Específicos por Serviço

O ambiente oferece comandos granulares para gerenciar cada serviço individualmente:

### 🐘 PostgreSQL
```bash
# Gerenciamento básico
make start-postgres    # Inicia apenas PostgreSQL
make stop-postgres     # Para PostgreSQL  
make restart-postgres  # Reinicia PostgreSQL
make health-postgres   # Verifica saúde
make logs-postgres     # Visualiza logs

# Acesso e debug
make shell-postgres    # Conecta via psql
make debug-postgres    # Debug completo
make reset-postgres    # Reset completo (REMOVE DADOS!)
make backup-postgres   # Backup dos dados
```

### 📮 Redis  
```bash
# Gerenciamento básico
make start-redis       # Inicia apenas Redis
make stop-redis        # Para Redis
make restart-redis     # Reinicia Redis  
make health-redis      # Verifica saúde
make logs-redis        # Visualiza logs

# Acesso
make shell-redis       # Conecta via redis-cli
```

### 🗂️ MinIO
```bash
# Gerenciamento básico
make start-minio       # Inicia apenas MinIO
make stop-minio        # Para MinIO
make restart-minio     # Reinicia MinIO
make health-minio      # Verifica saúde  
make logs-minio        # Visualiza logs

# Acesso e manutenção
make shell-minio       # Shell no container
make open-minio        # Abre interface web
make debug-minio       # Debug completo
make backup-minio      # Backup dos dados
make reset-minio       # Reset completo (REMOVE DADOS!)
```

### ✈️ Airflow
```bash
# Gerenciamento básico (inclui dependências)
make start-airflow     # Inicia Airflow + PostgreSQL + Redis
make stop-airflow      # Para todos os serviços Airflow  
make restart-airflow   # Reinicia Airflow
make health-airflow    # Verifica saúde de todos os componentes

# Logs específicos
make logs-airflow-webserver    # Logs do webserver
make logs-airflow-scheduler    # Logs do scheduler  
make logs-airflow-worker       # Logs do worker

# Acesso e manutenção
make shell-airflow     # Shell no container
make open-airflow      # Abre interface web
make debug-airflow     # Debug completo
make backup-airflow    # Backup configurações e logs
make check-deps-airflow # Verifica dependências
```

### ⚡ Spark
```bash
# Gerenciamento básico
make start-spark       # Inicia cluster Spark completo
make stop-spark        # Para cluster Spark
make restart-spark     # Reinicia cluster
make health-spark      # Verifica saúde do cluster

# Logs específicos  
make logs-spark-master   # Logs do master
make logs-spark-worker   # Logs dos workers

# Acesso e manutenção
make shell-spark       # Shell no Spark Master
make open-spark        # Abre Spark UI
make debug-spark       # Debug completo
make check-deps-spark  # Verifica dependências
```

### 📓 Jupyter
```bash
# Gerenciamento básico
make start-jupyter     # Inicia Jupyter
make stop-jupyter      # Para Jupyter
make restart-jupyter   # Reinicia Jupyter
make health-jupyter    # Verifica saúde
make logs-jupyter      # Visualiza logs

# Acesso
make shell-jupyter     # Shell no container
make open-jupyter      # Abre interface web (senha: jupyter)
```

### 🏗️ Jenkins
```bash
# Gerenciamento básico
make start-jenkins     # Inicia Jenkins
make stop-jenkins      # Para Jenkins  
make restart-jenkins   # Reinicia Jenkins
make health-jenkins    # Verifica saúde
make logs-jenkins      # Visualiza logs

# Acesso
make shell-jenkins     # Shell no container
make open-jenkins      # Abre interface web
```

## 🔧 Comandos de Status Consolidado

```bash
# Status por categoria
make status-database      # PostgreSQL + Redis
make status-storage       # MinIO
make status-compute       # Spark + Jupyter  
make status-orchestration # Airflow + Jenkins

# Verificação de dependências
make check-deps-airflow   # Dependências do Airflow
make check-deps-spark     # Dependências do Spark
```

## 💾 Backup e Restore por Serviço

```bash
# Backups individuais
make backup-postgres      # Backup PostgreSQL
make backup-minio         # Backup MinIO
make backup-airflow       # Backup Airflow

# Backups completos
make full-backup-postgres # Dados + volume PostgreSQL
make full-backup-minio    # Backup completo MinIO
make full-backup-airflow  # Configurações + logs Airflow

# Backup de todo ambiente
make backup-all           # Backup completo de tudo

# Gerenciamento de backups
make list-backups         # Lista todos os backups
make clean-old-backups    # Remove backups >7 dias
```

## 🚨 Troubleshooting por Serviço

```bash
# Debug específico
make debug-postgres       # Debug PostgreSQL completo
make debug-minio          # Debug MinIO completo  
make debug-airflow        # Debug Airflow completo
make debug-spark          # Debug Spark completo

# Reset de serviços (CUIDADO!)
make reset-postgres       # Remove todos os dados PostgreSQL
make reset-minio          # Remove todos os dados MinIO
make reset-airflow        # Remove logs e configurações

# Rebuild de containers
make rebuild-postgres     # Rebuild PostgreSQL
make rebuild-minio        # Rebuild MinIO
make rebuild-airflow      # Rebuild Airflow
make rebuild-spark        # Rebuild Spark  
make rebuild-jupyter      # Rebuild Jupyter
```

### Docker Compose (Comandos Manuais)

```bash
# Ver logs de um serviço específico
docker-compose logs -f airflow-webserver

# Reiniciar um serviço
docker-compose restart spark-master

# Acessar container
docker-compose exec jupyter bash

# Ver status dos containers
docker-compose ps
```

### Spark

```bash
# Submeter job Spark
docker-compose exec spark-master spark-submit \
    --master spark://spark-master:7077 \
    /opt/bitnami/spark/apps/example_spark_minio.py

# Acessar Spark shell
docker-compose exec spark-master spark-shell \
    --master spark://spark-master:7077
```

### MinIO

```bash
# Listar buckets
docker-compose exec minio mc ls myminio

# Copiar arquivo para bucket
docker-compose exec minio mc cp /data/arquivo.csv myminio/data-lake/
```

## 📊 Exemplos de Uso

### 1. DAG do Airflow

Um DAG de exemplo está incluído em `airflow/dags/example_bigdata_integration.py` que demonstra:
- Teste de conexão com MinIO
- Execução de job Spark
- Geração de relatórios

### 2. Notebook Jupyter

Um notebook de exemplo está incluído em `jupyter/notebooks/BigData_Integration_Example.ipynb` que demonstra:
- Conexão com Spark
- Processamento de dados
- Salvamento no MinIO
- Visualizações

### 3. Pipeline Jenkins

Um pipeline de exemplo é criado automaticamente que demonstra:
- Build e teste de aplicações
- Deploy para Spark
- Backup no MinIO

## 🔄 Fluxo de Desenvolvimento

1. **Desenvolvimento**: Use Jupyter para exploração e prototipagem
2. **Orquestração**: Crie DAGs no Airflow para workflows automatizados
3. **Processamento**: Desenvolva aplicações Spark para processamento em larga escala
4. **CI/CD**: Use Jenkins para automação de builds e deploys
5. **Storage**: Armazene dados e resultados no MinIO

## 🔧 Configurações Avançadas

### Escalabilidade do Spark

Para adicionar mais workers Spark, edite o `docker-compose.yml`:

```yaml
spark-worker-3:
  image: bitnami/spark:3.4.0
  container_name: bigdata_spark_worker_3
  # ... configurações similares aos outros workers
```

### Configurações do Airflow

Personalize configurações em `airflow/config/airflow.cfg`:
- Executors
- Conexões de banco
- Configurações de email
- Plugins

### Autenticação

Para produção, considere:
- Configurar autenticação LDAP/OAuth
- Usar secrets managers
- Implementar HTTPS
- Configurar firewalls

## 📈 Monitoramento

### Logs

```bash
# Todos os logs
docker-compose logs -f

# Logs específicos
docker-compose logs -f airflow-scheduler
docker-compose logs -f spark-master
```

### Métricas

- **Airflow**: Interface web com métricas de DAGs
- **Spark**: Spark UI com métricas de jobs
- **MinIO**: Console com estatísticas de storage
- **Jenkins**: Interface com histórico de builds

## 🚨 Troubleshooting

### Problemas Comuns

1. **Porta já em uso**
   ```bash
   # Verificar portas ocupadas
   netstat -tulpn | grep :8080
   ```

2. **Memória insuficiente**
   ```bash
   # Verificar uso de memória
   docker stats
   ```

3. **Permissões do Airflow**
   ```bash
   # Corrigir permissões
   sudo chown -R 1000:0 airflow/
   ```

4. **Containers não iniciam**
   ```bash
   # Ver logs detalhados
   docker-compose logs [serviço]
   ```

### Recuperação

```bash
# Restart completo
./scripts/stop.sh
./scripts/start.sh

# Limpeza completa (CUIDADO: remove todos os dados)
make clean
make start
```

## 🔧 Troubleshooting

### 🚨 Problemas Comuns

#### 1. **Permission denied while trying to connect to Docker daemon**
```bash
# Solução: Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER

# Depois faça logout/login ou:
newgrp docker

# Verificar se funcionou:
groups | grep docker
```

#### 2. **Erro "Port already in use"**
```bash
# Verificar portas ocupadas
sudo netstat -tlnp | grep :8080

# Parar todos os containers
make stop-all

# Ou alterar portas no arquivo .env
nano .env
```

#### 3. **Containers não iniciam (recursos insuficientes)**
```bash
# Verificar recursos disponíveis
make requirements

# Usar ambiente mais leve
make minimal  # Em vez de make start
```

#### 4. **Airflow não carrega DAGs**
```bash
# Verificar logs do Airflow
make logs-airflow

# Verificar permissões da pasta dags
ls -la airflow/dags/

# Corrigir permissões se necessário
sudo chown -R $USER:$USER airflow/
```

### 🔍 Comandos de Diagnóstico

```bash
# Status completo do sistema
make health               # Status de todos os serviços
make ps-all              # Containers de todos os ambientes
make check               # Verificar dependências
make info                # Informações do ambiente

# Verificar recursos
make top                 # Uso de CPU/RAM
docker system df         # Uso de disco

# Logs específicos
make logs-[serviço]      # Logs de serviço específico
```

### 💾 **Em Caso de Problemas Graves**

```bash
# Reset completo (CUIDADO: remove todos os dados!)
make stop-all
make clean

# Reinstalar do zero
cp .env.example .env
nano .env               # Configure suas variáveis
make minimal           # Começar com ambiente simples
```

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo LICENSE para detalhes.

## 🆘 Suporte

Para problemas ou dúvidas:
1. Verifique a seção de troubleshooting
2. Consulte os logs dos serviços
3. Abra uma issue no repositório

## 🔗 Recursos Úteis

- [Apache Airflow Documentation](https://airflow.apache.org/docs/)
- [Apache Spark Documentation](https://spark.apache.org/docs/latest/)
- [MinIO Documentation](https://docs.min.io/)
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Jupyter Documentation](https://jupyter.readthedocs.io/)

---

**🎉 Aproveite seu ambiente BigData integrado!**