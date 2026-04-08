// Package registry manages tool registration and lookup.
package registry

import (
	"fmt"

	"github.com/arihant/chamonix/pkg/tools"
)

// Registry holds registered tools.
type Registry struct {
	tools map[string]tools.Tool
}

// New creates a new tool registry.
func New() *Registry {
	return &Registry{
		tools: make(map[string]tools.Tool),
	}
}

// Register adds a tool to the registry.
func (r *Registry) Register(tool tools.Tool) {
	r.tools[tool.Name()] = tool
}

// Get retrieves a tool by name.
func (r *Registry) Get(name string) (tools.Tool, error) {
	tool, ok := r.tools[name]
	if !ok {
		return nil, fmt.Errorf("tool not found: %s", name)
	}
	return tool, nil
}

// List returns all registered tools.
func (r *Registry) List() []tools.Tool {
	result := make([]tools.Tool, 0, len(r.tools))
	for _, tool := range r.tools {
		result = append(result, tool)
	}
	return result
}

// ToOpenAITools converts registered tools to OpenAI function format.
func (r *Registry) ToOpenAITools() []map[string]any {
	result := make([]map[string]any, 0, len(r.tools))
	for _, tool := range r.tools {
		result = append(result, map[string]any{
			"type": "function",
			"function": map[string]any{
				"name":        tool.Name(),
				"description": tool.Description(),
				"parameters":  tool.Schema(),
			},
		})
	}
	return result
}
