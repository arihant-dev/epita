package tools

import (
	"os"
	"path/filepath"
	"testing"
)

func TestFilesTool_Read(t *testing.T) {
	// Create temp file
	tmpDir := t.TempDir()
	testFile := filepath.Join(tmpDir, "test.txt")
	content := "hello world"
	if err := os.WriteFile(testFile, []byte(content), 0644); err != nil {
		t.Fatal(err)
	}

	tool := NewFilesTool("")
	result, err := tool.Execute(map[string]any{
		"operation": "read",
		"path":      testFile,
	})

	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if result != content {
		t.Errorf("got %q, want %q", result, content)
	}
}

func TestFilesTool_Write(t *testing.T) {
	tmpDir := t.TempDir()
	testFile := filepath.Join(tmpDir, "new.txt")
	content := "new content"

	tool := NewFilesTool("")
	_, err := tool.Execute(map[string]any{
		"operation": "write",
		"path":      testFile,
		"content":   content,
	})

	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	// Verify file was written
	data, err := os.ReadFile(testFile)
	if err != nil {
		t.Fatal(err)
	}
	if string(data) != content {
		t.Errorf("got %q, want %q", string(data), content)
	}
}

func TestFilesTool_List(t *testing.T) {
	tmpDir := t.TempDir()
	os.WriteFile(filepath.Join(tmpDir, "a.txt"), []byte("a"), 0644)
	os.WriteFile(filepath.Join(tmpDir, "b.txt"), []byte("b"), 0644)
	os.Mkdir(filepath.Join(tmpDir, "subdir"), 0755)

	tool := NewFilesTool("")
	result, err := tool.Execute(map[string]any{
		"operation": "list",
		"path":      tmpDir,
	})

	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	// Check that files are listed
	if !contains(result, "a.txt") || !contains(result, "b.txt") || !contains(result, "subdir/") {
		t.Errorf("unexpected list result: %s", result)
	}
}

func TestFilesTool_PathTraversal(t *testing.T) {
	tmpDir := t.TempDir()
	tool := NewFilesTool(tmpDir)

	_, err := tool.Execute(map[string]any{
		"operation": "read",
		"path":      "../../../etc/passwd",
	})

	if err == nil {
		t.Error("expected error for path traversal, got nil")
	}
}

func contains(s, substr string) bool {
	return len(s) >= len(substr) && (s == substr || len(s) > 0 && containsHelper(s, substr))
}

func containsHelper(s, substr string) bool {
	for i := 0; i <= len(s)-len(substr); i++ {
		if s[i:i+len(substr)] == substr {
			return true
		}
	}
	return false
}
