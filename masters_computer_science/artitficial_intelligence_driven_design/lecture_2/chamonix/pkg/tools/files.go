package tools

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

// FilesTool provides file system operations.
type FilesTool struct {
	// BaseDir restricts operations to this directory (optional, for safety).
	BaseDir string
}

// NewFilesTool creates a new files tool.
func NewFilesTool(baseDir string) *FilesTool {
	return &FilesTool{BaseDir: baseDir}
}

func (f *FilesTool) Name() string {
	return "files"
}

func (f *FilesTool) Description() string {
	return "Read, write, and list files. Operations: read (path), write (path, content), list (path)."
}

func (f *FilesTool) Schema() map[string]any {
	return map[string]any{
		"type": "object",
		"properties": map[string]any{
			"operation": map[string]any{
				"type":        "string",
				"enum":        []string{"read", "write", "list"},
				"description": "The operation to perform",
			},
			"path": map[string]any{
				"type":        "string",
				"description": "File or directory path",
			},
			"content": map[string]any{
				"type":        "string",
				"description": "Content to write (only for write operation)",
			},
		},
		"required": []string{"operation", "path"},
	}
}

func (f *FilesTool) Execute(params map[string]any) (string, error) {
	op, _ := params["operation"].(string)
	path, _ := params["path"].(string)

	if path == "" {
		return "", fmt.Errorf("path is required")
	}

	// Resolve path relative to base directory if set
	if f.BaseDir != "" {
		path = filepath.Join(f.BaseDir, path)
	}

	// Security: prevent directory traversal
	if f.BaseDir != "" {
		absPath, err := filepath.Abs(path)
		if err != nil {
			return "", fmt.Errorf("invalid path: %w", err)
		}
		absBase, _ := filepath.Abs(f.BaseDir)
		if !strings.HasPrefix(absPath, absBase) {
			return "", fmt.Errorf("path outside base directory")
		}
	}

	switch op {
	case "read":
		return f.read(path)
	case "write":
		content, _ := params["content"].(string)
		return f.write(path, content)
	case "list":
		return f.list(path)
	default:
		return "", fmt.Errorf("unknown operation: %s", op)
	}
}

func (f *FilesTool) read(path string) (string, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return "", fmt.Errorf("read file: %w", err)
	}
	return string(data), nil
}

func (f *FilesTool) write(path, content string) (string, error) {
	// Create parent directories if needed
	dir := filepath.Dir(path)
	if err := os.MkdirAll(dir, 0755); err != nil {
		return "", fmt.Errorf("create directory: %w", err)
	}

	if err := os.WriteFile(path, []byte(content), 0644); err != nil {
		return "", fmt.Errorf("write file: %w", err)
	}
	return fmt.Sprintf("wrote %d bytes to %s", len(content), path), nil
}

func (f *FilesTool) list(path string) (string, error) {
	entries, err := os.ReadDir(path)
	if err != nil {
		return "", fmt.Errorf("list directory: %w", err)
	}

	var result []string
	for _, entry := range entries {
		name := entry.Name()
		if entry.IsDir() {
			name += "/"
		}
		result = append(result, name)
	}

	if len(result) == 0 {
		return "(empty directory)", nil
	}
	return strings.Join(result, "\n"), nil
}
