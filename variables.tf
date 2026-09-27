variable "aws_region" {
  default     = "eu-west-1"
  description = "AWS Region for deployment"
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "VPC CIDR Block"
}
