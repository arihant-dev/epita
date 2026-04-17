#!/usr/bin/env bash
set -euo pipefail

REGION="eu-west-3"

echo "Create CloudWatch dashboard and alarms for:"
echo "- EC2 CPUUtilization"
echo "- API 5xx (custom metric/log filter)"
echo "- service health endpoint failures"
echo "Region: ${REGION}"
