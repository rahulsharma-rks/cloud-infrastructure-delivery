# Cost management

Potential billable resources include EC2 instances, EBS, ALB hours and LCU usage, NAT Gateway hours and data processing, public IPv4 addresses, CodeBuild build minutes, S3 storage, and CloudWatch logs.

- Run template validation without deploying the application when possible.
- Set an AWS Budget alert; it is not a hard spending cap.
- Keep the full application up only during a planned test window.
- Delete the root application stack after testing and wait for deletion to finish.
- Verify NAT Gateway, Elastic IP, ALB, EC2, EBS, ENIs, log groups, and S3 artifacts in the selected Region.
- Keep pipeline infrastructure separate from the short-lived application stack.
- Do not use a single NAT Gateway design for production high availability.

To delete the pipeline too, run `./scripts/cleanup-pipeline.sh`. It permanently deletes versions and delete markers in the pipeline artifact and template buckets, then deletes the pipeline stack. Keep a copy of anything you need before running it.
