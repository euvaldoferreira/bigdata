# 🔄 ETL - Extract, Transform, Load

Processo completo de ETL usando o stack BigData para extrair dados de múltiplas fontes, transformar e carregar em data warehouse.

## 🎯 Cenário

Extrair dados de APIs, bancos de dados e arquivos, aplicar transformações complexas e carregar em um data lake estruturado.

## 🏗️ Arquitetura ETL

```
Fontes → [Extração] → Raw Layer → [Transformação] → Processed Layer → [Load] → Data Warehouse
   ↓           ↓              ↓              ↓                ↓              ↓
  APIs      Airflow        MinIO         Spark            MinIO        PostgreSQL
Files                                                                      ↓
  DB                                                                   Analytics
```

## 📊 Implementação

### 1. Extract - Extração de Dados

#### Airflow DAG para Extração
```python
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.providers.http.hooks.http import HttpHook
import pandas as pd
import json
from datetime import datetime, timedelta

def extract_api_data(**context):
    """Extrai dados de API REST"""
    http_hook = HttpHook(http_conn_id='api_connection', method='GET')
    
    response = http_hook.run('api/vendas')
    data = response.json()
    
    # Salvar em MinIO
    df = pd.DataFrame(data)
    df.to_parquet('/tmp/api_data.parquet')
    
    # Upload para MinIO
    from minio import Minio
    
    client.fput_object("raw-data", 
                       f"api/vendas/dt={context['ds']}/data.parquet",
                       "/tmp/api_data.parquet")

def extract_database_data(**context):
    """Extrai dados do PostgreSQL"""
    pg_hook = PostgresHook(postgres_conn_id='postgres_default')
    
    sql = """
    SELECT * FROM vendas 
    WHERE data_atualizacao >= %s
    """
    
    df = pg_hook.get_pandas_df(sql, parameters=[context['ds']])
    
    # Salvar no MinIO
    df.to_parquet('/tmp/db_data.parquet')
    
    
    client.fput_object("raw-data", 
                       f"database/vendas/dt={context['ds']}/data.parquet",
                       "/tmp/db_data.parquet")

def extract_file_data(**context):
    """Extrai dados de arquivos CSV"""
    import os
    
    # Processar arquivos na pasta de entrada
    for filename in os.listdir('/data/input/'):
        if filename.endswith('.csv'):
            df = pd.read_csv(f'/data/input/{filename}')
            
            # Salvar processado no MinIO
            parquet_name = filename.replace('.csv', '.parquet')
            df.to_parquet(f'/tmp/{parquet_name}')
            
            
            client.fput_object("raw-data", 
                               f"files/{parquet_name}",
                               f"/tmp/{parquet_name}")

# DAG Definition
etl_dag = DAG(
    'etl_completo',
    default_args={
        'owner': 'data-engineering',
        'retries': 2,
        'retry_delay': timedelta(minutes=5)
    },
    start_date=datetime(2025, 1, 1),
    schedule_interval='@daily',
    catchup=False
)

# Extract Tasks
extract_api = PythonOperator(
    task_id='extract_api_data',
    python_callable=extract_api_data,
    dag=etl_dag
)

extract_db = PythonOperator(
    task_id='extract_database_data', 
    python_callable=extract_database_data,
    dag=etl_dag
)

extract_files = PythonOperator(
    task_id='extract_file_data',
    python_callable=extract_file_data,
    dag=etl_dag
)
```

### 2. Transform - Transformação com Spark

```python
# /spark/apps/etl_transform.py
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.sql.types import *

def main():
    spark = SparkSession.builder \
        .appName("ETL_Transform") \
        .master("spark://spark-master:7077") \
        .config("spark.hadoop.fs.s3a.endpoint", "http://minio:9000") \
        .config("spark.hadoop.fs.s3a.access.key") \
        .config("spark.hadoop.fs.s3a.secret.key") \
        .config("spark.hadoop.fs.s3a.path.style.access", "true") \
        .getOrCreate()
    
    # 1. Ler dados brutos de múltiplas fontes
    df_api = spark.read.parquet("s3a://raw-data/api/vendas/")
    df_db = spark.read.parquet("s3a://raw-data/database/vendas/")
    df_files = spark.read.parquet("s3a://raw-data/files/")
    
    # 2. Padronização de Schema
    def standardize_schema(df, source_type):
        return df.select(
            col("id").cast(StringType()).alias("venda_id"),
            col("data_venda").cast(DateType()),
            col("produto").cast(StringType()),
            col("quantidade").cast(IntegerType()),
            col("valor").cast(DoubleType()),
            lit(source_type).alias("fonte")
        )
    
    df_api_std = standardize_schema(df_api, "api")
    df_db_std = standardize_schema(df_db, "database") 
    df_files_std = standardize_schema(df_files, "files")
    
    # 3. União dos DataFrames
    df_unified = df_api_std.union(df_db_std).union(df_files_std)
    
    # 4. Limpeza e Validação
    df_clean = df_unified \
        .filter(col("quantidade") > 0) \
        .filter(col("valor") > 0) \
        .filter(col("data_venda").isNotNull()) \
        .dropDuplicates(["venda_id"])
    
    # 5. Enriquecimento de Dados
    df_enriched = df_clean \
        .withColumn("ano", year(col("data_venda"))) \
        .withColumn("mes", month(col("data_venda"))) \
        .withColumn("trimestre", quarter(col("data_venda"))) \
        .withColumn("dia_semana", dayofweek(col("data_venda"))) \
        .withColumn("valor_total", col("quantidade") * col("valor")) \
        .withColumn("categoria_valor", 
                   when(col("valor_total") < 100, "Baixo")
                   .when(col("valor_total") < 500, "Médio")
                   .otherwise("Alto"))
    
    # 6. Agregações Dimensionais
    
    # Vendas por produto
    vendas_produto = df_enriched \
        .groupBy("produto", "ano", "mes") \
        .agg(
            sum("valor_total").alias("receita_total"),
            sum("quantidade").alias("quantidade_total"),
            avg("valor").alias("preco_medio"),
            count("venda_id").alias("numero_transacoes")
        )
    
    # Vendas por período
    vendas_periodo = df_enriched \
        .groupBy("ano", "mes", "trimestre") \
        .agg(
            sum("valor_total").alias("receita_mensal"),
            countDistinct("produto").alias("produtos_vendidos"),
            avg("valor_total").alias("ticket_medio")
        )
    
    # 7. Salvar Dados Processados
    
    # Dados detalhados particionados
    df_enriched.write \
        .mode("overwrite") \
        .partitionBy("ano", "mes") \
        .parquet("s3a://processed-data/vendas_detalhadas")
    
    # Agregações
    vendas_produto.write \
        .mode("overwrite") \
        .parquet("s3a://processed-data/vendas_por_produto")
        
    vendas_periodo.write \
        .mode("overwrite") \
        .parquet("s3a://processed-data/vendas_por_periodo")
    
    # 8. Métricas de Qualidade
    total_records = df_enriched.count()
    duplicates_removed = df_unified.count() - df_clean.count()
    
    quality_metrics = spark.createDataFrame([
        (datetime.now(), total_records, duplicates_removed)
    ], ["timestamp", "total_records", "duplicates_removed"])
    
    quality_metrics.write \
        .mode("append") \
        .parquet("s3a://processed-data/quality_metrics")
    
    spark.stop()

if __name__ == "__main__":
    main()
```

### 3. Load - Carregamento no Data Warehouse

```python
def load_to_warehouse(**context):
    """Carrega dados processados no PostgreSQL"""
    from pyspark.sql import SparkSession
    
    spark = SparkSession.builder \
        .appName("ETL_Load") \
        .master("spark://spark-master:7077") \
        .config("spark.jars", "/opt/bitnami/spark/jars/postgresql-42.6.0.jar") \
        .getOrCreate()
    
    # Ler dados processados
    df_vendas = spark.read.parquet("s3a://processed-data/vendas_detalhadas")
    df_produto = spark.read.parquet("s3a://processed-data/vendas_por_produto")
    
    # Configuração PostgreSQL
    postgres_props = {
        "user": "airflow",
        "password": "airflow",
        "driver": "org.postgresql.Driver"
    }
    
    # Escrever no Data Warehouse
    df_vendas.write \
        .jdbc("jdbc:postgresql://postgres:5432/warehouse", 
              "fact_vendas", 
              mode="overwrite", 
              properties=postgres_props)
    
    df_produto.write \
        .jdbc("jdbc:postgresql://postgres:5432/warehouse", 
              "dim_produto_vendas", 
              mode="overwrite", 
              properties=postgres_props)
    
    spark.stop()

# Adicionar ao DAG
from airflow.providers.apache.spark.operators.spark_submit import SparkSubmitOperator

transform_task = SparkSubmitOperator(
    task_id='transform_data',
    application='/opt/bitnami/spark/apps/etl_transform.py',
    name='etl_transform_{{ ds }}',
    dag=etl_dag
)

load_task = PythonOperator(
    task_id='load_to_warehouse',
    python_callable=load_to_warehouse,
    dag=etl_dag
)

# Dependências
[extract_api, extract_db, extract_files] >> transform_task >> load_task
```

## 🔧 Configuração e Deploy

### 1. Setup do Ambiente
```bash
# Iniciar serviços
make start

# Criar estrutura de buckets
make minio-setup

# Deploy dos scripts
cp etl_scripts/* ./spark/apps/
cp etl_dags/* ./airflow/dags/
```

### 2. Configuração de Conexões
No Airflow UI (http://localhost:8080):
- Criar conexão PostgreSQL
- Configurar conexão HTTP para APIs
- Setup de credenciais S3/MinIO

## 📊 Monitoramento

### Data Quality Checks
```python
def validate_data_quality():
    """Validações de qualidade dos dados"""
    quality_checks = [
        "count_nulls",
        "check_duplicates", 
        "validate_ranges",
        "check_referential_integrity"
    ]
    
    for check in quality_checks:
        result = run_quality_check(check)
        if not result:
            raise ValueError(f"Falha no teste: {check}")
```

### Alertas e Notificações
```python
def send_etl_report(**context):
    """Envia relatório do ETL"""
    metrics = get_etl_metrics(context['ds'])
    
    report = f"""
    ETL Report - {context['ds']}
    
    Records Processed: {metrics['total_records']}
    Processing Time: {metrics['duration']}
    Quality Score: {metrics['quality_score']}
    """
    
    send_slack_message(report)
```

## 📈 Otimizações

### Performance
- Particionamento por data
- Caching de DataFrames intermediários
- Broadcast joins para tabelas pequenas
- Otimização de formatos (Parquet com compressão)

### Escalabilidade
- Dynamic allocation no Spark
- Paralelização de extrações
- Processamento incremental
- Reprocessamento seletivo

## 📚 Próximos Passos

1. **Data Catalog**: Implementar catálogo de dados
2. **Lineage**: Rastreamento de linhagem de dados
3. **Governance**: Políticas de governança
4. **Real-time**: Streaming ETL com Kafka
5. **ML Integration**: Pipeline de ML automatizado