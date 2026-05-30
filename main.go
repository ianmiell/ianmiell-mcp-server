package main

import (
	"context"
	"log"
	"net/http"

	"github.com/mark3labs/mcp-go/mcp"
	"github.com/mark3labs/mcp-go/server"
)

func auth(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Header.Get("Authorization") !=
			"Bearer secret123" {
			http.Error(w, "unauthorized", 401)
			return
		}

		next.ServeHTTP(w, r)
	})
}

func main() {
	s := server.NewMCPServer(
		"Demo Server",
		"1.0.0",
	)

	tool := mcp.NewTool(
		"hello",
		mcp.WithDescription("Say hello"),
		mcp.WithString("name",
			mcp.Required(),
		),
	)

	s.AddTool(tool, func(
		ctx context.Context,
		req mcp.CallToolRequest,
	) (*mcp.CallToolResult, error) {

		name := req.GetString("name", "world")

		return mcp.NewToolResultText(
			"Hello "+name,
		), nil
	})

	httpServer := server.NewStreamableHTTPServer(s)

	log.Println("Listening on :8080")

	log.Fatal(http.ListenAndServe(
		":8080",
		auth(httpServer),
	))
}
