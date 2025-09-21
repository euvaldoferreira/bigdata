# ⚡ PySpark - Configuração de Variáveis de Ambiente

Guia completo para configuração de variáveis de ambiente do PySpark no ambiente BigData.

## 🎯 Objetivo

Este documento descreve as melhores práticas para configuração de variáveis de ambiente PySpark, garantindo integração adequada entre Jupyter, Spark e MinIO.

## 🔧 Variáveis Essenciais

### Configuração Base
```bash
# Localização do Spark
SPARK_HOME=/usr/local/spark

# Python paths para PySpark
PYTHONPATH=/usr/local/spark/python:/usr/local/spark/python/lib/py4j-0.10.9.7-src.zip

# Configurações Python do PySpark
PYSPARK_PYTHON=python3
PYSPARK_DRIVER_PYTHON=jupyter
PYSPARK_DRIVER_PYTHON_OPTS=lab
```

### Configuração de Recursos
```bash
# Memória
SPARK_DRIVER_MEMORY=1g
SPARK_EXECUTOR_MEMORY=1g

# CPU Cores
SPARK_DRIVER_CORES=1
SPARK_EXECUTOR_CORES=2

# Instâncias
SPARK_EXECUTOR_INSTANCES=2
```

### Configuração de Rede
```bash
# Cluster Spark
SPARK_MASTER=spark://spark-master:7077

# Configurações de rede
SPARK_DRIVER_HOST=jupyter
SPARK_DRIVER_BIND_ADDRESS=0.0.0.0
SPARK_LOCAL_IP=jupyter
```

## 📊 Configuração por Ambiente

### Ambiente Principal (docker-compose.yml)
```yaml
environment:
  - SPARK_HOME=/usr/local/spark
  - PYTHONPATH=/usr/local/spark/python:/usr/local/spark/python/lib/py4j-0.10.9.7-src.zip
  - GRANT_SUDO=yes
  - SPARK_MASTER=${SPARK_MASTER:-spark://spark-master:7077}
  - PYSPARK_PYTHON=${PYSPARK_PYTHON:-python3}
  - PYSPARK_DRIVER_PYTHON=${PYSPARK_DRIVER_PYTHON:-jupyter}
  - PYSPARK_DRIVER_PYTHON_OPTS=${PYSPARK_DRIVER_PYTHON_OPTS:-lab}
  - SPARK_DRIVER_MEMORY=${SPARK_DRIVER_MEMORY:-1g}
  - SPARK_EXECUTOR_MEMORY=${SPARK_EXECUTOR_MEMORY:-1g}
  - SPARK_DRIVER_CORES=${SPARK_DRIVER_CORES:-1}
  - SPARK_EXECUTOR_CORES=${SPARK_EXECUTOR_CORES:-2}
  - SPARK_EXECUTOR_INSTANCES=${SPARK_EXECUTOR_INSTANCES:-2}
```

### Ambiente Lab (docker-compose.lab.yml)
```yaml
environment:
  - SPARK_DRIVER_MEMORY=${SPARK_DRIVER_MEMORY:-512m}
  - SPARK_EXECUTOR_MEMORY=${SPARK_EXECUTOR_MEMORY:-512m}
  # ... outras configurações similares com recursos reduzidos
```

### Ambiente Minimal (docker-compose.minimal.yml)
```yaml
environment:
  - SPARK_DRIVER_MEMORY=${SPARK_DRIVER_MEMORY:-512m}
  - SPARK_EXECUTOR_MEMORY=${SPARK_EXECUTOR_MEMORY:-512m}
  # ... configurações para Spark local
```

## 🔍 Resolução de Problemas

### ModuleNotFoundError: No module named 'pyspark'

**Causa**: PYTHONPATH não configurado corretamente

**Solução**:
```bash
# Verificar se PYTHONPATH está definido
echo $PYTHONPATH

# Deve incluir:
# /usr/local/spark/python:/usr/local/spark/python/lib/py4j-0.10.9.7-src.zip
```

### Erro de Conexão com Spark Master

**Causa**: SPARK_MASTER não acessível

**Solução**:
```python
# Verificar conectividade
import socket
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
result = sock.connect_ex(('spark-master', 7077))
if result == 0:
    print("Conexão OK")
else:
    print("Erro de conexão")
```

### Problemas de Memória

**Causa**: Configurações inadequadas de memória

**Solução**:
```bash
# Ajustar no .env
SPARK_DRIVER_MEMORY=2g
SPARK_EXECUTOR_MEMORY=2g
```

## 🛠️ Arquivo .env

Exemplo de configuração no arquivo `.env`:

```bash
# PySpark Configuration
SPARK_HOME=/opt/spark
PYSPARK_PYTHON=python3
PYSPARK_DRIVER_PYTHON=jupyter
PYSPARK_DRIVER_PYTHON_OPTS=lab
SPARK_DRIVER_HOST=jupyter
SPARK_DRIVER_BIND_ADDRESS=0.0.0.0
SPARK_LOCAL_IP=jupyter
SPARK_DRIVER_MEMORY=1g
SPARK_EXECUTOR_MEMORY=1g
SPARK_EXECUTOR_CORES=2
SPARK_DRIVER_CORES=1
SPARK_EXECUTOR_INSTANCES=2
SPARK_MASTER=spark://spark-master:7077
```

## 📝 Validação da Configuração

### Teste Básico
```python
import pyspark
print(f"PySpark version: {pyspark.__version__}")

from pyspark.sql import SparkSession
spark = SparkSession.builder.appName("Test").getOrCreate()
print(f"Spark context: {spark.sparkContext.appName}")
```

### Teste de Integração
```python
# Teste completo de integração
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("Integration-Test") \
    .master("spark://spark-master:7077") \
    .config("spark.executor.memory", "1g") \
    .config("spark.executor.cores", "1") \
    .getOrCreate()

# Criar DataFrame teste
data = [("Alice", 25), ("Bob", 30)]
df = spark.createDataFrame(data, ["name", "age"])
df.show()

spark.stop()
```

## 🔗 Referências

- [Documentação PySpark](https://spark.apache.org/docs/latest/api/python/)
- [Configuração Spark](https://spark.apache.org/docs/latest/configuration.html)
- [Jupyter + PySpark](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#jupyter-pyspark-notebook)