// Package llm provides an OpenAI-compatible LLM client.
package llm

import (
	"bufio"
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
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
	Stream   bool             `json:"stream,omitempty"`
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

// StreamDelta represents a streaming chunk delta.
type StreamDelta struct {
	Role      string     `json:"role,omitempty"`
	Content   string     `json:"content,omitempty"`
	ToolCalls []ToolCall `json:"tool_calls,omitempty"`
}

// StreamChoice represents a choice in a streaming response.
type StreamChoice struct {
	Index        int         `json:"index"`
	Delta        StreamDelta `json:"delta"`
	FinishReason string      `json:"finish_reason,omitempty"`
}

// StreamResponse represents a streaming chunk.
type StreamResponse struct {
	Choices []StreamChoice `json:"choices"`
}

// StreamCallback is called for each content token received.
type StreamCallback func(token string)

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

// Chat sends a chat completion request (non-streaming).
func (c *Client) Chat(messages []Message, tools []map[string]any) (*Message, error) {
	return c.ChatStream(messages, tools, nil)
}

// ChatStream sends a chat completion request with optional streaming.
// If callback is nil, uses non-streaming mode.
func (c *Client) ChatStream(messages []Message, tools []map[string]any, callback StreamCallback) (*Message, error) {
	stream := callback != nil

	reqBody := ChatRequest{
		Model:    c.model,
		Messages: messages,
		Tools:    tools,
		Stream:   stream,
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

	if stream {
		return c.handleStreamResponse(resp.Body, callback)
	}
	return c.handleNonStreamResponse(resp.Body)
}

// handleNonStreamResponse processes a non-streaming response.
func (c *Client) handleNonStreamResponse(body io.Reader) (*Message, error) {
	data, err := io.ReadAll(body)
	if err != nil {
		return nil, fmt.Errorf("read response: %w", err)
	}

	var chatResp ChatResponse
	if err := json.Unmarshal(data, &chatResp); err != nil {
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

// handleStreamResponse processes a streaming SSE response.
func (c *Client) handleStreamResponse(body io.Reader, callback StreamCallback) (*Message, error) {
	reader := bufio.NewReader(body)

	// Accumulate the full message
	msg := &Message{Role: "assistant"}
	var toolCallsMap = make(map[int]*ToolCall)

	for {
		line, err := reader.ReadString('\n')
		if err != nil {
			if err == io.EOF {
				break
			}
			return nil, fmt.Errorf("read stream: %w", err)
		}

		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}

		// SSE format: "data: {...}" or "data: [DONE]"
		if !strings.HasPrefix(line, "data: ") {
			continue
		}

		data := strings.TrimPrefix(line, "data: ")
		if data == "[DONE]" {
			break
		}

		var streamResp StreamResponse
		if err := json.Unmarshal([]byte(data), &streamResp); err != nil {
			continue // Skip malformed chunks
		}

		if len(streamResp.Choices) == 0 {
			continue
		}

		choice := streamResp.Choices[0]
		delta := choice.Delta

		// Accumulate content
		if delta.Content != "" {
			msg.Content += delta.Content
			if callback != nil {
				callback(delta.Content)
			}
		}

		// Accumulate tool calls
		for _, tc := range delta.ToolCalls {
			idx := 0 // Default to index 0 for single tool calls
			if existing, ok := toolCallsMap[idx]; ok {
				// Append to existing tool call arguments
				existing.Function.Arguments += tc.Function.Arguments
			} else {
				// New tool call
				newTC := ToolCall{
					ID:   tc.ID,
					Type: tc.Type,
				}
				newTC.Function.Name = tc.Function.Name
				newTC.Function.Arguments = tc.Function.Arguments
				toolCallsMap[idx] = &newTC
			}
		}
	}

	// Convert tool calls map to slice
	for _, tc := range toolCallsMap {
		msg.ToolCalls = append(msg.ToolCalls, *tc)
	}

	return msg, nil
}

// Model returns the current model name.
func (c *Client) Model() string {
	return c.model
}
