# zsoftly-capstone
Static -Webpage
# 🌟 ZSOFTLY Capstone Project – AWS Containerized Web Application

## 📌 Overview

This project demonstrates the deployment of a **stateless, containerized web application** on Amazon Web Services using Infrastructure as Code.

The application serves two endpoints:

* `/page1`
* `/page2`

It is built with Docker and deployed using Amazon ECS with AWS Fargate.

---

# 🏗️ Architecture

```
User → Route53 → ALB → ECS (Fargate) → Docker Container (ECR)
```

---

# 📁 Repository Structure

```
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
│   ├── networking.tf
│   ├── security.tf
│   ├── iam.tf
│   ├── ecr.tf
│   ├── ecs.tf
│   ├── alb.tf
│   ├── route53.tf
│   ├── outputs.tf
│   └── terraform.tfvars
│
├── screenshots/
└── README.md
```

---

# 🧱 Step 1: Application Setup (`/app`)

## Create Static Pages

`page1.html`

```html
<h1>This is Page 1</h1>
```

`page2.html`

```html
<h1>This is Page 2</h1>
```

---

## Configure Nginx (`nginx.conf`)

```nginx
events {}

http {
    server {
        listen 80;

        location /page1 {
            root /usr/share/nginx/html;
            index page1.html;
        }

        location /page2 {
            root /usr/share/nginx/html;
            index page2.html;
        }
    }
}
```

---

## Dockerfile

```dockerfile
FROM nginx:latest

COPY page1.html /usr/share/nginx/html/
COPY page2.html /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/nginx.conf
```

---

# 🐳 Step 2: Build & Test Docker Image

```bash
cd app

docker build -t zsoftly-web .
docker run -p 8080:80 zsoftly-web
```

Test:

```
http://localhost:8080/page1
http://localhost:8080/page2
```

---

# 📦 Step 3: Push Image to ECR

## Create Repository

```bash
aws ecr create-repository --repository-name zsoftly-web
```

---

## Login to ECR

```bash
aws ecr get-login-password --region eu-west-2 \
| docker login \
--username AWS \
--password-stdin <account-id>.dkr.ecr.eu-west-2.amazonaws.com
```

---

## Tag & Push

```bash
docker tag zsoftly-web:latest \
<account-id>.dkr.ecr.eu-west-2.amazonaws.com/zsoftly-web:latest

docker push \
<account-id>.dkr.ecr.eu-west-2.amazonaws.com/zsoftly-web:latest
```

---

# 🌐 Step 4: Terraform Deployment (`/terraform`)

## Configure Variables

Edit `terraform.tfvars`:

```hcl
domain_name = "yourdomain.com"
image_url   = "<your-ecr-image-url>"
```

---

## Deploy Infrastructure

```bash
cd terraform

terraform init
terraform validate
terraform plan
terraform apply
```

---

# ⚙️ Infrastructure Created

### Networking

* VPC
* Public & Private Subnets
* Internet Gateway
* NAT Gateway

### Security

* ALB Security Group
* ECS Security Group

### Compute

* ECS Cluster
* Task Definition
* ECS Service (Fargate)

### Load Balancer

* Application Load Balancer
* Target Group
* Listener

### DNS

* Route 53 Hosted Zone
* DNS Record (`app.domain.com`)

---

# 🧪 Step 5: Testing

Access your application:

```
http://app.yourdomain.com/page1
http://app.yourdomain.com/page2
```

---

# 📸 Screenshots

Located in `/screenshots`:

* ECS Cluster & Tasks
* Load Balancer
* Target Group Health
* Browser Results

---

# ✅ Validation

✔ Terraform runs successfully
✔ ECS tasks are healthy
✔ Load balancer routes traffic correctly
✔ DNS resolves properly

---

# 🚀 Key Features

* Stateless architecture
* Multi-AZ deployment
* Secure private subnets
* Fully automated with Terraform
* Serverless containers via AWS Fargate

---

# 🔮 Future Improvements

* HTTPS (ACM)
* Auto Scaling
* CI/CD (GitHub Actions)
* Monitoring (CloudWatch)
* WAF security layer

---

# ⚠️ Notes

* Replace `<account-id>` with your AWS account ID
* Push Docker image **before** running Terraform
* Ensure domain exists in Route 53

---

# 🎯 Outcome

This project demonstrates:

* End-to-end deployment on Amazon Web Services
* Containerization with Docker
* Orchestration using Amazon ECS
* Full Infrastructure as Code with Terraform

---

# 👤 Author

Your Name
ZSOFTLY Capstone Project
