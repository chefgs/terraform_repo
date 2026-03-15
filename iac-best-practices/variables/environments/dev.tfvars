# dev.tfvars – Development environment variable overrides
environment      = "dev"
instance_count   = 1
enable_monitoring = false

database = {
  engine         = "postgres"
  engine_version = "16.1"
  instance_class = "db.t3.micro"
  storage_gb     = 20
  multi_az       = false
  backup_days    = 1
}

scaling_config = {
  min_size = 1
  max_size = 2
}
