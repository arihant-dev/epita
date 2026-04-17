#!/usr/bin/env bash
set -euo pipefail

REGION="eu-west-3"
PROJECT_TAG="UrbanMove-FinalLab"

echo "Daily manual cleanup checklist:"
echo "- stop non-required EC2"
echo "- remove unattached EBS volumes"
echo "- remove stale snapshots"
echo "- release unused Elastic IP"
echo "- review CloudWatch log retention"
echo "Scope by tag: ${PROJECT_TAG}, region: ${REGION}"
