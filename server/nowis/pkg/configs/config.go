package configs

import (
	"github.com/caarlos0/env/v8"
	"log"
)

type Config struct {
	// =========================== GENERAL SETTINGS ==================================== //
	Env string `env:"ENV" envDefault:"debug"`
	// ================================================================================= //

	// =========================== AUTHENTICATION SETTINGS ============================= //
	AuthPublicAddress    string `env:"SF_AUTH_PUBLIC_ADDRESS" envDefault:"localhost:8081"`
	AuthInternalAddress  string `env:"SF_AUTH_INTERNAL_ADDRESS" envDefault:"localhost:8081"`
	AuthDatabaseUser     string `env:"SF_AUTH_DATABASE_USER" envDefault:"postgres"`
	AuthDatabasePassword string `env:"SF_AUTH_DATABASE_PASSWORD" envDefault:"postgres"`
	AuthDatabaseName     string `env:"SF_AUTH_DATABASE_NAME" envDefault:"auth"`
	AuthDatabaseHost     string `env:"SF_AUTH_DATABASE_HOST" envDefault:"localhost"`
	AuthTokenExpiration  int    `env:"SF_AUTH_TOKEN_EXPIRATION" envDefault:"24"`
	AuthTokenSigningKey  string `env:"SF_AUTH_TOKEN_SIGNING_KEY" envDefault:"hehewhy"`
	// ================================================================================= //

	// ================================ NOWIS SETTINGS ================================= //
	NowisPublicAddress   string `env:"SF_NOWIS_PUBLIC_ADDRESS" envDefault:"localhost:8085"`
	NowisInternalAddress string `env:"SF_NOWIS_INTERNAL_ADDRESS" envDefault:"localhost:8085"`
	// ================================================================================= //
}

func GetConfig() Config {
	config := Config{}

	err := env.Parse(&config)
	if err != nil {
		log.Fatalf("Error parsing config: %v", err)
	}

	return config
}
