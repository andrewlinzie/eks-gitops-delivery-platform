# EKS GitOps Delivery Platform (CI/CD + Kubernetes + Terraform)
##Overview

This project demonstrates the design and implementation of a production-style DevOps delivery platform on AWS, combining:

- Infrastructure as Code (Terraform)
- Containerization (Docker)
- Kubernetes orchestration (EKS + Helm)
- CI/CD pipelines (GitHub Actions + Jenkins)
- GitOps-based deployment (Argo CD)

The system models how modern teams build, package, and deploy applications across environments using automated, reproducible workflows.

## Architecture

The platform consists of four core layers:

### 1. Application Layer
- Python Flask service (containerized)
- Served via Gunicorn for production readiness
- Exposed via Kubernetes ingress (ALB)

### 2. Infrastructure Layer (Terraform)
- VPC with public/private subnets, NAT, IGW
- EKS cluster with managed node group
- ECR for container image storage
- EC2 instance hosting Jenkins
- IAM roles and security groups following least-privilege principles

### 3. CI/CD Layer
Two pipeline strategies are implemented:

#### GitHub Actions (Primary – GitOps)
- Code push triggers workflow
- Validates, builds, and tags Docker images
- Uses OIDC for secure AWS authentication (no static credentials)
- Pushes images to ECR
- Updates deployment manifests

#### Jenkins (Legacy / Transitional)
- Runs on EC2 (containerized Jenkins master)
- Handles build + deploy workflow
- Demonstrates traditional CI/CD pipeline architecture

### 4. Deployment Layer (GitOps)
- Argo CD monitors Git state
- Detects changes in Helm values
- Automatically reconciles cluster state
- Kubernetes performs rolling updates with zero downtime

## Deployment Flow

End-to-end pipeline:

1. Developer pushes code
2. GitHub Actions pipeline runs:
    - validation (lint + tests)
    - Docker build + tag (commit SHA)
    - push to ECR
3. Helm values updated in Git repo
4. Argo CD detects change
5. Kubernetes pulls new image
6. Rolling deployment executed

This ensures:
- reproducibility
- traceability
- rollback capability

## Key Engineering Decisions
### GitOps over imperative deployment
- Eliminates manual kubectl usage
- Provides auditability via Git history
- Enables automated reconciliation

### Immutable image tagging
- Uses commit SHA for traceability
- Prevents drift across environments

### Separation of concerns
- Infrastructure, application, and deployment logic are modularized

### OIDC-based authentication
- Removes need for long-lived AWS credentials
- Improves security posture of CI/CD pipelines

## Infrastructure Highlights
- EKS cluster (v1.30)
- Node autoscaling (1–4 nodes)
- Horizontal Pod Autoscaler (CPU + memory based)
- ALB ingress for external traffic routing
- Private networking for internal workloads

## Verification
- Application deployed via ALB ingress
- Argo CD shows Healthy and Synced
- Kubernetes resources validated via:

`kubectl get pods`
`kubectl get ingress`

## Local Development
`cd App`
`docker build -t hello-app .`
`docker run -p 5000:5000 hello-app`

## Terraform Deployment
`cd infra/Terraform`
`terraform init`
`terraform apply`

## Lessons & Improvements
- Transitioned from Jenkins-based pipelines to GitOps model for better scalability and maintainability
- Identified limitations of imperative deployment approaches
- Improved deployment reliability through declarative infrastructure and reconciliation loops

## Future Enhancements
- Multi-service architecture (API + worker services)
- Environment promotion strategy (dev → staging → prod)
- Observability stack (Prometheus + Grafana)
- Multi-repo GitOps structure

## Author

Andrew Linzie
DevOps Engineer | AWS | Kubernetes | CI/CD