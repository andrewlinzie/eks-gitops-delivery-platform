# 🚧 Troubleshooting EKS Node Group Creation Failure

## ❌ Issue

When running `terraform apply` to create the EKS cluster and worker node group, Terraform hung on:

```
aws_eks_node_group.main: Still creating...
```

Eventually, AWS returned:

```
Error: waiting for EKS Node Group create: unexpected state 'CREATE_FAILED'
last error: NodeCreationFailure: Instances failed to join the Kubernetes cluster
```

Even though the worker node EC2 instances were running in the AWS Console, they were **not registering with the EKS control plane**, and `kubectl get nodes` showed no resources.

---

## 🔎 Root Causes

1. **Subnet Misconfiguration**

   * Original subnet CIDRs conflicted (`10.0.1.0/24`, `10.0.2.0/24` overlapped with other subnets).
   * Public subnets did not have `map_public_ip_on_launch = true`, so nodes couldn’t get public IPs for internet access.

2. **RBAC / IAM Mapping**

   * By default, worker nodes must be explicitly mapped in the EKS `aws-auth` ConfigMap.
   * Without this, EC2s launch but EKS rejects them.

3. **Missing Node Bootstrap**

   * Although the correct EKS-optimized AMI was used, nodes didn’t automatically bootstrap into the cluster.
   * They needed a `user_data` script to run `/etc/eks/bootstrap.sh eks-cluster`.

---

## 🛠️ Troubleshooting Steps Taken

1. **Verified EC2 Worker Instances**

   * Checked EC2 console → confirmed workers were running and healthy with IAM role attached.
   * Noticed they had public IPs only after fixing subnet auto-assign.

2. **Fixed Subnet Config**

   * Updated VPC Terraform:

     * Ensured unique CIDRs (`10.0.100.0/24`, `10.0.101.0/24`).
     * Set `map_public_ip_on_launch = true` for public subnets.

3. **Applied aws-auth ConfigMap**

   * Created `k8s-manifests/aws-auth.yaml` with:

     ```yaml
     mapRoles:
       - rolearn: arn:aws:iam::899631475351:role/eks-node-group-role
         username: system:node:{{EC2PrivateDNSName}}
         groups:
           - system:bootstrappers
           - system:nodes
     ```
   * Applied via `kubectl apply -f aws-auth.yaml`.

4. **Added Bootstrap to Launch Template**

   * Updated Terraform `aws_launch_template` with:

     ```hcl
     user_data = base64encode(<<EOF
     #!/bin/bash
     /etc/eks/bootstrap.sh eks-cluster
     EOF
     )
     ```

5. **Recreated Node Group**

   * Destroyed failed node group:

     ```bash
     terraform destroy -target=aws_eks_node_group.main -auto-approve
     ```
   * Re-applied Terraform to create fresh node group with corrected config.

6. **Validation**

   * Ran `kubectl get nodes` → saw worker node in `Ready` state:

     ```
     ip-10-0-100-64.us-east-2.compute.internal   Ready   <none>   v1.31.11-eks
     ```

---

## ✅ Resolution

After fixing subnet config, applying `aws-auth`, and adding the bootstrap script, the worker nodes successfully joined the EKS cluster.

---

## 📚 Lessons Learned

* Always confirm **public subnet attributes** (`map_public_ip_on_launch`) when worker nodes need internet access.
* Ensure the **`aws-auth` ConfigMap** is in place to map worker node IAM roles.
* Sometimes the AMI isn’t enough — explicitly providing **`bootstrap.sh`** in `user_data` ensures node registration.
* Use AWS Console (EC2, EKS Events) to cross-check when Terraform seems stuck.
