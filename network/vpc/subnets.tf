# CREATE PUBLIC SUBNETS
resource "aws_subnet" "public_subnets" {
  for_each          = var.create_public_subnets ? var.public_subnet_cidrs : {}
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = merge(
    local.tags,
    {
      Name = "${local.project_name}-${local.environment}-external-subnet-${each.value.az}"
    }
  )
}
# CREATE APPLICATION PRIVATE SUBNETS
resource "aws_subnet" "app_private_subnets" {
  for_each          = var.app_private_subnet_cidrs
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = merge(
    local.tags,
    {
      Name = "${local.project_name}-${local.environment}-${each.value.server}-internal-subnet-${each.value.az}"
    }
  )
}
# CREATE DATABASE PRIVATE SUBNETS
resource "aws_subnet" "db_private_subnets" {
  for_each          = var.db_private_subnet_cidrs
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = merge(
    local.tags,
    {
      Name = "${local.project_name}-${local.environment}-${each.value.server}-internal-subnet-${each.value.az}"
    }
  )
}
