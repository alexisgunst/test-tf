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


