data "aws_vpc_endpoint_service" "s3" {
  count        = var.create_s3_endpoint ? 1 : 0
  service      = "s3"
  service_type = "Gateway"
}

data "aws_vpc_endpoint_service" "ec2" {
  count        = var.create_ec2_endpoint ? 1 : 0
  service_name = "com.amazonaws.${var.vpc_region}.ec2"
  service_type = "Interface"
}

data "aws_vpc_endpoint_service" "ecr" {
  count        = var.create_ecr_endpoint ? 1 : 0
  service_name = "com.amazonaws.${var.vpc_region}.ecr.api"
  service_type = "Interface"
}

data "aws_vpc_endpoint_service" "secretmanager" {
  count        = var.create_secretmanager_endpoint ? 1 : 0
  service      = "secret_manager"
  service_type = "Interface"
}

data "aws_vpc_endpoint_service" "cloudwatch" {
  count        = var.create_cloudwatch_endpoint ? 1 : 0
  service      = "cloudwatch"
  service_type = "Interface"
}

data "aws_vpc_endpoint_service" "this" {
  for_each = var.vpc_interface_endpoints

  service      = lookup(each.value, "service", null)
  service_name = lookup(each.value, "service_name", null)

  filter {
    name   = "service-type"
    values = [lookup(each.value, "service_type", "Interface")]
  }
}


data "aws_route53_zone" "associations" {
  for_each     = toset(var.route53_zone_associations)
  name         = each.value
  private_zone = true
}

data "aws_route53_zone" "endpoints-dns-zones" {
  for_each     = var.vpc_interface_endpoints
  name         = each.value.private_dns_name
  private_zone = true
}

