locals {
  public_subnet = {
    purpose = "${var.vpc_name}-public"
  }

  private_a_subnet = {
    purpose = "${var.vpc_name}-private-a"
  }

  private_b_subnet = {
    purpose = "${var.vpc_name}-private-b"
  }
}
