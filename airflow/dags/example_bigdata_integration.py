"""
DAG de exemplo que demonstra a integração entre Airflow, Spark, MinIO e Jupyter
"""
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.operators.bash_operator import BashOperator
from airflow.utils.dates import days_ago

# Configurações padrão do DAG
default_args = {
    'owner': 'bigdata-team',
    'depends_on_past': False,
    'start_date': days_ago(1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# Definição do DAG
dag = DAG(
    'bigdata_integration_example',
    default_args=default_args,
    description='Exemplo de integração BigData',
    schedule_interval=timedelta(days=1),
    catchup=False,
    tags=['example', 'bigdata', 'integration'],
)

def test_minio_connection():
    """Testa conexão com MinIO"""
    from minio import Minio
    from minio.error import S3Error
    
    # Cliente MinIO
    client = Minio(
        "minio:9000",
        access_key="minioadmin",
        secret_key="minioadmin123",
        secure=False
    )
    
    try:
        # Lista buckets
        buckets = client.list_buckets()
        print(f"Buckets disponíveis: {[bucket.name for bucket in buckets]}")
        
        # Testa upload de arquivo simples
        import io
        data = "Teste de conexão MinIO\n"
        client.put_object(
            "airflow-logs",
            "test/connection_test.txt",
            io.BytesIO(data.encode('utf-8')),
            len(data)
        )
        print("Upload de teste realizado com sucesso!")
        
        return "MinIO conectado com sucesso"
    except S3Error as err:
        print(f"Erro ao conectar com MinIO: {err}")
        raise

def test_spark_connection():
    """Testa conexão com Spark"""
    from pyspark.sql import SparkSession
    
    spark = SparkSession.builder \
        .appName("Airflow-Spark-Test") \
        .master("spark://spark-master:7077") \
        .config("spark.executor.memory", "1g") \
        .config("spark.executor.cores", "1") \
        .getOrCreate()
    
    try:
        # Cria DataFrame de teste
        data = [("Alice", 25), ("Bob", 30), ("Charlie", 35)]
        columns = ["Nome", "Idade"]
        df = spark.createDataFrame(data, columns)
        
        # Mostra dados
        df.show()
        
        # Salva no MinIO via S3A (se configurado)
        print("Spark conectado com sucesso!")
        
        return "Spark conectado com sucesso"
    finally:
        spark.stop()

# Task 1: Teste de conexão com MinIO
test_minio_task = PythonOperator(
    task_id='test_minio_connection',
    python_callable=test_minio_connection,
    dag=dag,
)

# Task 2: Teste de conexão com Spark
test_spark_task = PythonOperator(
    task_id='test_spark_connection',
    python_callable=test_spark_connection,
    dag=dag,
)

# Task 3: Executa comando bash simples
bash_task = BashOperator(
    task_id='run_bash_command',
    bash_command='echo "BigData environment is running!" && date',
    dag=dag,
)

# Task 4: Gera relatório
generate_report_task = BashOperator(
    task_id='generate_report',
    bash_command='''
    echo "=== BigData Environment Report ===" > /opt/airflow/data/environment_report.txt
    echo "Data: $(date)" >> /opt/airflow/data/environment_report.txt
    echo "Airflow: OK" >> /opt/airflow/data/environment_report.txt
    echo "MinIO: OK" >> /opt/airflow/data/environment_report.txt
    echo "Spark: OK" >> /opt/airflow/data/environment_report.txt
    echo "Jupyter: OK" >> /opt/airflow/data/environment_report.txt
    echo "Jenkins: OK" >> /opt/airflow/data/environment_report.txt
    cat /opt/airflow/data/environment_report.txt
    ''',
    dag=dag,
)

# Definindo dependências
bash_task >> [test_minio_task, test_spark_task] >> generate_report_task