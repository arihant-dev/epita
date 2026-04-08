// Chamonix - An AI Agent with tool capabilities
package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
	"sync"
	"time"

	"github.com/arihant/chamonix/pkg/agent"
	"github.com/arihant/chamonix/pkg/llm"
	"github.com/arihant/chamonix/pkg/registry"
	"github.com/arihant/chamonix/pkg/tools"
)

// Spinner shows a loading animation while waiting for response.
type Spinner struct {
	frames  []string
	stop    chan struct{}
	stopped chan struct{}
	mu      sync.Mutex
	running bool
}

func NewSpinner() *Spinner {
	return &Spinner{
		frames:  []string{"⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"},
		stop:    make(chan struct{}),
		stopped: make(chan struct{}),
	}
}

func (s *Spinner) Start(message string) {
	s.mu.Lock()
	if s.running {
		s.mu.Unlock()
		return
	}
	s.running = true
	s.stop = make(chan struct{})
	s.stopped = make(chan struct{})
	s.mu.Unlock()

	go func() {
		defer close(s.stopped)
		i := 0
		for {
			select {
			case <-s.stop:
				fmt.Print("\r\033[K") // Clear line
				return
			default:
				fmt.Printf("\r%s %s", s.frames[i%len(s.frames)], message)
				i++
				time.Sleep(80 * time.Millisecond)
			}
		}
	}()
}

func (s *Spinner) Stop() {
	s.mu.Lock()
	if !s.running {
		s.mu.Unlock()
		return
	}
	s.running = false
	s.mu.Unlock()

	close(s.stop)
	<-s.stopped
}

const systemPrompt = `You are Chamonix, a helpful AI assistant with access to tools.

Available tools:
- files: Read, write, and list files
- http: Fetch content from URLs
- calc: Evaluate mathematical expressions and compute derivatives

Use tools when needed to help the user. Be concise and helpful.`

func main() {
	// Initialize LLM client
	client, err := llm.New()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		fmt.Fprintln(os.Stderr, "Set OPENAI_API_KEY environment variable")
		os.Exit(1)
	}

	// Create tool registry
	reg := registry.New()
	reg.Register(tools.NewFilesTool(""))
	reg.Register(tools.NewHTTPTool())
	reg.Register(tools.NewCalcTool())

	// Create agent
	ag := agent.New(client, reg)
	ag.SetSystemPrompt(systemPrompt)

	fmt.Println("🏔️  Chamonix Agent")
	fmt.Printf("   Model: %s\n", client.Model())
	fmt.Printf("   Tools: files, http, calc\n")
	fmt.Println("   Type 'quit' to exit, 'clear' to reset history")
	fmt.Println()

	// Interactive loop
	scanner := bufio.NewScanner(os.Stdin)
	spinner := NewSpinner()

	for {
		fmt.Print("You: ")
		if !scanner.Scan() {
			break
		}

		input := strings.TrimSpace(scanner.Text())
		if input == "" {
			continue
		}

		if input == "quit" || input == "exit" {
			fmt.Println("Goodbye!")
			break
		}

		if input == "clear" {
			ag.ClearHistory()
			fmt.Println("History cleared.")
			continue
		}

		// Show spinner initially
		spinner.Start("Thinking...")

		// Track if we've started streaming
		firstToken := true

		// Stream callback - prints tokens as they arrive
		streamCallback := func(token string) {
			if firstToken {
				spinner.Stop()
				fmt.Print("Chamonix: ")
				firstToken = false
			}
			fmt.Print(token)
		}

		// Run the agent with streaming
		_, err := ag.RunStream(input, streamCallback)

		// Ensure spinner is stopped if no tokens were received
		if firstToken {
			spinner.Stop()
		}

		if err != nil {
			if !firstToken {
				fmt.Println() // Newline after partial output
			}
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			continue
		}

		fmt.Println() // Newline after response
		fmt.Println() // Extra line for spacing
	}
}
