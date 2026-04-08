# Chamonix - AI Agent Vision

## What is Chamonix?
Chamonix is a Go-based LLM agent that can use tools to accomplish tasks. Named after the famous alpine town, it represents climbing to new heights with AI assistance.

## Core Capabilities
1. **Tool Invocation** - Execute files, HTTP, and calculus operations
2. **Memory** - Maintain conversation context across interactions
3. **Extensibility** - Easy-to-add new tools via a clean interface

## Architecture
```
User Query → Agent Loop → LLM (GPT-5-Mini) → Tool Calls → Results → Response
                ↑                                              ↓
                └──────────── Memory (History) ←───────────────┘
```

## Tools
| Tool | Operations | Purpose |
|------|------------|---------|
| files | read, write, list | File system interactions |
| http | GET | Fetch web resources |
| calc | eval, derivative | Mathematical computations |

## Design Principles
- **Simplicity** - Clean, readable code over clever abstractions
- **No Hardcoded Secrets** - All keys from environment variables
- **Testability** - Unit tests for tools, integration tests for agent
- **Lean Error Handling** - Wrap errors with context, fail fast

## AIDD Workflow
This project follows AI-Driven Development:
1. Vision document (this file) defines goals
2. Phased implementation with context passing
3. Commits reflect meaningful progress
4. Agent assists in coding each phase

## Success Metrics
- [ ] Agent responds to multi-tool queries
- [ ] All tests pass
- [ ] Live demo works
- [ ] Code is clean and maintainable
