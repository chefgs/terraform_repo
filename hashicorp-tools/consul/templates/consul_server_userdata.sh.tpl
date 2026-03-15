#!/bin/bash
# Consul server bootstrapping via cloud-init
set -euo pipefail

CONSUL_VERSION="${consul_version}"
DATACENTER="${datacenter}"
BOOTSTRAP_EXPECT=${bootstrap_expect}
PROJECT_NAME="${project_name}"
AWS_REGION="${aws_region}"

# Get instance private IP from IMDSv2
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
PRIVATE_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)

# Write Consul configuration
mkdir -p /etc/consul.d

cat > /etc/consul.d/consul.hcl <<EOF
datacenter          = "$DATACENTER"
data_dir            = "/opt/consul/data"
log_level           = "INFO"
server              = true
bootstrap_expect    = $BOOTSTRAP_EXPECT
bind_addr           = "$PRIVATE_IP"
client_addr         = "0.0.0.0"
ui_config {
  enabled = true
}

# Auto-join via EC2 tags
retry_join = ["provider=aws tag_key=ConsulAutoJoin tag_value=$PROJECT_NAME region=$AWS_REGION"]

connect {
  enabled = true
}

performance {
  raft_multiplier = 1
}

telemetry {
  prometheus_retention_time = "30s"
  disable_hostname = true
}
EOF

# Start Consul
systemctl enable consul
systemctl start consul
