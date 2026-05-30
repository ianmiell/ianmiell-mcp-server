package tools

import (
	"context"

	"github.com/mark3labs/mcp-go/mcp"
	"github.com/mark3labs/mcp-go/server"
)

func Register(s *server.MCPServer) {
	helloTool := mcp.NewTool(
		"hello",
		mcp.WithDescription("Say hello"),
		mcp.WithString("name", mcp.Required()),
	)

	s.AddTool(helloTool, func(ctx context.Context, req mcp.CallToolRequest) (*mcp.CallToolResult, error) {
		name := req.GetString("name", "world")
		return mcp.NewToolResultText("Hello " + name), nil
	})
}
