package app

import (
	"log"
	"net/http"

	"github.com/mark3labs/mcp-go/server"

	"github.com/yourname/my-mcp-server/internal/config"
	"github.com/yourname/my-mcp-server/internal/httpauth"
	"github.com/yourname/my-mcp-server/internal/tools"
)

func Run(cfg config.Config) error {
	mcpServer := server.NewMCPServer(cfg.ServerName, cfg.ServerVer)
	tools.Register(mcpServer)

	httpServer := server.NewStreamableHTTPServer(mcpServer)
	handler := httpauth.Middleware(cfg.AuthToken)(httpServer)

	log.Printf("Listening on %s", cfg.Address)
	return http.ListenAndServe(cfg.Address, handler)
}
