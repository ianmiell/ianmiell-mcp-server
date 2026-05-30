package main

import (
	"log"

	"github.com/yourname/my-mcp-server/internal/app"
	"github.com/yourname/my-mcp-server/internal/config"
)

func main() {
	cfg := config.Load()
	if err := app.Run(cfg); err != nil {
		log.Fatal(err)
	}
}
