
# Comprehensive Terraform Kubernetes Directory Documentation

## Table of Contents

- [What is Infrastructure as Code (IaC)?](#what-is-infrastructure-as-code-iac)
- [Why Terraform for IaC?](#why-terraform-for-iac)
- [Introduction to Terraform](#introduction-to-terraform)
- [Code Structure Overview](#code-structure-overview)
- [File-by-File Code Overview](#file-by-file-code-overview)
- [Modules and Resources](#modules-and-resources)
- [How to Run the Terraform Code](#how-to-run-the-terraform-code)
- [GitHub Actions CI/CD Workflow](#github-actions-cicd-workflow)
- [Kubernetes Provider: Configuration & Kubeconfig YAML](#kubernetes-provider-configuration--kubeconfig-yaml)
- [Kubernetes Provider vs. Cloud-Managed Kubernetes (EKS, AKS, GKE)](#kubernetes-provider-vs-cloud-managed-kubernetes-eks-aks-gke)
- [Detailed Code Walkthrough](#detailed-code-walkthrough)
  - [providers.tf](#providerstf)
  - [variables.tf](#variablestf)
  - [k8s.tf](#k8stf)
  - [outputs.tf](#outputstf)
- [Outputs and Usage](#outputs-and-usage)
- [References](#references)

---

## What is Infrastructure as Code (IaC)?

**Infrastructure as Code (IaC)** is a foundational DevOps practice where infrastructure is provisioned and managed through code rather than manual processes. With IaC, you describe and automate the configuration of servers, networks, Kubernetes clusters, and more using machine-readable files. This approach allows for version control, collaboration, rapid scaling, and repeatability.

### Key Principles

- **Declarative or Imperative:** Most modern IaC tools, including Terraform, are declarative—you describe the desired infrastructure state.
- **Idempotency:** Running the code repeatedly always yields the same infrastructure state.
- **Versioning:** Use of source/version control (like Git) to track all infrastructure changes.
- **Automation:** Eliminates repetitive manual work and reduces configuration drift.

### Benefits

- **Consistency** and **repeatability** across environments (dev, test, prod)
- **Auditability** and **traceability** of changes
- **Faster** deployments and recovery
- **Improved collaboration** among teams

---

## Why Terraform for IaC?

Terraform is a leading open-source IaC tool that supports provisioning and managing infrastructure across various cloud providers and platforms, including Kubernetes. Here’s why Terraform is a top choice:

- **Provider Ecosystem:** Manages resources from AWS, Azure, GCP, Kubernetes, and many others.
- **Declarative Syntax (HCL):** Simple, readable way to describe infrastructure.
- **Execution Plan:** Shows what will change before making changes.
- **State Management:** Tracks the current state of infrastructure for safe, incremental updates.
- **Modularization:** Supports reusable modules for DRY and consistent code.
- **Community & Extensibility:** Huge ecosystem of modules, providers, and extensions.

---

## Introduction to Terraform

Terraform, developed by HashiCorp, uses the HashiCorp Configuration Language (HCL) to define and provision infrastructure. The standard workflow consists of:

1. **Writing configuration files** to describe your infrastructure requirements.
2. **Initializing** (`terraform init`) to download providers and prepare the environment.
3. **Planning** (`terraform plan`) to preview the proposed infrastructure changes.
4. **Applying** (`terraform apply`) to execute changes and manage resources.
5. **Storing state** to track and reconcile actual vs. desired infrastructure.

### **Key Concepts:**

- **Providers:** Plugins for interacting with APIs (e.g., Kubernetes, AWS).
- **Resources:** Objects managed by Terraform (e.g., Kubernetes Deployment).
- **Modules:** Groups of resources packaged for reuse.
- **Variables/Outputs:** Parameterize and expose important values.
- **State:** Local or remote file tracking deployed infrastructure.

---

## Code Structure Overview

This directory contains Terraform code for deploying Kubernetes resources using the Kubernetes provider:

```bash
kubernetes/
├── .terraform.lock.hcl   # Provider lock file (auto-generated)
├── cmds.out              # Example CLI commands or logs (optional)
├── k8s.tf                # Main resource definitions
├── outputs.tf            # Outputs after apply
├── providers.tf          # Provider configuration
├── variables.tf          # Input variables (parameters)
├── README.md             # (Optional) Human-readable documentation
```

---

## File-by-File Code Overview

### 1. `providers.tf`

- **Purpose:** Configures the required Terraform providers, especially the Kubernetes provider.
- **Contents:**
  - Specifies provider source and version.
  - Configures the Kubernetes provider with `config_path` and `config_context` to use the correct kubeconfig and context.

### 2. `variables.tf`

- **Purpose:** Declares all input variables for the Kubernetes resources.
- **Contents:**
  - Variables for namespace, deployment, labels, replica counts, container image, resource requests/limits, environment, and owner.
  - Each variable includes a description, type, and default value.

### 3. `k8s.tf`

- **Purpose:** Main file for resource definitions.
- **Contents:**
  - **Namespace:** Creates and labels a namespace.
  - **Resource Quota:** Limits total resource usage (CPU, memory, pods).
  - **Limit Range:** Sets default/request resource limits for containers.
  - **Deployment:** Deploys a containerized app with security context, probes, and resource settings.
  - **Service:** Exposes the deployment as a ClusterIP service.

### 4. `outputs.tf`

- **Purpose:** Defines outputs to display after `terraform apply`.
- **Contents:**
  - Outputs for namespace name/UID, deployment details, service info (name, cluster IP, ports), resource quotas, pod security, and kubeconfig context.

### 5. `.terraform.lock.hcl`

- **Purpose:** Auto-generated lockfile for provider version pinning.
- **Contents:**
  - Not hand-edited. Ensures reproducible provider versions.

### 6. `cmds.out`

- **Purpose:** (Optional) Stores sample CLI commands and outputs.
- **Contents:**
  - Not required, but useful for knowledge sharing and troubleshooting.

### 7. `README.md`

- **Purpose:** (Optional) Human-readable documentation.
- **Contents:**
  - Project overview, usage, contribution guidelines, etc.

---

## Modules and Resources

### **Modules:**  

No external modules are used here, but you can refactor into modules for reuse.

### **Resources:**

- `kubernetes_namespace`
- `kubernetes_resource_quota`
- `kubernetes_limit_range`
- `kubernetes_deployment`
- `kubernetes_service`

---

## How to Run the Terraform Code

### Prerequisites

- **Terraform CLI:** [Install Terraform](https://www.terraform.io/downloads)
- **Kubernetes Cluster:** (Minikube, EKS, AKS, GKE, or any kubeconfig-accessible cluster)
- **kubectl:** To verify/apply changes.
- **Kubeconfig:** With access to target cluster.

### Steps

1. **Clone the repo and change directory:**

   ```sh
   git clone https://github.com/chefgs/terraform_repo.git
   cd terraform_repo/kubernetes
   ```

2. **Initialize Terraform:**

   ```sh
   terraform init
   ```

3. **(Optional) Customize variables:**  
   Edit `variables.tf`, use `terraform.tfvars`, or pass with `-var` on the CLI.

4. **Plan the deployment:**

   ```sh
   terraform plan
   ```

5. **Apply the configuration:**

   ```sh
   terraform apply
   ```

6. **(Optional) Destroy resources:**

   ```sh
   terraform destroy
   ```

---

## GitHub Actions CI/CD Workflow

This repository includes a GitHub Actions workflow that automates the deployment of Terraform-managed Kubernetes resources. This CI/CD pipeline ensures consistent and reliable infrastructure deployments.

### Workflow Features

- **Automated Testing**: Runs on pull requests and pushes to main branch
- **Manual Triggers**: Can be triggered manually with customizable parameters
- **Environment Setup**: Automatically configures Minikube, kubectl, and Terraform
- **Terraform Operations**: Supports plan, apply, and destroy operations
- **Verification**: Confirms successful deployment with kubectl commands

For detailed information on the workflow, including trigger events, inputs, job structure, and usage examples, see the [Workflow Documentation](workflow_documentation.md).

---

## Kubernetes Provider: Configuration & Kubeconfig YAML

### Provider Configuration (`providers.tf`)

```hcl
terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.38.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}
```

- **config_path:** Path to your kubeconfig file.
- **config_context:** Cluster context name.

### Example Kubeconfig YAML

```yaml
apiVersion: v1
kind: Config
clusters:
- name: minikube
  cluster:
    server: https://127.0.0.1:32768
    certificate-authority: /Users/you/.minikube/ca.crt
contexts:
- name: minikube
  context:
    cluster: minikube
    user: minikube
current-context: minikube
users:
- name: minikube
  user:
    client-certificate: /Users/you/.minikube/client.crt
    client-key: /Users/you/.minikube/client.key
```

**Docs:** [Kubernetes Provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)

---

## Kubernetes Provider vs. Cloud-Managed Kubernetes (EKS, AKS, GKE)

| Feature             | Kubernetes Provider | EKS/AKS/GKE Providers |
|---------------------|--------------------|-----------------------|
| Purpose             | In-cluster resources (Deployment, Service) | Cluster infrastructure (nodes, network) |
| Cluster Provision   | ❌ (Needs existing cluster) | ✅ (Creates clusters) |
| Resource Creation   | ✅ (Pods, Services, etc.) | ❌ (Limited to infra) |
| Kubeconfig Required | ✅                  | Not always            |
| Platform Scope      | Any K8s cluster    | Cloud-specific        |

**Workflow Example:**

1. Use AWS/Azure/GCP provider and EKS/AKS/GKE resource to create a cluster.
2. Export kubeconfig for the new cluster.
3. Use Kubernetes provider with this kubeconfig to manage resources inside the cluster.

---

## Detailed Code Walkthrough

### providers.tf

- **Purpose:** Specifies required providers and configures the Kubernetes provider.
- **Details:** Locks version, uses kubeconfig path and context for authentication.

### variables.tf

- **Purpose:** All input variables for parameterizing resources.
- **Sample Variables:**
  - `namespace`, `deployment_name`, `app_label`, `replica_count`, `container_image`, `container_name`
  - Resource requests/limits for CPU/memory
  - `environment`, `owner`
- **Usage:** Override with CLI flags or a `terraform.tfvars` file.

### k8s.tf

1. **Namespace**

    ```hcl
    resource "kubernetes_namespace" "example" {
      metadata {
        name = var.namespace
        labels = { environment = var.environment }
        annotations = { owner = var.owner }
      }
    }
    ```

2. **Resource Quota & Limit Range**
    - Enforces namespace-wide resource caps and per-container defaults.

3. **Deployment**
    - Deploys an app with labels, resource settings, security context, health checks, and volumes.

4. **Service**
    - Exposes the deployment as a ClusterIP service on port 80.

### outputs.tf

- **Purpose:** Outputs after apply.
- **Examples:**
  - `namespace_name`, `deployment_name`, `service_name`
  - `service_cluster_ip`, `service_endpoint`
  - `pod_security_settings`, `resource_quota_hard`

---

## Outputs and Usage

After `terraform apply`, outputs such as:

- Namespace and deployment names and UIDs
- Service name, cluster IP, and port
- Resource quota and container image info
- Pod security settings

**Verify with kubectl:**

```sh
kubectl get ns
kubectl get deployment -n <namespace>
kubectl get svc -n <namespace>
kubectl describe deployment -n <namespace>
kubectl get pods -n <namespace>
```

---

## References

- [Terraform Official Docs](https://www.terraform.io/docs/)
- [Kubernetes Provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)
- [Kubernetes Official Docs](https://kubernetes.io/)
- [Provisioning EKS with Terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster)
- [Provisioning AKS with Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster)
- [Provisioning GKE with Terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster)
