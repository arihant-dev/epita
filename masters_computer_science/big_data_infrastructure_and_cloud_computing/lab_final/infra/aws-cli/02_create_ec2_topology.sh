#!/usr/bin/env bash
set -euo pipefail

REGION="eu-west-3"
AMI_ID="${AMI_ID:-ami-xxxxxxxxxxxxxxxxx}"
KEY_NAME="${KEY_NAME:-urbanmove-key}"
INSTANCE_TYPE="t3.micro"

echo "Create three EC2 instances:"
echo "1) urbanmove-api-ec2"
echo "2) urbanmove-auth-ec2"
echo "3) urbanmove-ingest-ec2"
echo "Set SG rules so only API can call AUTH/INGEST gRPC ports."
echo "Fill AMI_ID before running real create commands."
echo "Region: ${REGION}, Type: ${INSTANCE_TYPE}, Key: ${KEY_NAME}"
