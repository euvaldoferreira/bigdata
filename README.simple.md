# 🚀 Ambiente BigData com Docker

> **Ambiente completo de BigData com Airflow, Spark, MinIO, Jupyter e Jenkins**

[![Docker](https://img.shields.io/badge/Docker-20.10+-blue.svg)](https://docker.com)
[![Docker Compose](https://img.shields.io/badge/Docker%20Compose-2.0+-blue.svg)](https://docs.docker.com/compose/)
[![Apache Airflow](https://img.shields.io/badge/Airflow-2.8.0-red.svg)](https://airflow.apache.org)
[![Apache Spark](https://img.shields.io/badge/Spark-3.5-orange.svg)](https://spark.apache.org)

## 📋 Início Rápido

### ⚡ Instalação Express

```bash
# 1. Clone o repositório
git clone https://github.com/euvaldoferreira/bigdata.git
cd bigdata/containers

# 2. Configure o ambiente
cp .env.example .env
nano .env  # Edite IP e senhas

# 3. Verificação rápida
make pre-check

# 4. Inicie o ambiente
make start      # Ambiente completo (10GB+ RAM)
# OU
make lab        # Ambiente laboratório (6GB RAM)  
# OU
make minimal    # Ambiente mínimo (4GB RAM)
```

### 🔍 Verificação

```bash
make status     # Status dos serviços
make health     # Verificação de saúde
make ports      # URLs de acesso
```

## 🌐 Interfaces Web

| Serviço | URL | Usuário | Senha |
|---------|-----|---------|-------|
| **Airflow** | http://localhost:8080 | admin | admin_secure_2024 |
| **Spark UI** | http://localhost:8081 | - | - |
| **MinIO** | http://localhost:9001 | minioadmin | minio_secure_2024 |
| **Jenkins** | http://localhost:8082 | admin | configurar |
| **Jupyter** | http://localhost:8888 | - | jupyter |

## 🛠️ Comandos Principais

```bash
# Controle do Ambiente
make start      # Inicia ambiente completo
make lab        # Inicia ambiente laboratório  
make minimal    # Inicia ambiente mínimo
make stop       # Para todos os serviços
make restart    # Reinicia ambiente

# Monitoramento
make status     # Status dos containers
make logs       # Logs de todos os serviços
make health     # Verificação de saúde
make top        # Uso de recursos

# Configuração
make check      # Verificação completa do servidor
make auto-ip    # Configura IP automaticamente
make ports      # Lista portas utilizadas

# Ajuda
make help       # Lista todos os comandos
```

## 📊 Ambientes Disponíveis

### 🚀 **Completo** (`make start`)
- **RAM**: 10-12GB | **CPU**: 6-8 cores | **Disco**: 20GB
- **Serviços**: Airflow + Spark + MinIO + Jenkins + Jupyter
- **Uso**: Produção, desenvolvimento completo

### 🧪 **Laboratório** (`make lab`) 
- **RAM**: 6-8GB | **CPU**: 4 cores | **Disco**: 10-15GB
- **Serviços**: Airflow + Spark + MinIO + Jupyter
- **Uso**: Aprendizado, testes, desenvolvimento

### 🔬 **Mínimo** (`make minimal`)
- **RAM**: 3-4GB | **CPU**: 2 cores | **Disco**: 5-8GB  
- **Serviços**: Airflow Standalone + Jupyter + MinIO
- **Uso**: Máquinas com recursos limitados

## 🚨 Resolução de Problemas

### Problemas Comuns

**Erro: "ModuleNotFoundError: No module named 'airflow'"**
```bash
make clean-airflow  # Limpa versões antigas
make start
```

**Erro: "Port already in use"**
```bash
make stop-all       # Para todos os ambientes
# OU edite as portas no arquivo .env
```

**Erro: "Not enough memory"**
```bash
make requirements   # Verifica recursos
make minimal        # Use ambiente mais leve
```

**Problemas graves**
```bash
make reset-env      # Reset completo (remove dados!)
make start
```

## 📚 Documentação Completa

- **[📖 Guia Completo](docs/)** - Documentação detalhada
- **[🔧 Configuração Avançada](docs/configuration.md)** - Configurações específicas
- **[🚨 Troubleshooting](docs/troubleshooting.md)** - Solução de problemas
- **[🔍 Comandos](docs/commands.md)** - Referência completa de comandos
- **[🏗️ Arquitetura](docs/architecture.md)** - Detalhes técnicos

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch: `git checkout -b feature/nova-funcionalidade`
3. Commit: `git commit -m 'feat: adiciona nova funcionalidade'`
4. Push: `git push origin feature/nova-funcionalidade`
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🆘 Suporte

- **[Issues](https://github.com/euvaldoferreira/bigdata/issues)** - Reporte bugs
- **[Discussions](https://github.com/euvaldoferreira/bigdata/discussions)** - Perguntas e discussões  
- **[Wiki](https://github.com/euvaldoferreira/bigdata/wiki)** - Guias avançados

---

⭐ **Se este projeto foi útil, deixe uma estrela!** ⭐