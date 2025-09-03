# Tech Challenge 2 – Application Deployment: Containerization, IaC, K8s & CI/CD

## Objective
Deploy a simple web application using **Docker**, orchestrate it with **AWS EKS**, and set up a **CI/CD pipeline**.  
As a bonus, implement a **GitOps workflow** with **GitHub Actions + Argo CD**.

---

## Application Overview
- **Language/Framework:** Python Flask  
- **App Behavior:** Returns `"Hello, World!"` at root endpoint (`/`)  
- **Container:** Dockerized with a `Dockerfile` (uses Gunicorn for production serving)  

---

## Repository Structure
├── App/ # Flask app + Dockerfile
│ ├── app.py
│ ├── requirements.txt
│ └── Dockerfile
├── infra/Terraform/ # Infrastructure as Code
│ ├── provider.tf
│ ├── vpc.tf
│ ├── ec2.tf
│ ├── ecr.tf
│ ├── eks.tf
│ ├── iam.tf
│ ├── outputs.tf
│ └── variables.tf
├── helm/hello/ # Helm chart for K8s deployment
├── .github/workflows/ # GitHub Actions workflows (GitOps branch)
│ └── docker-ci.yml
└── Jenkinsfile # Jenkins pipeline definition (main branch)


---

## Infrastructure (Provisioned with Terraform)
- **VPC** with 2 public + 2 private subnets, NAT, IGW, SGs  
- **EKS Cluster**  
  - Version: 1.30  
  - 1 node always active, scalable to 4 (`t3.small`)  
  - HPA scales pods (50% CPU or 50% memory)  
- **ECR Repository** for application images  
- **EC2 Instance** (Ubuntu 22.04) for Jenkins master  

---

## Deployment Workflow

### Jenkins (Main Branch)
- **EC2 Jenkins master** runs Jenkins in a Docker container  
- **Pipeline stages:**  
  1. Checkout code from GitHub  
  2. Build Docker image (`hello-world-flask`)  
  3. Push to Amazon ECR  
  4. Update kubeconfig for EKS  
  5. Deploy app with Helm to EKS  

> ⚠️ Note: Pipeline execution faced build issues in Jenkins, but configuration, credentials, and Jenkinsfile are included in this repo to demonstrate understanding of setup.  

---

### GitOps Alternative (Bonus – GitHub Actions + Argo CD)

Branch: **`gitops`**

- **GitHub Actions Workflow (`docker-ci.yml`):**
  - Triggered on pushes to `gitops` branch
  - Builds Docker image from `App/`
  - Pushes image to ECR

- **Argo CD (installed in EKS):**
  - Watches `helm/hello` chart on the `gitops` branch
  - Auto-syncs new images to EKS
  - Provides UI to track app health & sync status

✅ This flow is fully operational:
- Push to `gitops` → GitHub Actions builds & pushes image → Argo CD syncs Helm → App deployed to EKS.  

---

## Verification

- **App URL (ALB Ingress):**  
http://k8s-default-flaskhel-1b77394aa2-160451022.us-east-2.elb.amazonaws.com/
http://k8s-jenkinsd-helloapp-886addf9ff-1692053750.us-east-2.elb.amazonaws.com/


- **Argo CD UI:** Shows app `Healthy` and `Synced`.

- **kubectl check:**
```bash
kubectl get pods
kubectl get ingress
curl http://k8s-default-flaskhel-1b77394aa2-160451022.us-east-2.elb.amazonaws.com


Submission Requirements Met

✔ Web app (Hello, World!)
✔ Dockerized application
✔ Terraform provisioning of VPC, EKS, ECR, Jenkins
✔ App deployed to EKS (via Helm) with ALB & HPA
✔ CI/CD implemented (Jenkins attempted, GitOps alternative fully working)
✔ GitHub repo contains code, IaC, CI/CD configs
✔ README with environment setup & instructions
✔ Deployed application URL provided

How to Run
Local Run

cd App
docker build -t hello-app .
docker run -d -p 5000:5000 hello-app
# Visit http://localhost:5000

Deploy with Terraform

cd infra/Terraform
terraform init
terraform apply -auto-approve

Configure kubectl

aws eks update-kubeconfig --name eks-cluster --region us-east-2
kubectl get nodes

Deploy with Helm

cd helm/hello
helm upgrade --install hello .
kubectl get ingress

Bonus GitOps Setup (Optional)
1. Switch to gitops branch.
2. Push a commit (e.g., update a dummy file).
3. GitHub Actions builds & pushes Docker image to ECR.
4. Argo CD auto-syncs Helm chart to EKS.
5. Validate deployment via kubectl get pods or Argo CD UI.

Author:
Andrew Linzie
Deployed & documented as part of Tech Challenge 2

---

👉 This README ties everything together and explicitly covers Jenkins *and* GitOps. Do you want me to also prepare a **short submission note/email draft** you can send to your mentor along with the repo link and app URL?