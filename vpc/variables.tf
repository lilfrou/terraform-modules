# Required
variable "vpc_name" {
  type        = string
  description = "The tag to use as the name of the VPC. Applied to all resources created with this module"
}

variable "vpc_region" {
  type        = string
  description = "The region name to create the VPC. (e.g. us-west-2)"
}

variable "region_azs" {
  type        = list(string)
  description = "A list of availability zones to use for this VPC. (e.g. [a, b, c]) Make sure to check those AZs are available in the region you specified"
}

variable "cidr_prefix" {
  type        = string
  description = "The prefix CIDR. (e.g. use 10.100 if you want 10.100.0.0/16)"
}

# Pre-set
variable "public_cidr_postfix" {
  type        = list(string)
  description = "The postfix CIDR for the public subnets"
  default     = ["128.0", "144.0", "160.0", "176.0"]
}

variable "private_a_cidr_postfix" {
  type        = list(string)
  description = "The postfix CIDR for the app private subnets"
  default     = ["0.0", "32.0", "64.0", "96.0"]
}

variable "private_b_cidr_postfix" {
  type        = list(string)
  description = "The postfix CIDR for the db private subnets"
  default     = ["192.0", "200.0", "208.0", "216.0"]
}

# Pre-set-ipv6

variable "public_ipv6_cidr_postfix" {
  type        = list(string)
  description = "The postfix CIDR for the ipv6 public subnets"
  default     = ["02", "04", "06", "08"]
}

variable "private_a_ipv6_cidr_postfix" {
  type        = list(string)
  description = "The postfix CIDR for the app ipv6 private subnets"
  default     = ["12", "14", "16", "18"]
}

variable "private_b_ipv6_cidr_postfix" {
  type        = list(string)
  description = "The postfix CIDR for the db ipv6 private subnets"
  default     = ["22", "24", "26", "28"]
}

variable "vpc_flow_log_iam_arn" {
  type        = string
  description = "ARN of the IAM role for VPC flow logs"
}

variable "tags" {
  type        = map(any)
  description = "The tags that should be applied to all resources generated"
  default     = {}
}

variable "create_igw" {
  type        = bool
  default     = true
  description = "Create an Internet gateway within the VPC"
}

variable "create_nat_gateway" {
  type        = bool
  default     = true
  description = "Create a nat-gateway within the VPC"
}

variable "create_ec2_endpoint" {
  default     = false
  type        = bool
  description = "If true, creates a VPC EC2 Endpoint"
}

variable "create_ecr_endpoint" {
  default     = false
  type        = bool
  description = "If true, creates a VPC ECR Endpoint"
}

variable "create_secretmanager_endpoint" {
  default     = false
  type        = bool
  description = "If true, creates a VPC Secret Manager Endpoint"
}

variable "create_cloudwatch_endpoint" {
  default     = false
  type        = bool
  description = "If true, creates a VPC CloudWatch Endpoint"
}

variable "create_s3_endpoint" {
  default     = true
  type        = bool
  description = "If true, creates a VPC S3 Endpoint"
}

variable "vpc_interface_endpoints" {
  type        = map(any)
  default     = {}
  description = "A map of vpc interface endpoints configuration to create"
}

variable "route53_zone_associations" {
  description = "Route53 Hosted zones to associate with this VPC"
  default     = []
}

variable "enable_log_to_s3" {
  type        = bool
  description = "if true, send VPC flow logs to S3 bucket. If false, send to CloudWatch Logs"
  default     = false
}

variable "vpc_log_s3_bucket_arn" {
  type        = string
  description = "The ARN of the S3 bucket to send VPC flow logs to"
  default     = null
}

variable "assign_generated_ipv6_cidr_block" {
  default     = false
  type        = bool
  description = "Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC"
}

variable "create_egress_only_igw" {
  type        = bool
  default     = false
  description = "Creates an egress-only Internet gateway for your VPC only when IPV6 is enabled"
}

variable "enable_dns64" {
  type        = bool
  default     = false
  description = "Indicates whether DNS queries made to the Amazon-provided DNS Resolver in this subnet should return synthetic IPv6 addresses for IPv4-only destinations"
}

variable "assign_ipv6_address_on_creation" {
  type        = bool
  default     = false
  description = "Specify true to indicate that network interfaces created in the specified subnet should be assigned an IPv6 address"
}

variable "enable_nat64" {
  type        = bool
  default     = false
  description = "If you enable DNS64, you must enable NAT64 to allow your instances to communicate with the IPv4 internet"
}

variable "ipv6_ipam_pool_id" {
  type        = string
  default     = null
  description = "The IPAM ID of the IPV6 to Use from"
}
