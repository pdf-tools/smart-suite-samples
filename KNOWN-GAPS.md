# Known gaps

> **Internal.** This file references the private `smart-redact` repository and Jira tickets.
> Remove it (or move the open items to Jira) before this repository is made public.

This repository was created from `smart-redact-samples@83ce34b` and renamed to Smart Suite. A few things can't match Smart Suite yet because something outside this
repository doesn't exist. Each gap below says what is missing, what this repository does until it lands, and
what to change when it does. Delete a gap's section once it is closed.

This file lists only what keeps the existing samples from running on Smart Suite. New features (such as Smart
Extract samples) and upstream-only fixes belong in Jira, not here.

| #   | Gap                                                                    | Blocks                                              | Fixed in                         |
| --- | ---------------------------------------------------------------------- | --------------------------------------------------- | -------------------------------- |
| G1  | `pdftoolsag/smart-suite-{job-manager,orchestrator,hitl}` not published | Pulling the images, so running the samples at all   | `smart-redact` release + Docker Hub |
| G2  | No `suite/v1.0.0` release, so no Smart Suite `1.0.0` / `latest` tag     | "Runs on Smart Suite 1.0" acceptance check          | `smart-redact` release           |
| G3  | No Smart Suite pages on the documentation portal                        | Correct documentation links                         | `documentation-portal`           |
| G4  | No Smart Suite licensing page, key format or confirmed trial-key flow   | License links, placeholders and prerequisite text   | Licensing / portal               |
| G5  | Worker gets its own version stream (PDFTAI-666)                         | One `VERSION` for every image                       | `smart-redact`                   |

## G1: Smart Suite images on Docker Hub

**Missing:** Docker Hub has only `pdftoolsag/smart-redact-{manager,worker,orchestrator,hitl-web}`. The
`smart-suite-*` repositories return 404. The `smart-redact` release workflow still publishes the old names.

**Until then:** this repository already references the agreed names:

| Old Docker Hub image                   | Smart Suite image                     |
| -------------------------------------- | ------------------------------------- |
| `pdftoolsag/smart-redact-manager`      | `pdftoolsag/smart-suite-job-manager`  |
| `pdftoolsag/smart-redact-orchestrator` | `pdftoolsag/smart-suite-orchestrator` |
| `pdftoolsag/smart-redact-hitl-web`     | `pdftoolsag/smart-suite-hitl`         |
| `pdftoolsag/smart-redact-worker`       | unchanged (`-cuda` for GPU)           |

Container and Compose service names match the image names (`smart-suite-job-manager`, `smart-suite-hitl`).
`docker compose up` fails to pull the three `smart-suite-*` images. To test locally, re-tag the old images:

```bash
for pair in manager:job-manager orchestrator:orchestrator hitl-web:hitl; do
  docker pull "pdftoolsag/smart-redact-${pair%%:*}:latest"
  docker tag  "pdftoolsag/smart-redact-${pair%%:*}:latest" "pdftoolsag/smart-suite-${pair##*:}:latest"
done
```

**Upstream change (`smart-redact`):**
- `.github/workflows/release.yml`, `RETAG_IMAGES`: change `"dockerhub":"smart-redact-manager"` and
  `"dockerhub":"smart-redact-orchestrator"` to `smart-suite-job-manager` and `smart-suite-orchestrator`. Leave
  both `smart-redact-worker` entries unchanged.
- `.github/workflows/release.yml`, `REBUILD_IMAGES`: change `dockerhub` and `image_title` from
  `smart-redact-hitl-web` to `smart-suite-hitl`.
- Create the three repositories under the `pdftoolsag` Docker Hub organization.
- Mark `pdftoolsag/smart-redact-{manager,orchestrator,hitl-web}` as deprecated/archived on Docker Hub. The images
  stay available.
- `docs/getting-started/RELEASE.md`, "What Happens After Publishing": update the image list.

**Change here when it lands:** nothing, if the published names are exactly the ones above. If they differ, update
every reference (`grep -rn "pdftoolsag/smart-suite" .`):
- `docker-compose/{cpu,gpu,minimal}/docker-compose.yml`: `image:` lines
- `docker-run/run-manager.sh`, `run-orchestrator.sh`, `run-hitl-web.sh`: the `docker run` image argument
- `docker-run/cleanup.sh`: `IMAGE_REPOS`
- `smart-suite.sh`: `remove_smart_suite_images` and `cmd_docker_run_pull`

Container names follow the image names, so also update `container_name`/`--name`, `ManagerApi__BaseUrl`, the
Manager database `Server=`, `cleanup.sh` `CONTAINERS`, `container_for_service` and `cmd_docker_run_logs` in
`smart-suite.sh`, and the container lists in `docker-run/README.md`.

Then run the samples end to end (see G2).

## G2: Smart Suite 1.0 release tag

**Missing:** no `suite/v1.0.0` tag exists in `smart-redact`, so there is no Smart Suite `1.0.0` image and
`latest` doesn't point at a Smart Suite build. The old `pdftoolsag/smart-redact-*:1.0.0` tags belong to the
earlier Smart Redact 1.0.0 release and are not Smart Suite 1.0.

**Until then:** `VERSION` defaults to `latest`, as before. The README configuration table says Smart Suite
images are available from `1.0.0`.

**Change here when it lands:**
- No code change. Run the full check with `VERSION=1.0.0` against the real images:
  - `./smart-suite.sh setup --license-key "<key>"`, `./smart-suite.sh up`, `./smart-suite.sh health`
    (repeat with `--variant minimal` and `--backend docker-run`)
  - `api-examples/curl/full-workflow.sh`, `api-examples/python/full_workflow.py` and the C# sample on
    `samples/Sample Document - Smart Suite.pdf`: the redaction count must match `smart-redact-samples`
  - Sign in to the HITL Web UI at `http://localhost:3000` with the default admin account
- If the Suite release is not marked "latest" on GitHub, `latest` won't move. In that case change the `VERSION`
  comments in `.env.example` and `docker-compose/*/.env.example`, and the README configuration table, to
  recommend `VERSION=1.0.0`.

## G3: Smart Suite documentation pages

**Missing:** the documentation portal has only `/docs/smart-redact/...` pages.

**Until then:** the existing Smart Redact URLs stay, with link text "Smart Redact …" so the name matches the page.

**Change here when it lands:** replace each URL below (`grep -rn "pdf-tools.com/docs/smart-redact" .`).

| Current URL                                   | Used in                                                                                  |
| --------------------------------------------- | ---------------------------------------------------------------------------------------- |
| `/docs/smart-redact`                          | `README.md` (intro, Documentation), `api-examples/python/*.py` and `api-examples/csharp/Program.cs` header comments |
| `/docs/smart-redact/references/architecture/` | `README.md` (Architecture, Documentation)                                                |
| `/docs/smart-redact/references/api/`          | `README.md`, `api-examples/README.md`, `api-examples/csharp/README.md`                   |
| `/docs/smart-redact/guides/configuration/`    | `README.md`, `docker-compose/README.md`                                                  |
| `/docs/smart-redact/guides/authentication/`   | `api-examples/README.md`                                                                 |

Update the link text to "Smart Suite …" where the new page covers the whole suite.

## G4: Smart Suite licensing page and key format

**Missing:** there is no Smart Suite licensing page, no documented Smart Suite key format and no confirmed answer
on whether the portal trial key is a Smart Suite key.

**Until then:**
- The placeholder is `<your-license-key>` (the old repository used `<RDCTSRV,...>`).
- Text says "Smart Suite license key (legacy Smart Redact keys also work)". Legacy `RedactionSrv` keys are still
  accepted by the Manager, Orchestrator and Smart Redact Worker (`docs/reference/LICENSING.md` in `smart-redact`).
- The `/docs/licenses/products/smart-redact-license/` link and the portal.pdf-tools.com trial text stay.

**Change here when it lands:**
- License link (`grep -rn "smart-redact-license" .`): `README.md` (Prerequisites, Quick start, Documentation),
  `.env.example`, `docker-compose/README.md` (Required Environment Variables).
- Trial-key text: `README.md` Prerequisites and Quick start, `.env.example`.
- If a key format is documented, use it in the placeholders (`grep -rn "<your-license-key>" .`): `smart-suite.sh`
  usage, `README.md` Quick start, `docker-compose/README.md`, `docker-run/README.md`.
- Once legacy keys are no longer supported, drop "(legacy Smart Redact keys also work)"
  (`grep -rn "legacy Smart Redact" .`).

## G5: Separate Worker version (PDFTAI-666)

**Missing:** PDFTAI-666 gives the Smart Redact Worker its own release stream (`redact-worker/v`). The Smart Suite
images (`job-manager`, `orchestrator`, `hitl`) start at `1.0.0`, but the Worker continues at `1.2.0`, so the Worker
tag doesn't match the other tags.

**Until then:** one `VERSION` drives every image, so only `latest` works. Don't set `VERSION=1.0.0`: it would pull
`smart-redact-worker:1.0.0`, an old Smart Redact build.

**Change here when it lands:** add `WORKER_VERSION`, defaulting to `latest`. Don't fall back to `VERSION`,
because the Suite and Worker versions differ:
- `docker-compose/{cpu,gpu,minimal}/docker-compose.yml`: the Worker `image:` line
  (`pdftoolsag/smart-redact-worker:${WORKER_VERSION:-latest}`, plus `-cuda` in `gpu`)
- `docker-run/run-worker.sh`, `docker-run/run-worker-gpu.sh`: the image tag
- `smart-suite.sh`: the `load_env_file` allowlist, the generated env file comments in `write_env_file`, and
  `cmd_docker_run_pull`
- `.env.example`, `docker-compose/*/.env.example`, and the README configuration table
