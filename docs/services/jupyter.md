# 📓 Jupyter

Jupyter é um ambiente interativo para desenvolvimento, análise de dados e prototipagem.

## 🚀 Características

- **Notebooks Interativos**: Código, visualizações e documentação em um só lugar
- **Múltiplas Linguagens**: Python, R, Scala, SQL
- **Visualizações**: Matplotlib, Plotly, Seaborn integrados
- **Colaborativo**: Compartilhamento fácil de notebooks

## 🔧 Configuração no Projeto

### Acesso
- **URL**: http://localhost:8888
- **Token**: Não requerido (configurado para desenvolvimento)
- **Workspace**: `/home/jovyan/work`

### Imagens Disponíveis
- **Principal**: `jupyter/pyspark-notebook:latest` (PySpark integrado)
- **Lab**: `jupyter/pyspark-notebook:latest` (ambiente otimizado)
- **Minimal**: `jupyter/all-spark-notebook:latest` (Spark local)

## 📊 Uso Básico

### PySpark Integration
```python
from pyspark.sql import SparkSession

# Criar sessão conectada ao cluster
spark = SparkSession.builder \
    .appName("Jupyter-Spark-Integration") \
    .master("spark://spark-master:7077") \
    .getOrCreate()

# Seu código aqui
df = spark.read.csv("data/exemplo.csv", header=True)
```

### MinIO Integration
```python
from minio import Minio

# Conectar ao MinIO
client = Minio(
    "minio:9000",
    secure=False
)

# Upload de resultados
client.fput_object("jupyter-data", "resultado.csv", "output.csv")
```

### Visualizações
```python
import matplotlib.pyplot as plt
import seaborn as sns

# Configurar estilo
plt.style.use('seaborn-v0_8')
sns.set_palette('husl')

# Criar gráficos
df.plot(kind='bar')
plt.show()
```

## 🔗 Notebooks Disponíveis

- **[BigData Integration Example](../../jupyter/notebooks/BigData_Integration_Example.ipynb)**: Exemplo completo de integração
- **[PySpark Environment Setup](../../jupyter/notebooks/pyspark_environment_setup.ipynb)**: Configuração e exemplos PySpark

## 🛠️ Extensões Disponíveis

- **JupyterLab**: Interface moderna
- **Git Extension**: Controle de versão
- **Variable Inspector**: Debug de variáveis
- **Table of Contents**: Navegação em notebooks

## 📁 Estrutura de Arquivos

```
jupyter/
├── notebooks/          # Notebooks Jupyter (.ipynb)
└── shared-data/       # Dados compartilhados
```

## 🔗 Integração com Outros Serviços

- **Spark**: Processamento distribuído via PySpark
- **MinIO**: Storage de datasets e resultados
- **PostgreSQL**: Análise de dados relacionais

## 📚 Documentação Oficial

- [Documentação Jupyter](https://jupyter.org/documentation)
- [JupyterLab](https://jupyterlab.readthedocs.io/)