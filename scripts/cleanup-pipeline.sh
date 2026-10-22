#!/usr/bin/env bash
set -euo pipefail
REGION="${AWS_REGION:-ap-south-1}"
STACK="${PIPELINE_STACK_NAME:-cfn-platform-pipeline}"

read -r -p "This deletes pipeline infrastructure and all versions in its two retained buckets. Type DELETE to continue: " CONFIRM
[[ "$CONFIRM" == "DELETE" ]] || { echo 'Cancelled'; exit 1; }

ARTIFACT_BUCKET="$(aws cloudformation describe-stacks --stack-name "$STACK" --region "$REGION" --query "Stacks[0].Outputs[?OutputKey=='ArtifactBucketName'].OutputValue" --output text)"
TEMPLATE_BUCKET="$(aws cloudformation describe-stacks --stack-name "$STACK" --region "$REGION" --query "Stacks[0].Outputs[?OutputKey=='TemplateBucketName'].OutputValue" --output text)"
export ARTIFACT_BUCKET TEMPLATE_BUCKET AWS_REGION="$REGION"
python3 - <<'PY'
import os
import boto3

s3 = boto3.client("s3", region_name=os.environ["AWS_REGION"])
for bucket in (os.environ["ARTIFACT_BUCKET"], os.environ["TEMPLATE_BUCKET"]):
    paginator = s3.get_paginator("list_object_versions")
    for page in paginator.paginate(Bucket=bucket):
        objects = [
            {"Key": x["Key"], "VersionId": x["VersionId"]}
            for x in page.get("Versions", [])
        ]
        objects += [
            {"Key": x["Key"], "VersionId": x["VersionId"]}
            for x in page.get("DeleteMarkers", [])
        ]
        for start in range(0, len(objects), 1000):
            batch = objects[start:start + 1000]
            if batch:
                result = s3.delete_objects(
                    Bucket=bucket,
                    Delete={"Objects": batch, "Quiet": True},
                )
                if result.get("Errors"):
                    raise RuntimeError(result["Errors"])
    print(f"Emptied bucket versions: {bucket}")
PY

aws cloudformation delete-stack --stack-name "$STACK" --region "$REGION"
aws cloudformation wait stack-delete-complete --stack-name "$STACK" --region "$REGION"
echo 'Pipeline stack deleted. Verify CodeBuild log groups and all remaining billable resources.'
