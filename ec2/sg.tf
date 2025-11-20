# ec2/sg.tf
/*
Here we are going to define all the security groups that our EC2 will
inherit
*/

resource "aws_security_group" "etl_sg" {
  name = "etl-worker-sg"
  description = "Security group for private ETL worker instances"
  vpc_id = module.vpc.vpc_id

  # OUTBOUND RULE: Allows all outbound traffic (need for external API calls/NAT Gateway)
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  # INBOUND RULE: Keeping it empty for maximum privacy, access should be via a Bastion host
  ingress = []

  tags = {
    Name = "ETL-Worker-SG"
  }
}




