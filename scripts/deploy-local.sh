#!/usr/bin/env bash
set -euo pipefail
REGION="${AWS_REGION:-ap-south-1}"
BUCKET="${TEMPLATE_BUCKET:?Set TEMPLATE_BUCKET to a private S3 bucket in the same Region}"
STACK="${STACK_NAME:-cfn-platform-dev}"
aws cloudformation package --template-file templates/root.yaml --s3-bucket "$BUCKET" --s3-prefix packaged-templates --output-template-file /tmp/packaged-root.yaml --region "$REGION"
aws cloudformation deploy --template-file /tmp/packaged-root.yaml --stack-name "$STACK" --parameter-overrides file://parameters/dev.json --capabilities CAPABILITY_IAM --region "$REGION" --tags Project=cfn-platform Environment=dev ManagedBy=CloudFormation
aws cloudformation describe-stacks --stack-name "$STACK" --region "$REGION" --query 'Stacks[0].Outputs' --output table
