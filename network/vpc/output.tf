output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "app_private_subnets_ids" {
  value = values(aws_subnet.app_private_subnets)[*].id
}

output "db_private_subnets_ids" {
  value = values(aws_subnet.db_private_subnets)[*].id
}