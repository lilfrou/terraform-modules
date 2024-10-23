# Route table
resource "aws_route_table" "dmz" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    tomap({
      "Name" = "${var.vpc_name} public-RT",
      "VPC"  = var.vpc_name
    }),
    var.tags
  )
}

resource "aws_route" "igw" {
  count                  = var.create_igw ? 1 : 0
  route_table_id         = aws_route_table.dmz.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.vpc_gw.0.id
}

resource "aws_route" "igw_ipv6" {
  count                       = var.create_igw && (var.assign_generated_ipv6_cidr_block || (var.ipv6_ipam_pool_id != "" && var.ipv6_ipam_pool_id != null)) ? 1 : 0
  route_table_id              = aws_route_table.dmz.id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.vpc_gw[0].id
}

resource "aws_route" "nat64" {
  count                       = var.enable_nat64 ? 1 : 0
  route_table_id              = aws_route_table.dmz.id
  destination_ipv6_cidr_block = "64:ff9b::/96"
  nat_gateway_id              = aws_nat_gateway.nat_gw[0].id
}

# Create the same number of the following for each AZ
#  - EIP
#  - NAT Gateway
#  - Subnet
#  - Route table association
resource "aws_eip" "dmz" {
  count  = var.create_nat_gateway ? 1 : 0
  domain = "vpc"

  tags = merge(
    tomap({
      "VPC"      = var.vpc_name
      "Name"     = "${var.vpc_name}-nat-eip"
      "Reserved" = "false"
    }),
    var.tags
  )
}

resource "aws_nat_gateway" "nat_gw" {
  count         = var.create_nat_gateway ? 1 : 0
  allocation_id = aws_eip.dmz.0.id
  subnet_id     = random_shuffle.nat_subnet.result[0]

  tags = merge(
    tomap({
      "Name" = "${var.vpc_name}-nat"
      "Type" = "Public",
      "VPC"  = var.vpc_name
    }),
    var.tags
  )
}

# DMZ (Public) subnets => 4091 IPs
resource "aws_subnet" "dmz" {
  count = length(var.region_azs)

  vpc_id                          = aws_vpc.vpc.id
  cidr_block                      = "${var.cidr_prefix}.${var.public_cidr_postfix[count.index]}/20"
  availability_zone               = "${var.vpc_region}${var.region_azs[count.index]}"
  map_public_ip_on_launch         = true
  enable_dns64                    = var.enable_dns64
  assign_ipv6_address_on_creation = var.assign_ipv6_address_on_creation
  ipv6_cidr_block                 = (var.assign_generated_ipv6_cidr_block || (var.ipv6_ipam_pool_id != "" && var.ipv6_ipam_pool_id != null)) ? cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, 8, var.public_ipv6_cidr_postfix[count.index]) : null # /64 prefix with 18.4Q IPs

  tags = merge(
    tomap({
      "Name"               = "${var.vpc_name} DMZ ${var.region_azs[count.index]}",
      "VPC"                = var.vpc_name,
      "immutable_metadata" = jsonencode(local.public_subnet)
    }),
    var.tags
  )
}

resource "random_shuffle" "nat_subnet" {
  input        = aws_subnet.dmz.*.id
  result_count = 1
}

resource "aws_route_table_association" "rta_dmz" {
  count = length(var.region_azs)

  route_table_id = aws_route_table.dmz.id
  subnet_id      = aws_subnet.dmz[count.index].id
}
