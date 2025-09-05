# Terraform Kubernetes Configuration Explained

This document provides a comprehensive explanation of the Terraform configuration for deploying a Kubernetes application. It breaks down each section of the code to help understand how resources are created and configured.

## Table of Contents

- [Namespace Resource](#namespace-resource)
- [Resource Quota](#resource-quota)
- [Limit Range](#limit-range)
- [Deployment Resource](#deployment-resource)
- [Deployment Specification](#deployment-specification)
- [Pod Template](#pod-template)
- [Container Specification](#container-specification)
- [Resource Limits](#resource-limits-for-container)
- [Health Checks](#health-checks)
- [Security Context](#security-context)
- [Volume Mounts](#volume-mounts)
- [Volumes Definition](#volumes-definition)
- [Service Resource](#service-resource)
- [Summary](#summary)

## Namespace Resource

```terraform
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

**Explanation:**

- Creates a Kubernetes namespace (isolated cluster environment)
- Sets the namespace name from the `namespace` variable (default: "k8s-ns-by-tf")
- Adds an environment label for organization (default: "dev")
- Adds an owner annotation for tracking ownership (default: "chefgs")

## Resource Quota

```terraform
resource "kubernetes_resource_quota" "example" {
  metadata {
    name      = "rq-example"
    namespace = kubernetes_namespace.example.metadata[0].name
  }
  spec {
    hard = {
      "pods"           = 10
      "requests.cpu"   = "2"
      "requests.memory"= "2Gi"
      "limits.cpu"     = "4"
      "limits.memory"  = "4Gi"
    }
  }
}
```

**Explanation:**

- Creates resource limits for the namespace to prevent overuse
- References the namespace created above using `kubernetes_namespace.example.metadata[0].name`
- Sets hard limits for the namespace:
  - Maximum 10 pods
  - CPU request limit of 2 cores total
  - Memory request limit of 2 GB total
  - CPU limit ceiling of 4 cores total
  - Memory limit ceiling of 4 GB total

## Limit Range

```terraform
resource "kubernetes_limit_range" "example" {
  metadata {
    name      = "lr-example"
    namespace = kubernetes_namespace.example.metadata[0].name
  }
  spec {
    limit {
      type = "Container"
      default = {
        cpu    = var.resource_limits_cpu
        memory = var.resource_limits_memory
      }
      default_request = {
        cpu    = var.resource_requests_cpu
        memory = var.resource_requests_memory
      }
    }
  }
}
```

**Explanation:**

- Creates default resource constraints for containers in the namespace
- Sets default limits if not specified in a pod (ceiling):
  - CPU: 500m (half a core)
  - Memory: 512Mi
- Sets default requests if not specified (guaranteed resources):
  - CPU: 250m (quarter of a core)
  - Memory: 50Mi

## Deployment Resource

```terraform
resource "kubernetes_deployment" "example" {
  metadata {
    name      = var.deployment_name
    namespace = kubernetes_namespace.example.metadata[0].name
    labels = {
      app         = var.app_label
      environment = var.environment
    }
    annotations = {
      owner = var.owner
    }
  }
  
  # Add lifecycle block to handle recreation without errors
  lifecycle {
    create_before_destroy = true
  }
```

**Explanation:**

- Creates a Kubernetes deployment (manages Pod replicas)
- Sets the deployment name to "terraform-example" (from variable)
- Places it in our created namespace
- Adds labels for filtering and organization
- Includes a lifecycle block that ensures a new deployment is created before destroying the old one, helping with zero-downtime updates

## Deployment Specification

```terraform
  spec {
    replicas = var.replica_count

    selector {
      match_labels = {
        app = var.app_label
      }
    }
```

**Explanation:**

- Sets the number of pod replicas to 2 (from variable)
- The selector defines which pods the deployment manages (those with the app=MyExampleApp label)

## Pod Template

```terraform
    template {
      metadata {
        labels = {
          app         = var.app_label
          environment = var.environment
        }
        annotations = {
          owner = var.owner
        }
      }
```

**Explanation:**

- Defines the template for pods created by this deployment
- Adds the same labels and annotations to each pod

## Container Specification

```terraform
      spec {
        container {
          image = var.container_image
          name  = var.container_name
          
          port {
            container_port = 8080
          }
```

**Explanation:**

- Specifies container details for each pod
- Uses the nginxinc/nginx-unprivileged:1.25-alpine image (from variable)
- Names the container "example"
- Explicitly defines that the container listens on port 8080

## Resource Limits for Container

```terraform
          resources {
            limits = {
              cpu    = var.resource_limits_cpu
              memory = var.resource_limits_memory
            }
            requests = {
              cpu    = var.resource_requests_cpu
              memory = var.resource_requests_memory
            }
          }
```

**Explanation:**

- Sets resource constraints for the container:
  - Maximum CPU: 500m (half a core)
  - Maximum memory: 512Mi
  - Guaranteed CPU: 250m (quarter of a core)
  - Guaranteed memory: 50Mi

## Health Checks

```terraform
          liveness_probe {
            http_get {
              path = "/"
              port = 8080
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 8080
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
```

**Explanation:**

- **Liveness probe**: Checks if the container is running properly
  - Makes an HTTP GET request to path "/" on port 8080
  - Waits 10 seconds before first check
  - Repeats check every 10 seconds
  - If it fails, Kubernetes restarts the container

- **Readiness probe**: Checks if the container is ready to receive traffic
  - Makes an HTTP GET request to path "/" on port 8080
  - Waits 5 seconds before first check
  - Repeats check every 5 seconds
  - If it fails, Kubernetes removes the pod from service endpoints

## Security Context

```terraform
          security_context {
            run_as_non_root           = true
            read_only_root_filesystem = true
          }
```

**Explanation:**

- Enhances container security:
  - Forces container to run as a non-root user
  - Makes the root filesystem read-only (improves security)

## Volume Mounts

```terraform
          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
          }
          
          volume_mount {
            name       = "var-cache-nginx"
            mount_path = "/var/cache/nginx"
          }
          
          volume_mount {
            name       = "var-run"
            mount_path = "/var/run"
          }
        }
```

**Explanation:**

- Defines writable areas for the container even with a read-only root filesystem:
  - `/tmp`: For temporary files
  - `/var/cache/nginx`: For nginx cache
  - `/var/run`: For runtime files

## Volumes Definition

```terraform
        volume {
          name = "tmp"
          empty_dir {}
        }
        
        volume {
          name = "var-cache-nginx"
          empty_dir {}
        }
        
        volume {
          name = "var-run"
          empty_dir {}
        }
      }
```

**Explanation:**

- Creates the actual volume resources:
  - All three use the `empty_dir` type (ephemeral storage that exists for the pod's lifetime)
  - When the pod is deleted, these volumes are also deleted
  - Each volume matches a mount in the container section

## Service Resource

```terraform
resource "kubernetes_service" "example" {
  metadata {
    name      = "${var.deployment_name}-svc"
    namespace = kubernetes_namespace.example.metadata[0].name
    labels = {
      app = var.app_label
    }
  }

  spec {
    selector = {
      app = var.app_label
    }
    port {
      port        = 80
      target_port = 8080
      protocol    = "TCP"
    }
    type = "ClusterIP"
  }
}
```

**Explanation:**

- Creates a Kubernetes service to expose pods
- Names it "terraform-example-svc"
- The selector targets pods with the app=MyExampleApp label
- Port mapping:
  - External port: 80 (service exposes on port 80)
  - Target port: 8080 (routes traffic to port 8080 on the pods)
- Type "ClusterIP" means the service is only accessible within the cluster

## Summary

This Terraform configuration:

1. Creates an isolated namespace with resource limitations
2. Deploys a nginx web server (unprivileged version) with 2 replicas
3. Adds proper health checks, security contexts, and writable volumes
4. Exposes the web server via a service

The configuration follows Kubernetes best practices by:

- Using non-root containers
- Implementing read-only root filesystems
- Setting resource limits
- Adding health checks
- Using proper labels and annotations
- Providing a lifecycle block for smooth updates

---


## **Creating Kubernetes Clusters: YAML vs Terraform**

Comparison for creating Kubernetes YAML vs Terraform for creating a Kubernetes cluster

## **1️⃣ Kubernetes YAML Method**

### **Approach**

* Write raw YAML manifests (`apiVersion`, `kind`, `metadata`, `spec`) to define cluster resources (Deployments, Services, ConfigMaps, etc.).
* Apply using `kubectl apply -f`.

### **Steps**

1. Install `kubectl` and configure kubeconfig.
2. Create YAML for cluster components (usually requires a cluster already provisioned by cloud CLI or managed service).

   ```yaml
   apiVersion: v1
   kind: Service
   metadata:
     name: my-service
   spec:
     selector:
       app: my-app
     ports:
       - protocol: TCP
         port: 80
         targetPort: 9376
   ```
3. Run `kubectl apply -f service.yaml`.

### **Pros**

* Direct control over Kubernetes-native resources.
* Well-documented, widely adopted, good for learning K8s.
* Works with Helm for templating and reusability.

### **Cons**

* Cannot provision underlying infra (VPC, nodes, load balancers).
* State is not managed — config drift if changes applied manually.
* Harder to reuse across environments (dev, staging, prod).
* Needs GitOps tools (ArgoCD/Flux) to achieve declarative management at scale.

---

## **2️⃣ Terraform Method**

### **Approach**

* Use Terraform to provision both **cloud infra** (EKS, GKE, AKS, networking, storage) and Kubernetes resources.
* Supports both **Terraform-native Kubernetes resources** and **embedding YAML**.

### **Steps**

1. Write Terraform configuration for cluster creation:

   ```hcl
   resource "aws_eks_cluster" "example" {
     name     = "my-eks-cluster"
     role_arn = aws_iam_role.eks.arn
     vpc_config {
       subnet_ids = aws_subnet.public[*].id
     }
   }
   ```
2. Provision workloads using either:

   * **Terraform-native resources**:

     ```hcl
     resource "kubernetes_deployment" "nginx" {
       metadata {
         name = "nginx"
       }
       spec {
         replicas = 2
         selector { match_labels = { app = "nginx" } }
         template {
           metadata { labels = { app = "nginx" } }
           spec {
             container {
               name  = "nginx"
               image = "nginx:1.14.2"
             }
           }
         }
       }
     }
     ```
   * **YAML inside Terraform**:

     ```hcl
     resource "kubernetes_manifest" "nginx" {
       manifest = yamldecode(file("${path.module}/nginx-deployment.yaml"))
     }
     ```
3. Run:

   * `terraform init`
   * `terraform plan`
   * `terraform apply`

### **Pros**

* End-to-end automation: cluster + networking + storage + workloads.
* State management → prevents drift.
* Works across multi-cloud/hybrid environments.
* Modules → reusable and consistent across teams.
* CI/CD integration is straightforward.

### **Cons**

* Learning curve (HCL, providers, backend state).
* Some K8s features may lag in Terraform provider.
* Extra abstraction compared to direct YAML.

---

## **3️⃣ Key Takeaways**

* **Kubernetes YAML** → good for defining and applying workloads inside a cluster you already have.
* **Terraform** → ideal for provisioning **both the cluster itself and the workloads**, with automation, state management, and consistency.

✅ **Recommendation:**

* Use **Terraform-native resources** if your team is already Terraform-first.
* Use **YAML inside Terraform** if your team prefers YAML but still wants Terraform’s state and automation.
* Combine Terraform (infra + cluster) + YAML/Helm (apps) in GitOps workflows for best of both worlds.

