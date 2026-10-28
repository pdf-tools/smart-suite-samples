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

DB_HEALTH_TIMEOUT_SECONDS="${DB_HEALTH_TIMEOUT_SECONDS:-120}"

wait_for_healthy() {
  local container="$1"
  local start
  start=$(date +%s)
  until docker inspect --format='{{.State.Health.Status}}' "$container" 2>/dev/null | grep -qx healthy; do
    if (( $(date +%s) - start > DB_HEALTH_TIMEOUT_SECONDS )); then
      echo "Error: ${container} did not become healthy within ${DB_HEALTH_TIMEOUT_SECONDS}s." >&2
      docker logs --tail 50 "$container" >&2 || true
      exit 1
    fi
    sleep 1
  done
}

echo "Databases started. Waiting for health checks..."
wait_for_healthy smart-suite-job-manager-db
wait_for_healthy smart-suite-orchestrator-db
echo "Databases are ready."
