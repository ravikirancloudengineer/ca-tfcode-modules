# # Getting Central Transit Gateway ID
# data "aws_ec2_transit_gateway" "central_tgw" {
#   filter {
#     name = "tag:Name"
#     values = [ "Shared-Transit-Gateway"]
#   }
# }

# # Create Transit Gateway Attachment
# resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-attachment" {
#   subnet_ids         = [for s in aws_subnet.app_private_subnets: s.id]
#   transit_gateway_id = data.aws_ec2_transit_gateway.central_tgw.id
#   vpc_id             = aws_vpc.vpc.id
#   tags = {
#     Name = "${local.project_name}-${local.environment}-${aws_vpc.vpc.id}-attachment"
#   }
# }