# urbanmove-ingestion-routing

Go microservice for mobility event ingestion and route recommendation.

## Features
- gRPC:
  - `IngestEvent`
  - `GetCongestionSummary`
  - `GetBestRoute`
- HTTP mock government feed endpoint: `POST /gov-feed/events`
- Simulator fallback producer (enabled by default)
- NATS event bus
- Optional PostgreSQL persistence (`DATABASE_URL`)

## Run
```bash
docker compose -f deploy/docker-compose.infra.yml up -d
go mod tidy
export DATABASE_URL='postgres://urbanmove:urbanmove@localhost:5432/urbanmove?sslmode=disable'
go run ./cmd/urbanmove-ingestion-routing
```

Environment:
- `NATS_URL` (default `nats://localhost:4222`)
- `DATABASE_URL` (optional)
- `SIMULATOR_ENABLED=true|false`
- `SIMULATOR_INTERVAL_SECONDS=5`
