#!/bin/bash

# Script para configurar buckets e políticas no MinIO
# Este script é executado automaticamente pelo container minio-client

echo "Configurando MinIO..."

# Aguarda o MinIO estar disponível
until nc -z minio 9000; do
  echo "Aguardando MinIO estar disponível..."
  sleep 2
done

echo "MinIO disponível. Configurando alias..."

# Configura alias do MinIO
mc alias set myminio http://minio:9000 minioadmin minioadmin123

echo "Criando buckets..."

# Cria buckets principais
mc mb myminio/airflow-logs --ignore-existing
mc mb myminio/spark-data --ignore-existing
mc mb myminio/jupyter-data --ignore-existing
mc mb myminio/jenkins-backup --ignore-existing
mc mb myminio/data-lake --ignore-existing
mc mb myminio/processed-data --ignore-existing

echo "Configurando políticas de acesso..."

# Configura políticas de acesso público para alguns buckets
mc policy set public myminio/airflow-logs
mc policy set public myminio/spark-data
mc policy set public myminio/data-lake

# Configura política privada para backups
mc policy set private myminio/jenkins-backup

echo "Criando estrutura de diretórios nos buckets..."

# Cria estrutura de diretórios
mc cp /dev/null myminio/data-lake/raw/.keep
mc cp /dev/null myminio/data-lake/processed/.keep
mc cp /dev/null myminio/data-lake/staging/.keep
mc cp /dev/null myminio/spark-data/input/.keep
mc cp /dev/null myminio/spark-data/output/.keep
mc cp /dev/null myminio/jupyter-data/notebooks/.keep
mc cp /dev/null myminio/jupyter-data/datasets/.keep

echo "Configuração do MinIO concluída!"

# Lista buckets criados
echo "Buckets disponíveis:"
mc ls myminio

exit 0