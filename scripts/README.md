# 🧪 Scripts de Teste

Esta pasta contém scripts para executar testes locais do ambiente BigData.

## 📋 Scripts Disponíveis

### `test-basic.sh` - Testes Básicos
Executa testes básicos do ambiente:
- Verifica comandos essenciais
- Testa ambiente lab
- Verifica conectividade dos serviços

### `test-full.sh` - Testes Completos  
Executa suite completa de testes:
- Inicia ambiente completo
- Testa todos os serviços
- Verifica funcionalidades avançadas

### `test-ci.sh` - Simula CI Local
Simula os testes que rodam no CI:
- Todos os checks de validação
- Testes de segurança
- Verificação de documentação

## 🚀 Como Usar

```bash
# Testes básicos
./scripts/test-basic.sh

# Testes completos  
./scripts/test-full.sh

# Simular CI localmente
./scripts/test-ci.sh
```

## 📊 Interpretando Resultados

- ✅ **PASS**: Teste passou
- ❌ **FAIL**: Teste falhou  
- ⚠️ **WARN**: Aviso (não bloqueia)
- 📊 **INFO**: Informação