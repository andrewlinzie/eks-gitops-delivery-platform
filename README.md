# Branch Purpose

This branch introduces a pre-deployment Kubernetes health check script.

Includes:
- Bash script for cluster validation
- checks for pod health, node readiness, and service availability

Intended as an extension to the main GitOps pipeline.

# Pre-Deployment Cluster Health Gate

To prevent deployments during unstable cluster conditions, a pre-deployment health check stage was added to the CI/CD pipeline.

The health-check script verifies:
- Kubernetes node readiness
- Pod failure states (CrashLoopBackOff / Error)
- Node CPU utilization
- Node memory utilization

If any condition fails, the script exits with a non-zero status, causing Jenkins to halt the pipeline before deployment.

# Healthy Pipeline Run

When cluster conditions meet configured thresholds:

```
CPU=80%
MEMORY=80%
```

The pipeline proceeds to Helm deployment.

# Simulated Failure Scenario

To validate the guardrail behavior, thresholds were temporarily set to:

```
CPU=1%
MEMORY=1%
```

This forced the health check to fail.

The Jenkins pipeline then halted with:

```
Cluster health check FAILED
Stage "Helm Deploy/Upgrade" skipped due to earlier failure(s)
```

This confirms the deployment gate prevents application rollout during unhealthy cluster conditions.