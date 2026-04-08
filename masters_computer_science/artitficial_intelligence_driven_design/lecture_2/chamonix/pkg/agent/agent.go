// Package agent implements the main agent loop with memory.
package agent

import (
	"encoding/json"
	"fmt"

	"github.com/arihant/chamonix/pkg/llm"
	"github.com/arihant/chamonix/pkg/registry"
)

// EventType represents the type of agent event.
type EventType string

const (
	EventToken      EventType = "token"
	EventToolCall   EventType = "tool_call"
	EventToolResult EventType = "tool_result"
)

// Event represents an agent event during processing.
type Event struct {
	Type       EventType      `json:"type"`
	Content    string         `json:"content,omitempty"`
	ToolName   string         `json:"tool_name,omitempty"`
	ToolArgs   map[string]any `json:"tool_args,omitempty"`
	ToolResult string         `json:"tool_result,omitempty"`
}

// EventCallback is called for each event during agent processing.
type EventCallback func(Event)

// Agent is the main agent that processes queries using tools.
type Agent struct {
	client   *llm.Client
	registry *registry.Registry
	history  []llm.Message
}

// New creates a new agent.
func New(client *llm.Client, registry *registry.Registry) *Agent {
	return &Agent{
		client:   client,
		registry: registry,
		history:  []llm.Message{},
	}
}

// SetSystemPrompt sets the system prompt for the agent.
func (a *Agent) SetSystemPrompt(prompt string) {
	// Remove existing system prompt if any
	if len(a.history) > 0 && a.history[0].Role == "system" {
		a.history = a.history[1:]
	}
	// Add new system prompt at the beginning
	a.history = append([]llm.Message{{Role: "system", Content: prompt}}, a.history...)
}

// Run processes a user query and returns the final response.
// It handles the complete tool invocation loop.
func (a *Agent) Run(query string) (string, error) {
	return a.RunWithEvents(query, nil)
}

// RunStream processes a user query with streaming tokens.
// The callback is invoked for each content token received.
func (a *Agent) RunStream(query string, callback llm.StreamCallback) (string, error) {
	if callback == nil {
		return a.RunWithEvents(query, nil)
	}
	// Wrap the token callback into an event callback
	eventCallback := func(e Event) {
		if e.Type == EventToken {
			callback(e.Content)
		}
	}
	return a.RunWithEvents(query, eventCallback)
}

// RunWithEvents processes a user query with full event callbacks.
func (a *Agent) RunWithEvents(query string, callback EventCallback) (string, error) {
	// Add user message to history
	a.history = append(a.history, llm.Message{Role: "user", Content: query})

	// Get tools in OpenAI format
	tools := a.registry.ToOpenAITools()

	// Wrap callback for LLM streaming
	var llmCallback llm.StreamCallback
	if callback != nil {
		llmCallback = func(token string) {
			callback(Event{Type: EventToken, Content: token})
		}
	}

	// Agent loop - process until we get a final response
	for iterations := 0; iterations < 10; iterations++ {
		// Call LLM
		response, err := a.client.ChatStream(a.history, tools, llmCallback)
		if err != nil {
			return "", fmt.Errorf("LLM call failed: %w", err)
		}

		// Add assistant response to history
		a.history = append(a.history, *response)

		// Check if there are tool calls to process
		if len(response.ToolCalls) == 0 {
			// No tool calls - this is the final response
			return response.Content, nil
		}

		// Process each tool call
		for _, toolCall := range response.ToolCalls {
			// Parse arguments for event
			var args map[string]any
			json.Unmarshal([]byte(toolCall.Function.Arguments), &args)

			// Emit tool call event
			if callback != nil {
				callback(Event{
					Type:     EventToolCall,
					ToolName: toolCall.Function.Name,
					ToolArgs: args,
				})
			}

			result, err := a.executeTool(toolCall)
			if err != nil {
				result = fmt.Sprintf("Error: %s", err.Error())
			}

			// Emit tool result event
			if callback != nil {
				callback(Event{
					Type:       EventToolResult,
					ToolName:   toolCall.Function.Name,
					ToolResult: result,
				})
			}

			// Add tool result to history
			a.history = append(a.history, llm.Message{
				Role:       "tool",
				Content:    result,
				ToolCallID: toolCall.ID,
			})
		}
	}

	return "", fmt.Errorf("max iterations reached without final response")
}

// executeTool runs a single tool call.
func (a *Agent) executeTool(toolCall llm.ToolCall) (string, error) {
	// Get the tool from registry
	tool, err := a.registry.Get(toolCall.Function.Name)
	if err != nil {
		return "", err
	}

	// Parse arguments
	var params map[string]any
	if err := json.Unmarshal([]byte(toolCall.Function.Arguments), &params); err != nil {
		return "", fmt.Errorf("parse arguments: %w", err)
	}

	// Execute the tool
	return tool.Execute(params)
}

// ClearHistory clears conversation history (keeps system prompt).
func (a *Agent) ClearHistory() {
	if len(a.history) > 0 && a.history[0].Role == "system" {
		a.history = a.history[:1]
	} else {
		a.history = []llm.Message{}
	}
}

// History returns the current conversation history.
func (a *Agent) History() []llm.Message {
	return a.history
}
