# AWS CLI scripts (eu-west-3)

## Prerequisites
- AWS CLI configured (`aws sts get-caller-identity` works)
- Key pair already created in eu-west-3
- `bash` and `jq` installed locally (`brew install jq` if missing)

## Execution order
1. `01_budget_and_tags.sh`  
   Creates/updates SNS + Budget alerts.
2. `01a_identity_iam_setup.sh`  
   Configures IAM hardening baseline (password policy, deploy group/policy, EC2 role/profile).
3. `02a_create_vpc_private_network.sh` *(optional but recommended)*  
   Creates dedicated VPC with public/private subnets, IGW, NAT Gateway, and route tables.
4. `02_create_ec2_topology.sh`  
   Creates SGs and launches service hosts (public mode by default, private mode when `network.env` exists).
5. `03a_api_gateway_setup.sh`  
   Creates HTTP API Gateway routes across EC2 services (`/api/*`, `/gov-feed/*`, `/health/*`).
   - Public mode: direct HTTP integrations to public EC2.
   - Private mode: VPC Link + internal NLB integrations.
6. `03_s3_cloudfront_setup.sh`  
   Creates private UI bucket + OAC + CloudFront distribution (`/api/*` to API Gateway if configured).
7. `04_cloudwatch_setup.sh`  
   Creates dashboard and instance alarms.
8. `05_daily_cleanup.sh`  
   Dry-run by default; pass `APPLY=true` to apply stop/cleanup actions.
9. `06_waf_setup.sh`  
   Creates AWS WAF Web ACL and associates it with CloudFront.

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
- `PRIVATE_NETWORK_MODE` (`true` automatically when `02a_create_vpc_private_network.sh` is used)
- `VPC_CIDR`, `PUBLIC_SUBNET_CIDR`, `PRIVATE_SUBNET_A_CIDR`, `PRIVATE_SUBNET_B_CIDR` (private network tuning)
- `DEPLOY_USER_NAME`, `DEPLOY_GROUP_NAME`, `DEPLOY_POLICY_NAME` (IAM baseline)
- `WEB_ACL_NAME`, `RATE_LIMIT` (WAF tuning)

## Script outputs
- `./.state/network.env` with VPC/NAT/subnet IDs (private mode)
- `./.state/iam.env` with IAM artifact names/ARNs
- `./.state/ec2.env` with instance IDs and routing metadata (public DNS or bastion/private IP + NLB/VPC Link fields)
