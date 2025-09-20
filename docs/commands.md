# 🔧 Referência Completa de Comandos

## 📖 Ajuda e Informações

| Comando | Descrição |
|---------|-----------|
| `make help` | Mostra ajuda com todos os comandos |
| `make info` | Informações detalhadas do ambiente |
| `make requirements` | Mostra requisitos de sistema |
| `make version` | Versões dos componentes |

## 🔍 Verificação e Validação

| Comando | Descrição |
|---------|-----------|
| `make pre-check` | Verificação rápida dos requisitos |
| `make check` | Verificação completa do servidor |
| `make health` | Verifica saúde dos serviços |
| `make auto-ip` | Detecta e configura IP automaticamente |
| `make get-ip` | Descobre IPs disponíveis |
| `make set-ip IP=192.168.1.22` | Configura IP específico |

## 🚀 Controle de Ambientes

| Comando | Descrição | RAM | CPU |
|---------|-----------|-----|-----|
| `make start` | Ambiente completo | 10-12GB | 6-8 cores |
| `make lab` | Ambiente laboratório | 6-8GB | 4 cores |
| `make minimal` | Ambiente mínimo | 3-4GB | 2 cores |
| `make stop` | Para todos os serviços | - | - |
| `make stop-all` | Para TODOS os ambientes | - | - |
| `make restart` | Reinicia ambiente | - | - |

## 📊 Monitoramento e Status

| Comando | Descrição |
|---------|-----------|
| `make status` | Status dos containers |
| `make ps` | Lista containers ativos |
| `make ps-all` | Lista todos os containers BigData |
| `make logs` | Logs de todos os serviços |
| `make logs-airflow` | Logs específicos do Airflow |
| `make logs-spark` | Logs específicos do Spark |
| `make top` | Uso de recursos |

## 🧪 Testes

| Comando | Descrição |
|---------|-----------|
| `make test` | Executa todos os testes |
| `make test-airflow` | Testa Airflow |
| `make test-spark` | Testa Spark |
| `make test-minio` | Testa MinIO |

## 🌐 Rede e Conectividade

| Comando | Descrição |
|---------|-----------|
| `make ports` | Lista portas utilizadas |
| `make open` | Abre todas as interfaces web |

## 🔧 Build e Deploy

| Comando | Descrição |
|---------|-----------|
| `make build` | Build das imagens customizadas |
| `make pull` | Atualiza todas as imagens |
| `make rebuild` | Rebuild completo (pull + build) |

## 🗄️ Backup e Restore

### Backup Geral
| Comando | Descrição |
|---------|-----------|
| `make backup` | Backup básico dos dados |
| `make backup-all` | Backup completo do ambiente |

### Backup por Serviço
| Comando | Descrição |
|---------|-----------|
| `make backup-airflow` | Backup específico do Airflow |
| `make backup-postgres` | Backup específico do PostgreSQL |
| `make backup-minio` | Backup específico do MinIO |
| `make backup-jenkins` | Backup específico do Jenkins |
| `make backup-jupyter` | Backup específico do Jupyter |

### Restore
| Comando | Descrição |
|---------|-----------|
| `make restore-airflow FILE=backup.sql` | Restore do Airflow |
| `make restore-postgres FILE=backup.sql` | Restore do PostgreSQL |

## 🧹 Limpeza e Manutenção

| Comando | Descrição |
|---------|-----------|
| `make clean` | Remove containers e volumes (CUIDADO!) |
| `make clean-images` | Remove imagens não utilizadas |
| `make clean-airflow` | Limpeza específica do Airflow |
| `make reset-env` | Reset completo do ambiente |

## ✈️ Controle do Airflow

| Comando | Descrição |
|---------|-----------|
| `make airflow-start` | Inicia apenas o Airflow |
| `make airflow-stop` | Para apenas o Airflow |
| `make airflow-restart` | Reinicia serviços do Airflow |
| `make airflow-logs` | Logs do Airflow |
| `make airflow-bash` | Acesso bash no container |
| `make airflow-shell` | Shell interativo do Airflow |

## ⚡ Controle do Spark

| Comando | Descrição |
|---------|-----------|
| `make spark-start` | Inicia cluster Spark |
| `make spark-stop` | Para cluster Spark |
| `make spark-restart` | Reinicia cluster Spark |
| `make spark-logs` | Logs do cluster |
| `make spark-master-logs` | Logs apenas do Master |
| `make spark-worker-logs` | Logs apenas do Worker |
| `make spark-bash` | Acesso bash no Master |
| `make spark-shell` | Spark Shell interativo |
| `make spark-submit JOB=app.py` | Submete job Spark |

## 🗄️ Controle do MinIO

| Comando | Descrição |
|---------|-----------|
| `make minio-start` | Inicia MinIO |
| `make minio-stop` | Para MinIO |
| `make minio-restart` | Reinicia MinIO |
| `make minio-logs` | Logs do MinIO |
| `make minio-bash` | Acesso bash no container |
| `make minio-client` | Cliente MinIO (mc) |

## 🗃️ Controle do PostgreSQL

| Comando | Descrição |
|---------|-----------|
| `make postgres-start` | Inicia PostgreSQL |
| `make postgres-stop` | Para PostgreSQL |
| `make postgres-restart` | Reinicia PostgreSQL |
| `make postgres-logs` | Logs do PostgreSQL |
| `make postgres-bash` | Acesso bash no container |
| `make postgres-psql` | Acesso psql |

## 🔴 Controle do Redis

| Comando | Descrição |
|---------|-----------|
| `make redis-start` | Inicia Redis |
| `make redis-stop` | Para Redis |
| `make redis-restart` | Reinicia Redis |
| `make redis-logs` | Logs do Redis |
| `make redis-bash` | Acesso bash no container |
| `make redis-cli` | Cliente Redis |

## 📓 Controle do Jupyter

| Comando | Descrição |
|---------|-----------|
| `make jupyter-start` | Inicia Jupyter |
| `make jupyter-stop` | Para Jupyter |
| `make jupyter-restart` | Reinicia Jupyter |
| `make jupyter-logs` | Logs do Jupyter |
| `make jupyter-bash` | Acesso bash no container |
| `make jupyter-token` | Mostra token do Jupyter |

## 🧰 Controle do Jenkins

| Comando | Descrição |
|---------|-----------|
| `make jenkins-start` | Inicia Jenkins |
| `make jenkins-stop` | Para Jenkins |
| `make jenkins-restart` | Reinicia Jenkins |
| `make jenkins-logs` | Logs do Jenkins |
| `make jenkins-bash` | Acesso bash no container |

## 🔥 Controle do Flower

| Comando | Descrição |
|---------|-----------|
| `make flower-start` | Inicia Flower |
| `make flower-stop` | Para Flower |
| `make flower-restart` | Reinicia Flower |
| `make flower-logs` | Logs do Flower |

## 🧑‍💻 Desenvolvimento

| Comando | Descrição |
|---------|-----------|
| `make dev-logs` | Logs principais para desenvolvimento |
| `make dev-restart` | Reinicia serviços de desenvolvimento |
| `make dev-shell` | Menu interativo para shells |

## 🔧 Utilitários de Debug

| Comando | Descrição |
|---------|-----------|
| `make debug-airflow` | Debug do Airflow |
| `make debug-spark` | Debug do Spark |
| `make debug-env` | Debug das variáveis de ambiente |
| `make debug-network` | Debug da rede Docker |
| `make debug-resources` | Debug de recursos do sistema |

## 📝 Exemplos de Uso

### Início Típico
```bash
make pre-check    # Verificação rápida
make start        # Inicia ambiente
make status       # Verifica se tudo está rodando
make ports        # Vê URLs de acesso
```

### Desenvolvimento
```bash
make lab          # Ambiente mais leve
make dev-logs     # Logs focados
make dev-shell    # Acesso rápido aos shells
```

### Troubleshooting
```bash
make health       # Verifica saúde
make debug-airflow # Debug específico
make clean-airflow # Limpa se necessário
```

### Manutenção
```bash
make backup-all   # Backup antes de mudanças
make pull         # Atualiza imagens
make rebuild      # Rebuild se necessário
```