#!/usr/bin/env bash
set -euo pipefail

REGION="${REGION:-eu-west-3}"
STATE_DIR="$(cd "$(dirname "$0")" && pwd)/.state"

if [[ ! -f "${STATE_DIR}/ec2.env" ]]; then
  echo "Missing ${STATE_DIR}/ec2.env. Run 02_create_ec2_topology.sh first."
  exit 1
fi

# shellcheck source=/dev/null
source "${STATE_DIR}/ec2.env"

DASHBOARD_NAME="${DASHBOARD_NAME:-UrbanMoveFinalLabDashboard}"

cat > "${STATE_DIR}/dashboard-body.json" <<JSON
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "title": "EC2 CPU Utilization (%)",
        "region": "${REGION}",
        "metrics": [
          ["AWS/EC2", "CPUUtilization", "InstanceId", "${API_INSTANCE_ID}"],
          [".", ".", ".", "${AUTH_INSTANCE_ID}"],
          [".", ".", ".", "${INGEST_INSTANCE_ID}"]
        ],
        "stat": "Average",
        "period": 300
      }
    },
    {
      "type": "metric",
      "x": 12,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "title": "EC2 Status Check Failed",
        "region": "${REGION}",
        "metrics": [
          ["AWS/EC2", "StatusCheckFailed", "InstanceId", "${API_INSTANCE_ID}"],
          [".", ".", ".", "${AUTH_INSTANCE_ID}"],
          [".", ".", ".", "${INGEST_INSTANCE_ID}"]
        ],
        "stat": "Maximum",
        "period": 60
      }
    }
  ]
}
JSON

aws cloudwatch put-dashboard \
  --region "${REGION}" \
  --dashboard-name "${DASHBOARD_NAME}" \
  --dashboard-body file://"${STATE_DIR}/dashboard-body.json" >/dev/null

create_cpu_alarm() {
  local instance_id="$1"
  local alarm_name="$2"
  aws cloudwatch put-metric-alarm \
    --region "${REGION}" \
    --alarm-name "${alarm_name}" \
    --metric-name CPUUtilization \
    --namespace AWS/EC2 \
    --statistic Average \
    --period 300 \
    --threshold 75 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 2 \
    --dimensions Name=InstanceId,Value="${instance_id}" \
    --treat-missing-data notBreaching >/dev/null
}

create_cpu_alarm "${API_INSTANCE_ID}" "urbanmove-api-cpu-high"
create_cpu_alarm "${AUTH_INSTANCE_ID}" "urbanmove-auth-cpu-high"
create_cpu_alarm "${INGEST_INSTANCE_ID}" "urbanmove-ingest-cpu-high"

echo "CloudWatch dashboard and alarms created."
echo "Dashboard name: ${DASHBOARD_NAME}"
