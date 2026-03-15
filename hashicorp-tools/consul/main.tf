##############################################################################
# Consul – Service Discovery & Service Mesh for 2-Tier AWS App
#
# This sets up:
#   1. Security groups for Consul server and client communication
#   2. Consul server Auto Scaling Group (3-node cluster)
#   3. IAM roles allowing instances to auto-join via EC2 tags (aws-sdk)
#   4. Service registration configs for web and app tiers
##############################################################################

# ── Data Sources ──────────────────────────────────────────────────────────
data "aws_vpc" "main" {
  id = var.vpc_id
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Tier"
    values = ["private"]
  }
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

# ── Consul Server Security Group ──────────────────────────────────────────
resource "aws_security_group" "consul_servers" {
  name        = "${var.project_name}-consul-servers"
  description = "Security group for Consul server nodes"
  vpc_id      = var.vpc_id

  # Consul RPC port
  ingress {
    from_port   = 8300
    to_port     = 8300
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
    description = "Consul RPC"
  }

  # Consul Serf LAN (TCP+UDP)
  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
    description = "Consul Serf LAN TCP"
  }
  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "udp"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
    description = "Consul Serf LAN UDP"
  }

  # Consul Serf WAN (TCP+UDP)
  ingress {
    from_port   = 8302
    to_port     = 8302
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
    description = "Consul Serf WAN TCP"
  }

  # Consul HTTP API
  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
    description = "Consul HTTP API"
  }

  # Consul DNS
  ingress {
    from_port   = 8600
    to_port     = 8600
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
    description = "Consul DNS TCP"
  }
  ingress {
    from_port   = 8600
    to_port     = 8600
    protocol    = "udp"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
    description = "Consul DNS UDP"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-consul-servers"
    Project = var.project_name
  }
}

# ── IAM Role for Consul EC2 Auto-Join ─────────────────────────────────────
resource "aws_iam_role" "consul_server" {
  name = "${var.project_name}-consul-server-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "consul_auto_join" {
  name = "consul-auto-join"
  role = aws_iam_role.consul_server.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ec2:DescribeInstances",
        "ec2:DescribeTags",
        "autoscaling:DescribeAutoScalingGroups",
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_instance_profile" "consul_server" {
  name = "${var.project_name}-consul-server-profile"
  role = aws_iam_role.consul_server.name
}

# ── Consul Server Launch Template ──────────────────────────────────────────
resource "aws_launch_template" "consul_server" {
  name_prefix   = "${var.project_name}-consul-server-"
  image_id      = var.consul_ami_id
  instance_type = var.consul_instance_type

  iam_instance_profile {
    arn = aws_iam_instance_profile.consul_server.arn
  }

  vpc_security_group_ids = [aws_security_group.consul_servers.id]

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # IMDSv2 required
    http_put_response_hop_limit = 1
  }

  user_data = base64encode(templatefile("${path.module}/templates/consul_server_userdata.sh.tpl", {
    consul_version    = var.consul_version
    datacenter        = var.consul_datacenter
    bootstrap_expect  = var.consul_server_count
    project_name      = var.project_name
    aws_region        = var.aws_region
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "${var.project_name}-consul-server"
      Project = var.project_name
      Role    = "consul-server"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ── Consul Server Auto Scaling Group ──────────────────────────────────────
resource "aws_autoscaling_group" "consul_servers" {
  name                = "${var.project_name}-consul-servers"
  min_size            = var.consul_server_count
  max_size            = var.consul_server_count
  desired_capacity    = var.consul_server_count
  vpc_zone_identifier = data.aws_subnets.private.ids

  launch_template {
    id      = aws_launch_template.consul_server.id
    version = "$Latest"
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "${var.project_name}-consul-server"
    propagate_at_launch = true
  }
  tag {
    key                 = "ConsulAutoJoin"
    value               = var.project_name
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
