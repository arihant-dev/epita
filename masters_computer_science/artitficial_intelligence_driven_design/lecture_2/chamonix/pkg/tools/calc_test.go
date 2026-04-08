package tools

import (
	"math"
	"testing"
)

func TestCalcTool_Eval(t *testing.T) {
	tests := []struct {
		expr   string
		want   float64
		approx bool
	}{
		{"2+3", 5, false},
		{"10-4", 6, false},
		{"3*4", 12, false},
		{"15/3", 5, false},
		{"2+3*4", 14, false},
		{"(2+3)*4", 20, false},
		{"2**3", 8, false},
		{"2^3", 8, false},
	}

	tool := NewCalcTool()
	for _, tt := range tests {
		t.Run(tt.expr, func(t *testing.T) {
			result, err := tool.Execute(map[string]any{
				"operation":  "eval",
				"expression": tt.expr,
			})
			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}

			var got float64
			_, err = parseFloat(result, &got)
			if err != nil {
				t.Fatalf("cannot parse result %q: %v", result, err)
			}

			if tt.approx {
				if math.Abs(got-tt.want) > 0.0001 {
					t.Errorf("got %v, want approximately %v", got, tt.want)
				}
			} else {
				if got != tt.want {
					t.Errorf("got %v, want %v", got, tt.want)
				}
			}
		})
	}
}

func TestCalcTool_Derivative(t *testing.T) {
	tests := []struct {
		expr string
		want string
	}{
		{"x", "1"},
		{"5", "0"},
		{"x^2", "2*x"},
		{"x^3", "3*x^2"},
		{"3*x", "3"},
	}

	tool := NewCalcTool()
	for _, tt := range tests {
		t.Run(tt.expr, func(t *testing.T) {
			result, err := tool.Execute(map[string]any{
				"operation":  "derivative",
				"expression": tt.expr,
				"variable":   "x",
			})
			if err != nil {
				t.Fatalf("unexpected error: %v", err)
			}
			if result != tt.want {
				t.Errorf("got %q, want %q", result, tt.want)
			}
		})
	}
}

func TestCalcTool_MissingExpression(t *testing.T) {
	tool := NewCalcTool()
	_, err := tool.Execute(map[string]any{
		"operation": "eval",
	})
	if err == nil {
		t.Error("expected error for missing expression")
	}
}

func TestCalcTool_Schema(t *testing.T) {
	tool := NewCalcTool()
	schema := tool.Schema()

	if schema["type"] != "object" {
		t.Error("schema type should be object")
	}

	required, ok := schema["required"].([]string)
	if !ok {
		t.Fatal("required should be a string slice")
	}

	hasOp := false
	hasExpr := false
	for _, r := range required {
		if r == "operation" {
			hasOp = true
		}
		if r == "expression" {
			hasExpr = true
		}
	}
	if !hasOp || !hasExpr {
		t.Error("required should include operation and expression")
	}
}

func parseFloat(s string, f *float64) (int, error) {
	val := 0.0
	n, err := sscanf(s, "%f", &val)
	*f = val
	return n, err
}

func sscanf(s, format string, a ...any) (int, error) {
	var val float64
	for i, ch := range s {
		if ch >= '0' && ch <= '9' || ch == '.' || ch == '-' {
			continue
		}
		s = s[:i]
		break
	}
	_, err := parseFloatHelper(s, &val)
	if err != nil {
		return 0, err
	}
	if len(a) > 0 {
		if f, ok := a[0].(*float64); ok {
			*f = val
		}
	}
	return 1, nil
}

func parseFloatHelper(s string, f *float64) (int, error) {
	var val float64
	negative := false
	decimal := false
	decimalPlace := 1.0

	for _, ch := range s {
		if ch == '-' {
			negative = true
		} else if ch == '.' {
			decimal = true
		} else if ch >= '0' && ch <= '9' {
			if decimal {
				decimalPlace *= 10
				val += float64(ch-'0') / decimalPlace
			} else {
				val = val*10 + float64(ch-'0')
			}
		}
	}

	if negative {
		val = -val
	}
	*f = val
	return 1, nil
}
