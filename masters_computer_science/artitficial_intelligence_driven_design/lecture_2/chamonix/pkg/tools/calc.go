package tools

import (
	"fmt"
	"go/ast"
	"go/parser"
	"go/token"
	"math"
	"strconv"
	"strings"
)

// CalcTool provides mathematical expression evaluation and derivatives.
type CalcTool struct{}

// NewCalcTool creates a new calc tool.
func NewCalcTool() *CalcTool {
	return &CalcTool{}
}

func (c *CalcTool) Name() string {
	return "calc"
}

func (c *CalcTool) Description() string {
	return "Evaluate mathematical expressions or compute symbolic derivatives. Operations: eval (expression), derivative (expression, variable)."
}

func (c *CalcTool) Schema() map[string]any {
	return map[string]any{
		"type": "object",
		"properties": map[string]any{
			"operation": map[string]any{
				"type":        "string",
				"enum":        []string{"eval", "derivative"},
				"description": "The operation to perform",
			},
			"expression": map[string]any{
				"type":        "string",
				"description": "Mathematical expression (e.g., '2+3*4', 'x^2+3*x')",
			},
			"variable": map[string]any{
				"type":        "string",
				"description": "Variable for derivative (default: x)",
			},
		},
		"required": []string{"operation", "expression"},
	}
}

func (c *CalcTool) Execute(params map[string]any) (string, error) {
	op, _ := params["operation"].(string)
	expr, _ := params["expression"].(string)
	variable, _ := params["variable"].(string)

	if expr == "" {
		return "", fmt.Errorf("expression is required")
	}

	if variable == "" {
		variable = "x"
	}

	switch op {
	case "eval":
		result, err := c.evaluate(expr)
		if err != nil {
			return "", err
		}
		return fmt.Sprintf("%g", result), nil
	case "derivative":
		return c.derivative(expr, variable)
	default:
		return "", fmt.Errorf("unknown operation: %s", op)
	}
}

// evaluate computes a numerical expression.
func (c *CalcTool) evaluate(expr string) (float64, error) {
	// Preprocess: replace ^ with ** for parsing
	expr = strings.ReplaceAll(expr, "^", "**")
	return c.evalExpr(expr)
}

// evalExpr is a simple expression evaluator.
func (c *CalcTool) evalExpr(expr string) (float64, error) {
	expr = strings.TrimSpace(expr)

	// Try parsing as a number first
	if val, err := strconv.ParseFloat(expr, 64); err == nil {
		return val, nil
	}

	// Handle parentheses
	if strings.HasPrefix(expr, "(") && strings.HasSuffix(expr, ")") {
		return c.evalExpr(expr[1 : len(expr)-1])
	}

	// Find lowest precedence operator (right to left for left-associativity)
	// Precedence: + - (lowest), * /, ** (highest)
	parenDepth := 0
	lastAddSub := -1
	lastMulDiv := -1
	lastPow := -1

	for i := len(expr) - 1; i >= 0; i-- {
		ch := expr[i]
		if ch == ')' {
			parenDepth++
		} else if ch == '(' {
			parenDepth--
		} else if parenDepth == 0 {
			if (ch == '+' || ch == '-') && i > 0 {
				lastAddSub = i
				break
			} else if (ch == '*' || ch == '/') && lastMulDiv == -1 {
				// Check for **
				if ch == '*' && i > 0 && expr[i-1] == '*' {
					if lastPow == -1 {
						lastPow = i - 1
					}
					i-- // Skip the first *
				} else {
					lastMulDiv = i
				}
			}
		}
	}

	// Evaluate based on operator precedence
	if lastAddSub > 0 {
		left, err := c.evalExpr(expr[:lastAddSub])
		if err != nil {
			return 0, err
		}
		right, err := c.evalExpr(expr[lastAddSub+1:])
		if err != nil {
			return 0, err
		}
		if expr[lastAddSub] == '+' {
			return left + right, nil
		}
		return left - right, nil
	}

	if lastMulDiv > 0 {
		left, err := c.evalExpr(expr[:lastMulDiv])
		if err != nil {
			return 0, err
		}
		right, err := c.evalExpr(expr[lastMulDiv+1:])
		if err != nil {
			return 0, err
		}
		if expr[lastMulDiv] == '*' {
			return left * right, nil
		}
		if right == 0 {
			return 0, fmt.Errorf("division by zero")
		}
		return left / right, nil
	}

	if lastPow > 0 {
		left, err := c.evalExpr(expr[:lastPow])
		if err != nil {
			return 0, err
		}
		right, err := c.evalExpr(expr[lastPow+2:])
		if err != nil {
			return 0, err
		}
		return math.Pow(left, right), nil
	}

	// Handle functions
	if strings.HasPrefix(expr, "sin(") {
		inner, err := c.evalExpr(expr[4 : len(expr)-1])
		if err != nil {
			return 0, err
		}
		return math.Sin(inner), nil
	}
	if strings.HasPrefix(expr, "cos(") {
		inner, err := c.evalExpr(expr[4 : len(expr)-1])
		if err != nil {
			return 0, err
		}
		return math.Cos(inner), nil
	}

	return 0, fmt.Errorf("cannot evaluate: %s", expr)
}

// derivative computes symbolic derivative using basic rules.
func (c *CalcTool) derivative(expr, variable string) (string, error) {
	expr = strings.TrimSpace(expr)

	// First try simple pattern matching (handles ^ operator which Go doesn't parse)
	result, err := c.simpleDerivative(expr, variable)
	if err == nil {
		return result, nil
	}

	// Fallback to AST parser for complex expressions
	node, parseErr := parser.ParseExpr(expr)
	if parseErr != nil {
		return "", err // Return original error
	}

	return c.diffAST(node, variable)
}

// simpleDerivative handles common patterns.
func (c *CalcTool) simpleDerivative(expr, v string) (string, error) {
	expr = strings.TrimSpace(expr)

	// Constant
	if _, err := strconv.ParseFloat(expr, 64); err == nil {
		return "0", nil
	}

	// Variable itself
	if expr == v {
		return "1", nil
	}

	// Different variable
	if len(expr) == 1 && expr != v {
		return "0", nil
	}

	// x^n pattern
	if strings.Contains(expr, "^") {
		parts := strings.Split(expr, "^")
		if len(parts) == 2 && strings.TrimSpace(parts[0]) == v {
			n, err := strconv.ParseFloat(strings.TrimSpace(parts[1]), 64)
			if err == nil {
				if n == 1 {
					return "1", nil
				}
				if n == 2 {
					return fmt.Sprintf("2*%s", v), nil
				}
				return fmt.Sprintf("%g*%s^%g", n, v, n-1), nil
			}
		}
	}

	// a*x pattern
	if strings.Contains(expr, "*") {
		parts := strings.Split(expr, "*")
		if len(parts) == 2 {
			left := strings.TrimSpace(parts[0])
			right := strings.TrimSpace(parts[1])
			if right == v {
				return left, nil
			}
			if left == v {
				return right, nil
			}
		}
	}

	return "", fmt.Errorf("cannot differentiate: %s", expr)
}

// diffAST differentiates an AST node.
func (c *CalcTool) diffAST(node ast.Expr, v string) (string, error) {
	switch n := node.(type) {
	case *ast.BasicLit:
		return "0", nil

	case *ast.Ident:
		if n.Name == v {
			return "1", nil
		}
		return "0", nil

	case *ast.BinaryExpr:
		switch n.Op {
		case token.ADD:
			left, err := c.diffAST(n.X, v)
			if err != nil {
				return "", err
			}
			right, err := c.diffAST(n.Y, v)
			if err != nil {
				return "", err
			}
			return c.simplifySum(left, right), nil

		case token.SUB:
			left, err := c.diffAST(n.X, v)
			if err != nil {
				return "", err
			}
			right, err := c.diffAST(n.Y, v)
			if err != nil {
				return "", err
			}
			if right == "0" {
				return left, nil
			}
			if left == "0" {
				return "-" + right, nil
			}
			return fmt.Sprintf("(%s)-(%s)", left, right), nil

		case token.MUL:
			// Product rule: (fg)' = f'g + fg'
			f := c.exprToString(n.X)
			g := c.exprToString(n.Y)
			df, _ := c.diffAST(n.X, v)
			dg, _ := c.diffAST(n.Y, v)

			term1 := c.simplifyProduct(df, g)
			term2 := c.simplifyProduct(f, dg)
			return c.simplifySum(term1, term2), nil
		}

	case *ast.ParenExpr:
		return c.diffAST(n.X, v)
	}

	return "", fmt.Errorf("unsupported expression type")
}

func (c *CalcTool) exprToString(node ast.Expr) string {
	switch n := node.(type) {
	case *ast.BasicLit:
		return n.Value
	case *ast.Ident:
		return n.Name
	case *ast.BinaryExpr:
		return fmt.Sprintf("(%s%s%s)", c.exprToString(n.X), n.Op, c.exprToString(n.Y))
	case *ast.ParenExpr:
		return fmt.Sprintf("(%s)", c.exprToString(n.X))
	default:
		return "?"
	}
}

func (c *CalcTool) simplifySum(a, b string) string {
	if a == "0" {
		return b
	}
	if b == "0" {
		return a
	}
	return fmt.Sprintf("%s+%s", a, b)
}

func (c *CalcTool) simplifyProduct(a, b string) string {
	if a == "0" || b == "0" {
		return "0"
	}
	if a == "1" {
		return b
	}
	if b == "1" {
		return a
	}
	return fmt.Sprintf("%s*%s", a, b)
}
