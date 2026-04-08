# Chamonix Agent Context

## Current Phase: 3 - Complete ✓

## Project Structure
```
chamonix/
├── cmd/chamonix/main.go    # CLI entry point
├── pkg/
│   ├── agent/agent.go      # Agent loop with memory
│   ├── llm/client.go       # OpenAI-compatible LLM client
│   ├── tools/              # Tool implementations
│   │   ├── tool.go         # Tool interface
│   │   ├── files.go        # File operations
│   │   ├── http.go         # HTTP GET
│   │   └── calc.go         # Math operations
│   └── registry/registry.go # Tool registry
├── tests/                   # Unit and integration tests
├── vision.md               # Project vision
└── agents.md               # This file - context for agents
```

## Key Interfaces

### Tool Interface
```go
type Tool interface {
    Name() string
    Description() string
    Schema() map[string]any    // JSON schema for parameters
    Execute(params map[string]any) (string, error)
}
```

### LLM Client
- Uses OpenAI-compatible API
- Model: gpt-5-mini (or configurable)
- Env: OPENAI_API_KEY

## Phase Checklist
- [x] Phase 1: Foundation (setup, LLM client, tool interface)
- [x] Phase 2: Tools (files, http, calc + unit tests)
- [x] Phase 3: Integration (agent loop, integration tests, demo)

## Context for Next Agent
When continuing this project:
1. Check current phase above
2. Review existing code in pkg/
3. Follow the Tool interface for new tools
4. Run `go test ./...` to verify changes
