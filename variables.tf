variable "environment" {
  description = "Environment name (Production / Staging)"
  type        = string
}

variable "azs" {
  description = "AWS availability zones"
  type        = list(string)
}

variable "cidr_id" {
  description = "VPC CIDR is 10.x.0.0/16. This value correspond to the x"
  type        = number
}

variable "ou_arn" {
  description = "Organizational Unit (OU) ARN to which we want to share subnets"
  type        = string
}

variable "flow_log_s3bucket" {
  description = "ARN of the S3 bucket in Log account for VPC Flow logs"
  type        = string
}
