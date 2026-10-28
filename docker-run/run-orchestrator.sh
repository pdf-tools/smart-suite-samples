#!/usr/bin/env bash
# =============================================================================
# Start Smart Suite Orchestrator
# =============================================================================
set -euo pipefail

: "${PDFTOOLS_LICENSE_KEY:?Error: PDFTOOLS_LICENSE_KEY is not set}"
: "${ORCHESTRATOR_JWT_SECRET:?Error: ORCHESTRATOR_JWT_SECRET is not set}"

VERSION="${VERSION:-1.0.0}"
NETWORK="smart-suite-network"

docker network inspect "$NETWORK" >/dev/null 2>&1 || \
  docker network create "$NETWORK"

# No --health-cmd: the image ships a shell-free HEALTHCHECK, and --health-cmd would force /bin/sh, which the image lacks.
echo "Starting Smart Suite Orchestrator..."
docker run -d \
  --name smart-suite-orchestrator \
  --network "$NETWORK" \
  --restart unless-stopped \
  -p 9983:9983 \
  -e "ManagerApi__BaseUrl=http://smart-suite-job-manager:9982/" \
  -e "ManagerApi__PollingIntervalSeconds=3" \
  -e "Database__DatabaseType=PostgreSql" \
  -e "Database__ConnectionString=User ID=smartsuite;Password=smartsuite;Server=smart-suite-orchestrator-db;Port=5432;Database=smartsuite;Maximum Pool Size=50;Timeout=30;" \
  -e "Jwt__SecretKey=${ORCHESTRATOR_JWT_SECRET}" \
  -e "Licensing__LicenseKey=${PDFTOOLS_LICENSE_KEY}" \
  -v smart-suite-logs:/app/logs \
  "pdftoolsag/smart-suite-orchestrator:${VERSION}"

echo "Orchestrator started at http://localhost:9983"
echo "Swagger UI: http://localhost:9983/swagger"
echo ""
echo "Default login: admin@example.com / Admin@1234!Tmp (password change suggested on first login)"
