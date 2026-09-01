# ZSOFTLY Capstone Project – AWS Containerised Web Application

A production-style DevOps project demonstrating how to build, containerise, provision and continuously deploy a static web application on AWS using **Docker, Terraform, Amazon ECR, Amazon ECS Fargate, Application Load Balancer and GitHub Actions**.

---

## 📌 Project Overview

This project demonstrates an end-to-end **Infrastructure as Code and CI/CD workflow** for deploying a containerised Nginx web application on AWS.

The infrastructure is provisioned using **Terraform**, while GitHub Actions automates the application deployment process.

The application is packaged as a Docker image, pushed to Amazon Elastic Container Registry (ECR), and deployed to Amazon ECS using AWS Fargate.

Traffic is served through an **Application Load Balancer (ALB)** to an ECS task running the Nginx container.

### Application

The application contains two static pages:

* `/`
* `/page2.html`

The root page provides a personal DevOps introduction, while the second page confirms successful CI/CD deployment.

---

# Architecture

```text
                         Internet
                            │
                            ▼
                 ┌────────────────────┐
                 │ Application Load   │
                 │ Balancer (ALB)     │
                 └──────────┬─────────┘
                            │
                            │ HTTP :80
                            ▼
                 ┌────────────────────┐
                 │   ECS Service      │
                 │   Fargate          │
                 └──────────┬─────────┘
                            │
                            ▼
                 ┌────────────────────┐
                 │ Nginx Container    │
                 │ zsoftly-web        │
                 └──────────┬─────────┘
                            │
                            │
              ┌─────────────┴─────────────┐
              │                           │
              ▼                           ▼
       CloudWatch Logs              Amazon ECR
                                      ▲
                                      │
                                      │ Docker Image
                                      │
                              ┌───────┴────────┐
                              │ GitHub Actions  │
                              │ CI/CD Pipeline  │
                              └────────────────┘
```

### AWS Network Architecture

```text
                         VPC
                    10.0.0.0/16
                         │
          ┌──────────────┴──────────────┐
          │                             │
          ▼                             ▼
     Public Subnets               Private Subnets
          │                             │
          ▼                             ▼
      Application                  ECS Fargate
     Load Balancer                    Tasks
                                        │
                           ┌────────────┼────────────┐
                           │            │            │
                           ▼            ▼            ▼
                         ECR API      ECR DKR      CloudWatch
                      VPC Endpoint  VPC Endpoint  Logs Endpoint
                           │            │            │
                           └────────────┴────────────┘
                                        │
                                    S3 Gateway
                                    Endpoint
```

---

#  Technology Stack

| Category               | Technology                              |
| ---------------------- | --------------------------------------- |
| Cloud Platform         | AWS                                     |
| Infrastructure as Code | Terraform                               |
| Containerisation       | Docker                                  |
| Container Registry     | Amazon ECR                              |
| Container Platform     | Amazon ECS                              |
| Compute                | AWS Fargate                             |
| Web Server             | Nginx                                   |
| Load Balancing         | Application Load Balancer               |
| CI/CD                  | GitHub Actions                          |
| Logging                | Amazon CloudWatch                       |
| Networking             | Amazon VPC                              |
| Security               | AWS IAM, Security Groups, VPC Endpoints |
| Source Control         | Git / GitHub                            |
| Application            | HTML / Nginx                            |

---

# 📁 Repository Structure

```text
zsoftly-capstone/
│
├── app/
│   ├── Dockerfile
│   ├── nginx.conf
│   ├── page1.html
│   └── page2.html
│
├── terraform/
│   ├── provider.tf
│   ├── variables.tf
│   ├── vpc.tf
│   ├── group.tf
│   ├── security.tf
│   ├── endpoints.tf
│   ├── ecr.tf
│   ├── ecs.tf
│   ├── definition.tf
│   ├── iam.tf
│   ├── logging.tf
│   ├── alb.tf
│   ├── target.tf
│   ├── listener.tf
│   ├── route53.tf
│   ├── output.tf
│   ├── outputs.tf
│   └── github-actions-policy.json
│
├── screenshot/
│   ├── ECS screenshots
│   ├── ECR screenshots
│   ├── Terraform screenshots
│   ├── VPC screenshots
│   └── application screenshots
│
├── .gitignore
└── README.md
```

Terraform state files, plan files and the `.terraform` directory are excluded from Git through `.gitignore`.

---

#  1. Application

The application is a lightweight static website served using Nginx.

## Nginx Configuration

The container uses Nginx as the web server.

```nginx
server {
    listen 80;

    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

The configuration allows the root application and static resources to be served directly by Nginx.

---

# 2. Containerisation

The application is packaged into a Docker image.

```dockerfile
FROM nginx:latest

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY page1.html /usr/share/nginx/html/index.html
COPY page2.html /usr/share/nginx/html/page2.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

The Docker image:

1. Uses Nginx as the base image.
2. Copies the custom Nginx configuration.
3. Copies the application pages into the Nginx document root.
4. Exposes port 80.
5. Runs Nginx in the foreground.

---

# 3. Local Docker Testing

Build the image:

```bash
cd app

docker build -t zsoftly-web .
```

Run the container:

```bash
docker run -p 8080:80 zsoftly-web
```

Test the application:

```bash
curl http://localhost:8080/
curl http://localhost:8080/page2.html
```

---

# 4. Amazon ECR

The Docker image is stored in **Amazon Elastic Container Registry (ECR)**.

Repository:

```text
zsoftly-web
```

The GitHub Actions pipeline automatically builds the Docker image and pushes it to ECR.

Images are tagged using the Git commit SHA, providing an immutable identifier for each deployment.

Example:

```text
152160818896.dkr.ecr.us-east-1.amazonaws.com/zsoftly-web:<commit-sha>
```

This provides traceability between:

```text
Git Commit
     ↓
Docker Image
     ↓
ECR
     ↓
ECS Task Definition
     ↓
Production Deployment
```

# 5. Infrastructure as Code with Terraform

Terraform provisions and manages the AWS infrastructure.

The configuration creates and manages resources including:

### Networking

* AWS VPC
* Public subnets
* Private subnets
* Internet Gateway
* Route tables
* Route table associations
* VPC endpoints

### Container Infrastructure

* Amazon ECR repository
* ECS cluster
* ECS task definition
* ECS service
* AWS Fargate task

### Load Balancing

* Application Load Balancer
* Target group
* HTTP listener

### Security

* IAM execution role
* IAM policy attachment
* Security groups
* VPC endpoint security group

### Observability

* CloudWatch log group
* CloudWatch Logs VPC endpoint

---

# 6. VPC Endpoints

The ECS workload uses VPC endpoints to provide private connectivity to required AWS services.

The deployed environment includes:

```text
Amazon ECR API       → Interface Endpoint
Amazon ECR Docker    → Interface Endpoint
Amazon S3            → Gateway Endpoint
Amazon CloudWatch    → Interface Endpoint
```

This reduces the dependency on public internet connectivity for these AWS service interactions.

The CloudWatch Logs endpoint was particularly important during deployment because ECS initially could not initialise the logging configuration.

The issue was identified through ECS service events:

```text
ResourceInitializationError:
The task cannot find the Amazon CloudWatch log group defined
in the task definition.
```

After implementing the CloudWatch Logs VPC endpoint and correcting the infrastructure configuration, the ECS task was successfully deployed.

---

# 7. Amazon ECS Fargate

The application runs on Amazon ECS using the **Fargate launch type**.

Current service configuration:

```text
Cluster:        zsoftly-cluster
Service:        zsoftly-service
Task Definition: zsoftly-task
Launch Type:    FARGATE
Desired Tasks:  1
Running Tasks:  1
Pending Tasks:  0
```

Fargate removes the requirement to manage the underlying EC2 instances.

The application therefore runs as a serverless container workload.

---

# 8. Application Load Balancer

The Application Load Balancer provides the public entry point to the application.

Traffic flow:

```text
Internet
   │
   ▼
ALB
   │
   ▼
Target Group
   │
   ▼
ECS Fargate Task
   │
   ▼
Nginx :80
```

The ECS target group has been successfully validated as healthy.

Example health check result:

```text
Target: 10.0.x.x
Port:   80
State:  healthy
Reason: None
```

---

# 9. CI/CD with GitHub Actions

The project implements automated deployment using GitHub Actions.

The pipeline performs the following stages:

```text
Git Push
   │
   ▼
GitHub Actions
   │
   ├── Checkout repository
   │
   ├── Configure AWS credentials
   │
   ├── Verify AWS identity
   │
   ├── Login to Amazon ECR
   │
   ├── Build Docker image
   │
   ├── Push image to ECR
   │
   ├── Download ECS task definition
   │
   ├── Render new task definition
   │
   └── Deploy ECS service
            │
            ▼
       ECS Fargate
```

The deployment workflow uses:

```yaml
aws-actions/configure-aws-credentials
aws-actions/amazon-ecr-login
aws-actions/amazon-ecs-render-task-definition
aws-actions/amazon-ecs-deploy-task-definition
```

The pipeline has been successfully executed end-to-end.

---

# Deployment Strategy

The ECS service is configured with Terraform while the application deployment is handled by GitHub Actions.

Terraform manages the infrastructure.

GitHub Actions manages application releases.

This separation prevents Terraform from continuously attempting to revert ECS task-definition revisions created by the CI/CD pipeline.

The ECS service uses:

```hcl
lifecycle {
  ignore_changes = [task_definition]
}
```

This allows GitHub Actions to update the ECS task definition without Terraform attempting to replace it with the older Terraform-managed revision.

---

# 10. Monitoring and Logging

Application logs are configured to be sent to Amazon CloudWatch Logs.

Log group:

```text
/ecs/zsoftly
```

ECS therefore provides centralised container logging through CloudWatch.

Operational validation can be performed using the AWS CLI:

```bash
aws ecs describe-services \
  --cluster zsoftly-cluster \
  --services zsoftly-service \
  --region us-east-1
```

Target health can be checked using:

```bash
aws elbv2 describe-target-health \
  --target-group-arn <target-group-arn> \
  --region us-east-1
```

---

# 11. Deployment Validation

The final deployment was validated at multiple layers.

### GitHub Actions

```text
Build and Deploy to ECS
✓ Successful
```

### ECS

```text
Desired:   1
Running:   1
Pending:   0
Status:    ACTIVE
```

### Target Group

```text
Port:  80
State: healthy
```

### Application

Root endpoint:

```text
HTTP/1.1 200 OK
```

Second page:

```text
HTTP/1.1 200 OK
```

Example:

```bash
curl -i http://<alb-dns-name>/
```

and:

```bash
curl -i http://<alb-dns-name>/page2.html
```

Both endpoints successfully returned the expected HTML content.

---

# 12. Troubleshooting Experience

During development, the project encountered several realistic DevOps deployment issues.

### GitHub Actions action version issue

The initial pipeline referenced unavailable action versions.

This produced errors such as:

```text
Unable to resolve action
aws-actions/amazon-ecs-deploy-task-definition
```

The workflow was corrected to use supported action versions.

---

### ECS CloudWatch logging failure

ECS initially failed to start tasks because the task could not reach the configured CloudWatch Logs endpoint.

The ECS service reported:

```text
ResourceInitializationError
```

Investigation included:

* ECS service events
* CloudWatch log-group verification
* VPC endpoint inspection
* ECS task-definition inspection
* network configuration validation

A CloudWatch Logs VPC endpoint was subsequently provisioned.

---

### ECS deployment timeout

GitHub Actions initially reported:

```text
{"state":"TIMEOUT","reason":"Waiter has timed out"}
```

The underlying ECS service events were then inspected rather than treating the GitHub Actions timeout as the root cause.

This led to the CloudWatch Logs connectivity issue being identified and resolved.

---

### Terraform / CI/CD task-definition conflict

Terraform attempted to change the ECS service from a newer CI/CD-created task definition back to an older Terraform-managed revision.

The configuration was adjusted using:

```hcl
lifecycle {
  ignore_changes = [task_definition]
}
```

Terraform subsequently reported:

```text
No changes.

Your infrastructure matches the configuration.
```

This demonstrates the importance of defining clear ownership between Infrastructure as Code and application deployment pipelines.

---

# 13. Security Considerations

The project incorporates several AWS security practices:

* IAM roles are used for ECS task execution.
* AWS credentials are supplied to GitHub Actions through GitHub secrets.
* ECS tasks run in private subnets.
* Security groups control traffic between components.
* VPC endpoints provide private connectivity to selected AWS services.
* Terraform state files are excluded from source control.
* Sensitive `.tfvars` files are excluded through `.gitignore`.

---

# 14. Cost Considerations

The project was designed with AWS cost awareness in mind.

The workload uses:

```text
ECS Fargate
1 running task
```

The project also uses VPC endpoints rather than introducing unnecessary infrastructure such as a NAT Gateway.

Before leaving the environment running for extended periods, AWS resources should be reviewed and unused infrastructure should be destroyed.

To remove Terraform-managed infrastructure:

```bash
cd terraform

terraform destroy
```

> Always verify the resources selected for destruction before confirming the operation.

---

# 15. Future Improvements

Potential enhancements include:

* HTTPS using AWS Certificate Manager (ACM)
* Route 53 DNS configuration
* ECS Service Auto Scaling
* Application Load Balancer HTTPS listener
* AWS WAF
* Prometheus/Grafana monitoring
* CloudWatch alarms
* Container image vulnerability scanning
* Terraform remote state using Amazon S3
* DynamoDB state locking where appropriate
* Blue/green deployment
* Automated infrastructure testing
* OIDC authentication between GitHub Actions and AWS

---

# Skills Demonstrated

This project demonstrates practical experience with:

### Cloud

* AWS
* VPC
* ECS
* Fargate
* ECR
* ALB
* CloudWatch
* IAM
* VPC Endpoints

### DevOps

* CI/CD
* GitHub Actions
* Docker
* Infrastructure as Code
* Terraform
* Automated deployments
* Deployment troubleshooting

### Containers

* Docker image creation
* Containerised Nginx application
* Amazon ECR
* ECS task definitions
* ECS services
* Fargate

### Networking

* VPC
* Public/private subnet architecture
* Security groups
* Route tables
* Application Load Balancer
* VPC endpoints
* HTTP

### Operations

* Log analysis
* Health checks
* ECS service events
* AWS CLI troubleshooting
* Infrastructure validation
* Deployment failure investigation

---

# Screenshots

The `screenshot/` directory contains evidence of the project implementation, including:

* Terraform infrastructure
* VPC
* Subnets
* ECR repository
* Docker image pushed to ECR
* ECS cluster
* ECS service
* Application Load Balancer
* Application pages
* Deployment results

---

# Author

**Kehinde Suleiman**

Cloud & DevOps Engineer

GitHub: **KennySuleiman**

---

# Project Outcome

This project demonstrates an end-to-end DevOps workflow:

```text
Developer
    │
    ▼
GitHub
    │
    ▼
GitHub Actions
    │
    ├──────────────► Docker Build
    │                     │
    │                     ▼
    │                  Amazon ECR
    │                     │
    │                     ▼
    └──────────────► Amazon ECS
                          │
                       Fargate
                          │
                          ▼
                         ALB
                          │
                          ▼
                     Nginx Web App
```

The final environment successfully demonstrates:

**Source Code → Automated CI/CD → Container Build → ECR → ECS Fargate → ALB → Running Web Application**

The infrastructure is provisioned through **Terraform**, while application deployments are automated through **GitHub Actions**.

