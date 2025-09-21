# 🛡️ CONFIGURAÇÃO URGENTE: Proteção da Branch Main

## ⚠️ AÇÃO NECESSÁRIA NO GITHUB

Para ativar a proteção da branch e CI/CD, você precisa configurar no GitHub:

### 🔧 **1. Configurar Proteção da Branch (URGENTE)**

1. **Acesse:** `https://github.com/SEU_USUARIO/bigdata/settings/branches`
2. **Clique:** "Add rule" ou "Add protection rule"
3. **Configure:**

```
Branch name pattern: main

✅ Require a pull request before merging
   - Required number of reviewers: 1
   ✅ Dismiss stale PR approvals when new commits are pushed
   ✅ Require review from code owners

✅ Require status checks to pass before merging
   ✅ Require branches to be up to date before merging
   
   Status checks obrigatórios:
   - 🚀 Pre-checks
   - 🐳 Docker Compose Validation
   - 🧪 Makefile Commands Test
   - 📖 Documentation Check
   - 🔒 Security Scan
   - 🔗 Integration Test (apenas para PRs)
   - 📝 Conventional Commits Check (apenas para PRs)

✅ Require conversation resolution before merging
✅ Restrict pushes that create public files (opcional)
✅ Include administrators
❌ Allow force pushes (DISABLED)
❌ Allow deletions (DISABLED)
```

### 🚀 **2. Ativar GitHub Actions**

1. **Acesse:** `https://github.com/SEU_USUARIO/bigdata/settings/actions`
2. **Configure:**
   - ✅ **Allow all actions and reusable workflows**
   - ✅ **Read and write permissions**
   - ✅ **Allow GitHub Actions to create and approve pull requests**

### 📄 **3. Ativar GitHub Pages**

1. **Acesse:** `https://github.com/SEU_USUARIO/bigdata/settings/pages`
2. **Configure:**
   - **Source:** GitHub Actions
   - ✅ **Enforce HTTPS**

### 🔐 **4. Configurar Secrets (se necessário)**

1. **Acesse:** `https://github.com/SEU_USUARIO/bigdata/settings/secrets/actions`
2. **Adicione secrets se usar serviços externos:**
   - `DOCKER_USERNAME` (para push de imagens)
   - `DOCKER_PASSWORD` (para push de imagens)
   - Outros secrets conforme necessidade

## 🤖 **Workflows Configurados**

O projeto inclui 3 workflows automáticos:

### **1. CI Pipeline (ci.yml)**
- **Trigger:** Push/PR para main/develop
- **Função:** Testes automáticos de qualidade
- **Jobs:** Pre-checks, Docker validation, Makefile tests, Docs check, Security scan

### **2. Deploy Documentation (deploy-docs.yml)**  
- **Trigger:** Push para main (mudanças em docs/)
- **Função:** Deploy automático para GitHub Pages
- **Resultado:** Documentação online atualizada

### **3. Test Suite (test-suite.yml)**
- **Trigger:** Diário às 2h UTC + Manual
- **Função:** Testes extensivos do ambiente
- **Níveis:** Basic, Full, Stress, Matrix testing

## 🎯 **Resultado Esperado**

Após configurar corretamente:
- ❌ **Push direto** para main será **bloqueado**
- ✅ **PRs obrigatórios** com revisão de código
- ✅ **CI automático** executa em todos os PRs
- ✅ **Testes automatizados** diários (test-suite.yml)
- ✅ **Deploy automático** da documentação (deploy-docs.yml)
- ✅ **Proteção contra** commits não convencionais
- ✅ **Scanner de segurança** automático

## 🧪 **Testar Configuração Local**

```bash
# 1. Configure hooks locais
git config core.hooksPath .githooks

# 2. Teste simulação de CI
./scripts/test-ci.sh

# 3. Teste formato de commit (deve validar)
git commit -m "feat: teste do formato conventional"

# 4. Teste proteção de branch (deve falhar)
git push origin main  # Deve ser bloqueado pelos hooks
```

## 📊 **Verificar Status dos Checks**

Após criar um PR, verifique se todos os checks passam:
- 🚀 **Pre-checks** - Validações básicas
- 🐳 **Docker Compose** - Configuração válida  
- 🧪 **Makefile** - Comandos funcionais
- 📖 **Documentation** - Estrutura correta
- 🔒 **Security** - Scanner Trivy
- 🔗 **Integration** - Testes de integração
- 📝 **Conventional Commits** - Formato correto

## 🆘 **Suporte e Troubleshooting**

### **Problemas Comuns:**

**1. Actions não executam:**
- Verifique se GitHub Actions está habilitado
- Confirme permissões de read/write
- Verifique se o repositório não é privado com limitações

**2. Checks falham constantemente:**
- Execute `./scripts/test-ci.sh` localmente primeiro
- Verifique logs nas Actions do GitHub
- Confirme se `.env.example` está presente

**3. Branch protection não funciona:**
- Confirme que o nome da branch é exatamente `main`
- Verifique se os nomes dos checks estão corretos
- Aguarde primeira execução dos workflows

### **Recursos Adicionais:**
1. Documentação completa: `docs/branch-protection.md`
2. Testes locais: `./scripts/test-ci.sh`
3. Configuração Git: `docs/git-best-practices.md`
4. Setup personalizado: `docs/setup-personalizado.md`

### **Logs e Debug:**
- Actions logs: `https://github.com/SEU_USUARIO/bigdata/actions`
- Protection settings: `https://github.com/SEU_USUARIO/bigdata/settings/branches`

---

**⚡ CONFIGURAR AGORA PARA ATIVAR PROTEÇÃO TOTAL!**