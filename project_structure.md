# Project Structure

## Root Directory
- `apps`: Likely contains frontend applications.
- `modules`: Shared modules.
- `packages`: Dart packages (suggesting a Flutter/Dart context for some parts).
- `protobuf`: Protocol Buffer definitions for the API.
- `server/nowis`: The Go server implementation.

## Server (server/nowis)
The server is written in Go and follows a standard layout:

- `cmd/nowis`: Entry point for the application.
- `internal/nowis`: Core application logic.
    - `service`: Business logic layer (e.g., `nowis.go`).
    - `repository`: Data access layer (e.g., `nowis.go`).
    - `model`: Data models.
    - `util`: Internal utilities.
- `pkg`: Shared packages.
    - `interceptors`: gRPC interceptors (Auth, Validation).
    - `utils`: General utilities (JWT, Encryption, Validation, etc.).
    - `configs`: Configuration handling.
    - `db`: Database connection logic.
    - `network`: Network related code.

## Protobuf (protobuf/nowis)
Contains the gRPC service and message definitions:
- `nowis_service.proto`: The main service definition.
- Various message definitions like `post.proto`, `user.proto`, `create_post.proto`, etc.

## Key Observations
- **Authentication**: Uses JWT in `pkg/utils/jwt.go` and an Auth Interceptor in `pkg/interceptors/auth.go`.
- **Database**: Likely handled in `internal/nowis/repository`.
- **API**: gRPC based.
