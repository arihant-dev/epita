#!/usr/bin/env bash
set -euo pipefail

REGION="${REGION:-eu-west-3}"
PROJECT_TAG="${PROJECT_TAG:-UrbanMove-FinalLab}"
DEPLOY_GROUP_NAME="${DEPLOY_GROUP_NAME:-urbanmove-deployers}"
DEPLOY_POLICY_NAME="${DEPLOY_POLICY_NAME:-urbanmove-final-lab-deploy-policy}"
DEPLOY_USER_NAME="${DEPLOY_USER_NAME:-}"
EC2_ROLE_NAME="${EC2_ROLE_NAME:-urbanmove-ec2-role}"
EC2_INSTANCE_PROFILE_NAME="${EC2_INSTANCE_PROFILE_NAME:-urbanmove-ec2-instance-profile}"
ENFORCE_PASSWORD_POLICY="${ENFORCE_PASSWORD_POLICY:-true}"
STATE_DIR="$(cd "$(dirname "$0")" && pwd)/.state"
STATE_FILE="${STATE_DIR}/iam.env"
mkdir -p "${STATE_DIR}"

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
PARTITION="$(aws sts get-caller-identity --query Arn --output text | awk -F: '{print $2}')"
if [[ -z "${PARTITION}" ]]; then
  PARTITION="aws"
fi

if [[ "${ENFORCE_PASSWORD_POLICY}" == "true" ]]; then
  aws iam update-account-password-policy \
    --minimum-password-length 14 \
    --require-symbols \
    --require-numbers \
    --require-uppercase-characters \
    --require-lowercase-characters \
    --allow-users-to-change-password \
    --max-password-age 90 \
    --password-reuse-prevention 24 \
    --hard-expiry >/dev/null
fi

cat > "${STATE_DIR}/deploy-policy.json" <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "UrbanMoveInfraManagement",
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "elasticloadbalancing:*",
        "apigateway:*",
        "apigatewayv2:*",
        "cloudfront:*",
        "wafv2:*",
        "cloudwatch:*",
        "logs:*",
        "sns:*",
        "budgets:*",
        "s3:*",
        "ssm:GetParameter",
        "iam:Get*",
        "iam:List*",
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:CreateInstanceProfile",
        "iam:DeleteInstanceProfile",
        "iam:AddRoleToInstanceProfile",
        "iam:RemoveRoleFromInstanceProfile",
        "iam:PassRole",
        "iam:CreatePolicy",
        "iam:CreatePolicyVersion",
        "iam:DeletePolicyVersion",
        "iam:DeletePolicy",
        "iam:CreateGroup",
        "iam:DeleteGroup",
        "iam:AttachGroupPolicy",
        "iam:DetachGroupPolicy",
        "iam:AddUserToGroup",
        "iam:RemoveUserFromGroup",
        "iam:CreateUser",
        "iam:DeleteUser",
        "iam:Tag*",
        "iam:UpdateAccountPasswordPolicy"
      ],
      "Resource": "*"
    }
  ]
}
JSON

DEPLOY_POLICY_ARN="$(aws iam list-policies --scope Local --query "Policies[?PolicyName=='${DEPLOY_POLICY_NAME}'].Arn | [0]" --output text)"
if [[ -z "${DEPLOY_POLICY_ARN}" || "${DEPLOY_POLICY_ARN}" == "None" ]]; then
  DEPLOY_POLICY_ARN="$(aws iam create-policy \
    --policy-name "${DEPLOY_POLICY_NAME}" \
    --policy-document "file://${STATE_DIR}/deploy-policy.json" \
    --query 'Policy.Arn' \
    --output text)"
else
  NONDEFAULT_VERSION_ID="$(aws iam list-policy-versions \
    --policy-arn "${DEPLOY_POLICY_ARN}" \
    --query 'Versions[?IsDefaultVersion==`false`] | sort_by(@,&CreateDate)[0].VersionId' \
    --output text)"
  VERSION_COUNT="$(aws iam list-policy-versions --policy-arn "${DEPLOY_POLICY_ARN}" --query 'length(Versions)' --output text)"
  if [[ "${VERSION_COUNT}" -ge 5 && -n "${NONDEFAULT_VERSION_ID}" && "${NONDEFAULT_VERSION_ID}" != "None" ]]; then
    aws iam delete-policy-version --policy-arn "${DEPLOY_POLICY_ARN}" --version-id "${NONDEFAULT_VERSION_ID}" >/dev/null
  fi
  aws iam create-policy-version \
    --policy-arn "${DEPLOY_POLICY_ARN}" \
    --policy-document "file://${STATE_DIR}/deploy-policy.json" \
    --set-as-default \
    --query 'PolicyVersion.VersionId' \
    --output text >/dev/null
fi

aws iam get-group --group-name "${DEPLOY_GROUP_NAME}" >/dev/null 2>&1 || aws iam create-group --group-name "${DEPLOY_GROUP_NAME}" >/dev/null
aws iam attach-group-policy --group-name "${DEPLOY_GROUP_NAME}" --policy-arn "${DEPLOY_POLICY_ARN}" >/dev/null 2>&1 || true

if [[ -n "${DEPLOY_USER_NAME}" ]]; then
  aws iam get-user --user-name "${DEPLOY_USER_NAME}" >/dev/null 2>&1 || aws iam create-user --user-name "${DEPLOY_USER_NAME}" >/dev/null
  aws iam add-user-to-group --group-name "${DEPLOY_GROUP_NAME}" --user-name "${DEPLOY_USER_NAME}" >/dev/null 2>&1 || true
fi

cat > "${STATE_DIR}/ec2-role-trust.json" <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}
JSON

aws iam get-role --role-name "${EC2_ROLE_NAME}" >/dev/null 2>&1 || aws iam create-role \
  --role-name "${EC2_ROLE_NAME}" \
  --assume-role-policy-document "file://${STATE_DIR}/ec2-role-trust.json" \
  --tags "Key=Project,Value=${PROJECT_TAG}" >/dev/null

aws iam attach-role-policy --role-name "${EC2_ROLE_NAME}" --policy-arn "arn:${PARTITION}:iam::aws:policy/AmazonSSMManagedInstanceCore" >/dev/null 2>&1 || true
aws iam attach-role-policy --role-name "${EC2_ROLE_NAME}" --policy-arn "arn:${PARTITION}:iam::aws:policy/CloudWatchAgentServerPolicy" >/dev/null 2>&1 || true

aws iam get-instance-profile --instance-profile-name "${EC2_INSTANCE_PROFILE_NAME}" >/dev/null 2>&1 || aws iam create-instance-profile --instance-profile-name "${EC2_INSTANCE_PROFILE_NAME}" >/dev/null
aws iam add-role-to-instance-profile --instance-profile-name "${EC2_INSTANCE_PROFILE_NAME}" --role-name "${EC2_ROLE_NAME}" >/dev/null 2>&1 || true

cat > "${STATE_FILE}" <<EOF
ACCOUNT_ID=${ACCOUNT_ID}
PROJECT_TAG=${PROJECT_TAG}
DEPLOY_GROUP_NAME=${DEPLOY_GROUP_NAME}
DEPLOY_POLICY_NAME=${DEPLOY_POLICY_NAME}
DEPLOY_POLICY_ARN=${DEPLOY_POLICY_ARN}
DEPLOY_USER_NAME=${DEPLOY_USER_NAME}
EC2_ROLE_NAME=${EC2_ROLE_NAME}
EC2_INSTANCE_PROFILE_NAME=${EC2_INSTANCE_PROFILE_NAME}
EOF

echo "IAM baseline configured."
echo "Deploy group: ${DEPLOY_GROUP_NAME}"
echo "Deploy policy ARN: ${DEPLOY_POLICY_ARN}"
echo "EC2 role: ${EC2_ROLE_NAME}"
echo "EC2 instance profile: ${EC2_INSTANCE_PROFILE_NAME}"
if [[ -n "${DEPLOY_USER_NAME}" ]]; then
  echo "Deploy user in group: ${DEPLOY_USER_NAME}"
fi
if [[ "${ENFORCE_PASSWORD_POLICY}" == "true" ]]; then
  echo "Strong IAM account password policy is enforced."
fi
