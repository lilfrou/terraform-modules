resource "aws_security_group" "internal" {
  name_prefix = "vpc-internal-"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${var.vpc_name}-internal"
  }
}

resource "aws_security_group_rule" "ingress" {
  security_group_id = aws_security_group.internal.id

  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = [aws_vpc.vpc.cidr_block]
}

resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.internal.id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

# =================================================
#   VPC endpoints
# =================================================
resource "aws_security_group" "vpc_interface_endpoint_access" {
  count = anytrue([var.create_ec2_endpoint, var.create_s3_endpoint, var.create_cloudwatch_endpoint, var.create_secretmanager_endpoint, length(var.vpc_interface_endpoints) > 0]) ? 1 : 0

  name_prefix = "vpc-interface-endpoint-access-"
  vpc_id      = aws_vpc.vpc.id
  tags = merge({
    "Name" = "${var.vpc_name}-vpc-interface-endpoint"
  }, var.tags)
}

resource "aws_security_group_rule" "vpc_interface_endpoint_ingress" {
  count             = anytrue([var.create_ec2_endpoint, var.create_s3_endpoint, var.create_cloudwatch_endpoint, var.create_secretmanager_endpoint, length(var.vpc_interface_endpoints) > 0]) ? 1 : 0
  security_group_id = aws_security_group.vpc_interface_endpoint_access.0.id

  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "TCP"
  cidr_blocks = ["${var.cidr_prefix}.0.0/16", "10.0.0.0/8"]
}

resource "aws_security_group_rule" "vpc_interface_endpoint_egress" {
  count             = anytrue([var.create_ec2_endpoint, var.create_s3_endpoint, var.create_cloudwatch_endpoint, var.create_secretmanager_endpoint, length(var.vpc_interface_endpoints) > 0]) ? 1 : 0
  security_group_id = aws_security_group.vpc_interface_endpoint_access.0.id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
