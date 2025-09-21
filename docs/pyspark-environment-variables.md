# 🔧 PySpark Environment Variables - Best Practices

## 📋 **Por que usar variáveis de ambiente?**

### ✅ **Vantagens:**
1. **Flexibilidade** - Configurações diferentes para dev/test/prod
2. **Reutilização** - Mesmo código, configurações diferentes
3. **Segurança** - Credenciais e configurações sensíveis separadas
4. **Manutenibilidade** - Mudanças sem rebuild de containers
5. **Portabilidade** - Facilita deploy em diferentes ambientes

## 🌐 **Variáveis PySpark Configuradas**

### 📍 **Caminhos e Executáveis:**
```bash
SPARK_HOME=/opt/spark                    # Diretório de instalação do Spark
PYSPARK_PYTHON=python3                   # Python para executors
PYSPARK_DRIVER_PYTHON=jupyter            # Python para driver (Jupyter)
PYSPARK_DRIVER_PYTHON_OPTS=lab           # Modo Jupyter (lab/notebook)
```

### 🌐 **Conectividade:**
```bash
SPARK_DRIVER_HOST=jupyter                # Hostname do driver
SPARK_DRIVER_BIND_ADDRESS=0.0.0.0       # Interface de bind
SPARK_LOCAL_IP=jupyter                   # IP local para comunicação
```

### ⚡ **Performance:**
```bash
SPARK_DRIVER_MEMORY=1g                   # Memória do driver
SPARK_EXECUTOR_MEMORY=1g                 # Memória dos executors
SPARK_EXECUTOR_CORES=2                   # Cores por executor
```

## 🔧 **Como Customizar**

### 1️⃣ **Editar arquivo `.env`:**
```bash
# Para mais memória em desenvolvimento:
SPARK_DRIVER_MEMORY=2g
SPARK_EXECUTOR_MEMORY=2g

# Para produção com mais cores:
SPARK_EXECUTOR_CORES=4
```

### 2️⃣ **Override via command line:**
```bash
SPARK_DRIVER_MEMORY=4g make start
```

### 3️⃣ **Diferentes ambientes:**
```bash
# .env.dev
SPARK_DRIVER_MEMORY=1g
SPARK_EXECUTOR_MEMORY=1g

# .env.prod  
SPARK_DRIVER_MEMORY=4g
SPARK_EXECUTOR_MEMORY=8g
```

## 📚 **Documentação das Variáveis**

| Variável | Descrição | Default | Personalização |
|----------|-----------|---------|----------------|
| `SPARK_HOME` | Diretório do Spark | `/opt/spark` | Alterar apenas se Spark estiver em local diferente |
| `PYSPARK_PYTHON` | Python para executors | `python3` | `python`, `python3.8`, etc. |
| `PYSPARK_DRIVER_PYTHON` | Python para driver | `jupyter` | `ipython`, `python` |
| `PYSPARK_DRIVER_PYTHON_OPTS` | Modo Jupyter | `lab` | `notebook`, `--no-browser` |
| `SPARK_DRIVER_HOST` | Host do driver | `jupyter` | IP do container Jupyter |
| `SPARK_DRIVER_BIND_ADDRESS` | Interface bind | `0.0.0.0` | IP específico se necessário |
| `SPARK_LOCAL_IP` | IP local | `jupyter` | Para clusters multi-node |
| `SPARK_DRIVER_MEMORY` | Memória driver | `1g` | `2g`, `4g`, etc. |
| `SPARK_EXECUTOR_MEMORY` | Memória executors | `1g` | Baseado na memória disponível |
| `SPARK_EXECUTOR_CORES` | Cores por executor | `2` | Baseado em CPU disponível |

## 🚀 **Exemplos de Configuração**

### 🔬 **Desenvolvimento (recursos limitados):**
```bash
SPARK_DRIVER_MEMORY=512m
SPARK_EXECUTOR_MEMORY=512m
SPARK_EXECUTOR_CORES=1
```

### 🏢 **Produção (alta performance):**
```bash
SPARK_DRIVER_MEMORY=4g
SPARK_EXECUTOR_MEMORY=8g
SPARK_EXECUTOR_CORES=4
```

### 🧪 **Teste (modo local):**
```bash
PYSPARK_DRIVER_PYTHON=python
PYSPARK_DRIVER_PYTHON_OPTS=
SPARK_MASTER=local[2]
```

## 🔄 **Implementação no docker-compose.yml**

```yaml
environment:
  # ✅ CORRETO - Usando variáveis de ambiente
  - SPARK_HOME=${SPARK_HOME:-/opt/spark}
  - PYSPARK_PYTHON=${PYSPARK_PYTHON:-python3}
  
  # ❌ INCORRETO - Valores hardcoded
  - SPARK_HOME=/opt/spark
  - PYSPARK_PYTHON=python3
```

### **Benefícios da sintaxe `${VAR:-default}`:**
- **Flexibilidade**: Usa valor do `.env` se definido
- **Fallback**: Usa valor padrão se variável não existir
- **Portabilidade**: Funciona em qualquer ambiente

## 🎯 **Próximos Passos**

1. **Teste as configurações** executando o notebook de exemplo
2. **Monitore performance** via Spark UI
3. **Ajuste memória/cores** conforme necessário
4. **Documente** configurações específicas do seu projeto

---

**💡 Dica**: Sempre teste configurações em ambiente de desenvolvimento antes de aplicar em produção!