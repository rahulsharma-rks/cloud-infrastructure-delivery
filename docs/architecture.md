# Architecture

GitHub is the source of truth. AWS CodePipeline retrieves source through an authorized CodeConnections connection, then CodeBuild validates templates and parameters. The production extension should package nested templates, create a CloudFormation change set, pause for approval, execute the reviewed change set, and run a smoke test.

The root stack creates two nested stacks: network and application. The network stack creates a VPC, two public subnets for the ALB, two private subnets for application instances, and optionally one NAT Gateway for outbound package installation. The application stack creates security groups, an EC2 instance role/profile, encrypted EBS root volumes, an ALB, target group, listener, Auto Scaling Group, log group, and unhealthy-target alarm.

The single NAT Gateway is a cost-saving lab trade-off; it is not multi-AZ egress resilience. HTTP is used to avoid certificate setup in the initial lab. Add HTTPS and ACM for a stronger follow-up iteration.
