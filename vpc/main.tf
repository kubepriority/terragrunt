## Modulo VPC

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "vpc-kubepriority-prd"
  cidr = "10.217.0.0/18"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = var.private_subnets_cidr_blocks
  public_subnets  = var.public_subnets_cidr_blocks

  private_subnet_tags = {
    Type = "Private"
    "kubernetes.io/cluster/ex-eks-v1-23"          = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
  public_subnet_tags = {
    Type = "Public"
    "kubernetes.io/cluster/ex-eks-v1-23"          = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }
  enable_dns_hostnames   = true
  enable_vpn_gateway     = false
  enable_nat_gateway     = false
  single_nat_gateway     = false
  one_nat_gateway_per_az = false
  create_egress_only_igw = true

  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true

  tags = {
    Terraform = "true"
    Environment = "prod"
  }
  
}

## Key Pair

resource "aws_key_pair" "nat_key_name" {
  key_name   = var.key_name
  public_key = "${file("/root/.ssh/id_rsa.pub")}"
}

## Security Groups Roles

resource "aws_security_group" "this" {
  name_prefix = var.name
  vpc_id      = module.vpc.vpc_id
  description = "Security group for NAT instance ${var.name}"
  tags        = local.common_tags
}

resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.this.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
}

resource "aws_security_group_rule" "ingress_any" {
  security_group_id = aws_security_group.this.id
  type              = "ingress"
  cidr_blocks       = var.private_subnets_cidr_blocks
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
}

## EIP Public

resource "aws_network_interface" "this" {
  subnet_id          = module.vpc.public_subnets[0]
  security_groups    = [aws_security_group.this.id]
  source_dest_check  = false 

  tags = merge(var.tags, { "Name" = var.name })
}

resource "aws_eip" "eip" {
  public_ipv4_pool = "amazon"
  vpc = true
  network_interface = "${aws_network_interface.this.id}"

  tags = merge(var.tags, { "Name" = var.name })
}

## Nat_Instance

resource "aws_iam_instance_profile" "this" {
  name_prefix = var.name
  role        = aws_iam_role.this.name
}

resource "aws_iam_role" "this" {
  name_prefix        = var.name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.this.name
}

resource "aws_iam_role_policy" "eni" {
  role        = aws_iam_role.this.name
  name_prefix = var.name
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AttachNetworkInterface",
                "ec2:ModifyInstanceAttribute"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}


resource "aws_launch_template" "this" {
  name_prefix          = var.name
  image_id             = var.image_id
  key_name             = var.key_name
  instance_type        = var.instance_types

  iam_instance_profile {
    arn = aws_iam_instance_profile.this.arn
  }

  network_interfaces {
    device_index = 0
    network_interface_id = "${aws_network_interface.this.id}"
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 10
      volume_type = "gp3"
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          = local.common_tags
  }

  user_data = base64encode(join("\n", [
    "#cloud-config",
    yamlencode({
      # https://cloudinit.readthedocs.io/en/latest/topics/modules.html
      write_files : concat([
        {
          path : "/opt/nat/runonce.sh",
          content : templatefile("${path.module}/runonce.sh", { eni_id = aws_network_interface.this.id }),
          permissions : "0755",
        },
        {
          path : "/opt/nat/snat.sh",
          content : file("${path.module}/snat.sh"),
          permissions : "0755",
        },
        {
          path : "/etc/systemd/system/snat.service",
          content : file("${path.module}/snat.service"),
        },
      ], var.user_data_write_files),
      runcmd : concat([
        ["/opt/nat/runonce.sh"],
      ], var.user_data_runcmd),
    })
  ]))

  description = "Launch template for NAT instance ${var.name}"
  tags        = local.common_tags
}

resource "aws_autoscaling_group" "this" {
  name_prefix         = var.name
  desired_capacity    = 1
  min_size            = 1 
  max_size            = 1
  availability_zones = ["us-east-1a"]

  mixed_instances_policy {
      launch_template {
        launch_template_specification {
          launch_template_id = aws_launch_template.this.id
          version            = "$Latest"
        }
      }
    }
    
  lifecycle {
    create_before_destroy = true
  }
}

### Routes

resource "aws_route" "this" {
    count = length(module.vpc.private_route_table_ids)
    route_table_id     = module.vpc.private_route_table_ids[count.index]
#   route_table_id = "rtb-08893d79115607cf1"
    destination_cidr_block = "0.0.0.0/0"
    network_interface_id   = "${aws_network_interface.this.id}"
}