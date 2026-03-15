variable "name" {
  description = "Name for the security group."
  type        = string
}

variable "description" {
  description = "Description for the security group."
  type        = string
  default     = "Managed by Terraform"
}

variable "vpc_id" {
  description = "ID of the VPC where the security group will be created."
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rule objects."
  type = list(object({
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string), [])
    security_groups = optional(list(string), [])
    description     = optional(string, "")
  }))
  default = []
}

variable "egress_rules" {
  description = "List of egress rule objects."
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = optional(list(string), ["0.0.0.0/0"])
    description = optional(string, "Allow all outbound traffic")
  }))
  default = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }]
}

variable "tags" {
  description = "Additional tags to apply to the security group."
  type        = map(string)
  default     = {}
}
