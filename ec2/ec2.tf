# ec2/ec2.tf

# Amazon AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_instance" "etl_worker" {
  ami = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  # subnet_id = tolist(values(aws_subnet.private)[*].id)[0]
  subnet_id = module.vpc.private_subnet_ids[0]

  # Linked the security group and IAM role
  vpc_security_group_ids = [aws_security_group.etl_sg.id, aws_security_group.ssh_access_sg.id]
  iam_instance_profile = aws_iam_instance_profile.etl_worker_profile.name
  associate_public_ip_address = true
  key_name = "my-ssh-key"

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y python3
              /usr/bin/pip3 install requests pandas # Simulate ETL environment setup
              echo "ETL worker environment prepared." > /var/log/etl_setup.log
              EOF

  tags = {
    Name = "ETL-Worker"
  }
}

