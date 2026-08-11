# ECS PoC (dvn) 🚀

![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![ECS](https://img.shields.io/badge/ECS-Fargate-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-009639?style=for-the-badge&logo=nginx&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)

A proof-of-concept that provisions a complete AWS ECS (Fargate) environment using Terraform. It stands up a VPC with public/private subnets, an Application Load Balancer, and an ECS Fargate service running an `nginx` container, all behind a single `terraform apply`. ✨

## Architecture 🏗️

```
                        Internet
                           |
                     [Internet Gateway]
                           |
                 [Public Subnets 1a/1b]
                           |
              [Application Load Balancer (ALB)]
                           |  (HTTP :80 / HTTPS :443)
                 [ECS Tasks Security Group]
                           |
                 [Private Subnets 1a/1b]
                           |
              [ECS Fargate Service (nginx)]
                           |
                     [NAT Gateway]
                           |
                     [Internet Gateway]
```

- **VPC** (`10.0.0.0/24`) with two public and two private subnets across `us-east-1a` / `us-east-1b`.
- **Networking**: Internet Gateway for public egress, NAT Gateway (with an Elastic IP) for outbound traffic from the private subnets.
- **ALB**: Public-facing Application Load Balancer listening on port 80 (HTTP) or 443 (HTTPS, when a certificate is enabled), forwarding to the ECS target group.
- **ECS**: A Fargate cluster with a capacity provider, running a single `nginx:latest` task (1 vCPU / 2 GiB) in the private subnets. Logs are shipped to CloudWatch Logs.
- **IAM**: An ECS task execution role with the `AmazonECSTaskExecutionRolePolicy` and `CloudWatchLogsFullAccess` policies.

## Project Layout 📁

```
infra/
├── provider.tf                        # AWS provider (us-east-1)
├── variables.tf                       # Input variables (use_certificate)
├── outputs.tf                         # ALB DNS name
├── vpc.tf                             # VPC
├── vpc.public-subnet.tf               # Public subnets (1a, 1b)
├── vpc.private-subnet.tf              # Private subnets (1a, 1b)
├── vpc.internet-gtw.tf                # Internet Gateway
├── vpc.nat-gateway.tf                 # NAT Gateway
├── vpc.public-route-table.tf          # Public route table + associations
├── vpc.private-route-table.tf         # Private route table + associations
├── ec2.eip.tf                         # Elastic IP for the NAT Gateway
├── elb.application.tf                 # ALB + its security group
├── elb.target-group.tf                # Target group (IP target type)
├── elb.listener.tf                    # Listener (HTTP/HTTPS)
├── acm.certificate.tf                 # ACM certificate (optional)
├── acm.certificate.validation.tf      # Route53 DNS validation (optional)
├── iam.role.ecs-execution-role.tf     # ECS task execution role
├── ecs.cluster.tf                     # ECS cluster
├── ecs.cluster.capacity-provider.tf   # Fargate capacity provider
├── ecs.cluster.service.tf             # ECS service + task security group
└── ecs.cluster.service.td.tf          # Task definition (nginx container)
```

## Prerequisites ✅

- [Terraform](https://developer.hashicorp.com/terraform/downloads) (v1.x)
- AWS credentials configured (e.g. via `AWS_PROFILE`, `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY`, or the default credential chain)
- An AWS account with permission to create the resources above

## Usage 🚀

```bash
cd infra

terraform init
terraform plan
terraform apply
```

After the apply completes, the ALB DNS name is printed as an output:

```bash
terraform output alb_dns_name
```

Open that URL in a browser to see the default `nginx` welcome page.

To tear everything down:

```bash
terraform destroy
```

## Configuration ⚙️

| Variable          | Type   | Default | Description                                                         |
| ----------------- | ------ | ------- | ------------------------------------------------------------------- |
| `use_certificate` | `bool` | `false` | When `true`, provisions an ACM certificate and serves HTTPS on 443. |

### Enabling HTTPS

1. Set `use_certificate = true` (e.g. in a `terraform.tfvars` file or via `-var`).
2. Replace the placeholder domain names in `infra/acm.certificate.tf` and `infra/acm.certificate.validation.tf` (`*.dvn.com` / `dvn.com`) with your own domain.
3. Ensure the domain's hosted zone exists in Route 53.
4. Re-run `terraform apply`.

## Autoscaling Test with Siege ⚙️

A practical way to validate ECS autoscaling is to generate sustained traffic against the ALB and watch the service scale out in CloudWatch/ECS. `siege` is a good fit for this because it can send concurrent requests quickly and simulate pressure without extra infrastructure.

### Install Siege

On macOS:

```bash
brew install siege
```

On Ubuntu/Debian:

```bash
sudo apt-get update
sudo apt-get install -y siege
```

### Example load test

Use the ALB DNS name from Terraform output:

```bash
terraform output alb_dns_name
```

Then run a burst test against the public endpoint:

```bash
siege -c 50 -t 2M http://<alb-dns-name>/
```

Useful variations:

```bash
# light concurrency
siege -c 10 -t 1M http://<alb-dns-name>/

# heavier concurrency for scale-out testing
siege -c 100 -t 5M http://<alb-dns-name>/

# run multiple users repeatedly
siege -c 200 -r 10 http://<alb-dns-name>/
```

### What to watch

- ECS service desired count increasing
- ALB target health and request counts
- CloudWatch alarms and autoscaling activity
- CPU utilization in the ECS tasks

### Notes

- Start with a modest concurrency value and increase gradually.
- Because this is a proof-of-concept, scaling policies are intentionally simple and should be tuned for real workloads.
- For realistic autoscaling validation, pair `siege` with CPU-based CloudWatch alarms or target tracking policies.

## Notes 📝

- The task definition uses `nginx:latest` as a placeholder image — swap it for your own container image.
- The target group's health check block is currently commented out; uncomment it to enable ALB health checks.
- This is a proof-of-concept, so resources are minimal and not tuned for production (e.g. single NAT Gateway, no advanced autoscaling policies yet).
