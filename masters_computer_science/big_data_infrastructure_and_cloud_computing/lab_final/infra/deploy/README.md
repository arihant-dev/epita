# Deployment steps (Phase C)

## Frontend location
- `lab_final/frontend/static/index.html`
- `lab_final/frontend/static/login.html`
- `lab_final/frontend/static/operations.html`
- `lab_final/frontend/static/admin.html`
- `lab_final/frontend/static/app.js`
- `lab_final/frontend/static/styles.css`

## Prerequisites
1. AWS infra already created (`infra/aws-cli/*.sh` done).
   - Recommended secure flow:
     1. `infra/aws-cli/01a_identity_iam_setup.sh`
     2. `infra/aws-cli/02a_create_vpc_private_network.sh`
     3. `infra/aws-cli/02_create_ec2_topology.sh`
     4. `infra/aws-cli/03a_api_gateway_setup.sh`
     5. `infra/aws-cli/03_s3_cloudfront_setup.sh`
     6. `infra/aws-cli/06_waf_setup.sh`
   - Recommended: run `infra/aws-cli/03a_api_gateway_setup.sh` before CloudFront setup so `/api/*` uses API Gateway origin.
2. State file exists: `infra/aws-cli/.state/ec2.env`.
3. Private key available at `~/.ssh/aws_ec2_key.pem` (or set `KEY_PATH`).
4. Go toolchain available locally for building binaries.

## Deploy order
```bash
cd lab_final/infra/deploy

./01_bootstrap_hosts.sh
./02_deploy_auth.sh
./03_deploy_ingest.sh
./04_deploy_api.sh
./05_upload_frontend.sh
./06_smoke_test.sh
```

In private-network mode, deploy scripts automatically tunnel through bastion via SSH `ProxyJump` using values in `infra/aws-cli/.state/ec2.env`.

## Optional env overrides
- `KEY_PATH=/path/to/key.pem`
- `SSH_USER=ubuntu`
- `JWT_SECRET=...` (for auth deployment)
