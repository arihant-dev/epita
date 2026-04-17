#!/usr/bin/env bash
set -euo pipefail

REGION="eu-west-3"
UI_BUCKET="${UI_BUCKET:-urbanmove-ui-private-bucket}"

echo "Create private S3 bucket for UI and configure CloudFront OAC."
echo "Configure CloudFront behaviors:"
echo "- default -> S3 UI origin"
echo "- /api/* -> EC2 API origin"
echo "Region: ${REGION}, Bucket: ${UI_BUCKET}"
