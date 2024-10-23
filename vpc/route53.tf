resource "aws_route53_zone_association" "this" {
  for_each = data.aws_route53_zone.associations
  zone_id  = each.value.zone_id
  vpc_id   = aws_vpc.vpc.id
}
