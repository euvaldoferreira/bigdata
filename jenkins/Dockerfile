FROM jenkins/jenkins:lts

## Instalar Python packages úteis para CI/CD
RUN pip3 install --break-system-packages \
    boto3==1.28.57 \
    minio==7.1.17 \
    requests==2.32.4 \
    pyyaml==6.0.1 \
    docker==7.1.0ar como root para adicionar dependências
USER root

# Instalar Docker CLI, Python e outras dependências
RUN apt-get update && \
    apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    python3 \
    python3-pip \
    git \
    vim \
    wget && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli

# Instalar MinIO client
RUN wget https://dl.min.io/client/mc/release/linux-amd64/mc -O /usr/local/bin/mc && \
    chmod +x /usr/local/bin/mc

# Instalar Python packages úteis para CI/CD com versões fixas
RUN pip3 install --break-system-packages \
    boto3==1.34.144 \
    minio==7.2.7 \
    requests==2.32.3 \
    pyyaml==6.0.1 \
    docker==7.1.0

# Adicionar usuário jenkins ao grupo docker
RUN usermod -aG docker jenkins

# Voltar para usuário jenkins
USER jenkins

# Instalar plugins do Jenkins automaticamente
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Copiar configurações iniciais
COPY init.groovy.d/ /usr/share/jenkins/ref/init.groovy.d/

# Configurar variáveis de ambiente
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"
ENV JENKINS_OPTS="--httpPort=8082"