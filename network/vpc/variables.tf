variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
variable "create_public_subnets" {
  description = "Whether to create public subnets"
  type        = bool
  default     = true
}
variable "create_nat_gateway" {
  description = "Whether to create a NAT gateway"
  type        = bool
  default     = false
}
variable "public_subnet_cidrs" {
  description = "Map containing CIDR and AZ for Cluster public subnets"
  type = map(object({
    cidr = string
    az   = string
  }))
  default = {
    "public-subnet-1" = { cidr = "10.0.0.0/24", az = "ap-south-1a" }
    "public-subnet-2" = { cidr = "10.0.1.0/24", az = "ap-south-1b" }
    "public-subnet-3" = { cidr = "10.0.2.0/24", az = "ap-south-1c" }
  }
}
variable "app_private_subnet_cidrs" {
  description = "Map containing CIDR and AZ for Cluster private subnets"
  type = map(object({
    cidr   = string
    az     = string
    server = string
  }))
  default = {
    "private-subnet-1" = { cidr = "10.0.4.0/24", az = "ap-south-1a", server = "app" }
    "private-subnet-2" = { cidr = "10.0.5.0/24", az = "ap-south-1b", server = "app" }
    "private-subnet-3" = { cidr = "10.0.6.0/24", az = "ap-south-1c", server = "app" }
  }
}
variable "db_private_subnet_cidrs" {
  description = "Map containing CIDR and AZ for Database private subnets"
  type = map(object({
    cidr   = string
    az     = string
    server = string
  }))
  default = {
    "private-subnet-1" = { cidr = "10.0.4.0/24", az = "ap-south-1a", server = "db" }
    "private-subnet-2" = { cidr = "10.0.5.0/24", az = "ap-south-1b", server = "db" }
    "private-subnet-3" = { cidr = "10.0.6.0/24", az = "ap-south-1c", server = "db" }
  }
}
