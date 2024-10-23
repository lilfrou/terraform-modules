resource "aws_flow_log" "vpc-flow-log" {
  vpc_id               = aws_vpc.vpc.id
  log_destination      = var.enable_log_to_s3 ? var.vpc_log_s3_bucket_arn : aws_cloudwatch_log_group.vpc-flow-log-group.arn
  log_destination_type = var.enable_log_to_s3 ? "s3" : "cloud-watch-logs"
  iam_role_arn         = var.enable_log_to_s3 ? null : var.vpc_flow_log_iam_arn
  traffic_type         = "ALL"

  tags = merge(tomap({ "Name" = "${var.vpc_name} VPC" }), var.tags)
}

resource "aws_cloudwatch_log_group" "vpc-flow-log-group" {
  name              = "/${lower(var.vpc_name)}/vpc/flowlog"
  retention_in_days = 365
  tags              = merge(tomap({ "Name" = "${var.vpc_name} VPC" }), var.tags)
}


