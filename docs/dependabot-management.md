# 🤖 Guia de Gerenciamento de Dependabot

## 📋 Política de Atualizações Automáticas

### 🎯 **Estratégia Conservadora Implementada**

#### **Frequências de Update:**
- 🐍 **Python**: Semanal (segundas 09:00) - apenas security + major
- 🐳 **Docker**: Mensal (primeira terça) - apenas security
- 🔧 **GitHub Actions**: Mensal - apenas security + major

#### **Limites de Ruído:**
- ✅ **Máximo 3 PRs Python** simultâneos
- ✅ **Máximo 2 PRs Docker** simultâneos
- ✅ **Auto-assignment** para revisão imediata

### 🚨 **Controles de Segurança**

#### **❌ PRs NÃO são aprovados automaticamente:**
1. **Branch Protection** obriga revisão humana
2. **CI/CD deve passar** antes de merge
3. **Assignee automático** garante atenção imediata
4. **Labels claras** identificam tipo de update

#### **✅ Apenas atualizações críticas:**
- 🔒 **Security updates**: Sempre permitidos
- 📦 **Major versions**: Apenas quando necessário
- ❌ **Patch/Minor**: Ignorados (reduz ruído)

### 🔄 **Fluxo de Trabalho Recomendado**

#### **1. Quando Dependabot cria PR:**
```bash
# Você recebe notificação automática
# PR aparece com labels: "needs-review", "security", etc.
```

#### **2. Revisão obrigatória:**
```bash
# 1. Verificar CHANGELOG da dependência
# 2. Verificar se é security fix crítico
# 3. Testar localmente se necessário
# 4. Aprovar ou fechar PR
```

#### **3. Após aprovação:**
```bash
# CI/CD executa todos os testes
# Merge só acontece se tudo passar
# Branch do PR é deletada automaticamente
```

### 💻 **Ambiente Local - Sincronização**

#### **Problema:** Dev local desatualizado após merges automáticos

#### **Solução 1: Sync diário automático**
```bash
# Adicione ao seu ~/.bashrc ou script diário
alias git-sync='git checkout main && git pull origin main && git fetch --prune'

# Execute diariamente
git-sync
```

#### **Solução 2: Hook de pré-commit local**
```bash
# Script que roda antes de commits locais
#!/bin/bash
echo "🔍 Verificando se main está atualizada..."
git fetch origin main
BEHIND=$(git rev-list --count HEAD..origin/main)

if [ $BEHIND -gt 0 ]; then
    echo "⚠️  Sua main está $BEHIND commits atrás!"
    echo "Execute: git pull origin main"
    exit 1
fi
```

#### **Solução 3: Notificações automáticas**
```bash
# GitHub CLI para monitorar PRs
gh pr list --state merged --label "dependencies" --limit 5

# Webhook Discord/Slack quando PR é mergeado
# (configurar no GitHub repo settings)
```

### 📊 **Monitoramento e Controle**

#### **Dashboard de Dependências:**
- 🔍 **GitHub Security Tab**: Vulnerabilidades ativas
- 📋 **GitHub PRs**: PRs pendentes do Dependabot  
- 📈 **GitHub Insights**: Frequência de updates

#### **Comandos úteis:**
```bash
# Ver PRs do Dependabot
gh pr list --author "app/dependabot"

# Ver últimos merges automáticos
git log --oneline --author="dependabot" --since="1 week ago"

# Verificar diff da main local vs remota
git log HEAD..origin/main --oneline

# Sincronizar forçado
git reset --hard origin/main
```

### 🚫 **Como Desabilitar (se necessário)**

#### **Temporariamente:**
```yaml
# .github/dependabot.yml
schedule:
  interval: "weekly"
  # Comentar para pausar
```

#### **Por dependência específica:**
```yaml
ignore:
  - dependency-name: "problematic-package"
    update-types: ["version-update:all"]
```

#### **Completamente:**
```bash
# Deletar arquivo .github/dependabot.yml
rm .github/dependabot.yml
```

### 🎯 **Melhores Práticas para Equipe**

#### **Para Desenvolvedores:**
1. ✅ **Sync diário** com `git pull origin main`
2. ✅ **Revisar PRs** do Dependabot rapidamente
3. ✅ **Testar localmente** updates críticos
4. ✅ **Não ignorar** notificações de security

#### **Para Projeto Manager:**
1. ✅ **Monitorar** frequency de PRs (se muito alto, ajustar)
2. ✅ **Definir** SLA para aprovação (24h para security)
3. ✅ **Treinar** equipe no processo
4. ✅ **Revisar** configuração mensalmente

### 🔄 **Configuração Atual - Resumo**

```yaml
# Configuração conservadora implementada:
Python: Semanal, apenas security + major versions
Docker: Mensal, apenas security  
GitHub Actions: Mensal, apenas major + security
Max PRs: 3 Python, 2 Docker
Auto-assign: euvaldoferreira
Labels: needs-review, security, dependencies
```

### ⚠️ **Riscos Mitigados**

1. **❌ Merge automático**: Impossível - revisão obrigatória
2. **❌ Quebrar produção**: CI/CD obrigatório antes merge
3. **❌ Spam de PRs**: Limites configurados + filtros conservadores  
4. **❌ Dev desatualizado**: Guias de sincronização + notificações
5. **❌ Dependências problemáticas**: Allow list apenas para security

---

> 💡 **Conclusão:** Dependabot é seguro quando bem configurado. A chave é equilibrar automação com controle humano.