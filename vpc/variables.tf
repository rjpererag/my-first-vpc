# vpc/variables.tf

variable "region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "List of CIDR blocks for public subnets (AZ 1, AZ 3, ...)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidr" {
  description = "List of CIDR blocks for private subnets (AZ 1, AZ 3, ...)"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}




