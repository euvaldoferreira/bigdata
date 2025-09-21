# 🤖 Machine Learning Workflows

Pipeline completo de Machine Learning usando o stack BigData para treinar, validar e deployar modelos ML em produção.

## 🎯 Cenário

Desenvolver um modelo de previsão de vendas usando dados históricos, treinar com Spark MLlib, e implementar pipeline automatizado de ML.

## 🏗️ Arquitetura ML

```
Data Lake → Feature Engineering → Model Training → Model Validation → Model Deploy → Monitoring
    ↓              ↓                    ↓              ↓              ↓           ↓
  MinIO         Spark               MLlib         Jupyter        Airflow    Prometheus
                  ↓                    ↓              ↓              ↓           ↓
            Data Processing      Model Registry   Experiments    Automation   Alerts
```

## 📊 Implementação

### 1. Feature Engineering com Spark

```python
# /spark/apps/ml_feature_engineering.py
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.sql.window import Window
from pyspark.ml.feature import StringIndexer, VectorAssembler, StandardScaler
from pyspark.ml import Pipeline

def feature_engineering():
    spark = SparkSession.builder \
        .appName("ML_FeatureEngineering") \
        .master("spark://spark-master:7077") \
        .config("spark.hadoop.fs.s3a.endpoint", "http://minio:9000") \
        .config("spark.hadoop.fs.s3a.access.key") \
        .config("spark.hadoop.fs.s3a.secret.key") \
        .config("spark.hadoop.fs.s3a.path.style.access", "true") \
        .getOrCreate()
    
    # Ler dados históricos
    df_vendas = spark.read.parquet("s3a://processed-data/vendas_detalhadas")
    
    # Feature Engineering
    windowSpec = Window.partitionBy("produto").orderBy("data_venda")
    
    df_features = df_vendas \
        .withColumn("vendas_lag_1", lag("valor_total", 1).over(windowSpec)) \
        .withColumn("vendas_lag_7", lag("valor_total", 7).over(windowSpec)) \
        .withColumn("vendas_lag_30", lag("valor_total", 30).over(windowSpec)) \
        .withColumn("media_movel_7", 
                   avg("valor_total").over(windowSpec.rowsBetween(-6, 0))) \
        .withColumn("media_movel_30", 
                   avg("valor_total").over(windowSpec.rowsBetween(-29, 0))) \
        .withColumn("tendencia", 
                   col("valor_total") - col("media_movel_30")) \
        .withColumn("sazonalidade", dayofweek("data_venda")) \
        .withColumn("mes_ano", concat(year("data_venda"), month("data_venda"))) \
        .filter(col("vendas_lag_30").isNotNull())  # Remove registros sem histórico
    
    # Features categóricas
    indexer_produto = StringIndexer(inputCol="produto", outputCol="produto_idx")
    indexer_categoria = StringIndexer(inputCol="categoria_valor", outputCol="categoria_idx")
    
    # Features numéricas  
    feature_cols = [
        "produto_idx", "categoria_idx", "quantidade", "sazonalidade",
        "vendas_lag_1", "vendas_lag_7", "vendas_lag_30", 
        "media_movel_7", "media_movel_30", "tendencia"
    ]
    
    assembler = VectorAssembler(inputCols=feature_cols, outputCol="features_raw")
    scaler = StandardScaler(inputCol="features_raw", outputCol="features")
    
    # Pipeline de Feature Engineering
    pipeline = Pipeline(stages=[indexer_produto, indexer_categoria, assembler, scaler])
    model = pipeline.fit(df_features)
    df_ml_ready = model.transform(df_features)
    
    # Target variable (próxima venda)
    df_final = df_ml_ready \
        .withColumn("target", lead("valor_total", 1).over(windowSpec)) \
        .filter(col("target").isNotNull()) \
        .select("features", "target", "data_venda", "produto")
    
    # Salvar dados preparados para ML
    df_final.write \
        .mode("overwrite") \
        .parquet("s3a://ml-data/features_dataset")
    
    # Salvar pipeline de features
    model.write().overwrite().save("s3a://ml-models/feature_pipeline")
    
    spark.stop()

if __name__ == "__main__":
    feature_engineering()
```

### 2. Model Training com MLlib

```python
# /spark/apps/ml_model_training.py
from pyspark.sql import SparkSession
from pyspark.ml.regression import RandomForestRegressor, LinearRegression, GBTRegressor
from pyspark.ml.evaluation import RegressionEvaluator
from pyspark.ml.tuning import CrossValidator, ParamGridBuilder
from pyspark.ml import Pipeline
import json

def train_models():
    spark = SparkSession.builder \
        .appName("ML_ModelTraining") \
        .master("spark://spark-master:7077") \
        .getOrCreate()
    
    # Carregar dados preparados
    df = spark.read.parquet("s3a://ml-data/features_dataset")
    
    # Split treino/teste
    train_data, test_data = df.randomSplit([0.8, 0.2], seed=42)
    
    # Modelos para testar
    models = {
        "random_forest": RandomForestRegressor(featuresCol="features", labelCol="target"),
        "linear_regression": LinearRegression(featuresCol="features", labelCol="target"),
        "gradient_boosting": GBTRegressor(featuresCol="features", labelCol="target")
    }
    
    # Avaliador
    evaluator = RegressionEvaluator(labelCol="target", predictionCol="prediction", 
                                   metricName="rmse")
    
    results = {}
    
    for model_name, model in models.items():
        print(f"Treinando {model_name}...")
        
        # Hyperparameter tuning
        if model_name == "random_forest":
            paramGrid = ParamGridBuilder() \
                .addGrid(model.numTrees, [10, 20, 30]) \
                .addGrid(model.maxDepth, [5, 10, 15]) \
                .build()
        elif model_name == "gradient_boosting":
            paramGrid = ParamGridBuilder() \
                .addGrid(model.maxIter, [10, 20]) \
                .addGrid(model.maxDepth, [5, 10]) \
                .build()
        else:
            paramGrid = ParamGridBuilder() \
                .addGrid(model.regParam, [0.01, 0.1, 1.0]) \
                .build()
        
        # Cross Validation
        cv = CrossValidator(estimator=model,
                           estimatorParamMaps=paramGrid,
                           evaluator=evaluator,
                           numFolds=3)
        
        # Treinar modelo
        cv_model = cv.fit(train_data)
        best_model = cv_model.bestModel
        
        # Avaliar no conjunto de teste
        predictions = best_model.transform(test_data)
        rmse = evaluator.evaluate(predictions)
        
        # Métricas adicionais
        mae_evaluator = RegressionEvaluator(labelCol="target", predictionCol="prediction", 
                                           metricName="mae")
        mae = mae_evaluator.evaluate(predictions)
        
        r2_evaluator = RegressionEvaluator(labelCol="target", predictionCol="prediction", 
                                          metricName="r2")
        r2 = r2_evaluator.evaluate(predictions)
        
        results[model_name] = {
            "rmse": rmse,
            "mae": mae,
            "r2": r2,
            "best_params": str(best_model.extractParamMap())
        }
        
        # Salvar modelo
        best_model.write().overwrite().save(f"s3a://ml-models/{model_name}_model")
        
        print(f"{model_name} - RMSE: {rmse:.2f}, MAE: {mae:.2f}, R²: {r2:.2f}")
    
    # Salvar resultados de comparação
    with open("/tmp/model_comparison.json", "w") as f:
        json.dump(results, f, indent=2)
    
    # Upload para MinIO
    from minio import Minio
    client.fput_object("ml-experiments", "model_comparison.json", 
                       "/tmp/model_comparison.json")
    
    spark.stop()
    
    return results

if __name__ == "__main__":
    train_models()
```

### 3. Model Validation e Selection (Jupyter)

```python
# Notebook: Model_Validation_and_Selection.ipynb

import json
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from pyspark.sql import SparkSession
from pyspark.ml import Pipeline
from pyspark.ml.evaluation import RegressionEvaluator

# Configurar Spark
spark = SparkSession.builder \
    .appName("ModelValidation") \
    .master("spark://spark-master:7077") \
    .getOrCreate()

# Carregar resultados da comparação
from minio import Minio

client.fget_object("ml-experiments", "model_comparison.json", "/tmp/results.json")

with open("/tmp/results.json", "r") as f:
    results = json.load(f)

# Visualizar comparação de modelos
df_results = pd.DataFrame(results).T
df_results.reset_index(inplace=True)
df_results.columns = ['Model'] + list(df_results.columns[1:])

# Gráfico de comparação
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

metrics = ['rmse', 'mae', 'r2']
for i, metric in enumerate(metrics):
    df_results.plot(x='Model', y=metric, kind='bar', ax=axes[i])
    axes[i].set_title(f'{metric.upper()} por Modelo')
    axes[i].set_ylabel(metric.upper())

plt.tight_layout()
plt.show()

# Selecionar melhor modelo (menor RMSE)
best_model_name = df_results.loc[df_results['rmse'].idxmin(), 'Model']
print(f"Melhor modelo: {best_model_name}")

# Carregar melhor modelo para análise detalhada
from pyspark.ml.regression import RandomForestRegressionModel, LinearRegressionModel, GBTRegressionModel

if best_model_name == "random_forest":
    best_model = RandomForestRegressionModel.load(f"s3a://ml-models/{best_model_name}_model")
elif best_model_name == "linear_regression":
    best_model = LinearRegressionModel.load(f"s3a://ml-models/{best_model_name}_model")
else:
    best_model = GBTRegressionModel.load(f"s3a://ml-models/{best_model_name}_model")

# Análise de importância de features (se Random Forest)
if hasattr(best_model, 'featureImportances'):
    feature_importance = best_model.featureImportances.toArray()
    feature_names = ['produto_idx', 'categoria_idx', 'quantidade', 'sazonalidade',
                    'vendas_lag_1', 'vendas_lag_7', 'vendas_lag_30', 
                    'media_movel_7', 'media_movel_30', 'tendencia']
    
    importance_df = pd.DataFrame({
        'feature': feature_names,
        'importance': feature_importance
    }).sort_values('importance', ascending=False)
    
    plt.figure(figsize=(10, 6))
    sns.barplot(data=importance_df, x='importance', y='feature')
    plt.title('Importância das Features')
    plt.show()

# Análise de resíduos
test_data = spark.read.parquet("s3a://ml-data/features_dataset") \
    .sample(0.2, seed=42)  # Usar amostra de teste

predictions = best_model.transform(test_data)
residuals_df = predictions.select("target", "prediction") \
    .withColumn("residual", col("target") - col("prediction")) \
    .toPandas()

# Gráfico de resíduos
fig, axes = plt.subplots(1, 2, figsize=(12, 5))

# Predito vs Real
axes[0].scatter(residuals_df['prediction'], residuals_df['target'], alpha=0.5)
axes[0].plot([residuals_df['target'].min(), residuals_df['target'].max()], 
             [residuals_df['target'].min(), residuals_df['target'].max()], 'r--')
axes[0].set_xlabel('Predição')
axes[0].set_ylabel('Valor Real')
axes[0].set_title('Predição vs Valor Real')

# Distribuição dos resíduos
axes[1].hist(residuals_df['residual'], bins=30, alpha=0.7)
axes[1].set_xlabel('Resíduo')
axes[1].set_ylabel('Frequência')
axes[1].set_title('Distribuição dos Resíduos')

plt.tight_layout()
plt.show()

# Salvar modelo selecionado como "production"
best_model.write().overwrite().save("s3a://ml-models/production_model")

print("Modelo de produção atualizado!")
```

### 4. Pipeline de Deploy Automatizado (Airflow)

```python
# /airflow/dags/ml_pipeline.py
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.apache.spark.operators.spark_submit import SparkSubmitOperator
from airflow.operators.email import EmailOperator
from datetime import datetime, timedelta

def validate_new_data(**context):
    """Valida qualidade dos novos dados"""
    # Implementar validações de qualidade
    pass

def deploy_model(**context):
    """Deploy do modelo para produção"""
    # Implementar deployment
    pass

def monitor_model_performance(**context):
    """Monitora performance do modelo em produção"""
    # Implementar monitoramento
    pass

# DAG de ML Pipeline
ml_pipeline = DAG(
    'ml_pipeline_vendas',
    default_args={
        'owner': 'ml-team',
        'depends_on_past': False,
        'email_on_failure': True,
        'email_on_retry': False,
        'retries': 1,
        'retry_delay': timedelta(minutes=5)
    },
    description='Pipeline completo de ML',
    schedule_interval='@weekly',  # Retreino semanal
    start_date=datetime(2025, 1, 1),
    catchup=False
)

# Tasks
data_validation = PythonOperator(
    task_id='validate_new_data',
    python_callable=validate_new_data,
    dag=ml_pipeline
)

feature_engineering = SparkSubmitOperator(
    task_id='feature_engineering',
    application='/opt/bitnami/spark/apps/ml_feature_engineering.py',
    name='ml_feature_engineering_{{ ds }}',
    dag=ml_pipeline
)

model_training = SparkSubmitOperator(
    task_id='model_training',
    application='/opt/bitnami/spark/apps/ml_model_training.py',
    name='ml_model_training_{{ ds }}',
    dag=ml_pipeline
)

model_deployment = PythonOperator(
    task_id='deploy_model',
    python_callable=deploy_model,
    dag=ml_pipeline
)

performance_monitoring = PythonOperator(
    task_id='monitor_performance',
    python_callable=monitor_model_performance,
    dag=ml_pipeline
)

# Notificação de sucesso
success_notification = EmailOperator(
    task_id='send_success_email',
    to=['ml-team@company.com'],
    subject='ML Pipeline - Execução Concluída',
    html_content='Pipeline de ML executado com sucesso!',
    dag=ml_pipeline
)

# Dependências
data_validation >> feature_engineering >> model_training >> model_deployment >> performance_monitoring >> success_notification
```

## 🔧 Configuração e Deploy

### 1. Setup do Ambiente ML
```bash
# Estrutura de diretórios
mkdir -p ml/{models,data,experiments,notebooks}

# Deploy de scripts
cp ml_scripts/* ./spark/apps/
cp ml_dags/* ./airflow/dags/
cp ml_notebooks/* ./jupyter/notebooks/
```

### 2. MLflow Integration (Opcional)
```python
import mlflow
import mlflow.spark

# Track experiments
with mlflow.start_run():
    mlflow.log_param("model_type", "random_forest")
    mlflow.log_metric("rmse", rmse)
    mlflow.spark.log_model(best_model, "model")
```

## 📊 Monitoramento e Governança

### Model Drift Detection
```python
def detect_model_drift():
    """Detecta drift no modelo"""
    current_predictions = get_recent_predictions()
    baseline_predictions = get_baseline_predictions()
    
    # Statistical tests
    from scipy import stats
    statistic, p_value = stats.ks_2samp(current_predictions, baseline_predictions)
    
    if p_value < 0.05:
        send_alert("Model drift detected!")
```

### A/B Testing
```python
def ab_test_models():
    """Testa novos modelos vs modelo atual"""
    traffic_split = 0.1  # 10% para novo modelo
    
    if random.random() < traffic_split:
        return new_model.predict(features)
    else:
        return production_model.predict(features)
```

## 📈 Métricas e KPIs

### Business Metrics
- Accuracy de previsão
- Impact no revenue
- Redução de erro vs baseline

### Technical Metrics  
- Model latency
- Throughput
- Resource utilization
- Data drift scores

## 📚 Próximos Passos

1. **MLOps Platform**: Implementar MLflow ou Kubeflow
2. **Real-time Inference**: API de predição em tempo real
3. **AutoML**: Pipeline automatizado de ML
4. **Model Interpretability**: SHAP, LIME para explicabilidade
5. **Advanced Monitoring**: Comprehensive model monitoring