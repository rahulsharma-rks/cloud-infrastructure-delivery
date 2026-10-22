#!/usr/bin/env bash
set -euo pipefail
cfn-lint templates/*.yaml
for f in templates/*.yaml; do
  aws cloudformation validate-template --template-body "file://$f" --region "${AWS_REGION:-ap-south-1}" >/dev/null
done
python3 -m json.tool parameters/dev.json >/dev/null
echo 'Local validation passed.'
