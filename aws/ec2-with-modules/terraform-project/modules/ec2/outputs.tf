output "instance_id" {
  value = aws_instance.main.id
}

output "instance_public_ip" {
  value = aws_instance.main.public_ip
}