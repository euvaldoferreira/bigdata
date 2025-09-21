# 🔄 Pipeline de Dados com BigData Stack

Este caso de uso demonstra como criar um pipeline completo de dados usando todos os componentes do ambiente BigData.

## 🎯 Cenário

Processar dados de vendas em lotes diários, aplicar transformações e gerar relatórios automatizados.

## 🏗️ Arquitetura do Pipeline

```
Raw Data (CSV) → MinIO → Airflow → Spark → MinIO → Jupyter → Dashboard
```

## 📊 Implementação

### 1. Preparação dos Dados (MinIO)

```python
# Upload de dados via Python
from minio import Minio
import os

def get_minio_client():
    """Retorna cliente MinIO configurado"""
    return Minio("minio:9000", 
                 secure=False)

client = get_minio_client()

# Criar bucket para dados brutos
client.make_bucket("raw-data")

# Upload arquivo de vendas
client.fput_object("raw-data", "vendas_2025.csv", "vendas_2025.csv")
```

### 2. Orquestração (Airflow DAG)

```python
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.apache.spark.operators.spark_submit import SparkSubmitOperator
from datetime import datetime, timedelta

def validate_data():
    # Validação dos dados de entrada
    pass

def notify_completion():
    # Notificação de conclusão
    pass

dag = DAG(
    'pipeline_vendas_diario',
    default_args={
        'owner': 'data-team',
        'retries': 1,
        'retry_delay': timedelta(minutes=5)
    },
    start_date=datetime(2025, 1, 1),
    schedule_interval='@daily',
    catchup=False
)

# Tasks
validacao = PythonOperator(
    task_id='validar_dados',
    python_callable=validate_data,
    dag=dag
)

processamento = SparkSubmitOperator(
    task_id='processar_vendas',
    application='/opt/bitnami/spark/apps/processar_vendas.py',
    name='pipeline_vendas_{{ ds }}',
    dag=dag
)

notificacao = PythonOperator(
    task_id='notificar_conclusao',
    python_callable=notify_completion,
    dag=dag
)

# Dependências
validacao >> processamento >> notificacao
```

### 3. Processamento (Spark Job)

```python
# /spark/apps/processar_vendas.py
from pyspark.sql import SparkSession
from pyspark.sql.functions import *

def main():
    spark = SparkSession.builder \
        .appName("ProcessarVendas") \
        .master("spark://spark-master:7077") \
        .config("spark.hadoop.fs.s3a.endpoint", "http://minio:9000") \
        .config("spark.hadoop.fs.s3a.access.key") \
        .config("spark.hadoop.fs.s3a.secret.key") \
        .config("spark.hadoop.fs.s3a.path.style.access", "true") \
        .getOrCreate()
    
    # Ler dados brutos
    df_vendas = spark.read.csv("s3a://raw-data/vendas_2025.csv", header=True)
    
    # Transformações
    df_processado = df_vendas \
        .withColumn("data_venda", to_date(col("data_venda"), "yyyy-MM-dd")) \
        .withColumn("mes", month(col("data_venda"))) \
        .withColumn("ano", year(col("data_venda"))) \
        .withColumn("valor_total", col("quantidade") * col("preco_unitario"))
    
    # Agregações
    vendas_por_mes = df_processado \
        .groupBy("ano", "mes", "produto") \
        .agg(
            sum("valor_total").alias("total_vendas"),
            sum("quantidade").alias("total_quantidade"),
            avg("preco_unitario").alias("preco_medio")
        )
    
    # Salvar resultados
    vendas_por_mes.write \
        .mode("overwrite") \
        .option("header", "true") \
        .csv("s3a://processed-data/vendas_mensal")
    
    spark.stop()

if __name__ == "__main__":
    main()
```

### 4. Análise (Jupyter Notebook)

```python
# Notebook de análise
from pyspark.sql import SparkSession
import matplotlib.pyplot as plt
import seaborn as sns

# Conectar ao Spark
spark = SparkSession.builder \
    .appName("Analise_Vendas") \
    .master("spark://spark-master:7077") \
    .getOrCreate()

# Carregar dados processados
df = spark.read.csv("s3a://processed-data/vendas_mensal", header=True)

# Converter para Pandas para visualização
df_pandas = df.toPandas()

# Visualizações
plt.figure(figsize=(12, 6))
sns.lineplot(data=df_pandas, x='mes', y='total_vendas', hue='produto')
plt.title('Vendas Mensais por Produto')
plt.show()

# Salvar relatório
df_pandas.to_csv('/home/jovyan/shared-data/relatorio_vendas.csv', index=False)
```

## 🔧 Configuração

### 1. Setup do Pipeline

```bash
# 1. Iniciar ambiente
make start

# 2. Criar buckets necessários
make minio-create-buckets

# 3. Deploy da DAG
cp airflow/dags/pipeline_vendas.py ./airflow/dags/

# 4. Deploy do job Spark
cp jobs/processar_vendas.py ./spark/apps/
```

### 2. Monitoramento

- **Airflow UI**: http://localhost:8080
- **Spark UI**: http://localhost:8081
- **MinIO Console**: http://localhost:9001

## 📈 Vantagens

1. **Escalabilidade**: Spark processa grandes volumes
2. **Confiabilidade**: Airflow gerencia retries e dependências
3. **Flexibilidade**: MinIO oferece storage durável
4. **Observabilidade**: UIs para monitoramento completo

## 🔍 Monitoramento e Alertas

### Métricas Importantes
- Tempo de execução do pipeline
- Volume de dados processados
- Taxa de erro
- Utilização de recursos

### Alertas
```python
# No Airflow DAG
def check_data_quality():
    # Verificações de qualidade
    if data_quality_issues:
        send_alert("Problemas na qualidade dos dados")

def send_slack_notification():
    # Integração com Slack/Teams
    pass
```

## 📚 Próximos Passos

1. Implementar testes automatizados
2. Adicionar validação de schema
3. Configurar alertas avançados
4. Otimizar performance do Spark