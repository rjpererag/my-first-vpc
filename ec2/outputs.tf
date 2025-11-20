output "instance_public_ip" {
  description = "The public IP address to SSH into the instance"
  value = aws_instance.etl_worker.public_ip
}