#!/bin/bash
# Script para configurar repositório com informações específicas do usuário
# Usage: ./scripts/setup-repo.sh SEU_USUARIO OWNER_ORIGINAL

set -e

if [ $# -ne 2 ]; then
    echo "❌ Uso incorreto!"
    echo "📋 Uso: $0 SEU_USUARIO OWNER_ORIGINAL"
    echo ""
    echo "Exemplos:"
    echo "  $0 joao euvaldoferreira"
    echo "  $0 maria-dev euvaldoferreira"
    echo ""
    echo "Onde:"
    echo "  SEU_USUARIO    = Seu username no GitHub"
    echo "  OWNER_ORIGINAL = Owner do repositório original"
    exit 1
fi

USER_NAME="$1"
ORIGINAL_OWNER="$2"

echo "🔧 Configurando repositório para $USER_NAME"
echo "============================================"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "📝 Atualizando CODEOWNERS..."
sed -i "s/@euvaldoferreira/@$USER_NAME/g" .github/CODEOWNERS

echo "📖 Atualizando CONFIGURE-GITHUB.md..."
sed -i "s/SEU_USUARIO/$USER_NAME/g" CONFIGURE-GITHUB.md

echo "🤝 Atualizando CONTRIBUTING.md..."
sed -i "s/OWNER_ORIGINAL/$ORIGINAL_OWNER/g" CONTRIBUTING.md

echo "📚 Atualizando docs/git-best-practices.md..."
sed -i "s/OWNER_ORIGINAL/$ORIGINAL_OWNER/g" docs/git-best-practices.md

echo "🛡️ Atualizando docs/branch-protection.md..."
sed -i "s/SEU_USUARIO/$USER_NAME/g" docs/branch-protection.md

echo "⚙️ Configurando Git local..."
git config core.hooksPath .githooks
git config commit.template .gitmessage
git config pull.rebase true

echo "🔗 Configurando remotes..."
if git remote get-url upstream >/dev/null 2>&1; then
    echo "⚠️  Remote upstream já existe, removendo..."
    git remote remove upstream
fi

git remote add upstream "https://github.com/$ORIGINAL_OWNER/bigdata.git"

echo ""
echo -e "${GREEN}✅ Configuração concluída!${NC}"
echo ""
echo -e "${BLUE}📋 Próximos passos:${NC}"
echo "1. Commit das mudanças:"
echo "   git add ."
echo "   git commit -m 'chore: configura repositório para $USER_NAME'"
echo "   git push origin main"
echo ""
echo "2. Configure proteção no GitHub:"
echo "   https://github.com/$USER_NAME/bigdata/settings/branches"
echo ""
echo "3. Ative GitHub Actions:"
echo "   https://github.com/$USER_NAME/bigdata/settings/actions"
echo ""
echo "4. Configure GitHub Pages:"
echo "   https://github.com/$USER_NAME/bigdata/settings/pages"
echo ""
echo -e "${GREEN}🚀 Repositório pronto para colaboração!${NC}"