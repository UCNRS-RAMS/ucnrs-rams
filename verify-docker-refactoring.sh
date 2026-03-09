#!/bin/bash
# Verification script for Docker configuration refactoring
# This script validates that all changes have been properly applied

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  Docker Configuration Refactoring - Verification Script       ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

FAILED=0
PASSED=0

# Helper functions
check_file_exists() {
    if [ -f "$1" ]; then
        echo "✓ File exists: $1"
        ((PASSED++))
        return 0
    else
        echo "✗ File missing: $1"
        ((FAILED++))
        return 1
    fi
}

check_file_contains() {
    local file=$1
    local search_term=$2
    local description=$3

    if grep -q "$search_term" "$file" 2>/dev/null; then
        echo "✓ $description"
        ((PASSED++))
        return 0
    else
        echo "✗ $description"
        echo "  Expected to find: $search_term in $file"
        ((FAILED++))
        return 1
    fi
}

check_file_not_contains() {
    local file=$1
    local search_term=$2
    local description=$3

    if ! grep -q "$search_term" "$file" 2>/dev/null; then
        echo "✓ $description"
        ((PASSED++))
        return 0
    else
        echo "✗ $description"
        echo "  Found unexpected: $search_term in $file"
        ((FAILED++))
        return 1
    fi
}

echo ""
echo "1. Checking renamed files..."
echo "─────────────────────────────────────────────────────────────────"
check_file_exists "Dockerfile"
check_file_exists "Dockerfile.server"
check_file_not_contains "." "Dockerfile.production" "Dockerfile.production file should not exist"
check_file_exists "docker-compose.yml"
check_file_exists "docker-compose.server.yml"
check_file_not_contains "." "docker-compose.production.yml" "docker-compose.production.yml file should not exist"

echo ""
echo "2. Checking Dockerfile.server configuration..."
echo "─────────────────────────────────────────────────────────────────"
check_file_contains "Dockerfile.server" "FROM ruby:3.2.9-slim" "Uses slim Ruby image"
check_file_contains "Dockerfile.server" "FROM ruby:3.2.9-slim AS builder" "Multi-stage build"
check_file_contains "Dockerfile.server" "bundle config set --local without 'development test'" "Excludes dev/test gems"
check_file_contains "Dockerfile.server" "yarn install --production" "Production JS dependencies only"
check_file_contains "Dockerfile.server" "rails assets:precompile" "Precompiles assets"
check_file_contains "Dockerfile.server" "useradd -r -g rails rails" "Non-root user"
check_file_contains "Dockerfile.server" "HEALTHCHECK" "Health check configured"
check_file_contains "Dockerfile.server" "puma" "Uses Puma"

echo ""
echo "3. Checking docker-compose.server.yml configuration..."
echo "─────────────────────────────────────────────────────────────────"
check_file_contains "docker-compose.server.yml" "dockerfile: Dockerfile.server" "References Dockerfile.server"
check_file_contains "docker-compose.server.yml" "RAILS_ENV: production" "Production environment"
check_file_contains "docker-compose.server.yml" "WEB_CONCURRENCY: 2" "Multi-worker configuration"
check_file_contains "docker-compose.server.yml" "app_network" "Defines app network"
check_file_contains "docker-compose.server.yml" "healthcheck:" "Health check defined"

echo ""
echo "4. Checking documentation updates..."
echo "─────────────────────────────────────────────────────────────────"
check_file_exists "DEPLOYMENT.md"
check_file_contains "DEPLOYMENT.md" "Dockerfile.server" "DEPLOYMENT.md references Dockerfile.server"
check_file_not_contains "DEPLOYMENT.md" "Dockerfile.production" "DEPLOYMENT.md doesn't reference old filename"
check_file_exists "PRODUCTION_DOCKERFILE_SUMMARY.md"
check_file_contains "PRODUCTION_DOCKERFILE_SUMMARY.md" "Server Dockerfile" "Updated file summary title"
check_file_contains "PRODUCTION_DOCKERFILE_SUMMARY.md" "docker-compose.server.yml" "References docker-compose.server.yml"

echo ""
echo "5. Checking script updates..."
echo "─────────────────────────────────────────────────────────────────"
check_file_exists "scripts/docker-deploy.sh"
check_file_contains "scripts/docker-deploy.sh" "DOCKERFILE=\"Dockerfile.server\"" "Deploy script references Dockerfile.server"
check_file_contains "scripts/docker-deploy.sh" "docker-compose.server.yml" "Deploy script references docker-compose.server.yml"
check_file_contains "scripts/docker-deploy.sh" "Server Docker Build" "Deploy script has updated description"

echo ""
echo "6. Checking new documentation files..."
echo "─────────────────────────────────────────────────────────────────"
check_file_exists "DOCKERFILE_NAMING_RATIONALE.md"
check_file_contains "DOCKERFILE_NAMING_RATIONALE.md" "Dockerfile.server" "Naming rationale explained"
check_file_exists "DOCKER_REFACTORING_SUMMARY.md"
check_file_contains "DOCKER_REFACTORING_SUMMARY.md" "breaking change" "Breaking change documented"

echo ""
echo "═════════════════════════════════════════════════════════════════"
echo "                    VERIFICATION RESULTS"
echo "═════════════════════════════════════════════════════════════════"
echo "Passed: $PASSED ✓"
echo "Failed: $FAILED ✗"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "✓ All verification checks passed!"
    echo ""
    echo "Summary of changes:"
    echo "  • Dockerfile.production → Dockerfile.server"
    echo "  • docker-compose.production.yml → docker-compose.server.yml"
    echo "  • All references updated in:"
    echo "    - docker-compose.server.yml"
    echo "    - DEPLOYMENT.md"
    echo "    - PRODUCTION_DOCKERFILE_SUMMARY.md"
    echo "    - scripts/docker-deploy.sh"
    echo "  • New documentation:"
    echo "    - DOCKERFILE_NAMING_RATIONALE.md"
    echo "    - DOCKER_REFACTORING_SUMMARY.md"
    echo ""
    exit 0
else
    echo "✗ Verification failed! Please review the errors above."
    exit 1
fi

