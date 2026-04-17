#!/usr/bin/env bash
set -euo pipefail

REGION="eu-west-3"
BUDGET_LIMIT_USD="40"
PROJECT_TAG="UrbanMove-FinalLab"

echo "Create/verify budget alert manually once in Billing console if API permissions are missing."
echo "Region: ${REGION}"
echo "Project tag: ${PROJECT_TAG}"
echo "Budget limit: ${BUDGET_LIMIT_USD} USD"
