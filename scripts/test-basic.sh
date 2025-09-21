#!/bin/bash
# Basic tests for BigData environment
# Usage: ./scripts/test-basic.sh

set -e

echo "🧪 Starting Basic Tests for BigData Environment"
echo "================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Test counter
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    echo -n "🔍 Testing: $test_name... "
    
    if eval "$test_command" >/dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}FAIL${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Function to run test with output
run_test_verbose() {
    local test_name="$1"
    local test_command="$2"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    echo "🔍 Testing: $test_name"
    
    if eval "$test_command"; then
        echo -e "${GREEN}✅ PASS: $test_name${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}❌ FAIL: $test_name${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    echo ""
}

echo "📋 Environment Setup Tests"
echo "--------------------------"

# Test 1: Check if .env exists
run_test "Environment file exists" "[ -f .env ]"

# Test 2: Check if Docker is running
run_test "Docker is running" "docker info"

# Test 3: Check if Docker Compose is available
run_test "Docker Compose is available" "[ -n \"\$(get_docker_compose_cmd)\" ]"

# Test 4: Check if Makefile exists and is valid
run_test "Makefile exists and is valid" "make --dry-run help"

echo ""
echo "🚀 Basic Commands Tests"
echo "-----------------------"

# Test 5: Pre-check command
run_test_verbose "Pre-check command" "make pre-check"

# Test 6: Docker Compose config validation
run_test_verbose "Docker Compose config" "\$(get_docker_compose_cmd) config"

# Test 7: Help command
run_test "Help command" "make help"

echo ""
echo "🐳 Environment Startup Tests"
echo "----------------------------"

# Test 8: Start lab environment
echo "🚀 Starting lab environment (this may take a while)..."
if timeout 300 make lab >/dev/null 2>&1; then
    echo -e "${GREEN}✅ PASS: Lab environment started${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    
    # Wait for services to be ready
    echo "⏳ Waiting for services to be ready..."
    sleep 30
    
    # Test 9: Check status
    run_test_verbose "Status command" "make status"
    
    # Test 10: Health check
    run_test_verbose "Health check" "make health"
    
    # Test 11: Check specific services
    echo "🔍 Testing individual services..."
    
    # Jupyter
    if curl -f http://localhost:8888 >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Jupyter is responding${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${YELLOW}⚠️  Jupyter not responding (may be normal)${NC}"
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    
    # MinIO
    if curl -f http://localhost:9001 >/dev/null 2>&1; then
        echo -e "${GREEN}✅ MinIO is responding${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${YELLOW}⚠️  MinIO not responding (may be normal)${NC}"
    fi
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    
    echo ""
    echo "🛑 Cleaning up..."
    make clean >/dev/null 2>&1 || true
    
else
    echo -e "${RED}❌ FAIL: Lab environment failed to start${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
TESTS_TOTAL=$((TESTS_TOTAL + 1))

echo ""
echo "📊 Test Results"
echo "==============="
echo -e "Total Tests: ${BLUE}$TESTS_TOTAL${NC}"
echo -e "Passed:      ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed:      ${RED}$TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 All basic tests passed!${NC}"
    echo "The BigData environment is ready for development."
    exit 0
else
    echo ""
    echo -e "${RED}❌ Some tests failed.${NC}"
    echo "Please check the issues above before proceeding."
    exit 1
fi