# Docker Run Scripts

Individual `docker run` scripts for each Smart Suite service. Use these when you need full control over each container, or when Docker Compose is not available.

> For most use cases, [Docker Compose](../docker-compose/) is the easier option.
> Docker Compose uses native `healthcheck` and `docker compose up --wait`; the custom wait/health scripts live here because plain `docker run` does not provide the same orchestration.

You can also use the root helper with the docker-run backend:

```bash
../smart-suite.sh setup --backend docker-run --license-key "<SMARTST,V1,XXXXXXXXXXXXXXXXXXXX>"
../smart-suite.sh up --backend docker-run
../smart-suite.sh health --backend docker-run
../smart-suite.sh logs --backend docker-run
```

## Prerequisites

1. Create a Docker network:
   ```bash
   docker network create smart-suite-network
   ```

2. Set required environment variables:
   ```bash
   export PDFTOOLS_LICENSE_KEY="<SMARTST,V1,XXXXXXXXXXXXXXXXXXXX>"
   export ENCRYPTION_KEY=$(../scripts/generate-encryption-key.sh)
   export ORCHESTRATOR_JWT_SECRET=$(openssl rand -base64 64 | tr -d '\n')
   ```

## Usage

### Start all services at once

```bash
./run-all.sh
```

### Start services individually (in order)

```bash
# 1. Initialize shared volumes (chowns to app user UID/GID 1654)
./run-storage-init.sh

# 2. Databases
./run-postgres.sh

# 3. Worker (wait until healthy before starting Manager)
./run-worker.sh          # CPU
# ./run-worker-gpu.sh    # or GPU variant

# Inspect worker health - wait until it reports "healthy"
docker inspect --format='{{.State.Health.Status}}' smart-redact-worker

# 4. Manager (depends on Manager DB and Worker)
./run-manager.sh

# 5. Orchestrator (depends on Orchestrator DB and Manager)
./run-orchestrator.sh

# 6. HITL Web UI (depends on Orchestrator)
./run-hitl-web.sh
```

## Stopping Services

```bash
docker stop smart-suite-job-manager smart-redact-worker smart-suite-orchestrator smart-suite-hitl \
           smart-suite-job-manager-db smart-suite-orchestrator-db

docker rm smart-suite-job-manager smart-redact-worker smart-suite-orchestrator smart-suite-hitl \
         smart-suite-job-manager-db smart-suite-orchestrator-db
```

Or use the cleanup script (covers docker-run naming only):
```bash
./cleanup.sh                  # remove containers + network (keep volumes and images)
./cleanup.sh --volumes        # also remove volumes (DELETES ALL DATA)
./cleanup.sh --images         # also remove Smart Suite images
./cleanup.sh --all            # remove volumes AND Smart Suite images (shorthand)
```

> For Docker Compose deployments, use `docker compose down` (optionally `-v`) instead.

## Wait and Health Helpers

The docker-run backend includes custom helpers for readiness checks:

```bash
./wait-for-services.sh
./health-check.sh
```

These scripts check host-reachable HTTP endpoints and internal Worker container health. They are intentionally scoped to `docker-run`; Compose deployments should use `docker compose up --wait` and `../smart-suite.sh health`.
