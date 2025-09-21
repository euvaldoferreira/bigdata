# 🛠️ Scripts Utilitários

Esta pasta contém scripts utilitários para o ambiente BigData.

## 📋 Scripts Disponíveis

### `setup-minio.sh` - Configuração MinIO
Configura buckets e políticas no MinIO:
- Cria buckets essenciais para os serviços
- Configura políticas de acesso
- Executa automaticamente no container

### `setup-repo.sh` - Configuração Repositório
Configura repositório para novos mantenedores:
- Personaliza documentação com suas informações
- Configura Git hooks locais
- Facilita setup inicial

### `test-basic.sh` - Testes Básicos
Executa testes básicos do ambiente:
- Verifica comandos essenciais
- Testa ambiente lab
- Verifica conectividade dos serviços

### `test-ci.sh` - Simula CI Local
Simula os testes que rodam no CI:
- Todos os checks de validação
- Testes de segurança
- Verificação de documentação

## 🚀 Como Usar

```bash
# Configurar repositório (para novos mantenedores)
./scripts/setup-repo.sh SEU_USUARIO OWNER_ORIGINAL

# Testes básicos
./scripts/test-basic.sh

# Simular CI localmente
./scripts/test-ci.sh
```

## 📊 Interpretando Resultados

- ✅ **PASS**: Teste passou
- ❌ **FAIL**: Teste falhou  
- ⚠️ **WARN**: Aviso (não bloqueia)
- 📊 **INFO**: Informação

## 📝 Nota

Scripts de `start.sh`, `stop.sh` e `status.sh` foram removidos pois suas funcionalidades estão disponíveis no Makefile:
- Use `make start` ao invés de `scripts/start.sh`
- Use `make stop` ao invés de `scripts/stop.sh`  
- Use `make status` ao invés de `scripts/status.sh`