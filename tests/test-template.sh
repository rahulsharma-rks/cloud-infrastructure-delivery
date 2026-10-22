#!/usr/bin/env bash
set -euo pipefail
cfn-lint templates/*.yaml
python3 -m json.tool parameters/dev.json >/dev/null
grep -q 'HttpTokens: required' templates/application.yaml
grep -q 'AssociatePublicIpAddress: false' templates/application.yaml
grep -q 'SourceSecurityGroupId: !Ref AlbSecurityGroup' templates/application.yaml
if grep -Eq 'FromPort: 22|Port: 22' templates/application.yaml; then echo 'Unexpected SSH ingress found' >&2; exit 1; fi
echo 'Static project checks passed.'
