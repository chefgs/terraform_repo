---
layout: default
title: Kubernetes
nav_order: 3
---

# Kubernetes with Terraform

This section covers the Terraform code for deploying and managing Kubernetes resources using the [Terraform Kubernetes provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs).

---

## Table of Contents

- [Overview](#overview)
- [Code Structure](#code-structure)
- [Key Resources](#key-resources)
- [Configuration Details](#configuration-details)
- [Running the Code](#running-the-code)
- [Kubernetes Provider vs Cloud-Managed K8s](#kubernetes-provider-vs-cloud-managed-kubernetes)

---

## Overview

The `kubernetes/` directory demonstrates how to manage Kubernetes cluster resources entirely through Terraform — without writing YAML manifests. The Terraform Kubernetes provider translates HCL definitions into API calls against your cluster.

**Supported clusters:**
- [Minikube](https://minikube.sigs.k8s.io/) (local development)
- [Amazon EKS](https://aws.amazon.com/eks/)
- [Azure AKS](https://azure.microsoft.com/en-us/products/kubernetes-service/)
- [Google GKE](https://cloud.google.com/kubernetes-engine)
- Any kubeconfig-accessible Kubernetes cluster

---

## Code Structure

```
kubernetes/
├── providers.tf          # Kubernetes provider configuration
├── veriables.tf          # Input variables (namespace, images, replicas, etc.)
├── k8s.tf                # Main Kubernetes resource definitions
├── outputs.tf            # Terraform outputs after apply
├── .terraform.lock.hcl   # Provider lock file (auto-generated)
├── k8s_tf_implementation.md  # Detailed implementation notes
└── workflow_documentation.md # CI/CD workflow documentation
```

---

## Key Resources

### 1. Provider Configuration (`providers.tf`)

```hcl
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}
```

- **`config_path`** — Path to your kubeconfig file
- **`config_context`** — The cluster context to use

### 2. Namespace

```hcl
resource "kubernetes_namespace" "example" {
  metadata {
    name = var.namespace
    labels = {
      environment = var.environment
    }
    annotations = {
      owner = var.owner
    }
  }
}
```

### 3. Resource Quota

Enforce namespace-wide resource consumption limits:

```hcl
resource "kubernetes_resource_quota" "example" {
  metadata {
    name      = "${var.namespace}-quota"
    namespace = kubernetes_namespace.example.metadata[0].name
  }
  spec {
    hard = {
      "requests.cpu"    = "2"
      "requests.memory" = "2Gi"
      "limits.cpu"      = "4"
      "limits.memory"   = "4Gi"
      "pods"            = "10"
    }
  }
}
```

### 4. Deployment

```hcl
resource "kubernetes_deployment" "example" {
  metadata {
    name      = var.deployment_name
    namespace = kubernetes_namespace.example.metadata[0].name
    labels    = { app = var.app_label }
  }

  spec {
    replicas = var.replica_count

    selector {
      match_labels = { app = var.app_label }
    }

    template {
      metadata {
        labels = { app = var.app_label }
      }

      spec {
        container {
          name  = var.container_name
          image = var.container_image

          resources {
            requests = {
              cpu    = var.cpu_request
              memory = var.memory_request
            }
            limits = {
              cpu    = var.cpu_limit
              memory = var.memory_limit
            }
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = 8080
            }
            initial_delay_seconds = 10
            period_seconds        = 5
          }
        }
      }
    }
  }
}
```

### 5. Service

```hcl
resource "kubernetes_service" "example" {
  metadata {
    name      = "${var.deployment_name}-service"
    namespace = kubernetes_namespace.example.metadata[0].name
  }

  spec {
    selector = { app = var.app_label }

    port {
      port        = 80
      target_port = 8080
    }

    type = "ClusterIP"
  }
}
```

---

## Configuration Details

### Input Variables (`veriables.tf`)

| Variable | Description | Default |
|----------|-------------|---------|
| `namespace` | Kubernetes namespace name | `"k8s-ns-by-tf"` |
| `deployment_name` | Name of the deployment | `"tf-k8s-deployment"` |
| `app_label` | Label for pod selector | `"tf-k8s-app"` |
| `replica_count` | Number of pod replicas | `2` |
| `container_image` | Container image to deploy | `"nginx:latest"` |
| `container_name` | Container name | `"tf-k8s-container"` |
| `cpu_request` | CPU resource request | `"100m"` |
| `memory_request` | Memory resource request | `"128Mi"` |
| `cpu_limit` | CPU resource limit | `"500m"` |
| `memory_limit` | Memory resource limit | `"256Mi"` |
| `environment` | Environment label | `"dev"` |
| `owner` | Annotation for resource ownership | `"terraform"` |

### Outputs (`outputs.tf`)

After `terraform apply`, the following values are displayed:

- `namespace_name` — Created namespace name
- `deployment_name` — Deployment resource name
- `service_name` — Service resource name
- `service_cluster_ip` — Assigned ClusterIP address
- `service_endpoint` — Full service endpoint URL
- `resource_quota_hard` — Enforced resource quota limits
- `pod_security_settings` — Security context configuration

---

## Running the Code

### Prerequisites

- [Terraform CLI](https://www.terraform.io/downloads)
- A running Kubernetes cluster (Minikube recommended for local dev)
- [kubectl](https://kubernetes.io/docs/tasks/tools/) configured for your cluster

### Local Setup with Minikube

```bash
# Start Minikube
minikube start

# Verify the context
kubectl config current-context  # should output "minikube"

# Clone and navigate
git clone https://github.com/chefgs/terraform_repo.git
cd terraform_repo/kubernetes

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply (creates namespace, quota, deployment, service)
terraform apply

# Verify the deployment
kubectl get ns
kubectl get deployment -n k8s-ns-by-tf
kubectl get svc -n k8s-ns-by-tf
kubectl get pods -n k8s-ns-by-tf

# Clean up
terraform destroy
```

### Custom Variables

Override variables with a `terraform.tfvars` file:

```hcl
# terraform.tfvars
namespace        = "my-namespace"
replica_count    = 3
container_image  = "my-registry/my-app:v1.0.0"
environment      = "production"
owner            = "platform-team"
```

---

## Kubernetes Provider vs Cloud-Managed Kubernetes

Understanding when to use the Kubernetes provider vs cloud-specific providers:

| Feature | Kubernetes Provider | EKS / AKS / GKE Providers |
|---------|--------------------|-----------------------------|
| **Purpose** | Manage in-cluster resources | Provision cluster infrastructure |
| **Creates cluster** | ❌ (requires existing cluster) | ✅ |
| **Manages Deployments, Services** | ✅ | ❌ |
| **Kubeconfig required** | ✅ | Not always |
| **Platform scope** | Any K8s cluster | Cloud-specific |

### Typical Workflow

```
1. Use AWS/Azure/GCP provider to CREATE the cluster (EKS/AKS/GKE resource)
       ↓
2. Export kubeconfig from the new cluster
       ↓
3. Use Kubernetes provider with that kubeconfig to MANAGE resources inside the cluster
```

---

## GitHub Actions CI/CD

The [Terraform Kubernetes Workflow](https://github.com/chefgs/terraform_repo/actions/workflows/tf_code_validation_k8s.yml) automates:

1. Spins up a Minikube cluster in the GitHub Actions runner
2. Installs kubectl and Terraform
3. Runs `terraform init`, `validate`, and `plan`
4. Applies the configuration (`terraform apply`)
5. Verifies the deployment with `kubectl get deployment`
6. Runs `terraform destroy` to clean up

See the [GitHub Actions page](./github-actions) for full workflow documentation.

---

## References

- [Terraform Kubernetes Provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)
- [Kubernetes Official Docs](https://kubernetes.io/docs/)
- [Minikube Getting Started](https://minikube.sigs.k8s.io/docs/start/)
- [Provisioning EKS with Terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster)
- [Provisioning AKS with Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster)
- [Provisioning GKE with Terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster)

---

*[← Back to AWS Samples](./aws-samples)* | *[Next: Cloud Providers →](./cloud-providers)*
