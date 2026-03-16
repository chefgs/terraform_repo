##############################################################################
# ASG – Auto Scaling Groups for Web Tier and App Tier
#
# Provisions:
#   - IAM instance profiles (for Vault IAM auth & Consul auto-join)
#   - Launch templates for web and app tiers
#   - Auto Scaling Groups registered with the ALB target groups
##############################################################################

# ── IAM Role: Web Tier ────────────────────────────────────────────────────
resource "aws_iam_role" "web" {
  name = "${var.project_name}-web-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "web_permissions" {
  name = "${var.project_name}-web-permissions"
  role = aws_iam_role.web.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sts:GetCallerIdentity"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["ec2:DescribeInstances", "ec2:DescribeTags"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "web" {
  name = "${var.project_name}-web-instance-profile"
  role = aws_iam_role.web.name
}

# ── IAM Role: App Tier ────────────────────────────────────────────────────
resource "aws_iam_role" "app" {
  name = "${var.project_name}-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "app_permissions" {
  name = "${var.project_name}-app-permissions"
  role = aws_iam_role.app.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sts:GetCallerIdentity"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["ec2:DescribeInstances", "ec2:DescribeTags"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "app" {
  name = "${var.project_name}-app-instance-profile"
  role = aws_iam_role.app.name
}

# ── Launch Template: Web Tier ─────────────────────────────────────────────
resource "aws_launch_template" "web" {
  name_prefix   = "${var.project_name}-web-"
  image_id      = var.web_ami_id
  instance_type = var.web_instance_type

  iam_instance_profile {
    arn = aws_iam_instance_profile.web.arn
  }

  vpc_security_group_ids = [aws_security_group.web.id]

  key_name = var.key_name != "" ? var.key_name : null

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    # Start Nginx (installed and configured by Packer)
    systemctl enable nginx
    systemctl start nginx
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "${var.project_name}-web-server"
      Tier    = "web"
      Project = var.project_name
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ── Auto Scaling Group: Web Tier ──────────────────────────────────────────
resource "aws_autoscaling_group" "web" {
  name                = "${var.project_name}-web-asg"
  min_size            = var.web_min_size
  max_size            = var.web_max_size
  desired_capacity    = var.web_desired_capacity
  vpc_zone_identifier = aws_subnet.public[*].id

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.web.arn]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "${var.project_name}-web-server"
    propagate_at_launch = true
  }

  tag {
    key                 = "Tier"
    value               = "web"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ── Launch Template: App Tier ─────────────────────────────────────────────
resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-app-"
  image_id      = var.app_ami_id
  instance_type = var.app_instance_type

  iam_instance_profile {
    arn = aws_iam_instance_profile.app.arn
  }

  vpc_security_group_ids = [aws_security_group.app.id]

  key_name = var.key_name != "" ? var.key_name : null

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    # Start the Node.js application (installed and configured by Packer)
    systemctl enable app
    systemctl start app
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "${var.project_name}-app-server"
      Tier    = "app"
      Project = var.project_name
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ── Auto Scaling Group: App Tier ──────────────────────────────────────────
resource "aws_autoscaling_group" "app" {
  name                = "${var.project_name}-app-asg"
  min_size            = var.app_min_size
  max_size            = var.app_max_size
  desired_capacity    = var.app_desired_capacity
  vpc_zone_identifier = aws_subnet.private[*].id

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app.arn]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "${var.project_name}-app-server"
    propagate_at_launch = true
  }

  tag {
    key                 = "Tier"
    value               = "app"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
