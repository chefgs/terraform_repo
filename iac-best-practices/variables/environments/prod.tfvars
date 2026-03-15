# prod.tfvars – Production environment variable overrides
environment      = "prod"
instance_count   = 3
enable_monitoring = true

database = {
  engine         = "postgres"
  engine_version = "16.1"
  instance_class = "db.r6g.large"
  storage_gb     = 100
  multi_az       = true
  backup_days    = 30
}

scaling_config = {
  min_size         = 2
  max_size         = 10
  desired_capacity = 3
  cooldown_seconds = 300
}
