#!/usr/bin/env bash

set -Eeuo pipefail

# ==========================================
# MERN Project Deployment Script
# Docker Compose + Prometheus Monitoring
# ==========================================

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    exit 1
}

# Step 1: Check dependencies
log "Checking required tools..."

command -v docker >/dev/null 2>&1 ||
    error "Docker is not installed or unavailable."

docker info >/dev/null 2>&1 ||
    error "Docker is not running. Start Docker Desktop and try again."

docker compose version >/dev/null 2>&1 ||
    error "Docker Compose plugin is unavailable."

# Step 2: Check project files
log "Checking project files..."

[[ -f docker-compose.yml ]] ||
    error "docker-compose.yml not found."

[[ -f prometheus-config.yaml ]] ||
    warn "prometheus-config.yaml not found. Check your monitoring configuration."

# Step 3: Validate Docker Compose configuration
log "Validating Docker Compose configuration..."
docker compose config --quiet ||
    error "Docker Compose configuration is invalid."

# Step 4: Build and start Compose services
log "Building images and starting Compose services..."
docker compose up -d --build

# Step 5: Start existing optional containers, if present
for container in backend frontend grafana; do
    if docker container inspect "$container" >/dev/null 2>&1; then
        state="$(docker inspect -f '{{.State.Status}}' "$container")"

        if [[ "$state" != "running" ]]; then
            log "Starting existing container: $container"
            docker start "$container" >/dev/null
        else
            log "$container is already running."
        fi
    fi
done

# Step 6: Display deployment status
echo
log "Container status:"
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

echo
log "Deployment script completed."

echo
echo "Monitoring URLs (if the corresponding services are running):"
echo "  Prometheus : http://localhost:9090"
echo "  Grafana    : http://localhost:3001"
echo "  Backend    : http://localhost:5000"
echo "  Frontend   : http://localhost:5173"

echo
warn "Check that backend and frontend are defined in docker-compose.yml"
warn "for a complete MERN deployment. This script does not deploy Kubernetes or Terraform."
