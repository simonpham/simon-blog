# Project Rules & Guidelines

This document outlines the architectural decisions, conventions, and guidelines for the `simon` project.

## Architecture

### API Gateway Pattern
- **Gateway**: The `simon` server (`server/nowis`) acts as an API Gateway using the Gin framework.
- **Internal Services**: Business logic is implemented in gRPC services.
- **Communication**: The Gateway proxies HTTP requests to internal gRPC services.
- **Public Access**: Browser and external clients communicate with the Gateway via REST (JSON). Internal services communicate via gRPC.

### Authentication
- **Service**: Authentication is handled by the external `sofluffy` `AuthService`.
- **Mechanism**: JWT (JSON Web Tokens) are used for authentication.
- **Flow**:
    1.  Client sends credentials to Gateway (`POST /v1/auth`).
    2.  Gateway calls `AuthService` (gRPC) to validate credentials and get tokens.
    3.  Gateway returns tokens to client.
    4.  For protected routes, Client sends JWT in `Authorization` header.
    5.  Gateway extracts JWT and forwards it in gRPC metadata (`authorization` key).
    6.  Internal services use `AuthInterceptor` to verify the token and extract `userID`.

## Dart Client (`packages`)

### Structure
- **`core`**: Contains pure domain models (e.g., `AuthTokens`, `Post`, `User`).
- **`core_remote_data`**: Defines abstract interfaces for data access (e.g., `AuthApis`, `PostApis`).
    - **Rule**: Separate interfaces by domain (e.g., `AuthApis` is separate from `UserApis`).
- **`core_remote_data_pb`**: Implements interfaces using specific protocols.
    - **`services/rest.dart`**: REST implementations (consume Gateway APIs).
    - **`services/grpc.dart`**: gRPC implementations (consume gRPC services directly, mostly for internal/admin tools or server-to-server).

### Conventions
- **Naming**: Use `Auth` instead of `Login` for services and models (e.g., `AuthRequestBody`, `AuthResponse`, `AuthApis`).
- **IDs**: User IDs are `UUID` strings, not integers.
- **Imports**: Use `package:` imports.

## Protobuf
- **Location**: `protobuf/nowis` (main service), `protobuf/auth` (synced from `sofluffy`).
- **Generation**: Run `scripts/pbgen.sh` to generate Go and Dart code.
- **Dart Exports**: Generated Dart files are exported via `packages/core_remote_data_pb/lib/core_remote_data_pb.dart`.

## Testing
- **Dart Tests**: Located in `packages/core_remote_data_pb/test`.
- **Mocking**: Mocks are available in `modules/simon/lib/content/mock.dart`.
- **Integration**: When testing against the Gateway, use the REST client implementation (`RestNowis...`).

## Development Workflow
1.  **Modify Proto**: Update `.proto` files in `protobuf/`.
2.  **Generate**: Run `./scripts/pbgen.sh`.
3.  **Implement Server**: Update Go server (`internal/nowis` and `internal/gateway`).
4.  **Implement Client**: Update Dart interfaces (`core_remote_data`) and implementations (`core_remote_data_pb`).
5.  **Verify**: Run tests and `dart analyze`.

## Version Control (Git)
- **Commit Style**: Use emoji prefixes for commit messages (e.g., ✨ for features, 🐛 for fixes, ♻️ for refactoring, 🔥 for removals).
- **Consistency**: Check previous commits (`git log`) to match the existing style.
- **Granularity**: Keep commits separate and atomic; avoid `git add .`.
