# 🏗️ Arquitetura do Ambiente BigData

## 🎯 Visão Geral

O ambiente BigData é composto por múltiplos serviços containerizados que trabalham em conjunto para formar uma plataforma completa de processamento de dados.

```
┌─────────────────────────────────────────────────────────────────┐
│                    AMBIENTE BIGDATA                             │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │
│  │   AIRFLOW   │  │    SPARK    │  │   JUPYTER   │            │
│  │ Orquestração│  │ Processamento│  │  Notebooks  │            │
│  └─────────────┘  └─────────────┘  └─────────────┘            │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │
│  │   MINIO     │  │  JENKINS    │  │    REDIS    │            │
│  │  Storage    │  │   CI/CD     │  │   Cache     │            │
│  └─────────────┘  └─────────────┘  └─────────────┘            │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐                             │
│  │ POSTGRESQL  │  │   FLOWER    │                             │
│  │  Database   │  │ Monitoring  │                             │
│  └─────────────┘  └─────────────┘                             │
└─────────────────────────────────────────────────────────────────┘
```

## 🔧 Componentes Principais

### 1. **Apache Airflow** - Orquestração de Workflows
- **Função**: Orquestração e agendamento de pipelines de dados
- **Componentes**:
  - `airflow-webserver`: Interface web
  - `airflow-scheduler`: Agendador de tarefas
  - `airflow-worker`: Executor de tarefas
  - `airflow-flower`: Monitor do Celery
- **Portas**: 8080 (web), 5555 (flower)
- **Volumes**: dags, plugins, logs, config

### 2. **Apache Spark** - Processamento Distribuído
- **Função**: Processamento de big data e analytics
- **Componentes**:
  - `spark-master`: Nó coordenador
  - `spark-worker`: Nós de processamento
- **Portas**: 8081 (Spark UI), 7077 (master)
- **Recursos**: CPU e memória distribuídos

### 3. **MinIO** - Object Storage
- **Função**: Storage compatível com S3
- **Componentes**:
  - `minio`: Servidor de storage
  - `minio-client`: Cliente CLI
- **Portas**: 9000 (API), 9001 (console)
- **Volumes**: Dados persistentes

### 4. **Jupyter** - Notebooks Interativos
- **Função**: Desenvolvimento e análise interativa
- **Recursos**: Python, Spark, pandas, ML libs
- **Porta**: 8888
- **Volumes**: Workspace compartilhado

### 5. **Jenkins** - CI/CD
- **Função**: Integração e deploy contínuo
- **Porta**: 8082
- **Volumes**: Jenkins home persistente

### 6. **PostgreSQL** - Database
- **Função**: Metadados do Airflow e dados estruturados
- **Porta**: 5432
- **Volumes**: Dados persistentes

### 7. **Redis** - Cache e Message Broker
- **Função**: Cache e broker para Celery/Airflow
- **Porta**: 6379
- **Tipo**: In-memory

## 🌐 Arquitetura de Rede

```
┌─────────────────────────────────────────────────────────────────┐
│                     REDE: bigdata                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  airflow-webserver:8080  ←→  postgres:5432                     │
│  airflow-scheduler       ←→  redis:6379                        │
│  airflow-worker         ←→  minio:9000                         │
│                          ←→  spark-master:7077                 │
│                                                                 │
│  spark-master:8081      ←→  spark-worker                       │
│  jupyter:8888           ←→  spark-master                       │
│                          ←→  minio:9000                        │
│                                                                 │
│  jenkins:8082           ←→  minio:9000                         │
│                          ←→  postgres:5432                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 💾 Arquitetura de Volumes

### Volumes Persistentes
```
postgres_data/     # Dados do PostgreSQL
  └── pgdata/

minio_data/        # Dados do MinIO
  └── buckets/

jenkins_home/      # Jenkins home
  └── workspace/

airflow_logs/      # Logs do Airflow
  └── dag_processor_manager/
```

### Volumes Bind Mounts
```
./airflow/dags/     → /opt/airflow/dags
./airflow/plugins/  → /opt/airflow/plugins
./airflow/config/   → /opt/airflow/airflow.cfg
./data/            → /opt/airflow/data
```

## 🔄 Fluxo de Dados

### Pipeline Típico
```
1. DESENVOLVIMENTO
   Jupyter → Spark (desenvolvimento) → MinIO (testes)

2. ORQUESTRAÇÃO
   Airflow → Spark (produção) → MinIO (storage)
             ↓
           PostgreSQL (metadados)

3. CI/CD
   Jenkins → Build → Deploy → Monitor
```

### Fluxo de Metadados
```
Airflow Scheduler → PostgreSQL (metadados)
                 → Redis (task queue)
                 → Airflow Workers
```

## ⚙️ Configurações por Ambiente

### Ambiente Completo (`make start`)
```yaml
Services: ALL
Resources:
  - postgres: 512MB RAM
  - redis: 256MB RAM  
  - airflow-*: 2GB RAM total
  - spark-*: 4GB RAM total
  - minio: 512MB RAM
  - jenkins: 1GB RAM
  - jupyter: 1GB RAM
Total: ~10GB RAM
```

### Ambiente Lab (`make lab`)
```yaml
Services: airflow + spark + minio + jupyter
Resources:
  - postgres: 256MB RAM
  - redis: 128MB RAM
  - airflow-*: 1.5GB RAM total
  - spark-*: 2GB RAM total
  - minio: 256MB RAM
  - jupyter: 512MB RAM
Total: ~6GB RAM
```

### Ambiente Minimal (`make minimal`)
```yaml
Services: airflow-standalone + jupyter + minio
Resources:
  - postgres: 256MB RAM
  - airflow-standalone: 1GB RAM
  - minio: 256MB RAM
  - jupyter: 512MB RAM
Total: ~4GB RAM
```

## 🔒 Segurança

### Autenticação
- **Airflow**: Basic Auth (admin/admin_secure_2024)
- **MinIO**: Access/Secret Keys
- **Jenkins**: Initial admin setup
- **Jupyter**: Token-based
- **PostgreSQL**: User/password

### Rede
- **Isolamento**: Container network `bigdata`
- **Exposição**: Apenas portas necessárias
- **Comunicação**: Internal DNS resolution

### Volumes
- **Permissões**: UID/GID controlados
- **Isolamento**: Volumes por serviço
- **Backup**: Estratégias por volume

## 📈 Escalabilidade

### Horizontal
- **Spark Workers**: Adicionar workers conforme necessário
- **Airflow Workers**: Celery permite múltiplos workers
- **MinIO**: Clustering (não implementado)

### Vertical
- **Recursos**: Ajustar limits nos docker-compose
- **Storage**: Expandir volumes conforme necessário

### Load Balancing
- **Airflow**: Multiple workers via Celery
- **Spark**: Automatic load distribution
- **MinIO**: Client-side load balancing

## 🔧 Customização

### Modificação de Recursos
```yaml
# docker-compose.yml
deploy:
  resources:
    limits:
      memory: 2G
      cpus: '1.0'
```

### Adição de Serviços
1. Adicionar ao `docker-compose.yml`
2. Configurar rede `bigdata`
3. Adicionar comandos no `Makefile`
4. Documentar no README

### Configuração Avançada
- **Environment variables**: `.env`
- **Config files**: `./airflow/config/`
- **Custom images**: Build customizados