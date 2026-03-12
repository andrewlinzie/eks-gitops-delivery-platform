GitOps / ArgoCD layout

- projects/: ArgoCD AppProjects (RBAC + boundaries)
- apps/: App-of-apps definitions and per-app Application manifests
- clusters/: per-environment "entrypoints" (dev/staging/prod) that ArgoCD syncs
- bootstrap/: optional manifests to install/bootstrap ArgoCD (often separate)
