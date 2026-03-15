##############################################################################
# Module: Security Group
# Creates a security group with dynamic ingress/egress rules
##############################################################################

resource "aws_security_group" "this" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = lookup(ingress.value, "cidr_blocks", [])
      security_groups = lookup(ingress.value, "security_groups", [])
      description     = lookup(ingress.value, "description", "")
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = lookup(egress.value, "cidr_blocks", ["0.0.0.0/0"])
      description = lookup(egress.value, "description", "")
    }
  }

  tags = merge(var.tags, {
    Name = var.name
  })

  lifecycle {
    create_before_destroy = true
  }
}
