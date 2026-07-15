package main

import (
	"fmt"
	"os"
)

func main() {
	file, err := os.Open("sample.xlsx")
	if err != nil {
		fmt.Println("Error opening file:", err)
	}
}
