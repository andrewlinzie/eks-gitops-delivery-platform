# GitOps Branch – EKS GitOps Delivery Platform

## Purpose

This branch focuses on the GitOps-based deployment workflow using GitHub Actions and Argo CD.

It demonstrates a modern deployment model where application state is managed declaratively through Git and automatically reconciled into the Kubernetes cluster.

## Key Differences from Main

- Uses GitHub Actions as the primary CI pipeline
- Implements GitOps deployment via Argo CD
- Emphasizes declarative infrastructure and automated reconciliation

## Workflow

1. Code is pushed to repository
2. GitHub Actions builds and pushes images to ECR
3. Deployment manifests are updated in Git
4. Argo CD detects changes
5. Cluster state is reconciled automatically

## Notes

This branch isolates the GitOps approach from the legacy Jenkins-based pipeline in the main branch.