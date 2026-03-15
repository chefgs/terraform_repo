# Terraform v1.3 – Optional Object Attributes & Import Improvements (September 2022)

## What's New

### 1. Optional Object Type Attributes

Object type variables can now have **optional attributes with defaults**:

```hcl
variable "server_config" {
  type = object({
    instance_type = string
    disk_size_gb  = optional(number, 20)        # optional with default 20
    enable_backup = optional(bool, true)         # optional with default true
    tags          = optional(map(string), {})    # optional with default {}
    extra_disks   = optional(list(string))       # optional, defaults to null
  })
}

# Caller can omit optional attributes:
server_config = {
  instance_type = "t3.medium"
  # disk_size_gb defaults to 20
  # enable_backup defaults to true
  # tags defaults to {}
}
```

### 2. `terraform import` Improvements

Import now supports module addresses and count/for_each indexes:

```bash
# Import into module
terraform import module.network.aws_vpc.this vpc-12345678

# Import into for_each resource
terraform import 'aws_instance.web["us-east-1a"]' i-12345678

# Import into count-indexed resource
terraform import 'aws_instance.web[0]' i-12345678
```

### 3. `null` Values in `for_each`

```hcl
variable "optional_resources" {
  type = map(object({
    enabled = optional(bool, true)
  }))
}

# Filter out disabled resources
resource "aws_s3_bucket" "this" {
  for_each = {
    for k, v in var.optional_resources : k => v if v.enabled
  }
  bucket = each.key
}
```

### 4. `startswith()` and `endswith()` Functions

```hcl
# New string functions
locals {
  is_prod_region = startswith(var.aws_region, "us-")
  is_s3_arn      = startswith(var.resource_arn, "arn:aws:s3:")
  is_tf_file     = endswith(var.filename, ".tf")
}
```

## Upgrade from v1.2

No breaking changes. Update `required_version`:

```hcl
terraform {
  required_version = ">= 1.3"
}
```
