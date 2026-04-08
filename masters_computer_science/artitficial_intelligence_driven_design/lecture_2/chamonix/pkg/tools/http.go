package tools

import (
	"fmt"
	"io"
	"net/http"
	"time"
)

// HTTPTool provides HTTP GET requests.
type HTTPTool struct {
	client *http.Client
}

// NewHTTPTool creates a new HTTP tool.
func NewHTTPTool() *HTTPTool {
	return &HTTPTool{
		client: &http.Client{
			Timeout: 30 * time.Second,
		},
	}
}

func (h *HTTPTool) Name() string {
	return "http"
}

func (h *HTTPTool) Description() string {
	return "Fetch content from a URL using HTTP GET request."
}

func (h *HTTPTool) Schema() map[string]any {
	return map[string]any{
		"type": "object",
		"properties": map[string]any{
			"url": map[string]any{
				"type":        "string",
				"description": "The URL to fetch",
			},
		},
		"required": []string{"url"},
	}
}

func (h *HTTPTool) Execute(params map[string]any) (string, error) {
	url, _ := params["url"].(string)
	if url == "" {
		return "", fmt.Errorf("url is required")
	}

	resp, err := h.client.Get(url)
	if err != nil {
		return "", fmt.Errorf("fetch URL: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 400 {
		return "", fmt.Errorf("HTTP %d: %s", resp.StatusCode, resp.Status)
	}

	// Limit response size to 100KB
	body, err := io.ReadAll(io.LimitReader(resp.Body, 100*1024))
	if err != nil {
		return "", fmt.Errorf("read response: %w", err)
	}

	return string(body), nil
}
