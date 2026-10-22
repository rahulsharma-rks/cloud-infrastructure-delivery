# Security controls and limitations

- Application instances are in private subnets and have no public IP addresses.
- No SSH ingress rule is defined; use Systems Manager Session Manager after validating required egress/endpoints.
- ALB is the only inbound HTTP source for instances.
- IMDSv2 is required and EBS root volumes are encrypted.
- Separate pipeline, CodeBuild, and CloudFormation execution roles should be used. Keep `iam:PassRole` scoped to the exact CloudFormation execution role or EC2 instance role as appropriate.
- Never commit credentials. Prefer IAM Identity Center locally and CodeConnections for source.
- Enable CloudTrail in the account and set CloudWatch log retention.
- Starter template still needs organization-specific least-privilege policy refinement. Do not use AdministratorAccess as a workaround. Validate all IAM policies in a dedicated lab account.
- HTTP is used for learning; it is not suitable for sensitive production traffic. Add ACM certificate, HTTPS listener, and HTTP-to-HTTPS redirect before claiming production readiness.
- One NAT Gateway is used for cost control and is a single-AZ dependency.
