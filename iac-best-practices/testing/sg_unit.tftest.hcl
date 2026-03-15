##############################################################################
# Security Group Module Unit Tests
# Uses mock_provider (Terraform 1.7+) to test SG rules without real AWS
##############################################################################

mock_provider "aws" {
  mock_resource "aws_security_group" {
    defaults = {
      id  = "sg-mock12345678"
      arn = "arn:aws:ec2:us-east-1:123456789012:security-group/sg-mock12345678"
    }
  }
}

# ── Test: Web tier security group rules ────────────────────────────────────
run "web_sg_http_https" {
  command = plan

  variables {
    name   = "test-web-sg"
    vpc_id = "vpc-mock12345678"

    ingress_rules = [
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow HTTP"
      },
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow HTTPS"
      },
    ]
  }

  assert {
    condition     = aws_security_group.this.name == "test-web-sg"
    error_message = "Security group name should match input variable"
  }

  assert {
    condition     = length(aws_security_group.this.ingress) == 2
    error_message = "Should have exactly 2 ingress rules (HTTP + HTTPS)"
  }
}

# ── Test: Default allow-all egress rule ────────────────────────────────────
run "sg_default_egress" {
  command = plan

  variables {
    name   = "test-sg"
    vpc_id = "vpc-mock12345678"
    # No custom egress rules – should get default allow-all
  }

  assert {
    condition     = length(aws_security_group.this.egress) == 1
    error_message = "Should have exactly 1 default egress rule"
  }
}

# ── Test: Custom egress restriction ────────────────────────────────────────
run "sg_restricted_egress" {
  command = plan

  variables {
    name   = "test-sg-restricted"
    vpc_id = "vpc-mock12345678"

    egress_rules = [
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow HTTPS outbound only"
      }
    ]
  }

  assert {
    condition     = length(aws_security_group.this.egress) == 1
    error_message = "Should have only 1 restricted egress rule"
  }
}
