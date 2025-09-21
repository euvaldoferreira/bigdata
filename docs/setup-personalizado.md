# 🔧 Setup Personalizado do Repositório

## ⚡ Setup Automático

Para novos colaboradores, use o script automático:

```bash
# Configurar para seu usuário
./scripts/setup-repo.sh SEU_USUARIO euvaldoferreira

# Exemplo:
./scripts/setup-repo.sh joao euvaldoferreira
```

## 📋 O que o script faz:

✅ **Atualiza CODEOWNERS** com seu usuário  
✅ **Configura URLs** personalizadas  
✅ **Atualiza documentação** com suas informações  
✅ **Configura Git local** com hooks e templates  
✅ **Adiciona remote upstream** automaticamente  

## 🔧 Setup Manual (se preferir)

### 0. Configurar Plataforma Docker
```bash
# Detectar e configurar automaticamente
make detect-platform

# OU configurar manualmente no .env
echo "DOCKER_PLATFORM=linux/amd64" >> .env  # Para Intel/Codespaces
echo "DOCKER_PLATFORM=linux/arm64" >> .env  # Para Mac M1/M2
```

### 1. Atualizar CODEOWNERS
```bash
# Substitua @euvaldoferreira por @SEU_USUARIO
nano .github/CODEOWNERS
```

### 2. Atualizar URLs de configuração
Edite os arquivos:
- `CONFIGURE-GITHUB.md`
- `CONTRIBUTING.md` 
- `docs/git-best-practices.md`
- `docs/branch-protection.md`

### 3. Configurar Git local
```bash
git config core.hooksPath .githooks
git config commit.template .gitmessage
git config pull.rebase true
```

### 4. Adicionar upstream
```bash
git remote add upstream https://github.com/euvaldoferreira/bigdata.git
```

## 🎯 Resultado

Após o setup, você terá:
- ✅ **Configurações personalizadas** para seu repositório
- ✅ **URLs corretas** para proteção de branch
- ✅ **Git hooks ativos** com validações
- ✅ **Upstream configurado** para sincronização
- ✅ **Documentação atualizada** com suas informações

---

**💡 Dica: Execute o script sempre que fizer fork do repositório!**