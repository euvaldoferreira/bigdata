# 🌪️ Apache Airflow

Apache Airflow é uma plataforma para desenvolver, agendar e monitorar workflows de forma programática.

## 🚀 Características

- **Orquestração de Workflows**: Define pipelines como código usando Python
- **Interface Web**: Dashboard para monitoramento e gerenciamento
- **Extensível**: Rico ecosistema de operadores e hooks
- **Escalável**: Suporte a múltiplos executores

## 🔧 Configuração no Projeto

### Acesso
- **URL**: http://localhost:8080
- **Usuário**: admin
- **Senha**: admin (configurável via .env)

### Estrutura de Arquivos
```
airflow/
├── dags/           # Definições de DAGs
├── plugins/        # Plugins customizados
├── config/         # Configurações
└── requirements.txt # Dependências Python
```

## 📊 Uso Básico

### Criando uma DAG
```python
from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime

def minha_funcao():
    print("Hello from Airflow!")

dag = DAG(
    'exemplo_dag',
    start_date=datetime(2025, 1, 1),
    schedule_interval='@daily'
)

task = PythonOperator(
    task_id='minha_task',
    python_callable=minha_funcao,
    dag=dag
)
```

## 🔗 Integração com Outros Serviços

- **Spark**: Executa jobs Spark via SparkSubmitOperator
- **MinIO**: Acesso a object storage via S3Hook
- **PostgreSQL**: Banco de dados para metadados

## 📚 Documentação Oficial

- [Documentação Airflow](https://airflow.apache.org/docs/)
- [Tutorial](https://airflow.apache.org/docs/apache-airflow/stable/tutorial.html)