module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  azs = "${slice(data.aws_availability_zones.available.names, 0, var.number_of_azs)}"
  cidr = "${var.vpc_cidr}"
  create_vpc = true
  enable_dns_hostnames = true
  enable_dns_support = true
  enable_nat_gateway = true
  name = "vpc"
  public_subnets = "${var.public_vpc_subnet_cidrs}"
  private_subnets = "${var.private_vpc_subnet_cidrs}"
}
