resource "aws_vpc" "vpc" {
  cidr_block                       = "${var.cidr_prefix}.0.0/16"
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = var.assign_generated_ipv6_cidr_block ? var.assign_generated_ipv6_cidr_block : null
  ipv6_ipam_pool_id                = var.ipv6_ipam_pool_id
  ipv6_netmask_length              = (var.ipv6_ipam_pool_id != null && var.ipv6_ipam_pool_id != "") ? 56 : null

  tags = merge(tomap({ "Name" = "${var.vpc_name} VPC" }), var.tags)
}

resource "aws_internet_gateway" "vpc_gw" {
  count  = var.create_igw ? 1 : 0
  vpc_id = aws_vpc.vpc.id

  tags = merge(tomap({ "Name" = "${var.vpc_name} Gateway" }), var.tags)
}

################################################################################
# egress-only Internet gateway for your IPV6 VPC
################################################################################

resource "aws_egress_only_internet_gateway" "vpc_egress_only_igw" {
  count  = var.create_egress_only_igw ? 1 : 0
  vpc_id = aws_vpc.vpc.id

  tags = merge(tomap({ "Name" = "${var.vpc_name} egress-only Internet Gateway" }), var.tags)
}


################################################################################
# Endpoint(s)
################################################################################

resource "aws_vpc_endpoint" "s3" {
  count             = var.create_s3_endpoint ? 1 : 0
  vpc_id            = aws_vpc.vpc.id
  vpc_endpoint_type = data.aws_vpc_endpoint_service.s3.0.service_type
  service_name      = data.aws_vpc_endpoint_service.s3.0.service_name

  route_table_ids = flatten([
    aws_route_table.private_a.*.id,
    aws_route_table.private_b.*.id,
  ])

  tags = {
    "Name" = "s3-endpoint"
  }
}

resource "aws_vpc_endpoint" "ec2" {
  count             = var.create_ec2_endpoint ? 1 : 0
  vpc_id            = aws_vpc.vpc.id
  vpc_endpoint_type = data.aws_vpc_endpoint_service.ec2.0.service_type
  service_name      = data.aws_vpc_endpoint_service.ec2.0.service_name

  private_dns_enabled = true
  auto_accept         = true

  security_group_ids = [aws_security_group.vpc_interface_endpoint_access.0.id]

  subnet_ids = [
    "${aws_subnet.private_a.*.id}",
    "${aws_subnet.private_b.*.id}",
  ]

  tags = {
    "Name" = "ec2-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr" {
  count             = var.create_ecr_endpoint ? 1 : 0
  vpc_id            = aws_vpc.vpc.id
  vpc_endpoint_type = data.aws_vpc_endpoint_service.ecr.0.service_type
  service_name      = data.aws_vpc_endpoint_service.ecr.0.service_name

  private_dns_enabled = true
  auto_accept         = true

  security_group_ids = [aws_security_group.vpc_interface_endpoint_access.0.id]

  subnet_ids = [
    "${aws_subnet.private_a.*.id}",
    "${aws_subnet.private_b.*.id}",
  ]

  tags = {
    "Name" = "ecr-endpoint"
  }
}

resource "aws_vpc_endpoint" "secretmanager" {
  count             = var.create_secretmanager_endpoint ? 1 : 0
  vpc_id            = aws_vpc.vpc.id
  vpc_endpoint_type = data.aws_vpc_endpoint_service.secretmanager.0.service_type
  service_name      = data.aws_vpc_endpoint_service.secretmanager.0.service_name

  private_dns_enabled = true
  auto_accept         = true

  security_group_ids = [aws_security_group.vpc_interface_endpoint_access.0.id]

  subnet_ids = [
    "${aws_subnet.private_a.*.id}",
    "${aws_subnet.private_b.*.id}",
  ]

  tags = {
    "Name" = "secretmanager-endpoint"
  }
}

resource "aws_vpc_endpoint" "cloudwatch" {
  count             = var.create_cloudwatch_endpoint ? 1 : 0
  vpc_id            = aws_vpc.vpc.id
  vpc_endpoint_type = data.aws_vpc_endpoint_service.cloudwatch.0.service_type
  service_name      = data.aws_vpc_endpoint_service.cloudwatch.0.service_name

  private_dns_enabled = true
  auto_accept         = true

  security_group_ids = [aws_security_group.vpc_interface_endpoint_access.0.id]

  subnet_ids = [
    "${aws_subnet.private_a.*.id}",
    "${aws_subnet.private_b.*.id}",
  ]

  tags = {
    "Name" = "cloudwatch-endpoint"
  }
}

# This is of type interface endpoints because we only have two types of services
# Gateway (which only consists of S3 and DynamoDB) and all other services.
# If need for DynamoDB endpoint arises, please create an exclusive aws_vpc_endpoint for it
resource "aws_vpc_endpoint" "this" {
  for_each = var.vpc_interface_endpoints

  vpc_id              = aws_vpc.vpc.id
  service_name        = data.aws_vpc_endpoint_service.this[each.key].service_name
  vpc_endpoint_type   = "Interface"
  auto_accept         = true
  security_group_ids  = distinct(concat([aws_security_group.vpc_interface_endpoint_access.0.id], lookup(each.value, "security_group_ids", [])))
  subnet_ids          = distinct(aws_subnet.private_a.*.id)
  policy              = lookup(each.value, "policy", null)
  private_dns_enabled = true

  tags = merge(var.tags, {
    "Name" = "${each.key}-endpoint"
  }, lookup(each.value, "tags", {}))
}


resource "aws_route53_record" "endpoints" {
  for_each = aws_vpc_endpoint.this
  zone_id  = data.aws_route53_zone.endpoints-dns-zones[each.key].zone_id
  name     = var.vpc_interface_endpoints[each.key]["private_dns_name"]
  type     = "A"

  alias {
    name                   = each.value.dns_entry.0.dns_name
    zone_id                = each.value.dns_entry.0.hosted_zone_id
    evaluate_target_health = false
  }
}


