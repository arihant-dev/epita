#!/usr/bin/env bash
set -euo pipefail

REGION="${REGION:-eu-west-3}"
BUDGET_LIMIT_USD="${BUDGET_LIMIT_USD:-100}"
PROJECT_TAG="${PROJECT_TAG:-UrbanMove-FinalLab}"
ALERT_EMAIL="${ALERT_EMAIL:-}"
BUDGET_NAME="${BUDGET_NAME:-UrbanMoveFinalLabBudget}"
SNS_TOPIC_NAME="${SNS_TOPIC_NAME:-urbanmove-finallab-budget-alerts}"

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required. Install with: brew install jq"
  exit 1
fi

if [[ -z "${ALERT_EMAIL}" ]]; then
  echo "ALERT_EMAIL is required."
  echo "Example: ALERT_EMAIL=you@example.com ./01_budget_and_tags.sh"
  exit 1
fi

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
ARN="$(aws sts get-caller-identity --query Arn --output text)"
if [[ "${ARN}" == *":root" ]]; then
  echo "WARNING: You are using root credentials. Create a dedicated IAM deploy user after this lab."
fi

TOPIC_ARN="$(aws sns create-topic \
  --region "${REGION}" \
  --name "${SNS_TOPIC_NAME}" \
  --query TopicArn \
  --output text)"

aws sns subscribe \
  --region "${REGION}" \
  --topic-arn "${TOPIC_ARN}" \
  --protocol email \
  --notification-endpoint "${ALERT_EMAIL}" >/dev/null || true

BUDGET_JSON="$(cat <<JSON
{
  "BudgetName": "${BUDGET_NAME}",
  "BudgetLimit": {
    "Amount": "${BUDGET_LIMIT_USD}",
    "Unit": "USD"
  },
  "TimeUnit": "MONTHLY",
  "BudgetType": "COST"
}
JSON
)"

NOTIFICATION_JSON='{"NotificationType":"ACTUAL","ComparisonOperator":"GREATER_THAN","Threshold":50,"ThresholdType":"PERCENTAGE"}'
NOTIFICATION_JSON_75='{"NotificationType":"ACTUAL","ComparisonOperator":"GREATER_THAN","Threshold":75,"ThresholdType":"PERCENTAGE"}'
NOTIFICATION_JSON_90='{"NotificationType":"ACTUAL","ComparisonOperator":"GREATER_THAN","Threshold":90,"ThresholdType":"PERCENTAGE"}'
NOTIFICATION_JSON_100='{"NotificationType":"ACTUAL","ComparisonOperator":"GREATER_THAN","Threshold":100,"ThresholdType":"PERCENTAGE"}'
SUBSCRIBERS_JSON="[{\"SubscriptionType\":\"SNS\",\"Address\":\"${TOPIC_ARN}\"}]"

if aws budgets describe-budget --account-id "${ACCOUNT_ID}" --budget-name "${BUDGET_NAME}" >/dev/null 2>&1; then
  aws budgets update-budget --account-id "${ACCOUNT_ID}" --new-budget "${BUDGET_JSON}" >/dev/null
else
  aws budgets create-budget --account-id "${ACCOUNT_ID}" --budget "${BUDGET_JSON}" >/dev/null
fi

for n in "${NOTIFICATION_JSON}" "${NOTIFICATION_JSON_75}" "${NOTIFICATION_JSON_90}" "${NOTIFICATION_JSON_100}"; do
  aws budgets create-notification \
    --account-id "${ACCOUNT_ID}" \
    --budget-name "${BUDGET_NAME}" \
    --notification "${n}" \
    --subscribers "${SUBSCRIBERS_JSON}" >/dev/null || true
done

echo "Budget configured."
echo "Account: ${ACCOUNT_ID}"
echo "Budget: ${BUDGET_NAME} (${BUDGET_LIMIT_USD} USD)"
echo "SNS topic: ${TOPIC_ARN}"
echo "Project tag for all resources: ${PROJECT_TAG}"
