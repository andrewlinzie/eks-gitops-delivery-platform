# EKS GitOps Delivery Platform (CI/CD + Kubernetes + Terraform)
## Overview
This project demonstrates the design and implementation of a production-style DevOps delivery platform on AWS, combining:
- Infrastructure as Code (Terraform)
- Containerization (Docker)
- Kubernetes orchestration (EKS + Helm)
- CI/CD pipelines (GitHub Actions + Jenkins)
- GitOps-based deployment (Argo CD)

The system models how modern teams build, package, and deploy applications across environments using automated, reproducible workflows.

## Purpose
The goal of this project is to demonstrate how to:
- Build a modern GitOps-based deployment system using Kubernetes
- Automate application delivery using CI/CD pipelines
- Enable environment-based deployments with strong traceability

This results in a system that is scalable, observable, and aligned with modern DevOps best practices.

## Architecture
### High-Level Flow
1. Developers push code to the repository
2. GitHub Actions builds and pushes Docker images to ECR
3. Deployment manifests (Helm values) are updated in Git
4. Argo CD monitors the Git repository for changes
5. Argo CD syncs desired state to the EKS cluster
6. Kubernetes performs rolling updates with zero downtime

### Core Components
- EKS (Kubernetes) – Container orchestration platform
- Helm – Kubernetes package management
- Argo CD – GitOps deployment controller
- GitHub Actions – Primary CI pipeline
- Jenkins (EC2) – Legacy CI/CD pipeline
- ECR – Container image registry
- Terraform – Infrastructure provisioning
- ALB Ingress – External traffic routing

## Workflow
### GitOps + CI/CD Workflow
1. Code is pushed to repository
2. GitHub Actions pipeline runs:
    - validation (lint + tests)
    - Docker build + tag (commit SHA)
    - push to ECR
3. Helm values are updated in Git
4. Argo CD detects changes in Git repository
5. Argo CD reconciles desired state with cluster
6. Kubernetes deploys updated containers via rolling updates

## Tech Stack
- Terraform – Infrastructure as Code
- Docker – Containerization
- Kubernetes (EKS) – Container orchestration
- Helm – Kubernetes package management
- GitHub Actions – CI/CD automation
- Jenkins – Legacy CI/CD pipeline
- Argo CD – GitOps deployment
- Amazon ECR – Image storage

## Key Engineering Decisions
### GitOps vs Imperative Deployment
GitOps was chosen to eliminate manual deployment processes.
- Removes reliance on manual kubectl commands
- Provides auditability through Git history
- Enables automated reconciliation via Argo CD

Imperative deployment approaches were avoided due to lack of traceability and consistency.

### Immutable Image Tagging
Docker images are tagged using commit SHA identifiers.
- Ensures traceability across deployments
- Prevents version drift across environments
- Enables reliable rollback to known versions

### Separation of Concerns
The system is modularized into distinct layers:
- Application layer
- Infrastructure layer
- CI/CD layer
- Deployment (GitOps) layer

This improves maintainability, scalability, and clarity of responsibilities.

### OIDC-Based Authentication
OIDC was implemented for secure AWS authentication.
- Eliminates long-lived AWS credentials
- Enables short-lived, secure authentication tokens
- Improves CI/CD security posture

## Infrastructure Highlights
- EKS cluster (v1.30) with managed node groups
- Node autoscaling (1–4 nodes)
- Horizontal Pod Autoscaler (CPU + memory based)
- ALB ingress for external traffic routing
- Private networking for internal workloads

## Notable Features
- GitOps-based deployment with Argo CD
- Automated CI/CD pipeline using GitHub Actions
- Immutable deployments using commit-based tagging
- Zero-downtime deployments via Kubernetes rolling updates
- Dual pipeline model (modern GitOps + legacy Jenkins)

## Deployment / Execution Flow (End-to-End)
1. Local Development
    - Build and test application locally
    - Validate container behavior
2. Containerization
    - Dockerize application
    - Validate container execution
3. Infrastructure Provisioning
    - Use Terraform to provision:
        - VPC and networking
        - EKS cluster
        - ECR repositories
        - IAM roles and security groups
4. CI/CD Execution
    - GitHub Actions builds and pushes images
    - Jenkins pipeline (optional) demonstrates legacy approach
5. GitOps Deployment
    - Helm values updated in Git repository
    - Argo CD detects changes
    - Argo CD syncs cluster state
6. Production Deployment
    - Kubernetes deploys updated containers
    - ALB routes traffic to services
7. Validation
    - Argo CD shows Healthy and Synced
    - Validate with:
        - `kubectl get pods`
        - `kubectl get ingress`

## Outcomes
- Eliminated manual deployment processes
- Enabled fully automated, Git-driven deployments
- Improved deployment traceability and rollback capability
- Established production-grade Kubernetes delivery workflow

## Future Improvements
- Multi-service architecture (API + worker services)
- Environment promotion strategy (dev → staging → prod)
- Observability stack (Prometheus + Grafana)
- Multi-repo GitOps structure

## Summary
This project demonstrates a modern, production-grade DevOps delivery platform that integrates:
- Infrastructure as Code (Terraform)
- Containerization (Docker)
- Orchestration (Kubernetes / EKS)
- Automation (GitHub Actions, Jenkins)
- GitOps deployment (Argo CD)

It reflects real-world DevOps practices: automation, scalability, security, and traceability.