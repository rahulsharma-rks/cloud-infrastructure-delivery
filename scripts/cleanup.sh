#!/usr/bin/env bash
set -euo pipefail
REGION="${AWS_REGION:-ap-south-1}"
STACK="${STACK_NAME:-cfn-platform-dev}"
echo "About to delete application stack: $STACK in $REGION"
read -r -p "Type DELETE to continue: " CONFIRM
[[ "$CONFIRM" == "DELETE" ]] || { echo 'Cancelled'; exit 1; }
aws cloudformation delete-stack --stack-name "$STACK" --region "$REGION"
aws cloudformation wait stack-delete-complete --stack-name "$STACK" --region "$REGION"
echo 'Application stack deleted. Check for residual NAT Gateway, EIP, ENIs, log groups, and S3 artifacts.'
