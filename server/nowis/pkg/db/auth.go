package db

import (
	"database/sql"
	"log"
	"nowis/pkg/configs"
)

func OpenAuthDatabase() (*sql.DB, error) {
	config := configs.GetConfig()

	connStr := "user=" + config.AuthDatabaseUser + " "
	connStr += "password=" + config.AuthDatabasePassword + " "
	connStr += "dbname=" + config.AuthDatabaseName + " "
	connStr += "host=" + config.AuthDatabaseHost + " "
	connStr += "sslmode=verify-full"

	db, err := OpenDbConnection(connStr)

	if err != nil {
		log.Fatalf("[OpenUserTable] Error opening database: %v", err)
		return nil, err
	}

	return db, nil
}
