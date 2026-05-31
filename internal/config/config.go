package config

import "os"

const (
	defaultAddress = ":9482"
	defaultToken   = "secret123"
	defaultName    = "Demo Server"
	defaultVersion = "1.0.0"
)

// Config contains runtime configuration for the server.
type Config struct {
	Address    string
	AuthToken  string
	ServerName string
	ServerVer  string
}

func Load() Config {
	return Config{
		Address:    getEnv("MCP_ADDRESS", defaultAddress),
		AuthToken:  getEnv("MCP_AUTH_TOKEN", defaultToken),
		ServerName: getEnv("MCP_SERVER_NAME", defaultName),
		ServerVer:  getEnv("MCP_SERVER_VERSION", defaultVersion),
	}
}

func getEnv(key, fallback string) string {
	v := os.Getenv(key)
	if v == "" {
		return fallback
	}
	return v
}
