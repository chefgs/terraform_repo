# Terraform v1.2 – Preconditions, Postconditions & replace_triggered_by (May 2022)

## What's New

### 1. Preconditions and Postconditions

Add validation rules to **resources, data sources, and outputs** that run before/after planning.

```hcl
# Precondition on a resource
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type

  lifecycle {
    # Precondition: check before resource is created/updated
    precondition {
      condition     = data.aws_ami.selected.architecture == "x86_64"
      error_message = "The AMI must be x86_64 architecture. Got: ${data.aws_ami.selected.architecture}"
    }

    # Postcondition: check after resource is created
    postcondition {
      condition     = self.public_ip != ""
      error_message = "EC2 instance must have a public IP assigned."
    }
  }
}

# Precondition on a data source
data "aws_ami" "selected" {
  most_recent = true
  owners      = ["amazon"]

  lifecycle {
    postcondition {
      condition     = self.architecture == "x86_64"
      error_message = "Selected AMI must be x86_64."
    }
  }
}

# Precondition on an output
output "api_base_url" {
  value = "https://${aws_lb.this.dns_name}/api"

  precondition {
    condition     = aws_lb.this.load_balancer_type == "application"
    error_message = "Only ALBs are supported for the API endpoint."
  }
}
```

### 2. `replace_triggered_by` – Force Resource Replacement

Force a resource to be replaced when another resource or attribute changes:

```hcl
resource "aws_instance" "app" {
  ami           = data.aws_ami.app.id
  instance_type = var.instance_type

  lifecycle {
    # Replace the EC2 instance whenever the launch template changes
    replace_triggered_by = [
      aws_launch_template.app.id,
      aws_launch_template.app.latest_version,
    ]
  }
}

# Replace on any attribute change of another resource
resource "aws_ecs_service" "app" {
  lifecycle {
    replace_triggered_by = [aws_ecs_task_definition.app]
  }
}
```

### 3. `nullable = false` in Variables

```hcl
variable "name_prefix" {
  type     = string
  nullable = false  # prevents null being passed explicitly
  default  = "myapp"
}
```

## Upgrade from v1.1

No breaking changes. Update `required_version`:

```hcl
terraform {
  required_version = ">= 1.2"
}
```
