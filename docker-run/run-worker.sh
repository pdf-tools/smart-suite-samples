#!/usr/bin/env bash
# =============================================================================
# Start Smart Redact Worker (CPU)
# =============================================================================
set -euo pipefail

: "${PDFTOOLS_LICENSE_KEY:?Error: PDFTOOLS_LICENSE_KEY is not set}"
: "${ENCRYPTION_KEY:?Error: ENCRYPTION_KEY is not set}"

WORKER_VERSION="${WORKER_VERSION:-1.2.0}"
NETWORK="smart-suite-network"

docker network inspect "$NETWORK" >/dev/null 2>&1 || \
  docker network create "$NETWORK"

# No --health-cmd: the image ships a shell-free HEALTHCHECK, and --health-cmd would force /bin/sh, which the image lacks.
echo "Starting Smart Redact Worker (CPU)..."
docker run -d \
  --name smart-redact-worker \
  --network "$NETWORK" \
  --restart unless-stopped \
  -e "ServiceCommunication__ServiceCommunicationType=RabbitMQ" \
  -e "ServiceCommunication__Host=smart-suite-rabbitmq" \
  -e "ServiceCommunication__Username=guest" \
  -e "ServiceCommunication__Password=guest" \
  -e "Licensing__LicenseKey=${PDFTOOLS_LICENSE_KEY}" \
  -e "Encryption__EncryptionKey=${ENCRYPTION_KEY}" \
  -e "Encryption__DekTokenTtlMinutes=1440" \
  -e "FileStorage__FileStorageType=HostFileSystem" \
  -e "FileStorage__FilesDirectoryPath=/app/storage_folder" \
  -v smart-suite-storage:/app/storage_folder \
  -v smart-suite-logs:/app/logs \
  "pdftoolsag/smart-redact-worker:${WORKER_VERSION}"

echo "Worker started."
echo "Inspect container health with: docker inspect --format='{{.State.Health.Status}}' smart-redact-worker"
