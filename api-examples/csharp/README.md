# C# API example

Standalone .NET console application demonstrating the full Smart Redact workflow using only `HttpClient` (no external packages).
The sample requests synchronous detection/redaction jobs and falls back to polling if the service returns an async response.

## Prerequisites

- [.NET 8 SDK](https://dotnet.microsoft.com/download) or later
- Smart Suite Manager running (default: `http://localhost:9982`)

## Usage

Run with an input PDF (from the repository root):

```bash
dotnet run --project api-examples/csharp -- "samples/Sample Document - Smart Suite.pdf"
```

Specify an output path:

```bash
dotnet run --project api-examples/csharp -- "samples/Sample Document - Smart Suite.pdf" redacted.pdf
```

If you don't specify an output path, the sample saves the redacted file as `<input>_redacted.pdf` in the current directory.

## Configuration

| Environment Variable                | Default                 | Description                                          |
| ----------------------------------- | ----------------------- | ---------------------------------------------------- |
| `MANAGER_URL`                       | `http://localhost:9982` | Smart Suite Manager base URL                         |
| `SMART_SUITE_HTTP_TIMEOUT_SECONDS` | `120`                   | Timeout for upload, download, and polling HTTP calls |
| `SMART_SUITE_JOB_TIMEOUT_SECONDS`  | `3600`                  | Timeout for synchronous detection/redaction requests |

Example:

```bash
MANAGER_URL=http://smartsuite.example.com:9982 dotnet run --project api-examples/csharp -- "samples/Sample Document - Smart Suite.pdf"
```

## API reference

For full API documentation, refer to [Smart Redact API Reference](https://www.pdf-tools.com/docs/smart-redact/references/api/).
