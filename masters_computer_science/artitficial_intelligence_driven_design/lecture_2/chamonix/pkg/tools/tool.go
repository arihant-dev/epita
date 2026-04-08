// Package tools defines the Tool interface for agent capabilities.
package tools

// Tool represents a capability the agent can invoke.
type Tool interface {
	// Name returns the unique identifier for this tool.
	Name() string

	// Description returns a human-readable description for the LLM.
	Description() string

	// Schema returns the JSON schema for the tool's parameters.
	// This follows OpenAI's function calling format.
	Schema() map[string]any

	// Execute runs the tool with the given parameters.
	Execute(params map[string]any) (string, error)
}
