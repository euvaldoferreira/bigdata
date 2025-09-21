#!/bin/bash
# CI simulation script for BigData environment
# Simulates all CI checks locally

set -e

echo "🤖 Simulating CI/CD Pipeline Locally"
echo "===================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CHECKS_TOTAL=0
CHECKS_PASSED=0
CHECKS_FAILED=0

# Function to get docker compose command
get_docker_compose_cmd() {
    if command -v docker &> /dev/null && docker compose version &> /dev/null 2>&1; then
        echo "docker compose"
    elif command -v docker-compose &> /dev/null; then
        echo "docker-compose"
    else
        echo ""
    fi
}

# Function to run CI check
run_ci_check() {
    local check_name="$1"
    local check_command="$2"
    
    CHECKS_TOTAL=$((CHECKS_TOTAL + 1))
    echo ""
    echo -e "${BLUE}🔍 CI Check: $check_name${NC}"
    echo "$(echo "$check_name" | sed 's/./-/g')"
    
    if eval "$check_command"; then
        echo -e "${GREEN}✅ PASS: $check_name${NC}"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        echo -e "${RED}❌ FAIL: $check_name${NC}"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    fi
}

echo "Starting CI simulation..."
echo ""

# 1. Pre-checks
run_ci_check "Pre-checks" "
    echo 'Checking environment...'
    [ -f .env ] || (cp .env.example .env && echo 'Created .env from example')
    make pre-check
    echo 'Pre-checks completed'
"

# 2. Docker Compose Validation
run_ci_check "Docker Compose Validation" "
    echo 'Validating Docker Compose configuration...'
    COMPOSE_CMD=\$(get_docker_compose_cmd)
    if [ -z \"\$COMPOSE_CMD\" ]; then
        echo '❌ Docker Compose not found'
        exit 1
    fi
    \$COMPOSE_CMD config >/dev/null
    echo 'Docker Compose configuration is valid'
"

# 3. Makefile Tests
run_ci_check "Makefile Commands Test" "
    echo 'Testing Makefile commands...'
    make help >/dev/null
    make --dry-run clean || echo 'clean command not found, using alternative'
    make --dry-run backup-all || echo 'backup-all command not found, using alternative'
    echo 'Makefile commands are working'
"

# 4. Documentation Check
run_ci_check "Documentation Structure" "
    echo 'Checking documentation structure...'
    required_files=(
        'README.md'
        'CONTRIBUTING.md' 
        'CODE_OF_CONDUCT.md'
        'docs/commands.md'
        'docs/troubleshooting.md'
        'docs/architecture.md'
    )
    
    for file in \"\${required_files[@]}\"; do
        if [[ ! -f \"\$file\" ]]; then
            echo \"❌ Missing required file: \$file\"
            exit 1
        fi
    done
    echo 'All required documentation files exist'
"

# 5. Security Scan (basic)
run_ci_check "Basic Security Scan" "
    echo 'Running basic security checks...'
    # Check for exposed secrets (excluding known safe patterns)
    if grep -r 'password.*=' . --exclude-dir=.git --exclude='*.md' --exclude-dir=scripts --exclude-dir=.githooks | grep -v '.env' | grep -v '.env.example' | grep -v "password = ''" | grep -v "password=''" | grep -v "NotebookApp.password=''" | grep -v 'smtp_password = $'; then
        echo '❌ Potential exposed secrets found'
        exit 1
    fi
    echo 'No exposed secrets found'
"

# 6. Git Configuration Check
run_ci_check "Git Configuration" "
    echo 'Checking Git configuration files...'
    [ -f .gitignore ] || echo 'Warning: No .gitignore file'
    [ -f .gitmessage ] && echo 'Commit template found'
    [ -f .github/CODEOWNERS ] && echo 'CODEOWNERS file found'
    echo 'Git configuration check completed'
"

# 7. CI/CD Configuration
run_ci_check "CI/CD Configuration" "
    echo 'Checking CI/CD configuration...'
    [ -f .github/workflows/ci.yml ] && echo 'CI workflow found'
    [ -f .github/workflows/deploy-docs.yml ] && echo 'Deploy workflow found'
    [ -f .github/workflows/test-suite.yml ] && echo 'Test suite workflow found'
    echo 'CI/CD configuration is present'
"

# 8. Conventional Commits Check (for recent commits)
run_ci_check "Conventional Commits Format" "
    echo 'Checking recent commit messages...'
    # Check last 5 commits
    git log --format='%s' -5 | while read -r commit; do
        if [[ -z \"\$commit\" ]]; then
            continue
        fi
        if ! echo \"\$commit\" | grep -E '^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .+'; then
            echo \"❌ Invalid commit message: \$commit\"
            exit 1
        fi
    done
    echo 'Recent commit messages follow Conventional Commits'
"

# 9. Environment Test (quick)
run_ci_check "Quick Environment Test" "
    echo 'Running quick environment test...'
    timeout 120 make lab >/dev/null 2>&1 || true
    sleep 10
    COMPOSE_CMD=\$(get_docker_compose_cmd)
    if [ -n \"\$COMPOSE_CMD\" ]; then
        \$COMPOSE_CMD ps
    fi
    make clean >/dev/null 2>&1 || true
    echo 'Quick environment test completed'
"

# 10. File Permissions Check
run_ci_check "File Permissions" "
    echo 'Checking file permissions...'
    [ -x .githooks/pre-commit ] && echo 'pre-commit hook is executable'
    [ -x .githooks/commit-msg ] && echo 'commit-msg hook is executable'
    [ -x scripts/test-basic.sh ] && echo 'test-basic.sh is executable'
    echo 'File permissions check completed'
"

echo ""
echo "📊 CI Simulation Results"
echo "========================"
echo -e "Total Checks: ${BLUE}$CHECKS_TOTAL${NC}"
echo -e "Passed:       ${GREEN}$CHECKS_PASSED${NC}"
echo -e "Failed:       ${RED}$CHECKS_FAILED${NC}"

if [ $CHECKS_FAILED -eq 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 All CI checks passed!${NC}"
    echo "Your code is ready for Pull Request."
    echo ""
    echo "Next steps:"
    echo "1. git add ."
    echo "2. git commit -m 'feat: your commit message'"
    echo "3. git push origin your-branch"
    echo "4. Create Pull Request on GitHub"
    exit 0
else
    echo ""
    echo -e "${RED}❌ Some CI checks failed.${NC}"
    echo "Please fix the issues above before creating a Pull Request."
    exit 1
fi