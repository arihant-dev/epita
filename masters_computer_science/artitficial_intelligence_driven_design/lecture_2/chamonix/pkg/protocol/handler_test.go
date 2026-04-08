package protocol

import (
	"bytes"
	"encoding/json"
	"strings"
	"testing"

	"github.com/arihant/chamonix/pkg/agent"
	"github.com/arihant/chamonix/pkg/llm"
	"github.com/arihant/chamonix/pkg/registry"
	"github.com/arihant/chamonix/pkg/tools"
)

// mockAgent creates a test agent (won't actually call LLM).
func mockAgent() *agent.Agent {
	// Create a mock client - won't work without API key but good for structure tests
	client := llm.NewWithConfig("test-key", "test-model", "http://localhost:9999")
	reg := registry.New()
	reg.Register(tools.NewCalcTool())
	reg.Register(tools.NewFilesTool(""))
	return agent.New(client, reg)
}

func TestHandler_ParseRequest(t *testing.T) {
	tests := []struct {
		name      string
		input     string
		wantErr   bool
		skipAgent bool // Skip tests that need actual LLM
	}{
		{
			name:      "valid request",
			input:     `{"query": "hello"}`,
			wantErr:   false,
			skipAgent: true, // Would need LLM
		},
		{
			name:    "invalid json",
			input:   `{not valid json}`,
			wantErr: true,
		},
		{
			name:    "empty query",
			input:   `{"query": ""}`,
			wantErr: true,
		},
		{
			name:    "clear request",
			input:   `{"clear": true}`,
			wantErr: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if tt.skipAgent {
				t.Skip("requires LLM connection")
			}

			ag := mockAgent()
			input := strings.NewReader(tt.input + "\n")
			output := &bytes.Buffer{}

			handler := NewHandlerWithIO(ag, input, output)
			handler.Run()

			var resp Response
			json.Unmarshal(output.Bytes(), &resp)

			if tt.wantErr && resp.Error == "" {
				t.Error("expected error, got none")
			}
			if !tt.wantErr && resp.Error != "" {
				t.Errorf("unexpected error: %s", resp.Error)
			}
		})
	}
}

func TestHandler_ClearHistory(t *testing.T) {
	ag := mockAgent()
	input := strings.NewReader(`{"clear": true}` + "\n")
	output := &bytes.Buffer{}

	handler := NewHandlerWithIO(ag, input, output)
	handler.Run()

	var resp Response
	if err := json.Unmarshal(output.Bytes(), &resp); err != nil {
		t.Fatalf("failed to parse response: %v", err)
	}

	if resp.Response != "history cleared" {
		t.Errorf("expected 'history cleared', got %q", resp.Response)
	}
}

func TestRequest_JSONFormat(t *testing.T) {
	// Test that our request struct matches expected JSON format
	req := Request{
		Query:  "test query",
		Stream: true,
	}

	data, err := json.Marshal(req)
	if err != nil {
		t.Fatal(err)
	}

	expected := `{"query":"test query","stream":true}`
	if string(data) != expected {
		t.Errorf("got %s, want %s", string(data), expected)
	}
}

func TestResponse_JSONFormat(t *testing.T) {
	resp := Response{
		Response: "test response",
	}

	data, err := json.Marshal(resp)
	if err != nil {
		t.Fatal(err)
	}

	// Verify it can be parsed back
	var parsed Response
	if err := json.Unmarshal(data, &parsed); err != nil {
		t.Fatal(err)
	}

	if parsed.Response != resp.Response {
		t.Errorf("got %s, want %s", parsed.Response, resp.Response)
	}
}

func TestStreamEvent_JSONFormat(t *testing.T) {
	events := []StreamEvent{
		{Type: "token", Content: "Hello"},
		{Type: "tool_call", Name: "calc", Args: map[string]any{"expr": "2+2"}},
		{Type: "done", Content: "Final response"},
		{Type: "error", Content: "something went wrong"},
	}

	for _, event := range events {
		data, err := json.Marshal(event)
		if err != nil {
			t.Errorf("failed to marshal event %v: %v", event, err)
			continue
		}

		var parsed StreamEvent
		if err := json.Unmarshal(data, &parsed); err != nil {
			t.Errorf("failed to unmarshal event: %v", err)
		}
	}
}
