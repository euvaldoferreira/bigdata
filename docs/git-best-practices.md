# 🚀 Configurações Recomendadas do Git

Este guia apresenta as **melhores práticas e configurações do Git** para contribuir efetivamente com o projeto BigData.

## 📋 Índice

- [⚙️ Configuração Inicial](#️-configuração-inicial)
- [🌿 Estratégia de Branches](#-estratégia-de-branches)
- [📝 Conventional Commits](#-conventional-commits)
- [🔄 Workflow Recomendado](#-workflow-recomendado)
- [🛠️ Ferramentas e Aliases](#️-ferramentas-e-aliases)
- [📊 Boas Práticas](#-boas-práticas)
- [🚨 Problemas Comuns](#-problemas-comuns)

## ⚙️ Configuração Inicial

### 1. Configuração Básica do Git
```bash
# Configurações globais essenciais
git config --global user.name "Seu Nome Completo"
git config --global user.email "seu.email@exemplo.com"

# Configurações de comportamento
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global push.default simple
git config --global core.autocrlf input  # Linux/Mac
# git config --global core.autocrlf true  # Windows

# Editor padrão (escolha um)
git config --global core.editor "nano"
git config --global core.editor "vim"
git config --global core.editor "code --wait"  # VS Code
```

### 2. Template de Commit
```bash
# Configure o template de commit para mensagens consistentes
git config --global commit.template ~/.gitmessage

# Copie o template do projeto para seu home
cp .gitmessage ~/.gitmessage
```

### 3. Configurações de Segurança
```bash
# Habilita verificação de assinatura (recomendado)
git config --global commit.gpgsign true
git config --global user.signingkey SEU_GPG_KEY_ID

# Habilita verificação de push
git config --global push.followTags true
```

### 4. Configurações de Performance
```bash
# Melhora performance em repositórios grandes
git config --global core.preloadindex true
git config --global core.fscache true
git config --global gc.auto 256

# Habilita paralelização
git config --global checkout.workers 0  # Auto-detecta
```

## 🌿 Estratégia de Branches

### Modelo Git Flow Simplificado

```
main (produção)
  ↑
develop (desenvolvimento)
  ↑
feature/nome-da-funcionalidade
hotfix/nome-da-correcao
docs/nome-da-documentacao
refactor/nome-da-refatoracao
```

### Convenção de Nomes de Branches

#### Prefixos Padrão:
- **`feature/`**: Novas funcionalidades
- **`fix/`**: Correções de bugs
- **`hotfix/`**: Correções urgentes
- **`docs/`**: Melhorias na documentação
- **`refactor/`**: Refatoração de código
- **`test/`**: Adição/correção de testes
- **`chore/`**: Tarefas de manutenção

#### Exemplos:
```bash
feature/adiciona-monitoring-prometheus
fix/corrige-conexao-postgresql
hotfix/resolve-memory-leak-airflow
docs/atualiza-guia-instalacao
refactor/reorganiza-comandos-makefile
test/adiciona-testes-integracao
chore/atualiza-dependencias-docker
```

### Comandos de Branch
```bash
# Criar e trocar para nova branch
git checkout -b feature/nova-funcionalidade

# Listar branches locais e remotas
git branch -a

# Deletar branch local
git branch -d feature/funcionalidade-antiga

# Deletar branch remota
git push origin --delete feature/funcionalidade-antiga

# Trocar para branch principal e atualizar
git checkout main
git pull upstream main
```

## 📝 Conventional Commits

### Formato Padrão
```
<tipo>[escopo opcional]: <descrição>

[corpo opcional]

[rodapé opcional]
```

### Tipos Principais
- **`feat`**: Nova funcionalidade
- **`fix`**: Correção de bug
- **`docs`**: Mudanças na documentação
- **`style`**: Formatação, pontos e vírgulas, etc.
- **`refactor`**: Refatoração sem mudança de funcionalidade
- **`test`**: Adição ou correção de testes
- **`chore`**: Manutenção, atualização de dependências

### Exemplos Práticos
```bash
# Funcionalidade simples
feat: adiciona comando make backup-all

# Funcionalidade com escopo
feat(airflow): adiciona DAG de processamento de logs

# Correção de bug
fix: corrige erro de conexão com PostgreSQL

# Breaking change
feat!: remove suporte ao Docker Compose v1

# Com corpo e rodapé
feat: adiciona sistema de monitoring

Implementa Prometheus e Grafana para monitoramento
dos serviços do ambiente BigData.

Closes #123
```

## 🔄 Workflow Recomendado

### 1. Preparação
```bash
# 1. Fork do repositório (no GitHub)
# 2. Clone do seu fork
git clone https://github.com/SEU_USUARIO/bigdata.git
cd bigdata/containers

# 3. Adicione o repositório original
git remote add upstream https://github.com/euvaldoferreira/bigdata.git

# 4. Verifique os remotes
git remote -v
```

### 2. Início do Trabalho
```bash
# 1. Sincronize com upstream
git checkout main
git pull upstream main
git push origin main

# 2. Crie branch para sua contribuição
git checkout -b feature/minha-contribuicao

# 3. Trabalhe e faça commits
git add .
git commit -m "feat: adiciona nova funcionalidade"

# 4. Push regular para backup
git push origin feature/minha-contribuicao
```

### 3. Finalizando
```bash
# 1. Sincronize novamente antes do PR
git checkout main
git pull upstream main
git checkout feature/minha-contribuicao
git rebase main

# 2. Push final
git push origin feature/minha-contribuicao --force-with-lease

# 3. Crie Pull Request no GitHub
```

## 🛠️ Ferramentas e Aliases

### Aliases Úteis
```bash
# Adicione ao ~/.gitconfig ou use git config --global
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual '!gitk'

# Aliases avançados
git config --global alias.lg "log --oneline --decorate --graph --all"
git config --global alias.amend "commit --amend --no-edit"
git config --global alias.force "push --force-with-lease"
git config --global alias.cleanup "branch --merged | grep -v main | xargs git branch -d"
```

### Hooks Úteis

#### Pre-commit Hook
```bash
# .git/hooks/pre-commit
#!/bin/sh
# Verifica se comandos Makefile funcionam antes do commit

echo "🔍 Verificando comandos Makefile..."
make pre-check

if [ $? -ne 0 ]; then
    echo "❌ Pre-check falhou. Commit cancelado."
    exit 1
fi

echo "✅ Pre-check passou. Continuando commit..."
```

#### Commit Message Hook
```bash
# .git/hooks/commit-msg
#!/bin/sh
# Verifica se a mensagem segue Conventional Commits

commit_regex='^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .+'

if ! grep -qE "$commit_regex" "$1"; then
    echo "❌ Mensagem de commit inválida!"
    echo "Use o formato: <tipo>[escopo]: <descrição>"
    echo "Exemplo: feat: adiciona nova funcionalidade"
    exit 1
fi
```

## 📊 Boas Práticas

### Commits
- **Faça commits pequenos e frequentes**
- **Uma mudança por commit**
- **Teste antes de commitar**
- **Use mensagens descritivas**

### Branches
- **Use nomes descritivos**
- **Mantenha branches atualizadas**
- **Delete branches após merge**
- **Evite branches de longa duração**

### Pull Requests
- **Sincronize antes de criar PR**
- **Use template fornecido**
- **Adicione descrição detalhada**
- **Responda aos comentários rapidamente**

### Colaboração
- **Comunique mudanças grandes**
- **Revise PRs de outros**
- **Seja respeitoso nos comentários**
- **Documente decisões técnicas**

## 🚨 Problemas Comuns

### 1. Conflitos de Merge
```bash
# Resolver conflitos durante rebase
git checkout feature/minha-branch
git rebase main

# Edite arquivos em conflito
# Marque como resolvido
git add arquivo-resolvido.txt
git rebase --continue

# Se necessário, aborte o rebase
git rebase --abort
```

### 2. Commit com Informações Erradas
```bash
# Alterar último commit
git commit --amend -m "nova mensagem"

# Alterar autor do último commit
git commit --amend --author="Nome Correto <email@correto.com>"
```

### 3. Push Rejeitado
```bash
# Usar force-with-lease (mais seguro)
git push --force-with-lease origin feature/minha-branch

# Se necessário, fazer rebase primeiro
git pull --rebase origin feature/minha-branch
```

### 4. Branch Desatualizada
```bash
# Atualizar branch com main
git checkout feature/minha-branch
git rebase main

# Ou merge (menos preferível)
git merge main
```

## 🔒 Segurança

### GPG Signing
```bash
# Gerar chave GPG
gpg --full-generate-key

# Listar chaves
gpg --list-secret-keys --keyid-format LONG

# Configurar Git
git config --global user.signingkey SEU_KEY_ID
git config --global commit.gpgsign true

# Adicionar ao GitHub
gpg --armor --export SEU_KEY_ID
```

### SSH Keys
```bash
# Gerar chave SSH
ssh-keygen -t ed25519 -C "seu.email@exemplo.com"

# Adicionar ao ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Testar conexão
ssh -T git@github.com
```

## 📈 Monitoramento

### Estatísticas Úteis
```bash
# Estatísticas de contribuições
git shortlog -sn
git log --oneline --graph --decorate --all

# Arquivos mais modificados
git log --pretty=format: --name-only | sort | uniq -c | sort -rg | head -20

# Commits por autor
git shortlog -s -n --all --no-merges
```

### Verificação de Saúde
```bash
# Verificar integridade do repositório
git fsck

# Limpar objetos desnecessários
git gc --aggressive

# Verificar status
git status --porcelain
```

---

**Seguindo essas práticas, você contribuirá de forma efetiva e profissional para o projeto BigData!** 🚀