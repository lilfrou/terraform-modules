# The generated VPC id
output "vpc_id" {
  value = aws_vpc.vpc.id
}

# The ARN of the generated VPC
output "vpc_arn" {
  value = aws_vpc.vpc.arn
}

# The full CIDR range for the VPC
output "vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

# Route table id for DMZ
output "dmz_route_table_id" {
  value = aws_route_table.dmz.id
}

# Route table ids for the Private A Network Layer (can be use for peering)
output "private_a_route_table_ids" {
  value = aws_route_table.private_a.*.id
}

# Route table ids for the Private B Network Layer (can be use for peering)
output "private_b_route_table_ids" {
  value = aws_route_table.private_b.*.id
}

# Public network CIDR block
output "dmz_cidr_block" {
  value = "${var.cidr_prefix}.128.0/18"
}

# Private A (layer 1) CIDR block
output "private_a_cidr_block" {
  value = "${var.cidr_prefix}.0.0/17"
}

# Private B (layer 2) CIDR block
output "private_b_cidr_block" {
  value = "${var.cidr_prefix}.192.0/19"
}

# Public subnet ids
output "dmz_subnet_ids" {
  value = aws_subnet.dmz.*.id
}

# Private A (layer 1) subnet ids
output "private_a_subnet_ids" {
  value = aws_subnet.private_a.*.id
}

# Private B (layer 2) subnet ids
output "private_b_subnet_ids" {
  value = aws_subnet.private_b.*.id
}

# VPC internal security group id
output "vpc_security_group_id" {
  value = aws_security_group.internal.id
}

# The id of the VPC S3 endpoint
output "vpc_s3_endpoint_id" {
  value = var.create_s3_endpoint ? aws_vpc_endpoint.s3.0.id : null
}

# The id of the VPC Cloudwatch endpoint
output "vpc_cloudwatch_endpoint_id" {
  value = var.create_cloudwatch_endpoint ? aws_vpc_endpoint.cloudwatch.0.id : null
}

# The id of the VPC EC2 endpoint
output "vpc_ec2_endpoint_id" {
  value = var.create_ec2_endpoint ? aws_vpc_endpoint.ec2.0.id : null
}

# The id of the VPC Secret Manager endpoint
output "vpc_secretmanager_endpoint_id" {
  value = var.create_secretmanager_endpoint ? aws_vpc_endpoint.secretmanager.0.id : null
}

# The id of the VPC ECR endpoint
output "vpc_ecr_endpoint_id" {
  value = var.create_ecr_endpoint ? aws_vpc_endpoint.ecr.0.id : null
}
