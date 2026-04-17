# Final Lab Plan — UrbanMove Smart Mobility (3 EC2 / 3 Repos)

## 1) Objective
Deliver all required final project artifacts with a working prototype:
- Architecture diagram
- Implementation report (PDF)
- Source code repositories
- Deployment evidence / demo
- Presentation slides support

Budget guardrail: keep projected spend under **$50** for the lab run.

## 2) Locked decisions
- Domain: UrbanMove smart mobility
- Main use-case: congestion monitoring + route recommendation
- Region: eu-west-3
- Repos: `urbanmove-api`, `urbanmove-auth`, `urbanmove-ingestion-routing`
- Inter-service RPC: gRPC + protobuf
- Messaging: NATS
- Ingestion: mock government transport API + simulator fallback
- UI: static HTML/JS on private S3 + CloudFront (OAC)
- Auth: JWT + role checks
- CI/CD: separate GitLab CI per repository

## 3) Runtime architecture (implemented)
## 3.1 EC2 layout (required)
1. **EC2-API** (`urbanmove-api`)
   - Public entry for REST endpoints (fronted by CloudFront `/api/*`)
   - Calls auth and ingestion-routing via gRPC
2. **EC2-AUTH** (`urbanmove-auth`)
   - JWT issue/validate/refresh
   - gRPC auth service
3. **EC2-INGEST** (`urbanmove-ingestion-routing` + PostgreSQL + NATS)
   - mock government API feed
   - simulator fallback producer
   - route recommendation logic
   - event stream + persistence

## 3.2 Edge + static frontend
- CloudFront distribution:
  - origin A: private S3 bucket (frontend)
  - origin B: EC2-API (`/api/*`)

## 3.3 Security baseline
- Least-privilege IAM users/roles
- SG rules: allow only required service-to-service ports
- Private S3 bucket with OAC
- JWT auth and role-based route guards

## 4) Cost-control (mandatory first)
1. Create AWS Budget alerts (50/75/90/100% thresholds).
2. Tag every resource: `Project=UrbanMove-FinalLab`.
3. Use t3.micro only; no NAT Gateway, no EKS, no managed Kafka.
4. Short log retention (7 days).
5. Stop instances when not actively demoing.
6. End-of-day cleanup script for stale volumes/snapshots/EIPs.

## 5) Folder source-of-truth (this `lab_final/` directory)
- `architecture/` diagram source + exports
- `infra/aws-cli/` infrastructure scripts
- `repos/` per-service CI/deploy templates + proto contract
- `evidence/` screenshots, command outputs, demo artifacts
- `report/` LaTeX final report files/assets

## 6) Execution phases
## Phase A — AWS baseline
1. IAM deployment user + local AWS CLI profile
2. Budget + SNS email alerts
3. EC2 instances + SG topology
4. S3 buckets + CloudFront + OAC

## Phase B — Service implementation
1. Build `urbanmove-auth`
2. Build `urbanmove-ingestion-routing` (mock gov API + simulator + NATS + Postgres)
3. Build `urbanmove-api` (REST facade + gRPC clients)

## Phase C — Deploy and wire
1. Separate deploy script and GitLab CI in each repo
2. Deploy each service to its own EC2
3. Verify end-to-end flow via CloudFront URL

## Phase D — Observability + resilience evidence
1. CloudWatch metrics/logs dashboard
2. Security evidence screenshots
3. Backup/restore drill evidence

## Phase E — Final artifacts
1. Eraser diagram + PNG export
2. `report/lab_report_final.tex` + PDF
3. Evidence mapping table (requirement -> screenshot/output)
4. Slide outline for presentation handoff

## 7) Assignment mapping checklist
- Functional requirements: ingestion, user service, storage, analytics, auth, monitoring
- Non-functional requirements: scalability, availability approach, security, cost, DR
- Submission package: diagram + report + repos + demo evidence + slides
