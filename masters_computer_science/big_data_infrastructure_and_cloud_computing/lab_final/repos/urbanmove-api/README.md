# urbanmove-api

Public API facade service.

## Endpoints
- `POST /api/v1/auth/login`
- `GET /api/v1/congestion?limit=5` (Bearer token)
- `GET /api/v1/routes/recommendation?origin=A&destination=B` (Bearer token)
- `POST /api/v1/routes/recommendation` with `{ "origin": "...", "destination": "..." }` (Bearer token)
- `POST /api/v1/events` (Bearer token, `admin`/`operator`)
- `GET /healthz`

Compatibility aliases are also available for routing setups that strip or keep prefixes:
- `/v1/*`
- `/api/*`
- unprefixed paths (`/auth/login`, `/congestion`, `/routes/recommendation`, `/events`)

## Run
```bash
go mod tidy
go run ./cmd/urbanmove-api
```

Environment:
- `AUTH_GRPC_ADDR` (default `localhost:50051`)
- `MOBILITY_GRPC_ADDR` (default `localhost:50052`)
