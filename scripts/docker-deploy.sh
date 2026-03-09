#!/bin/bash
# Production Docker Build and Deploy Script
# This script helps build and deploy the production Docker image

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="ucnrs-rams"
DOCKERFILE="Dockerfile.production"

# Helper functions
print_info() {
    echo -e "${BLUE}ℹ ${1}${NC}"
}

print_success() {
    echo -e "${GREEN}✓ ${1}${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ ${1}${NC}"
}

print_error() {
    echo -e "${RED}✗ ${1}${NC}"
}

# Function to check if required tools are installed
check_requirements() {
    print_info "Checking requirements..."

    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi

    if ! command -v git &> /dev/null; then
        print_warning "Git is not installed. Version tagging will not be available."
    fi

    print_success "Requirements check passed"
}

# Function to get git commit hash for tagging
get_git_version() {
    if command -v git &> /dev/null && [ -d .git ]; then
        echo $(git rev-parse --short HEAD)
    else
        echo "latest"
    fi
}

# Function to build the Docker image
build_image() {
    local VERSION_TAG=${1:-$(get_git_version)}

    print_info "Building production Docker image..."
    print_info "Version tag: ${VERSION_TAG}"

    docker build \
        -f ${DOCKERFILE} \
        -t ${APP_NAME}:${VERSION_TAG} \
        -t ${APP_NAME}:latest \
        .

    print_success "Image built successfully"
    print_info "Tagged as: ${APP_NAME}:${VERSION_TAG} and ${APP_NAME}:latest"
}

# Function to test the image locally
test_image() {
    local VERSION_TAG=${1:-latest}

    print_info "Testing image ${APP_NAME}:${VERSION_TAG}..."

    # Run a simple test to ensure the image starts
    print_info "Starting container for health check..."
    CONTAINER_ID=$(docker run -d \
        -e SECRET_KEY_BASE=test_key_for_health_check \
        -e DATABASE_HOST=localhost \
        -e DATABASE_NAME=test \
        -e DATABASE_USERNAME=test \
        -e DATABASE_PASSWORD=test \
        ${APP_NAME}:${VERSION_TAG})

    print_info "Waiting for application to start..."
    sleep 10

    # Check if container is still running
    if docker ps -q --filter "id=${CONTAINER_ID}" | grep -q .; then
        print_success "Container is running"
        docker logs ${CONTAINER_ID} | tail -20
        docker stop ${CONTAINER_ID} > /dev/null
        docker rm ${CONTAINER_ID} > /dev/null
        print_success "Test passed"
    else
        print_error "Container failed to start"
        docker logs ${CONTAINER_ID}
        docker rm ${CONTAINER_ID} > /dev/null
        exit 1
    fi
}

# Function to push to AWS ECR
push_to_ecr() {
    local VERSION_TAG=${1:-$(get_git_version)}
    local AWS_REGION=${2:-us-west-2}
    local AWS_ACCOUNT_ID=${3}

    if [ -z "${AWS_ACCOUNT_ID}" ]; then
        print_error "AWS Account ID is required for ECR push"
        echo "Usage: $0 push-ecr <version_tag> <aws_region> <aws_account_id>"
        exit 1
    fi

    local ECR_REPO="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${APP_NAME}"

    print_info "Pushing to ECR: ${ECR_REPO}"

    # Login to ECR
    print_info "Authenticating with ECR..."
    aws ecr get-login-password --region ${AWS_REGION} | \
        docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

    # Tag for ECR
    docker tag ${APP_NAME}:${VERSION_TAG} ${ECR_REPO}:${VERSION_TAG}
    docker tag ${APP_NAME}:${VERSION_TAG} ${ECR_REPO}:latest

    # Push to ECR
    print_info "Pushing ${ECR_REPO}:${VERSION_TAG}..."
    docker push ${ECR_REPO}:${VERSION_TAG}

    print_info "Pushing ${ECR_REPO}:latest..."
    docker push ${ECR_REPO}:latest

    print_success "Successfully pushed to ECR"
    print_info "Image URI: ${ECR_REPO}:${VERSION_TAG}"
}

# Function to show image info
show_info() {
    print_info "Docker images for ${APP_NAME}:"
    docker images | grep ${APP_NAME} || print_warning "No images found"

    echo ""
    print_info "Image size comparison:"
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep -E "REPOSITORY|${APP_NAME}" || true
}

# Function to run migrations
run_migrations() {
    print_info "Running database migrations..."

    if [ -f "docker-compose.production.yml" ]; then
        docker-compose -f docker-compose.production.yml exec app bundle exec rails db:migrate
        print_success "Migrations completed"
    else
        print_warning "docker-compose.production.yml not found"
        print_info "Run migrations manually with:"
        print_info "  docker run --rm -e RAILS_ENV=production [env vars] ${APP_NAME}:latest bundle exec rails db:migrate"
    fi
}

# Function to display usage
usage() {
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  build [version]              Build production Docker image"
    echo "  test [version]               Test the Docker image"
    echo "  build-test [version]         Build and test the image"
    echo "  push-ecr <version> <region> <account_id>  Push image to AWS ECR"
    echo "  deploy-ecr [version] [region] [account_id]  Build, test, and push to ECR"
    echo "  info                         Show information about built images"
    echo "  migrate                      Run database migrations"
    echo "  help                         Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 build v1.0.0              Build with version tag v1.0.0"
    echo "  $0 build-test                Build and test with git commit hash"
    echo "  $0 push-ecr v1.0.0 us-west-2 123456789012"
    echo "  $0 deploy-ecr v1.0.0 us-west-2 123456789012"
    echo ""
}

# Main script logic
main() {
    local COMMAND=${1:-help}

    case ${COMMAND} in
        build)
            check_requirements
            build_image ${2}
            ;;
        test)
            check_requirements
            test_image ${2}
            ;;
        build-test)
            check_requirements
            VERSION=${2:-$(get_git_version)}
            build_image ${VERSION}
            test_image ${VERSION}
            ;;
        push-ecr)
            check_requirements
            push_to_ecr ${2} ${3} ${4}
            ;;
        deploy-ecr)
            check_requirements
            VERSION=${2:-$(get_git_version)}
            AWS_REGION=${3:-us-west-2}
            AWS_ACCOUNT_ID=${4}

            if [ -z "${AWS_ACCOUNT_ID}" ]; then
                print_error "AWS Account ID is required"
                usage
                exit 1
            fi

            build_image ${VERSION}
            test_image ${VERSION}
            push_to_ecr ${VERSION} ${AWS_REGION} ${AWS_ACCOUNT_ID}
            ;;
        info)
            show_info
            ;;
        migrate)
            run_migrations
            ;;
        help|--help|-h)
            usage
            ;;
        *)
            print_error "Unknown command: ${COMMAND}"
            usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"

