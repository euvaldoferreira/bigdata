# 🗄️ MinIO

MinIO é um object storage compatível com Amazon S3, otimizado para cloud native e containers.

## 🚀 Características

- **S3 Compatible**: API totalmente compatível com Amazon S3
- **Alta Performance**: Otimizado para throughput e latência
- **Cloud Native**: Projetado para containers e Kubernetes
- **Multi-Cloud**: Deploy em qualquer nuvem ou on-premises

## 🔧 Configuração no Projeto

### Acesso
- **Console**: http://localhost:9001
- **API**: http://localhost:9000
- **Usuário**: minioadmin (configurável via .env)
- **Senha**: minioadmin123 (configurável via .env)

### Buckets Padrão
- `airflow-data`: Dados do Airflow
- `spark-data`: Dados do Spark
- `jupyter-data`: Dados dos notebooks

## 📊 Uso Básico

### Python Client
```python
from minio import Minio
import os

# Conectar ao MinIO usando variáveis de ambiente
client = Minio(
    "minio:9000",
    secure=False
)

# Listar buckets
buckets = client.list_buckets()

# Upload arquivo
client.fput_object("meu-bucket", "arquivo.csv", "local_file.csv")

# Download arquivo
client.fget_object("meu-bucket", "arquivo.csv", "downloaded_file.csv")
```

### PySpark S3A
```python
# Configuração no SparkSession usando variáveis de ambiente
spark = SparkSession.builder \
    .config("spark.hadoop.fs.s3a.endpoint", "http://minio:9000") \
    .config("spark.hadoop.fs.s3a.access.key", os.getenv("MINIO_USER")) \
    .config("spark.hadoop.fs.s3a.secret.key", os.getenv("MINIO_CONFIG_TOKEN")) \
    .config("spark.hadoop.fs.s3a.path.style.access", "true") \
    .getOrCreate()

# Ler dados do MinIO
df = spark.read.csv("s3a://meu-bucket/dados.csv", header=True)
```

### MC Client (Command Line)
```bash
# Configurar alias
mc alias set myminio http://localhost:9000 minioadmin minioadmin123

# Listar buckets
mc ls myminio

# Copiar arquivos
mc cp arquivo.csv myminio/meu-bucket/
```

## 🔗 Integração com Outros Serviços

- **Spark**: Storage distribuído via protocolo S3A
- **Jupyter**: Upload/download de datasets
- **Airflow**: Storage para artefatos de pipeline

## 📚 Documentação Oficial

- [Documentação MinIO](https://docs.min.io/)
- [Python Client](https://docs.min.io/docs/python-client-quickstart-guide.html)