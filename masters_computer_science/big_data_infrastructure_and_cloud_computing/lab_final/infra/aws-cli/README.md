# AWS CLI scripts (eu-west-3)

## Prerequisites
- AWS CLI configured (`aws sts get-caller-identity` works)
- Key pair already created in eu-west-3
- Default VPC available (scripts use default VPC/subnet)
- `bash` and `jq` installed locally (`brew install jq` if missing)

## Execution order
1. `01_budget_and_tags.sh`  
   Creates/updates SNS + Budget alerts.
2. `02_create_ec2_topology.sh`  
   Creates SGs and launches 3 EC2 instances (api/auth/ingest).
3. `03a_api_gateway_setup.sh`  
   Creates HTTP API Gateway routes across EC2 services (`/api/*`, `/gov-feed/*`, `/health/*`).
4. `03_s3_cloudfront_setup.sh`  
   Creates private UI bucket + OAC + CloudFront distribution (`/api/*` to API Gateway if configured).
5. `04_cloudwatch_setup.sh`  
   Creates dashboard and instance alarms.
6. `05_daily_cleanup.sh`  
   Dry-run by default; pass `APPLY=true` to apply stop/cleanup actions.

## Environment variables
- `REGION` (default: `eu-west-3`)
- `PROJECT_TAG` (default: `UrbanMove-FinalLab`)
- `ALERT_EMAIL` (required for budget SNS subscription)
- `BUDGET_LIMIT_USD` (default: `100`)
- `KEY_NAME` (required before EC2 creation)
- `AMI_ID` (optional, default Ubuntu 22.04 eu-west-3 public AMI)
- `ADMIN_CIDR` (default: your current public IP `/32`)
- `EXPOSE_SERVICE_HTTP_FOR_APIGW` (default: `true`, opens demo HTTP ports 8081/8082 for API Gateway routing)
- `API_HTTP_API_NAME` (default: `urbanmove-routing-http-api`)
- `API_PUBLIC_DNS` (fallback CloudFront `/api/*` origin when API Gateway is not configured)
- `API_GW_ENDPOINT` (used by CloudFront `/api/*` origin when present)

## Script outputs
- `./.state/ec2.env` with instance IDs and public DNS values.
