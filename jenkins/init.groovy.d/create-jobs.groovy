import jenkins.model.*
import org.jenkinsci.plugins.workflow.job.WorkflowJob
import org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition

def instance = Jenkins.getInstance()

// Job de exemplo para Build e Deploy
def jobName = "BigData-Pipeline-Example"
def job = instance.createProject(WorkflowJob.class, jobName)

def pipelineScript = '''
pipeline {
    agent any
    
    environment {
        MINIO_ENDPOINT = 'minio:9000'
        MINIO_ACCESS_KEY = 'minioadmin'
        MINIO_SECRET_KEY = 'minioadmin123'
        SPARK_MASTER = 'spark://spark-master:7077'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Fazendo checkout do código...'
                // git 'https://github.com/seu-repo/bigdata-project.git'
            }
        }
        
        stage('Test MinIO Connection') {
            steps {
                script {
                    sh '''
                        python3 -c "
import sys
sys.path.append('/usr/local/lib/python3.9/site-packages')
from minio import Minio
client = Minio('${MINIO_ENDPOINT}', '${MINIO_ACCESS_KEY}', '${MINIO_SECRET_KEY}', secure=False)
buckets = client.list_buckets()
print('Buckets:', [b.name for b in buckets])
"
                    '''
                }
            }
        }
        
        stage('Build') {
            steps {
                echo 'Construindo aplicação...'
                // Aqui você colocaria os comandos de build
            }
        }
        
        stage('Test') {
            steps {
                echo 'Executando testes...'
                // Aqui você colocaria os comandos de teste
            }
        }
        
        stage('Deploy to Spark') {
            steps {
                echo 'Fazendo deploy para Spark...'
                // Comando para submeter job ao Spark
                // sh 'spark-submit --master ${SPARK_MASTER} app.py'
            }
        }
        
        stage('Backup to MinIO') {
            steps {
                echo 'Fazendo backup para MinIO...'
                script {
                    sh '''
                        mc alias set myminio http://${MINIO_ENDPOINT} ${MINIO_ACCESS_KEY} ${MINIO_SECRET_KEY}
                        mc cp -r . myminio/jenkins-backup/builds/$(date +%Y%m%d_%H%M%S)/
                    '''
                }
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline concluído!'
        }
        success {
            echo 'Pipeline executado com sucesso!'
        }
        failure {
            echo 'Pipeline falhou!'
        }
    }
}
'''

job.setDefinition(new CpsFlowDefinition(pipelineScript, true))
job.save()

println("Job '$jobName' criado com sucesso!")

instance.save()