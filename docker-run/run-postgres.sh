#!/usr/bin/env bash
# =============================================================================
# Start PostgreSQL databases for Smart Suite
# =============================================================================
set -euo pipefail

NETWORK="smart-suite-network"

# Create network if it doesn't exist
docker network inspect "$NETWORK" >/dev/null 2>&1 || \
  docker network create "$NETWORK"

echo "Starting Manager database..."
docker run -d \
  --name smart-suite-job-manager-db \
  --network "$NETWORK" \
  --restart unless-stopped \
  -e POSTGRES_USER=smartsuite \
  -e POSTGRES_PASSWORD=smartsuite \
  -e POSTGRES_DB=smartsuite \
  -e TZ=UTC \
  -v smart-suite-pgdata-manager:/var/lib/postgresql/data \
  --health-cmd "pg_isready -U smartsuite" \
  --health-interval 5s \
  --health-timeout 5s \
  --health-retries 5 \
  postgres:15-alpine

echo "Starting Orchestrator database..."
docker run -d \
  --name smart-suite-orchestrator-db \
  --network "$NETWORK" \
  --restart unless-stopped \
  -e POSTGRES_USER=smartsuite \
  -e POSTGRES_PASSWORD=smartsuite \
  -e POSTGRES_DB=smartsuite \
  -e TZ=UTC \
  -v smart-suite-pgdata-orchestrator:/var/lib/postgresql/data \
  --health-cmd "pg_isready -U smartsuite" \
  --health-interval 5s \
  --health-timeout 5s \
  --health-retries 5 \
  postgres:15-alpine

echo "Databases started. Waiting for health checks..."
until docker inspect --format='{{.State.Health.Status}}' smart-suite-job-manager-db 2>/dev/null | grep -q healthy; do sleep 1; done
until docker inspect --format='{{.State.Health.Status}}' smart-suite-orchestrator-db 2>/dev/null | grep -q healthy; do sleep 1; done
echo "Databases are ready."
