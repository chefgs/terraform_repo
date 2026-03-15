##############################################################################
# locals.tf – Local Values Best Practices
#
# Use locals for:
#   1. Derived/computed values (avoids repeating expressions)
#   2. Constructing names/tags consistently
#   3. Conditional resource configurations
#   4. Type conversions and data transformations
##############################################################################

locals {
  # ── Name construction ──────────────────────────────────────────────────
  # Single source of truth for resource naming
  name_prefix = "${var.environment}-${var.aws_region}"

  # ── Tag merging ────────────────────────────────────────────────────────
  # Merge common tags with environment-specific ones
  resource_tags = merge(var.common_tags, {
    Environment = var.environment
    Region      = var.aws_region
  })

  # ── Conditional values ─────────────────────────────────────────────────
  # Environment-specific instance type (uses map lookup with fallback)
  effective_instance_type = lookup(
    var.instance_type_per_env,
    var.environment,
    var.instance_type   # fallback to explicit variable
  )

  # Production gets multi-AZ, others use single AZ
  effective_multi_az = var.environment == "prod" ? true : var.database.multi_az

  # ── Derived scaling config ─────────────────────────────────────────────
  # Use desired_capacity from variable or default to min_size
  effective_desired = coalesce(var.scaling_config.desired_capacity, var.scaling_config.min_size)

  # ── List/Map transformations ──────────────────────────────────────────
  # Create a set of unique AZ names (deduplication)
  az_set = toset(var.availability_zones)

  # Create a map from AZ index to AZ name (for resource iteration)
  az_map = { for idx, az in var.availability_zones : idx => az }

  # ── Computed resource sizing ──────────────────────────────────────────
  # Scale storage based on environment
  effective_storage = var.environment == "prod" ? var.database.storage_gb * 2 : var.database.storage_gb

  # ── Boolean flags ─────────────────────────────────────────────────────
  is_production = var.environment == "prod"
  is_dev        = var.environment == "dev"

  # Enable monitoring in prod and staging only
  effective_monitoring = local.is_production || var.environment == "staging" ? true : var.enable_monitoring
}
