# urbanmove-auth

Go auth microservice.

## Features
- gRPC `IssueToken` and `ValidateToken`
- JWT role claims (`user`, `operator`, `admin`)
- `/healthz` endpoint

## Run
```bash
go mod tidy
go run ./cmd/urbanmove-auth
```

Default users:
- `user1 / user123`
- `operator1 / operator123`
- `admin1 / admin123`
