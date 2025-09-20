"""
Exemplo de aplicação PySpark que demonstra integração com MinIO
"""
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, count, avg, max, min
import sys

def create_spark_session():
    """Cria sessão Spark com configurações para MinIO"""
    spark = SparkSession.builder \
        .appName("BigData-MinIO-Integration") \
        .config("spark.hadoop.fs.s3a.endpoint", "http://minio:9000") \
        .config("spark.hadoop.fs.s3a.access.key", "minioadmin") \
        .config("spark.hadoop.fs.s3a.secret.key", "minioadmin123") \
        .config("spark.hadoop.fs.s3a.path.style.access", "true") \
        .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
        .config("spark.hadoop.fs.s3a.connection.ssl.enabled", "false") \
        .getOrCreate()
    
    return spark

def process_sample_data(spark):
    """Processa dados de exemplo"""
    # Criar dados de exemplo
    data = [
        ("Alice", 25, "Engenharia", 5000),
        ("Bob", 30, "Marketing", 4500),
        ("Charlie", 35, "Engenharia", 6000),
        ("Diana", 28, "RH", 4800),
        ("Eve", 32, "Marketing", 5200),
        ("Frank", 29, "Engenharia", 5500),
        ("Grace", 26, "RH", 4600),
        ("Henry", 31, "Marketing", 4900)
    ]
    
    columns = ["nome", "idade", "departamento", "salario"]
    df = spark.createDataFrame(data, columns)
    
    print("=== Dados Originais ===")
    df.show()
    
    # Análises básicas
    print("=== Estatísticas por Departamento ===")
    stats_df = df.groupBy("departamento") \
        .agg(
            count("nome").alias("total_funcionarios"),
            avg("idade").alias("idade_media"),
            avg("salario").alias("salario_medio"),
            max("salario").alias("salario_maximo"),
            min("salario").alias("salario_minimo")
        )
    
    stats_df.show()
    
    # Salvar no MinIO
    print("=== Salvando dados no MinIO ===")
    try:
        # Salvar dados originais
        df.write \
            .mode("overwrite") \
            .option("header", "true") \
            .csv("s3a://spark-data/output/funcionarios")
        
        # Salvar estatísticas
        stats_df.write \
            .mode("overwrite") \
            .option("header", "true") \
            .csv("s3a://spark-data/output/estatisticas_departamento")
        
        print("Dados salvos com sucesso no MinIO!")
        
    except Exception as e:
        print(f"Erro ao salvar no MinIO: {e}")
        # Salvar localmente como fallback
        df.write \
            .mode("overwrite") \
            .option("header", "true") \
            .csv("/opt/bitnami/spark/data/funcionarios")
        
        stats_df.write \
            .mode("overwrite") \
            .option("header", "true") \
            .csv("/opt/bitnami/spark/data/estatisticas")
        
        print("Dados salvos localmente como fallback!")

def main():
    """Função principal"""
    print("Iniciando aplicação Spark...")
    
    # Criar sessão Spark
    spark = create_spark_session()
    
    try:
        # Processar dados
        process_sample_data(spark)
        
        print("Aplicação executada com sucesso!")
        
    except Exception as e:
        print(f"Erro na execução: {e}")
        sys.exit(1)
        
    finally:
        # Parar sessão Spark
        spark.stop()

if __name__ == "__main__":
    main()