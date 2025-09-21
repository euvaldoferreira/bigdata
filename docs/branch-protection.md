# 🔒 Configuração de Proteção da Branch Principal

Este documento descreve as configurações necessárias para proteger a branch `main` no GitHub.

## ⚙️ Configurações Obrigatórias

### 📋 Passos para Configurar no GitHub

1. **Acesse as configurações do repositório:**
   - Vá para `Settings` → `Branches`
   - Clique em `Add rule` ou `Add protection rule`

2. **Configure a Branch Protection Rule:**

#### 🎯 **Branch name pattern**
```
main
```

#### ✅ **Proteções Obrigatórias**

**Require a pull request before merging**
- ✅ Habilitado
- **Required number of reviewers:** `1` (ou `2` para projetos críticos)
- ✅ `Dismiss stale PR approvals when new commits are pushed`
- ✅ `Require review from code owners` (se houver CODEOWNERS)
- ✅ `Restrict pushes that create public files` (opcional)

**Require status checks to pass before merging**
- ✅ Habilitado
- ✅ `Require branches to be up to date before merging`
- **Status checks required:**
  ```
  pre-checks
  docker-compose-validation
  makefile-tests
  documentation-check
  security-scan
  conventional-commits (for PRs)
  ```

**Require conversation resolution before merging**
- ✅ Habilitado

**Require signed commits**
- ✅ Habilitado (recomendado para projetos enterprise)

**Require linear history**
- ✅ Habilitado (força rebase em vez de merge commits)

**Include administrators**
- ✅ Habilitado (apply rules to admins too)

**Allow force pushes**
- ❌ Desabilitado

**Allow deletions**
- ❌ Desabilitado

## 🚀 GitHub Actions Configuradas

### 1. **CI Pipeline** (`ci.yml`)
**Executado em:** Push para `main`/`develop` e Pull Requests

**Jobs:**
- 🚀 **Pre-checks:** Validação básica e sintaxe
- 🐳 **Docker Compose Validation:** Valida configurações Docker
- 🧪 **Makefile Tests:** Testa comandos essenciais
- 📖 **Documentation Check:** Verifica documentação
- 🔒 **Security Scan:** Scanner de vulnerabilidades
- 🔗 **Integration Test:** Teste de integração (apenas PRs)
- 📝 **Conventional Commits:** Verifica formato de commits (apenas PRs)

### 2. **Deploy Documentation** (`deploy-docs.yml`)
**Executado em:** Push para `main` (mudanças em docs/)

**Funcionalidade:**
- 📖 Build automático com Jekyll
- 🚀 Deploy para GitHub Pages

### 3. **Test Suite** (`test-suite.yml`)
**Executado em:** Agendamento diário + manual

**Níveis de Teste:**
- 🧪 **Basic:** Testes básicos do ambiente
- 🚀 **Full:** Teste completo de todos os serviços
- 💪 **Stress:** Testes de carga e estresse
- 🔄 **Matrix:** Teste com diferentes versões Docker/Compose

## 🛡️ Configuração de CODEOWNERS (Opcional)

Crie arquivo `.github/CODEOWNERS`:

```bash
# Global owners
* @euvaldoferreira

# Documentation
docs/ @euvaldoferreira
*.md @euvaldoferreira

# Infrastructure
docker-compose.yml @euvaldoferreira
Makefile @euvaldoferreira
.env.example @euvaldoferreira

# CI/CD
.github/ @euvaldoferreira
```

## 🔧 Configuração Local Recomendada

### Para Desenvolvedores
```bash
# Configure git hooks locais
git config core.hooksPath .githooks

# Configure commit template
git config commit.template .gitmessage

# Configure rebase por padrão
git config pull.rebase true

# Configure push para branch atual
git config push.default current
```

### Exemplo de Pre-commit Hook Local
```bash
#!/bin/sh
# .githooks/pre-commit

echo "🔍 Running pre-commit checks..."

# Run pre-check
if ! make pre-check; then
    echo "❌ Pre-check failed"
    exit 1
fi

# Check commit message format (se staging área não vazia)
if git diff --cached --quiet; then
    exit 0
fi

echo "✅ Pre-commit checks passed"
```

## 📊 Workflow de Desenvolvimento

### 🔄 **Processo Padrão:**

1. **Criar Issue** (usando templates)
2. **Fork** do repositório
3. **Clone** e configuração local
4. **Branch** a partir de `main`
5. **Desenvolvimento** com commits frequentes
6. **Testes locais** antes de push
7. **Push** para fork
8. **Pull Request** usando template
9. **CI automático** executa
10. **Code Review** obrigatório
11. **Aprovação** e merge

### 🚨 **Bloqueios Automáticos:**

- ❌ **Direct push** para `main`
- ❌ **Merge** sem aprovação
- ❌ **CI failing** impede merge
- ❌ **Commits não convencionais** (em PRs)
- ❌ **Vulnerabilidades** de segurança críticas

## 🎯 Benefícios da Configuração

### ✅ **Qualidade Garantida:**
- Todos os PRs passam por CI/CD
- Review obrigatório antes do merge
- Testes automatizados múltiplos níveis
- Verificação de segurança automática

### ✅ **Processo Padronizado:**
- Conventional Commits obrigatório
- Templates para Issues e PRs
- Documentação sempre atualizada
- Deploy automático da documentação

### ✅ **Segurança Maximizada:**
- Branch principal protegida
- Commits assinados (recomendado)
- Scanner de vulnerabilidades
- Revisão obrigatória de código

## 🔄 Comandos para Testar CI Localmente

```bash
# Simular checks de CI
make pre-check
docker-compose config
make help

# Testar ambiente básico
make lab
make status
make health
make clean-all

# Verificar documentação
ls docs/
grep -r "TODO\|FIXME" docs/ || echo "No TODOs found"
```

---

## 📞 Aplicação das Configurações

Para aplicar essas configurações:

1. **Acesse GitHub.com** → Seu repositório
2. **Settings** → **Branches** 
3. **Add rule** e configure conforme descrito acima
4. **Settings** → **Actions** → **General**
   - Allow GitHub Actions: ✅ Enabled
   - Workflow permissions: ✅ Read and write permissions

**Após configurar, a branch `main` estará totalmente protegida e o projeto terá CI/CD profissional!** 🛡️