// Package protocol provides JSON-based communication for the agent.
package protocol

import (
	"bufio"
	"encoding/json"
	"fmt"
	"io"
	"os"

	"github.com/arihant/chamonix/pkg/agent"
)

// Request represents an incoming JSON request.
type Request struct {
	Query  string `json:"query"`
	Stream bool   `json:"stream,omitempty"`
	Clear  bool   `json:"clear,omitempty"` // Clear conversation history
}

// Response represents a complete JSON response.
type Response struct {
	Response  string     `json:"response,omitempty"`
	ToolCalls []ToolCall `json:"tool_calls,omitempty"`
	Error     string     `json:"error,omitempty"`
}

// ToolCall represents a tool invocation in the response.
type ToolCall struct {
	Name   string         `json:"name"`
	Args   map[string]any `json:"args"`
	Result string         `json:"result"`
}

// StreamEvent represents a streaming event (NDJSON).
type StreamEvent struct {
	Type    string         `json:"type"` // "token", "tool_call", "tool_result", "done", "error"
	Content string         `json:"content,omitempty"`
	Name    string         `json:"name,omitempty"`
	Args    map[string]any `json:"args,omitempty"`
	Result  string         `json:"result,omitempty"`
}

// Handler processes JSON requests via stdin/stdout.
type Handler struct {
	agent  *agent.Agent
	input  io.Reader
	output io.Writer
}

// NewHandler creates a new protocol handler.
func NewHandler(ag *agent.Agent) *Handler {
	return &Handler{
		agent:  ag,
		input:  os.Stdin,
		output: os.Stdout,
	}
}

// NewHandlerWithIO creates a handler with custom IO (for testing).
func NewHandlerWithIO(ag *agent.Agent, input io.Reader, output io.Writer) *Handler {
	return &Handler{
		agent:  ag,
		input:  input,
		output: output,
	}
}

// Run starts processing JSON requests from stdin.
func (h *Handler) Run() error {
	scanner := bufio.NewScanner(h.input)
	encoder := json.NewEncoder(h.output)

	for scanner.Scan() {
		line := scanner.Text()
		if line == "" {
			continue
		}

		var req Request
		if err := json.Unmarshal([]byte(line), &req); err != nil {
			encoder.Encode(Response{Error: fmt.Sprintf("invalid JSON: %v", err)})
			continue
		}

		if req.Clear {
			h.agent.ClearHistory()
			encoder.Encode(Response{Response: "history cleared"})
			continue
		}

		if req.Query == "" {
			encoder.Encode(Response{Error: "query is required"})
			continue
		}

		if req.Stream {
			h.handleStreaming(req.Query)
		} else {
			h.handleNonStreaming(req.Query, encoder)
		}
	}

	return scanner.Err()
}

// handleNonStreaming processes a request and returns a single response.
func (h *Handler) handleNonStreaming(query string, encoder *json.Encoder) {
	response, err := h.agent.Run(query)
	if err != nil {
		encoder.Encode(Response{Error: err.Error()})
		return
	}
	encoder.Encode(Response{Response: response})
}

// handleStreaming processes a request with streaming output.
func (h *Handler) handleStreaming(query string) {
	encoder := json.NewEncoder(h.output)
	var fullResponse string

	callback := func(token string) {
		fullResponse += token
		encoder.Encode(StreamEvent{
			Type:    "token",
			Content: token,
		})
	}

	response, err := h.agent.RunStream(query, callback)
	if err != nil {
		encoder.Encode(StreamEvent{
			Type:    "error",
			Content: err.Error(),
		})
		return
	}

	// Use the returned response (may differ from accumulated tokens if tool calls happened)
	if response != "" {
		fullResponse = response
	}

	encoder.Encode(StreamEvent{
		Type:    "done",
		Content: fullResponse,
	})
}

// RunSingle processes a single request (for piped input).
func (h *Handler) RunSingle(req Request) error {
	encoder := json.NewEncoder(h.output)

	if req.Clear {
		h.agent.ClearHistory()
		return encoder.Encode(Response{Response: "history cleared"})
	}

	if req.Query == "" {
		return encoder.Encode(Response{Error: "query is required"})
	}

	if req.Stream {
		h.handleStreaming(req.Query)
	} else {
		h.handleNonStreaming(req.Query, encoder)
	}

	return nil
}
