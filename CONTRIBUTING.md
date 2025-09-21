# 🤝 Guia de Contribuição

Obrigado por seu interesse em contribuir com o projeto **Ambiente BigData**! Este guia irá ajudá-lo a contribuir de forma efetiva.

## 📋 Índice

- [🚀 Começando](#-começando)
- [🔧 Configuração do Ambiente](#-configuração-do-ambiente)
- [🌿 Workflow de Contribuição](#-workflow-de-contribuição)
- [📝 Padrões de Código](#-padrões-de-código)
- [📬 Tipos de Contribuição](#-tipos-de-contribuição)
- [🐛 Reportando Bugs](#-reportando-bugs)
- [✨ Sugerindo Melhorias](#-sugerindo-melhorias)
- [📖 Melhorando Documentação](#-melhorando-documentação)
- [🔍 Code Review](#-code-review)

## 🚀 Começando

### Pré-requisitos
- **Git** configurado
- **Docker** e **Docker Compose**
- **Make** (para comandos do projeto)
- Conhecimento básico de containers e BigData

### Primeira Contribuição
1. **Fork** do repositório
2. **Clone** seu fork
3. **Configure** o ambiente
4. **Teste** o ambiente local
5. **Faça** sua primeira contribuição

## 🔧 Configuração do Ambiente

### 1. Fork e Clone
```bash
# 1. Faça fork do repositório no GitHub
# 2. Clone seu fork
git clone https://github.com/SEU_USUARIO/bigdata.git
cd bigdata/containers

# 3. Adicione o repositório original como upstream
git remote add upstream https://github.com/euvaldoferreira/bigdata.git

# 4. Verifique os remotes
git remote -v
```

### 2. Configuração do Git
```bash
# Configure suas informações (se ainda não fez)
git config --global user.name "Seu Nome"
git config --global user.email "seu.email@exemplo.com"

# Configure para usar rebase por padrão
git config --global pull.rebase true

# Configure para usar conventional commits (opcional)
git config --global commit.template .gitmessage
```

### 3. Configuração do Projeto
```bash
# Copie e configure o ambiente
cp .env.example .env
nano .env  # Configure IP e senhas

# Teste o ambiente
make pre-check
make lab     # Ambiente mais leve para desenvolvimento
make status  # Verifique se tudo está funcionando
```

## 🌿 Workflow de Contribuição

### Branch Strategy
Seguimos o **Git Flow** simplificado:

```
main (produção)
  ↑
develop (desenvolvimento) 
  ↑
feature/nova-funcionalidade
hotfix/correcao-urgente
docs/melhoria-documentacao
```

### Processo Passo-a-Passo

#### 1. Sincronizar com upstream
```bash
git checkout main
git pull upstream main
git push origin main
```

#### 2. Criar branch para contribuição
```bash
# Para nova funcionalidade
git checkout -b feature/nome-da-funcionalidade

# Para correção de bug
git checkout -b fix/nome-do-bug

# Para documentação
git checkout -b docs/nome-da-melhoria

# Para refatoração
git checkout -b refactor/nome-da-refatoracao
```

#### 3. Fazer as mudanças
```bash
# Edite os arquivos necessários
# Teste suas mudanças
make test
make health

# Faça commits frequentes com mensagens claras
git add .
git commit -m "feat: adiciona nova funcionalidade X"
```

#### 4. Push e Pull Request
```bash
# Push para seu fork
git push origin feature/nome-da-funcionalidade

# Crie Pull Request no GitHub
# Use o template fornecido
# Aguarde code review
```

## 📝 Padrões de Código

### Conventional Commits
Usamos **Conventional Commits** para mensagens consistentes:

```bash
# Formato
<tipo>[escopo opcional]: <descrição>

[corpo opcional]

[rodapé opcional]
```

#### Tipos principais:
- **feat**: Nova funcionalidade
- **fix**: Correção de bug
- **docs**: Mudanças na documentação
- **style**: Formatação (sem mudança de código)
- **refactor**: Refatoração de código
- **test**: Adição/correção de testes
- **chore**: Tarefas de manutenção

#### Exemplos:
```bash
feat: adiciona comando make backup-all
fix: corrige erro de conexão com PostgreSQL
docs: atualiza guia de instalação
refactor: reorganiza estrutura de comandos do Makefile
test: adiciona testes para verificação de saúde dos serviços
chore: atualiza versão do Docker Compose para 2.0
```

### Padrões de Arquivos

#### Makefile
- Use tabs (não espaços) para indentação
- Adicione comentários descritivos
- Siga o padrão de cores existente
- Teste comandos antes de commitar

#### Docker Compose
- Use sempre a versão mais recente sem declarar `version:`
- Mantenha ordem alfabética nos serviços
- Use variáveis de ambiente do `.env`
- Documente portas e volumes

#### Documentação
- Use Markdown padrão
- Adicione emojis para melhor UX
- Mantenha TOC (Table of Contents)
- Teste links e comandos

## 📬 Tipos de Contribuição

### 🐛 Correções de Bug
- Use template de bug report
- Reproduza o problema
- Adicione testes se possível
- Documente a correção

### ✨ Novas Funcionalidades
- Discuta primeiro em Issues
- Siga padrões existentes
- Adicione documentação
- Adicione testes quando aplicável

### 📖 Documentação
- README conciso
- Docs detalhadas em `docs/`
- Exemplos práticos
- Screenshots quando necessário

### 🔧 Melhorias de Performance
- Benchmark antes/depois
- Documente mudanças
- Considere retrocompatibilidade

## 🐛 Reportando Bugs

Use o template de Issue para bugs:

```markdown
**Descrição do Bug**
Descrição clara do problema.

**Para Reproduzir**
Passos para reproduzir:
1. Execute '...'
2. Clique em '....'
3. Veja o erro

**Comportamento Esperado**
O que deveria acontecer.

**Screenshots**
Se aplicável, adicione screenshots.

**Ambiente:**
- OS: [Ubuntu 20.04, Windows 10, etc.]
- Docker: [versão]
- RAM: [quantidade]

**Logs**
```
logs relevantes aqui
```

**Contexto Adicional**
Qualquer outra informação relevante.
```

## ✨ Sugerindo Melhorias

Para sugestões de melhorias:

1. **Verifique** se já não foi sugerido
2. **Descreva** o problema atual
3. **Proponha** a solução
4. **Considere** alternativas
5. **Adicione** contexto adicional

## 📖 Melhorando Documentação

### Estrutura da Documentação
```
README.md              # Guia rápido e essencial
docs/
├── commands.md        # Referência de comandos
├── troubleshooting.md # Soluções de problemas
├── architecture.md    # Detalhes técnicos
└── services/          # Docs específicas por serviço
```

### Diretrizes
- **README**: Mantenha conciso e focado
- **docs/**: Documentação detalhada
- **Exemplos**: Sempre inclua exemplos práticos
- **Screenshots**: Use quando necessário
- **Links**: Mantenha links atualizados

## 🔍 Code Review

### Como Revisor
- **Seja construtivo** e respeitoso
- **Teste** as mudanças localmente
- **Verifique** se segue os padrões
- **Considere** o impacto das mudanças

### Como Autor
- **Responda** aos comentários
- **Faça** mudanças solicitadas
- **Teste** novamente após mudanças
- **Mantenha** a discussão técnica

## 🏷️ Versionamento

Seguimos **Semantic Versioning** (SemVer):

- **MAJOR** (1.0.0): Mudanças incompatíveis
- **MINOR** (0.1.0): Novas funcionalidades compatíveis
- **PATCH** (0.0.1): Correções de bugs

## 🧪 Testes

### Antes de Submeter PR
```bash
# Teste comandos básicos
make pre-check
make start     # ou make lab
make status
make health
make test

# Teste comandos específicos da sua mudança
make [seu-novo-comando]

# Verifique logs
make logs
```

### Ambiente de Teste
- Use `make lab` para desenvolvimento
- Teste em ambiente limpo
- Verifique com `make clean-airflow` se necessário

## 🆘 Obtendo Ajuda

- **Issues**: Para bugs e sugestões
- **Discussions**: Para perguntas gerais
- **Discord/Slack**: Se disponível
- **Email**: Para questões sensíveis

## 📄 Licença

Ao contribuir, você concorda que suas contribuições serão licenciadas sob a mesma licença do projeto (MIT).

## 🙏 Reconhecimento

Contribuidores são reconhecidos:
- **README**: Seção de contribuidores
- **CHANGELOG**: Menções em releases
- **GitHub**: Profile contributions

---

**Obrigado por contribuir! Sua ajuda torna este projeto melhor para todos.** 🚀