#!/usr/bin/env bash
# =============================================================================
# Initialize Smart Suite shared volumes
# =============================================================================
# Creates the smart-suite-storage and smart-suite-logs named volumes (if
# missing) and sets ownership to the non-root app user (UID/GID 1654) used
# by the Manager and Worker images. Run this BEFORE starting the Manager and
# Worker so that their first write does not fail with "Permission denied".
# =============================================================================
set -euo pipefail

echo "Initializing Smart Suite shared volumes..."
docker run --rm \
  --user 0:0 \
  -v smart-suite-storage:/app/storage_folder \
  -v smart-suite-logs:/app/logs \
  alpine:3 \
  sh -c "chown -R 1654:1654 /app/storage_folder /app/logs && chmod -R u+rwX,g+rwX /app/storage_folder /app/logs"

echo "Volumes initialized: smart-suite-storage, smart-suite-logs"
