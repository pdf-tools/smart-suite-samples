#!/usr/bin/env bash
# =============================================================================
# Start RabbitMQ broker for Smart Suite Manager <-> Worker communication
# =============================================================================
set -euo pipefail

NETWORK="smart-suite-network"

docker network inspect "$NETWORK" >/dev/null 2>&1 || \
  docker network create "$NETWORK"

echo "Starting RabbitMQ..."
docker run -d \
  --name smart-suite-rabbitmq \
  --network "$NETWORK" \
  --restart unless-stopped \
  -e RABBITMQ_DEFAULT_USER=guest \
  -e RABBITMQ_DEFAULT_PASS=guest \
  --health-cmd "rabbitmq-diagnostics -q check_port_connectivity" \
  --health-interval 10s \
  --health-timeout 10s \
  --health-start-period 30s \
  --health-retries 5 \
  rabbitmq:4-management-alpine

echo "RabbitMQ started. Waiting for health check..."
RABBITMQ_HEALTH_TIMEOUT_SECONDS="${RABBITMQ_HEALTH_TIMEOUT_SECONDS:-180}"
rabbitmq_wait_start=$(date +%s)
until docker inspect --format='{{.State.Health.Status}}' smart-suite-rabbitmq 2>/dev/null | grep -qx healthy; do
  if (( $(date +%s) - rabbitmq_wait_start > RABBITMQ_HEALTH_TIMEOUT_SECONDS )); then
    echo "Error: RabbitMQ did not become healthy within ${RABBITMQ_HEALTH_TIMEOUT_SECONDS}s." >&2
    docker logs --tail 50 smart-suite-rabbitmq >&2 || true
    exit 1
  fi
  sleep 1
done
echo "RabbitMQ is ready."
