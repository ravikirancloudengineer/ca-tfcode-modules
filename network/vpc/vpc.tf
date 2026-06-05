# VPC Creation
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(
    local.tags,
    {
      Name = "${local.project_name}-${local.environment}-vpc"
    }
  )
}

data "aws_region" "current" {}
# Creation of IAM Role for VPC Flow Logs
resource "aws_iam_role" "local_flow_log_role" {
  name               = "${local.project_name}-${local.environment}-flow-logs-role-${aws_vpc.vpc.id}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",		 	 	 
  "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "vpc-flow-logs.amazonaws.com"},
      "Action": "sts:AssumeRole"
  }]
}
EOF
}
# Creation of IAM Role Policy for VPC Flow Logs
resource "aws_iam_role_policy" "logs_permissions" {
  name   = "${local.project_name}-${local.environment}-flow-logs-policy-${aws_vpc.vpc.id}"
  role   = aws_iam_role.local_flow_log_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",		 	 	 
  "Statement": [{
      "Action": ["logs:CreateLogGroup","logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogGroups","logs:DescribeLogStreams", "logs:DeleteLogDelivery"],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:logs:${data.aws_region.current.id}:*:log-group:${local.project_name}-${local.environment}-${aws_vpc.vpc.id}-vpc-flow-logs*",
        "arn:aws:logs:${data.aws_region.current.id}:*:log-group:${local.project_name}-${local.environment}-${aws_vpc.vpc.id}-vpc-flow-logs*:log-stream:*"

      ]
  }]
}
EOF
}
# Creation of CloudWatch Log Group for VPC Flow Logs (Use Custom KMS)
resource "aws_cloudwatch_log_group" "vpc_flow_logs_group" {
  name              = "${local.project_name}-${local.environment}-${aws_vpc.vpc.id}-vpc-flow-logs"
  retention_in_days = 0
  #deletion_protection_enabled = true
}
# Creation of VPC Flow Logs
resource "aws_flow_log" "vpc_flow_log" {
  iam_role_arn    = aws_iam_role.local_flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs_group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.vpc.id
  depends_on      = [aws_iam_role.local_flow_log_role, aws_cloudwatch_log_group.vpc_flow_logs_group, aws_vpc.vpc]
  tags = merge(
    local.tags,
    {
      Name = "${local.project_name}-${local.environment}-${aws_vpc.vpc.id}-flow-logs"
    }
  )
}
# Creation of Custom Network ACL
resource "aws_network_acl" "custom_nacl" {
  vpc_id = aws_vpc.vpc.id
  ingress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  tags = merge(
    local.tags,
    {
      Name = "${local.project_name}-${local.environment}-custom-nacl-${aws_vpc.vpc.id}"
    }
  )
}
# Association of Public Subnets with Custom Network ACL
resource "aws_network_acl_association" "public_subnets_assoc" {
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
  network_acl_id = aws_network_acl.custom_nacl.id
  depends_on     = [aws_network_acl.custom_nacl, aws_subnet.public_subnets]
}
# Association of Application Private Subnets with Custom Network ACL
resource "aws_network_acl_association" "private_subnets_assoc" {
  for_each       = aws_subnet.app_private_subnets
  subnet_id      = each.value.id
  network_acl_id = aws_network_acl.custom_nacl.id
  depends_on     = [aws_network_acl.custom_nacl, aws_subnet.app_private_subnets]
}
# Association of Database Private Subnets with Custom Network ACL
resource "aws_network_acl_association" "db_subnets_assoc" {
  for_each       = aws_subnet.db_private_subnets
  subnet_id      = each.value.id
  network_acl_id = aws_network_acl.custom_nacl.id
  depends_on     = [aws_network_acl.custom_nacl, aws_subnet.db_private_subnets]
}