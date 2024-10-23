# Create the same number of the following for each AZ
#  - Private A route tables
#  - Subnet
#  - Route table association
resource "aws_route_table" "private_a" {
  count = length(var.region_azs)

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    tomap({
      "Name" = "${var.vpc_name} private-A-RT ${var.region_azs[count.index]}",
      "VPC"  = var.vpc_name
    }),
    var.tags
  )
}

resource "aws_route" "private_a_egress" {
  count = var.create_nat_gateway ? length(var.region_azs) : 0

  route_table_id         = aws_route_table.private_a[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.0.id
}

resource "aws_route" "private_a_egress_only_igw" {
  count                       = var.create_egress_only_igw ? length(var.region_azs) : 0
  route_table_id              = aws_route_table.private_a[count.index].id
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = aws_egress_only_internet_gateway.vpc_egress_only_igw[0].id
}

resource "aws_route" "private_a_nat64" {
  count                       = var.enable_nat64 ? length(var.region_azs) : 0
  route_table_id              = aws_route_table.private_a[count.index].id
  destination_ipv6_cidr_block = "64:ff9b::/96"
  nat_gateway_id              = aws_nat_gateway.nat_gw[0].id
}

# Private A (layer 1) subnet => 8187 ips
resource "aws_subnet" "private_a" {
  count = length(var.region_azs)

  vpc_id                          = aws_vpc.vpc.id
  cidr_block                      = "${var.cidr_prefix}.${var.private_a_cidr_postfix[count.index]}/19"
  availability_zone               = "${var.vpc_region}${var.region_azs[count.index]}"
  enable_dns64                    = var.enable_dns64
  assign_ipv6_address_on_creation = var.assign_ipv6_address_on_creation
  ipv6_cidr_block                 = (var.assign_generated_ipv6_cidr_block || (var.ipv6_ipam_pool_id != "" && var.ipv6_ipam_pool_id != null)) ? cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, 8, var.private_a_ipv6_cidr_postfix[count.index]) : null # /64 prefix with 18.4Q IPs

  tags = merge(
    tomap({
      "Name"               = "${var.vpc_name} private-A ${var.region_azs[count.index]}",
      "Type"               = "Private A (layer 1)",
      "VPC"                = var.vpc_name,
      "immutable_metadata" = jsonencode(local.private_a_subnet)
    }),
    var.tags
  )
}

resource "aws_route_table_association" "rta_private_a" {
  count = length(var.region_azs)

  route_table_id = aws_route_table.private_a[count.index].id
  subnet_id      = aws_subnet.private_a[count.index].id
}
