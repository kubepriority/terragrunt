module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc-kubepriority-prd"
  cidr = "10.217.0.0/18"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.217.0.0/24", "10.217.4.0/24", "10.217.8.0/24"]
  public_subnets  = ["10.217.40.0/24", "10.217.48.0/24", "10.217.56.0/24"]

  private_subnet_tags = {
    Type = "Private"
  }
  public_subnet_tags = {
    Type = "Public"
  }
  enable_dns_hostnames = true
  enable_vpn_gateway = false
  enable_nat_gateway = false
  single_nat_gateway = false
  one_nat_gateway_per_az = false

  tags = {
    Terraform = "true"
    Environment = "prod"
  }
}

resource "aws_instance" "nat-instance-1a" {
    ami = "ami-0636eac5d73e0e5d7"
    availability_zone = "us-east-1a"
    instance_type = "t4g.small"
    key_name = "kubepriority-prd"
    subnet_id = module.vpc.public_subnets[0]
    associate_public_ip_address = true
    source_dest_check = false
    tags = {
        Name = "nat-instance-1a"
    }
}

resource "aws_eip" "nat-instance-1a" {
    instance = "${aws_instance.nat-instance-1a.id}"
    vpc = true
}

resource "aws_instance" "nat-instance-1b" {
    ami = "ami-0636eac5d73e0e5d7"
    availability_zone = "us-east-1b"
    instance_type = "t4g.small"
    key_name = "kubepriority-prd"
    subnet_id = module.vpc.public_subnets[1]
    associate_public_ip_address = true
    source_dest_check = false
    tags = {
        Name = "nat-instance-1b"
    }
}

resource "aws_eip" "nat-instance-1b" {
    instance = "${aws_instance.nat-instance-1b.id}"
    vpc = true
}

resource "aws_instance" "nat-instance-1c" {
    ami = "ami-0636eac5d73e0e5d7"
    availability_zone = "us-east-1c"
    instance_type = "t4g.small"
    key_name = "kubepriority-prd"
    subnet_id = module.vpc.public_subnets[2]
    associate_public_ip_address = true
    source_dest_check = false
    tags = {
        Name = "nat-instance-1c"
    }
}

resource "aws_eip" "nat-instance-1c" {
    instance = "${aws_instance.nat-instance-1c.id}"
    vpc = true
}


