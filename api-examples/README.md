# API examples

Usage examples for Smart Redact workflows on the Smart Suite Manager API.

> For the full API reference, refer to [Smart Suite API Documentation](https://www.pdf-tools.com/docs/smart-suite/references/api/).

## Available examples

| Language   | Directory          | Description                         |
| ---------- | ------------------ | ----------------------------------- |
| **curl**   | [curl/](curl/)     | Shell scripts for each API step     |
| **C#**     | [csharp/](csharp/) | .NET console app using `HttpClient` |
| **Python** | [python/](python/) | Python scripts using `requests`     |

## Typical workflow

A standard PII detection and redaction workflow:

```
1. Upload a PDF file           POST /v1/files/upload/fromLocal
2. Start PII detection         POST /v1/jobs/detection
3. Take the detected entities from the response's result.redactions
4. Start PII redaction         POST /v1/jobs/redaction
5. Download the redacted PDF   POST /v1/files/download
```

Detection and redaction both take the uploaded PDF's own `fileId` and `dekToken`. Detection
returns its entities inline in `result.redactions` and produces no file; redaction returns the
redacted PDF in `outputFiles`.

For asynchronous jobs:

```
1. Create the job with "processingMode": "async"
2. Save the jobId. For a redaction job, also save the outputFiles entry and its DEK
   token: poll responses omit the token. A detection job produces no file.
3. Poll GET /v1/jobs/.../{jobId}/result until "jobStatus" becomes "finished"
4. Use the DEK token from the initial async response to download the result file
```

## Running the examples

The repository includes a sample PDF for testing. From the repository root:

**curl (full workflow):**

```bash
./api-examples/curl/full-workflow.sh "samples/Sample Document - Smart Suite.pdf"
```

**Python (full workflow):**

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r api-examples/python/requirements.txt
python3 api-examples/python/full_workflow.py "samples/Sample Document - Smart Suite.pdf"
```

**C# (full workflow):**

```bash
dotnet run --project api-examples/csharp -- "samples/Sample Document - Smart Suite.pdf"
```

## API endpoints

**Manager API** (default: http://localhost:9982):

| Method   | Endpoint                            | Description           |
| -------- | ----------------------------------- | --------------------- |
| `POST`   | `/v1/files/upload/fromLocal`        | Upload a PDF file     |
| `POST`   | `/v1/files/upload/fromUrl`          | Upload a PDF from URL |
| `GET`    | `/v1/files`                         | List uploaded files   |
| `GET`    | `/v1/files/{fileId}`                | Get file metadata     |
| `POST`   | `/v1/files/download`                | Download a file       |
| `DELETE` | `/v1/files/{fileId}`                | Delete a file         |
| `POST`   | `/v1/jobs/detection`                | Start a detection job |
| `GET`    | `/v1/jobs/detection/{jobId}/result` | Get detection result  |
| `POST`   | `/v1/jobs/redaction`                | Start a redaction job |
| `GET`    | `/v1/jobs/redaction/{jobId}/result` | Get redaction result  |

**Swagger UI:** http://localhost:9982/swagger

## Orchestrator API

If you're using the Orchestrator (web UI backend), it has its own API with authentication:

- **Default credentials:** `admin@example.com` / `Admin@1234!Tmp` (the Orchestrator suggests changing the password after first login)
- **Swagger UI:** http://localhost:9983/swagger

> For details, refer to [Orchestrator Authentication Guide](https://www.pdf-tools.com/docs/smart-suite/guides/authentication/).
