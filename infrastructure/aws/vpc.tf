module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  azs = "${slice(data.aws_availability_zones.available.names, 0, var.number_of_azs)}"
  cidr = "${var.vpc_cidr}"
  create_vpc = true
  enable_dns_hostnames = true
  enable_dns_support = true
  enable_nat_gateway = true
  one_nat_gateway_per_az = true
  name = "vpc"
  private_subnets = "${var.private_vpc_subnet_cidrs}"
}
