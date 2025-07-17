resource "random_id" "eks_cluster_id" {
  byte_length = 8
}

resource "aws_eks_cluster" "eks_cluster" {
  name = "${var.cluster_name}-${random_id.eks_cluster_id.hex}"
  role_arn = var.cluster_iam_role_arn

  vpc_config {
    subnet_ids = var.public_subnets
  }
}

data "aws_ami" "eks_worker" {
  most_recent = true
  owners      = ["602401143452"]  # AWS EKS AMI owner ID

  filter {
    name   = "name"
    values = ["amazon-eks-node-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_launch_template" "eks_node_group" {
  name_prefix   = "eks-node-group-"
  image_id      = data.aws_ami.eks_worker.id
  instance_type = var.instance_type

  key_name = var.key_name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eks_node_group" "eks_node_group" {
  depends_on = [ aws_eks_cluster.eks_cluster ]
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks-node-group"
  node_role_arn   = var.node_group_iam_role_arn
  subnet_ids      = var.private_subnets

  launch_template {
    id      = aws_launch_template.eks_node_group.id
    version = "$Latest"
  }

  scaling_config {
    desired_size = var.desired_capacity
    max_size     = var.max_size
    min_size     = var.min_size
  }
}
