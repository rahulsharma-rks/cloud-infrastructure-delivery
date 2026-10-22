# AWS CloudFormation Production-Style Portfolio

A portfolio project demonstrating reusable CloudFormation templates, private application networking, AWS CodePipeline and CodeBuild, deployment verification, security controls, and cost-aware lifecycle management.

## Architecture

- Root CloudFormation stack orchestrates network and application nested stacks.
- VPC spans two Availability Zones with public ALB subnets and private application subnets.
- EC2 Auto Scaling Group runs Amazon Linux 2023 instances without public IPs.
- Application Load Balancer is internet-facing; instance ingress is allowed only from the ALB security group.
- EC2 uses an instance profile for Systems Manager, IMDSv2, and encrypted EBS.
- CodePipeline retrieves source from GitHub through CodeConnections and invokes CodeBuild for validation, packaging, deployment, and tests.

## Repository layout

```text
templates/       # root, network, application, and pipeline CloudFormation templates
buildspec/       # CodeBuild build specifications
parameters/      # environment-specific JSON parameter files
scripts/         # validation, deployment, smoke test, cleanup
tests/           # static template assertions
docs/            # architecture, security, deployment, cost guidance
```

## Prerequisites

- AWS CLI v2 and an approved AWS profile
- Python 3 and `cfn-lint`
- A private S3 bucket in the target Region for nested-template packaging
- AWS CodeConnections connection to GitHub for the pipeline implementation

## Local validation

```bash
export AWS_PROFILE=cloudformation-lab
export AWS_REGION=ap-south-1
./scripts/validate-local.sh
./tests/test-template.sh
```

## Deploy the application stack

```bash
export TEMPLATE_BUCKET=YOUR-PRIVATE-TEMPLATE-BUCKET
export STACK_NAME=cfn-platform-dev
./scripts/deploy-local.sh
./scripts/smoke-test.sh
```

The template bucket must already exist, have public access blocked, and be in the same Region. Keep its lifecycle separate from the application stack.

## CI/CD workflow

1. Source from GitHub using CodeConnections.
2. Validate with `cfn-lint`, CloudFormation template validation, JSON checks, and CloudFormation Guard.
3. Package nested templates and upload them to a private S3 bucket.
4. Create a CloudFormation change set using a dedicated execution role.
5. Require manual approval before executing the change set.
6. Execute the approved change set and run a smoke test.
7. Record the result and inspect CloudFormation events on failure.

The `templates/pipeline-stack.yaml` file provides the CodePipeline bootstrap, validation/package build projects, a manual approval stage, and CloudFormation change-set actions. Review its IAM policy before deploying; the execution policy is intentionally broad for a dedicated lab and must be narrowed before use in any shared or production account. Do not use AdministratorAccess as a shortcut.

## Security notes

The application instances have no public IP addresses, require IMDSv2, and accept HTTP only from the ALB. EBS root volumes are encrypted. Use least-privilege service roles, protect the main branch, and never commit credentials. This lab uses HTTP at the ALB and one NAT Gateway for cost control; add HTTPS/ACM and multi-AZ egress before presenting it as production-ready.

## Cost and cleanup

Set a budget alert before deployment. ALB, NAT Gateway, EC2, EBS, CodeBuild, S3, and CloudWatch may incur charges. Run `./scripts/cleanup.sh` to delete the application stack. If you also want to delete the pipeline, run `./scripts/cleanup-pipeline.sh`; it empties versioned objects from the retained artifact/template buckets before deleting the pipeline stack. Verify remaining resources in the AWS Console.

## Future improvements

- Full CodePipeline CloudFormation change-set + manual approval + execution stages
- CloudFormation Guard rules and unit tests
- HTTPS listener with ACM and HTTP redirect
- SSM VPC endpoints to reduce NAT dependency
- Canary or blue/green application deployment
- Separate dev and prod accounts with StackSets

## CI/CD Trigger Verification

The CodePipeline source stage is configured to detect pushes to the
`main` branch through AWS CodeConnections. The pipeline validates and
packages templates, prepares a CloudFormation change set, and pauses
for manual approval before deployment.

<!-- GitHub push-trigger verification: 2026-10-22 -->

GitHub trigger verification test: 2026-10-22
