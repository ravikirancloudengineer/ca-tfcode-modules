# Create Route Table for Public Subnets
resource "aws_route_table" "public_rtb" {
  count  = var.create_public_subnets ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    local.tags,
    {
      Name = "${local.project_name}-${local.environment}-external-rtb"
    }
  )
}
# Create Route Table for Application Private Subnets
resource "aws_route_table" "app_private_rtb" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    local.tags,
    {
      Name = "${local.project_name}-${local.environment}-app-internal-rtb"
    }
  )
}
# Create Route Table for Database Private Subnets
resource "aws_route_table" "db_private_rtb" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    local.tags,
    {
      Name = "${local.project_name}-${local.environment}-db-internal-rtb"
    }
  )
}
# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  count  = var.create_public_subnets ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    local.tags,
    {
      Name = "${local.project_name}-${local.environment}-igw"
    }
  )
}
# Create Route for Internet Gateway to Public Subnets
resource "aws_route" "igw_to_public_subnets" {
  count                  = var.create_public_subnets ? 1 : 0
  route_table_id         = aws_route_table.public_rtb[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id
}
# Create Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  count  = var.create_nat_gateway ? 1 : 0
  domain = "vpc"
  tags = merge(
    local.tags,
    {
      Name = "${local.project_name}-${local.environment}-nat-eip"
    }
  )
}
# Create NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  count         = var.create_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat_eip[0].id
  subnet_id     = values(aws_subnet.public_subnets)[0].id
  depends_on    = [aws_eip.nat_eip[0]]
  tags = merge(
    local.tags,
    {
      Name = "${local.project_name}-${local.environment}-nat-gw"
    }
  )
}
# Create Route for Private Subnets to NAT Gateway
resource "aws_route" "private_to_nat_gw" {
  count                  = var.create_nat_gateway ? 1 : 0
  route_table_id         = aws_route_table.app_private_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[0].id
}
# # Create Route for Network VPC through Transit Gateway
# resource "aws_route" "network_vpc_to_tgw" {
#   route_table_id         = aws_route_table.app_private_rtb.id
#   destination_cidr_block = "10.40.0.0/18"
#   transit_gateway_id     = data.aws_ec2_transit_gateway.central_tgw.id
# }
# # Create Route for Network VPC through Transit Gatewa
# resource "aws_route" "network_vpc_to_tgw_db" {
#   route_table_id         = aws_route_table.db_private_rtb.id
#   destination_cidr_block = "0.0.0.0/0"
#   transit_gateway_id     = data.aws_ec2_transit_gateway.central_tgw.id
# }
# Create subnet association for public route table
resource "aws_route_table_association" "public_subnet_assoc" {
  for_each       = var.create_public_subnets ? aws_subnet.public_subnets : {}
  route_table_id = aws_route_table.public_rtb[0].id
  subnet_id      = each.value.id
  depends_on     = [aws_route_table.public_rtb, aws_subnet.public_subnets]
}
# Create subnet association for Application Private Subnets
resource "aws_route_table_association" "app_private_subnet_assoc" {
  for_each       = aws_subnet.app_private_subnets
  route_table_id = aws_route_table.app_private_rtb.id
  subnet_id      = each.value.id
  depends_on     = [aws_route_table.app_private_rtb, aws_subnet.app_private_subnets]
}
# Create subnet association for Database Private Subnets
resource "aws_route_table_association" "db_private_subnet_assoc" {
  for_each       = aws_subnet.db_private_subnets
  route_table_id = aws_route_table.db_private_rtb.id
  subnet_id      = each.value.id
  depends_on     = [aws_route_table.db_private_rtb, aws_subnet.db_private_subnets]
}