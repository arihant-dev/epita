package tools

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestHTTPTool_Get(t *testing.T) {
	// Create test server
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method != "GET" {
			t.Errorf("expected GET, got %s", r.Method)
		}
		w.Write([]byte("hello from server"))
	}))
	defer server.Close()

	tool := NewHTTPTool()
	result, err := tool.Execute(map[string]any{
		"url": server.URL,
	})

	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if result != "hello from server" {
		t.Errorf("got %q, want %q", result, "hello from server")
	}
}

func TestHTTPTool_Error(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusNotFound)
	}))
	defer server.Close()

	tool := NewHTTPTool()
	_, err := tool.Execute(map[string]any{
		"url": server.URL,
	})

	if err == nil {
		t.Error("expected error for 404, got nil")
	}
}

func TestHTTPTool_MissingURL(t *testing.T) {
	tool := NewHTTPTool()
	_, err := tool.Execute(map[string]any{})

	if err == nil {
		t.Error("expected error for missing URL, got nil")
	}
}

func TestHTTPTool_Schema(t *testing.T) {
	tool := NewHTTPTool()
	schema := tool.Schema()

	if schema["type"] != "object" {
		t.Error("schema type should be object")
	}

	props, ok := schema["properties"].(map[string]any)
	if !ok {
		t.Fatal("properties should be a map")
	}

	if _, ok := props["url"]; !ok {
		t.Error("schema should have url property")
	}
}
