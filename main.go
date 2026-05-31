package main

import (
	"log"

	"github.com/ianmiell/ianmiell-mcp-server/internal/app"
	"github.com/ianmiell/ianmiell-mcp-server/internal/config"
)

func main() {
	cfg := config.Load()
	if err := app.Run(cfg); err != nil {
		log.Fatal(err)
	}
}
