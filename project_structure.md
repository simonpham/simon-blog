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
- `internal/nowis`: Core application logic (gRPC Service).
  - `service`: Business logic layer (e.g., `nowis.go`).
  - `repository`: Data access layer (e.g., `nowis.go`).
  - `model`: Data models.
  - `util`: Internal utilities.
- `internal/gateway`: API Gateway (Gin).
  - `controller`: HTTP handlers (`auth.go`, `nowis.go`).
  - `model`: Request/Response models (`auth.go`, `post.go`).
  - `router`: Route definitions.
- `pkg`: Shared packages.
  - `interceptors`: gRPC interceptors (Auth, Validation).
  - `utils`: General utilities (JWT, Encryption, Validation, etc.).
  - `configs`: Configuration handling.
  - `db`: Database connection logic.
  - `network`: Network related code.

## Protobuf

Contains the gRPC service and message definitions:

- `protobuf/nowis`: `NowisService` and related messages.
- `protobuf/auth`: `AuthService` definitions (copied/synced from `sofluffy`).

## Packages (Dart/Flutter)

- `packages/core`: Core models and utilities.
  - `models`: Domain models (`AuthTokens`, `Post`, `User`, etc.).
- `packages/core_remote_data`: Abstract interfaces for data access.
  - `interfaces`: Repository interfaces (`AuthApis`, `PostApis`, `UserApis`).
- `packages/core_remote_data_pb`: Implementation of interfaces using gRPC and REST.
  - `services`: Service implementations (`grpc.dart`, `rest.dart`).
  - `generated`: Generated Protobuf Dart code.

## Key Observations

- **Authentication**: Uses JWT. `AuthService` (external) for login, `AuthInterceptor` in `nowis` for verification.
- **Database**: Likely handled in `internal/nowis/repository`.
- **API**:
  - Internal: gRPC.
  - External/Browser: REST via API Gateway (Gin) which proxies to gRPC.
