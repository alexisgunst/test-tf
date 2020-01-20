
provider "aws" {
}



module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.21.0"

  name = var.environment
  cidr = "10.${var.cidr_id}.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support   = true

  azs = var.azs

  #--[ Private subnets ]-----------------------------------------------------------------
  # Default route to NAT Gateways. One per AZ for high availability
  private_subnets = length(var.azs) < 3 ? ["10.${var.cidr_id}.0.0/19", "10.${var.cidr_id}.32.0/19"] : ["10.${var.cidr_id}.0.0/19", "10.${var.cidr_id}.32.0/19", "10.${var.cidr_id}.64.0/19"]

  private_dedicated_network_acl = true
  enable_nat_gateway            = true
  enable_dynamodb_endpoint      = true
  enable_s3_endpoint            = true

  # Allow traffic only from private networks (RFC1918)
  private_inbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "10.0.0.0/8"
    },
    {
      rule_number = 101
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "192.168.0.0/16"
    },
    {
      rule_number = 102
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "172.16.0.0/12"
    }
  ]


  #--[ Database subnets ]----------------------------------------------------------------
  # We do want a RDS subnet route but we don't need a default route. RDS don't need to
  # access to the Internet
  database_subnets = length(var.azs) < 3 ? ["10.${var.cidr_id}.128.0/22", "10.${var.cidr_id}.132.0/22"] : ["10.${var.cidr_id}.128.0/22", "10.${var.cidr_id}.132.0/22", "10.${var.cidr_id}.136.0/22"]

  database_dedicated_network_acl     = true
  create_database_subnet_group       = true
  create_database_subnet_route_table = true
  create_database_nat_gateway_route  = false

  # Allow traffic only from private subnets on standard ports
  # and to private subnets only
  database_inbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_block  = "10.${var.cidr_id}.0.0/17"
    },
    {
      rule_number = 101
      rule_action = "allow"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_block  = "10.${var.cidr_id}.0.0/17"
    },
    {
      rule_number = 102
      rule_action = "allow"
      from_port   = 6379
      to_port     = 6379
      protocol    = "tcp"
      cidr_block  = "10.${var.cidr_id}.0.0/17"
    }
  ]

  database_outbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "10.${var.cidr_id}.0.0/17"
    }
  ]



  #--[ Public subnets ]------------------------------------------------------------------
  # Public subnets has default route to the Internet Gateway
  public_subnets = length(var.azs) < 3 ? ["10.${var.cidr_id}.144.0/22", "10.${var.cidr_id}.148.0/22"] : ["10.${var.cidr_id}.144.0/22", "10.${var.cidr_id}.148.0/22", "10.${var.cidr_id}.152.0/22"]

  public_dedicated_network_acl = true

  # Allow traffic from everywhere but only on HTTP(S) ports
  public_inbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number = 101
      rule_action = "allow"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    }
  ]
}

