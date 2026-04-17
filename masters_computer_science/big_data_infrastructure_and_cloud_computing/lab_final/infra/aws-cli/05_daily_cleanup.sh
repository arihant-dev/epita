#!/usr/bin/env bash
set -euo pipefail

REGION="${REGION:-eu-west-3}"
PROJECT_TAG="${PROJECT_TAG:-UrbanMove-FinalLab}"
APPLY="${APPLY:-false}"

echo "Region: ${REGION}"
echo "Project tag: ${PROJECT_TAG}"
echo "APPLY=${APPLY}"

INSTANCE_IDS="$(aws ec2 describe-instances \
  --region "${REGION}" \
  --filters "Name=tag:Project,Values=${PROJECT_TAG}" "Name=instance-state-name,Values=running,stopped" \
  --query 'Reservations[].Instances[].InstanceId' \
  --output text)"

VOLUME_IDS="$(aws ec2 describe-volumes \
  --region "${REGION}" \
  --filters "Name=status,Values=available" "Name=tag:Project,Values=${PROJECT_TAG}" \
  --query 'Volumes[].VolumeId' \
  --output text)"

EIP_ALLOCS="$(aws ec2 describe-addresses \
  --region "${REGION}" \
  --query "Addresses[?AssociationId==null].[AllocationId]" \
  --output text)"

echo "Instances (tagged): ${INSTANCE_IDS:-none}"
echo "Unattached tagged volumes: ${VOLUME_IDS:-none}"
echo "Unassociated EIPs: ${EIP_ALLOCS:-none}"

if [[ "${APPLY}" != "true" ]]; then
  echo "Dry run complete. Re-run with APPLY=true to stop/release."
  exit 0
fi

if [[ -n "${INSTANCE_IDS}" ]]; then
  aws ec2 stop-instances --region "${REGION}" --instance-ids ${INSTANCE_IDS} >/dev/null || true
fi

if [[ -n "${VOLUME_IDS}" ]]; then
  for vol in ${VOLUME_IDS}; do
    aws ec2 delete-volume --region "${REGION}" --volume-id "${vol}" >/dev/null || true
  done
fi

if [[ -n "${EIP_ALLOCS}" ]]; then
  for alloc in ${EIP_ALLOCS}; do
    aws ec2 release-address --region "${REGION}" --allocation-id "${alloc}" >/dev/null || true
  done
fi

echo "Cleanup actions applied."
