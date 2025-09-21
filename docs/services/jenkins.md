# 🏗️ Jenkins

Jenkins é uma plataforma de automação que suporta Continuous Integration e Continuous Deployment (CI/CD).

## 🚀 Características

- **CI/CD**: Automação de build, test e deploy
- **Plugins**: Mais de 1800 plugins disponíveis
- **Pipeline as Code**: Jenkinsfile para versionamento
- **Distribuído**: Master/Agent architecture

## 🔧 Configuração no Projeto

### Acesso
- **URL**: http://localhost:8082
- **Usuário**: admin (configurável via .env)
- **Senha**: admin (configurável via .env)

### Estrutura de Arquivos
```
jenkins/
├── Dockerfile          # Custom Jenkins image
├── config/             # Configurações
└── jobs/              # Definições de jobs
```

## 📊 Uso Básico

### Pipeline Exemplo
```groovy
pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/seu-repo/projeto.git'
            }
        }
        
        stage('Build') {
            steps {
                sh 'docker-compose build'
            }
        }
        
        stage('Test') {
            steps {
                sh 'make test'
            }
        }
        
        stage('Deploy') {
            steps {
                sh 'make deploy'
            }
        }
    }
}
```

### Integração com Docker
```groovy
// Executar dentro de container
pipeline {
    agent {
        docker {
            image 'python:3.11'
        }
    }
    
    stages {
        stage('Test') {
            steps {
                sh 'pip install -r requirements.txt'
                sh 'python -m pytest'
            }
        }
    }
}
```

## 🔗 Integração com Outros Serviços

- **Docker**: Build e deploy de containers
- **Git**: Integração com repositórios
- **Spark**: Automação de jobs Spark
- **Airflow**: Deploy de DAGs

## 📚 Plugins Recomendados

- **Blue Ocean**: Interface moderna
- **Pipeline**: Pipeline as Code
- **Docker**: Integração Docker
- **Git**: Integração Git avançada

## 📚 Documentação Oficial

- [Documentação Jenkins](https://www.jenkins.io/doc/)
- [Pipeline Tutorial](https://www.jenkins.io/doc/book/pipeline/)