#!/usr/bin/env bash
set -euo pipefail
REGION="${AWS_DEFAULT_REGION:-ap-south-1}"
STACK_NAME="${STACK_NAME:-cfn-platform-dev}"
URL="$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --region "$REGION" --query "Stacks[0].Outputs[?OutputKey=='ApplicationURL'].OutputValue" --output text)"
for attempt in $(seq 1 24); do
  if curl --fail --silent --max-time 5 "$URL" | grep -q 'Production-style CloudFormation deployment successful'; then
    echo "PASS: $URL"; exit 0
  fi
  echo "Waiting for target health ($attempt/24)"; sleep 10
done
echo "FAIL: application did not return expected content" >&2
exit 1
