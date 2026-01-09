package configs

import (
	"log"

	"github.com/caarlos0/env/v8"
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
	NowisPublicAddress           string `env:"SF_NOWIS_PUBLIC_ADDRESS" envDefault:"localhost:8085"`
	NowisInternalAddress         string `env:"SF_NOWIS_INTERNAL_ADDRESS" envDefault:"localhost:8085"`
	NowisEncryptionPassphrase    string `env:"SF_NOWIS_ENCRYPTION_PASSPHRASE" envDefault:"ThisIsMySuperSecretPublicPassphraseThatEveryoneKnows"`
	NowisEncryptionStaticSaltHex string `env:"SF_NOWIS_ENCRYPTION_STATIC_SALT_HEX" envDefault:"a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2"`
	// ================================================================================= //

	// ================================ SHARE SETTINGS ================================= //
	ShareInternalAddress string `env:"SF_SHARE_INTERNAL_ADDRESS" envDefault:"localhost:8085"`
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
