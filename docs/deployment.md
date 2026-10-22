# Deployment guide

## Prerequisites

- AWS CLI v2, Python 3, `cfn-lint`, Git
- Authorized AWS CLI profile and selected Region
- Private S3 bucket in the same Region for nested template packaging
- AWS CodeConnections connection to the GitHub repository

## Local validation

```bash
export AWS_PROFILE=cloudformation-lab
export AWS_REGION=ap-south-1
./scripts/validate-local.sh
./tests/test-template.sh
```

## Manual deployment

```bash
export TEMPLATE_BUCKET=YOUR-PRIVATE-TEMPLATE-BUCKET
export STACK_NAME=cfn-platform-dev
./scripts/deploy-local.sh
./scripts/smoke-test.sh
```

## CI/CD pipeline stages to implement

1. Source: GitHub via CodeConnections; protect the main branch and require review.
2. Validate: `cfn-lint`, CloudFormation `validate-template`, JSON validation, and CloudFormation Guard policies.
3. Package: `aws cloudformation package` uploads nested templates to a dedicated private S3 bucket.
4. Prepare: create a named CloudFormation change set using the packaged root template and a dedicated execution role.
5. Approval: add a CodePipeline Manual Approval action after the change set is available. Include the change-set ARN and review instructions in approval details.
6. Execute: execute only the approved change set.
7. Verify: run the smoke test and collect CloudFormation stack events if it fails.

For the first iteration, use a manual approval before executing every infrastructure change. Later, allow automatic deployment only to a disposable dev environment.


## Bootstrap the CI/CD pipeline

1. Create and authorize a GitHub connection in AWS CodeConnections. Confirm its status is `AVAILABLE`.
2. Push this repository to GitHub.
3. Deploy the pipeline stack with the commands below.

```bash
export AWS_PROFILE=cloudformation-lab
export AWS_REGION=ap-south-1
export GITHUB_CONNECTION_ARN='arn:aws:codeconnections:ap-south-1:ACCOUNT_ID:connection/CONNECTION_ID'
export GITHUB_OWNER='YOUR_GITHUB_USERNAME'
export GITHUB_REPOSITORY='aws-cloudformation-production-portfolio'

aws cloudformation validate-template \
  --template-body file://templates/pipeline-stack.yaml \
  --region "$AWS_REGION"

aws cloudformation deploy \
  --template-file templates/pipeline-stack.yaml \
  --stack-name cfn-platform-pipeline \
  --parameter-overrides \
    ProjectName=cfn-platform \
    GitHubConnectionArn="$GITHUB_CONNECTION_ARN" \
    GitHubOwner="$GITHUB_OWNER" \
    GitHubRepository="$GITHUB_REPOSITORY" \
    GitHubBranch=main \
    ApplicationStackName=cfn-platform-dev \
    EnvironmentName=dev \
  --capabilities CAPABILITY_IAM \
  --region "$AWS_REGION"
```

4. Open CodePipeline and inspect each stage. The initial execution creates a change set, pauses for manual approval, then executes it.
5. Confirm the application URL from CloudFormation outputs and run the smoke test from a CodeBuild job or from a network that can reach the public ALB.

The pipeline template is a lab scaffold: review IAM permissions and validate CodePipeline action role behavior in a disposable account before relying on it. The CloudFormation execution role includes broad lab permissions to support nested stack creation; replace them with a policy constrained to the exact resource types and role ARNs before any shared-account deployment.
