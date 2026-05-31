# Repository Guidelines

## Project Structure & Module Organization
- `main.go` is the entrypoint; it loads env-based config and starts the app.
- `internal/app/app.go` wires MCP server setup, tool registration, HTTP transport, and auth middleware.
- `internal/config/config.go` contains runtime configuration and defaults.
- `internal/httpauth/middleware.go` enforces bearer-token auth on every request.
- `internal/tools/hello.go` currently registers the `hello` MCP tool.
- `nginx/README.md` documents proxy settings required for MCP streaming.
- `bin/` is the default build output directory (`make build`).

## Build, Test, and Development Commands
- `make help`: list available targets.
- `make build`: compile binary to `bin/ianmiell-mcp-server`.
- `make run`: start server via `go run`.
- `make test`: run `go test ./...`.
- `make fmt`: run `go fmt ./...`.
- `make vet`: run `go vet ./...`.
- `make lint`: run `fmt`, `vet`, and `test` in sequence.
- `make tidy`: tidy module dependencies.
- `make clean`: remove `bin/` artifacts.

## Runtime Configuration
Environment variables read by `internal/config/config.go`:
- `MCP_ADDRESS` (default `:9482`)
- `MCP_AUTH_TOKEN` (default `secret123`)
- `MCP_SERVER_NAME` (default `Demo Server`)
- `MCP_SERVER_VERSION` (default `1.0.0`)

Example local run:
```bash
MCP_AUTH_TOKEN=dev-token MCP_SERVER_NAME='Ian MCP' make run
```

## Auth and API Behavior
- Requests must include `Authorization: Bearer <token>`.
- Missing/incorrect token returns HTTP `401 unauthorized`.
- Auth is applied globally in `app.Run` through `httpauth.Middleware`.

## MCP Tooling Notes
- Add new tools under `internal/tools/` and register them in `Register`.
- Existing tool contract example: `hello` expects required string arg `name` and returns text.

## Reverse Proxy Notes
For nginx, preserve streaming behavior (from `nginx/README.md`):
- disable proxy buffering/cache
- keep HTTP/1.1 upstream
- preserve chunked transfer support

## Coding and Change Guidelines
- Keep Go code `gofmt`-clean and run `make lint` before shipping changes.
- Prefer small, focused edits in `internal/` packages.
- Keep auth behavior explicit and unchanged unless request requires security changes.

## Common Task Recipes

### Add a New MCP Tool
1. Create a new file in `internal/tools/` (for example `time.go`).
2. Define the tool with `mcp.NewTool(...)` and a handler function.
3. Register it from `Register(s *server.MCPServer)` in `internal/tools/hello.go` (or split registration by file and keep a single `Register` entrypoint).
4. Run `make fmt && make test`.
5. Start locally with `make run` and call the tool through your MCP client.

Minimal pattern:
```go
newTool := mcp.NewTool(
    "tool_name",
    mcp.WithDescription("What it does"),
)

s.AddTool(newTool, func(ctx context.Context, req mcp.CallToolRequest) (*mcp.CallToolResult, error) {
    return mcp.NewToolResultText("ok"), nil
})
```

### Run Locally with Explicit Config
```bash
MCP_ADDRESS=':9482' \
MCP_AUTH_TOKEN='dev-token' \
MCP_SERVER_NAME='Ian MCP' \
MCP_SERVER_VERSION='1.0.0-dev' \
make run
```

### Smoke Test Auth from Terminal
Use any endpoint your MCP client/server exposes over HTTP and include the bearer token.
```bash
curl -i http://127.0.0.1:9482/mcp \
  -H 'Authorization: Bearer dev-token'
```

Negative test (should return 401):
```bash
curl -i http://127.0.0.1:9482/mcp
```

### Verify Reverse Proxy Streaming Setup
1. Apply nginx config from `nginx/README.md`.
2. Confirm `proxy_http_version 1.1` is set.
3. Confirm `proxy_buffering off` and `proxy_cache off` are set.
4. Reload nginx and call via proxy path (for example `/mcp`).
