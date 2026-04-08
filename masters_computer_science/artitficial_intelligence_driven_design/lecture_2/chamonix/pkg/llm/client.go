// Package llm provides an OpenAI-compatible LLM client.
package llm

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
)

const defaultModel = "gpt-5-mini"
const defaultBaseURL = "https://api.openai.com/v1"

// Client is an OpenAI-compatible LLM client.
type Client struct {
	apiKey  string
	model   string
	baseURL string
	client  *http.Client
}

// Message represents a chat message.
type Message struct {
	Role       string     `json:"role"`
	Content    string     `json:"content,omitempty"`
	ToolCalls  []ToolCall `json:"tool_calls,omitempty"`
	ToolCallID string     `json:"tool_call_id,omitempty"`
}

// ToolCall represents a tool invocation request from the LLM.
type ToolCall struct {
	ID       string `json:"id"`
	Type     string `json:"type"`
	Function struct {
		Name      string `json:"name"`
		Arguments string `json:"arguments"`
	} `json:"function"`
}

// ChatRequest is the request body for chat completions.
type ChatRequest struct {
	Model    string           `json:"model"`
	Messages []Message        `json:"messages"`
	Tools    []map[string]any `json:"tools,omitempty"`
}

// ChatResponse is the response from chat completions.
type ChatResponse struct {
	Choices []struct {
		Message      Message `json:"message"`
		FinishReason string  `json:"finish_reason"`
	} `json:"choices"`
	Error *struct {
		Message string `json:"message"`
	} `json:"error,omitempty"`
}

// New creates a new LLM client.
// It reads OPENAI_API_KEY from environment.
func New() (*Client, error) {
	apiKey := os.Getenv("OPENAI_API_KEY")
	if apiKey == "" {
		return nil, fmt.Errorf("OPENAI_API_KEY environment variable not set")
	}

	return &Client{
		apiKey:  apiKey,
		model:   defaultModel,
		baseURL: defaultBaseURL,
		client:  &http.Client{},
	}, nil
}

// NewWithConfig creates a client with custom configuration.
func NewWithConfig(apiKey, model, baseURL string) *Client {
	if model == "" {
		model = defaultModel
	}
	if baseURL == "" {
		baseURL = defaultBaseURL
	}
	return &Client{
		apiKey:  apiKey,
		model:   model,
		baseURL: baseURL,
		client:  &http.Client{},
	}
}

// Chat sends a chat completion request.
func (c *Client) Chat(messages []Message, tools []map[string]any) (*Message, error) {
	reqBody := ChatRequest{
		Model:    c.model,
		Messages: messages,
		Tools:    tools,
	}

	jsonBody, err := json.Marshal(reqBody)
	if err != nil {
		return nil, fmt.Errorf("marshal request: %w", err)
	}

	req, err := http.NewRequest("POST", c.baseURL+"/chat/completions", bytes.NewReader(jsonBody))
	if err != nil {
		return nil, fmt.Errorf("create request: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+c.apiKey)

	resp, err := c.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("send request: %w", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("read response: %w", err)
	}

	var chatResp ChatResponse
	if err := json.Unmarshal(body, &chatResp); err != nil {
		return nil, fmt.Errorf("unmarshal response: %w", err)
	}

	if chatResp.Error != nil {
		return nil, fmt.Errorf("API error: %s", chatResp.Error.Message)
	}

	if len(chatResp.Choices) == 0 {
		return nil, fmt.Errorf("no choices in response")
	}

	return &chatResp.Choices[0].Message, nil
}

// Model returns the current model name.
func (c *Client) Model() string {
	return c.model
}
