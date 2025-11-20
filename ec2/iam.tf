# ec2/iam.tf


# Grants EC2 instance permissions needed for data processing
resource "aws_iam_role" "etl_worker_role" {
  name = "etl-worker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
      },
    ],
  })
}

# Attach a placeholder policy for S3 Read-Only access
resource "aws_iam_role_policy_attachment" "s3_access" {
  role               = aws_iam_role.etl_worker_role.name
  policy_arn         = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# Required container for the IAM Role to be attached to the EC2 instance
resource "aws_iam_instance_profile" "etl_worker_profile" {
  name = "etl-worker-profile"
  role = aws_iam_role.etl_worker_role.name
}
