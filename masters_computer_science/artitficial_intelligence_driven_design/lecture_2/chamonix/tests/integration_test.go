// Package tests contains integration tests for the Chamonix agent.
package tests

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/arihant/chamonix/pkg/registry"
	"github.com/arihant/chamonix/pkg/tools"
)

// TestToolRegistry tests the tool registry integration.
func TestToolRegistry(t *testing.T) {
	reg := registry.New()

	// Register all tools
	reg.Register(tools.NewFilesTool(""))
	reg.Register(tools.NewHTTPTool())
	reg.Register(tools.NewCalcTool())

	// Verify all tools are registered
	toolList := reg.List()
	if len(toolList) != 3 {
		t.Errorf("expected 3 tools, got %d", len(toolList))
	}

	// Verify tool lookup
	names := []string{"files", "http", "calc"}
	for _, name := range names {
		tool, err := reg.Get(name)
		if err != nil {
			t.Errorf("failed to get tool %s: %v", name, err)
		}
		if tool.Name() != name {
			t.Errorf("tool name mismatch: got %s, want %s", tool.Name(), name)
		}
	}

	// Verify OpenAI format conversion
	openAITools := reg.ToOpenAITools()
	if len(openAITools) != 3 {
		t.Errorf("expected 3 OpenAI tools, got %d", len(openAITools))
	}

	for _, tool := range openAITools {
		if tool["type"] != "function" {
			t.Error("tool type should be 'function'")
		}
		fn, ok := tool["function"].(map[string]any)
		if !ok {
			t.Error("function should be a map")
			continue
		}
		if fn["name"] == nil || fn["description"] == nil || fn["parameters"] == nil {
			t.Error("function should have name, description, and parameters")
		}
	}
}

// TestMultiToolWorkflow tests a workflow using multiple tools.
func TestMultiToolWorkflow(t *testing.T) {
	tmpDir := t.TempDir()

	// Create files tool with base directory
	filesTool := tools.NewFilesTool(tmpDir)

	// Step 1: Write a file
	result, err := filesTool.Execute(map[string]any{
		"operation": "write",
		"path":      "data.txt",
		"content":   "x^2 + 3*x + 5",
	})
	if err != nil {
		t.Fatalf("write failed: %v", err)
	}
	t.Logf("Write result: %s", result)

	// Step 2: Read the file back
	result, err = filesTool.Execute(map[string]any{
		"operation": "read",
		"path":      "data.txt",
	})
	if err != nil {
		t.Fatalf("read failed: %v", err)
	}
	if result != "x^2 + 3*x + 5" {
		t.Errorf("unexpected content: %s", result)
	}

	// Step 3: Use calc to evaluate something
	calcTool := tools.NewCalcTool()
	result, err = calcTool.Execute(map[string]any{
		"operation":  "derivative",
		"expression": "x^2",
		"variable":   "x",
	})
	if err != nil {
		t.Fatalf("derivative failed: %v", err)
	}
	if result != "2*x" {
		t.Errorf("unexpected derivative: %s", result)
	}

	// Step 4: List directory
	result, err = filesTool.Execute(map[string]any{
		"operation": "list",
		"path":      ".",
	})
	if err != nil {
		t.Fatalf("list failed: %v", err)
	}
	if result != "data.txt" {
		t.Errorf("unexpected list result: %s", result)
	}
}

// TestToolErrorHandling tests that tools handle errors gracefully.
func TestToolErrorHandling(t *testing.T) {
	tests := []struct {
		name   string
		tool   tools.Tool
		params map[string]any
	}{
		{
			name: "files read nonexistent",
			tool: tools.NewFilesTool(""),
			params: map[string]any{
				"operation": "read",
				"path":      "/nonexistent/path/file.txt",
			},
		},
		{
			name: "calc invalid operation",
			tool: tools.NewCalcTool(),
			params: map[string]any{
				"operation":  "integrate", // not supported
				"expression": "x^2",
			},
		},
		{
			name: "http invalid url",
			tool: tools.NewHTTPTool(),
			params: map[string]any{
				"url": "http://invalid.localhost.test:99999",
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := tt.tool.Execute(tt.params)
			if err == nil {
				t.Error("expected error, got nil")
			}
		})
	}
}

// TestEndToEndFileOperations simulates an agent workflow.
func TestEndToEndFileOperations(t *testing.T) {
	tmpDir := t.TempDir()

	// Simulate agent executing a series of tool calls
	filesTool := tools.NewFilesTool(tmpDir)

	// Agent wants to create a project structure
	steps := []struct {
		params map[string]any
		check  func(result string, err error)
	}{
		{
			params: map[string]any{
				"operation": "write",
				"path":      "README.md",
				"content":   "# My Project\n\nThis is a test project.",
			},
			check: func(result string, err error) {
				if err != nil {
					t.Errorf("step 1 failed: %v", err)
				}
			},
		},
		{
			params: map[string]any{
				"operation": "write",
				"path":      "src/main.go",
				"content":   "package main\n\nfunc main() {}\n",
			},
			check: func(result string, err error) {
				if err != nil {
					t.Errorf("step 2 failed: %v", err)
				}
			},
		},
		{
			params: map[string]any{
				"operation": "list",
				"path":      ".",
			},
			check: func(result string, err error) {
				if err != nil {
					t.Errorf("step 3 failed: %v", err)
				}
				// Should list README.md and src/
			},
		},
	}

	for i, step := range steps {
		result, err := filesTool.Execute(step.params)
		t.Logf("Step %d result: %s", i+1, result)
		step.check(result, err)
	}

	// Verify files exist on disk
	if _, err := os.Stat(filepath.Join(tmpDir, "README.md")); os.IsNotExist(err) {
		t.Error("README.md should exist")
	}
	if _, err := os.Stat(filepath.Join(tmpDir, "src", "main.go")); os.IsNotExist(err) {
		t.Error("src/main.go should exist")
	}
}
