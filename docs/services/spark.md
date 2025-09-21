# ⚡ Apache Spark

Apache Spark é um framework de processamento distribuído para análise de big data.

## 🚀 Características

- **Processamento Rápido**: Engine de análise unificado para big data
- **APIs Múltiplas**: SQL, DataFrames, Datasets, RDDs
- **Machine Learning**: MLlib para algoritmos de ML
- **Stream Processing**: Spark Streaming para dados em tempo real

## 🔧 Configuração no Projeto

### Cluster Spark
- **Spark Master**: http://localhost:8081
- **Workers**: Configuráveis via docker-compose
- **Modo**: Cluster standalone

### Estrutura de Arquivos
```
spark/
├── apps/           # Aplicações Spark
├── data/          # Dados de entrada/saída
└── conf/          # Configurações customizadas
```

## 📊 Uso Básico

### PySpark no Jupyter
```python
from pyspark.sql import SparkSession

# Criar sessão Spark
spark = SparkSession.builder \
    .appName("MeuApp") \
    .master("spark://spark-master:7077") \
    .getOrCreate()

# Ler dados
df = spark.read.csv("path/to/file.csv", header=True)

# Processamento
result = df.groupBy("coluna").count()
result.show()
```

### Submit de Jobs
```bash
# Via make command
make spark-submit APP=meu_app.py

# Via docker
docker exec spark-master spark-submit \
    --master spark://spark-master:7077 \
    /opt/bitnami/spark/apps/meu_app.py
```

## 🔗 Integração com Outros Serviços

- **Jupyter**: Notebooks interativos com PySpark
- **MinIO**: Storage distribuído via S3A
- **Airflow**: Orquestração de jobs Spark

## 📚 Documentação Oficial

- [Documentação Spark](https://spark.apache.org/docs/latest/)
- [PySpark API](https://spark.apache.org/docs/latest/api/python/)