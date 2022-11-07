data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Environment"
    values = ["prod"]
  }
}

data "terraform_remote_state" "remote" {
  backend = "s3"
  config = {
    bucket         = "vpc-terraform-kubepriority-state"
    dynamodb_table = "kubepriority-tf-lock-table"
    encrypt        = true
    key            = "vpc/terraform.tfstate"
    region         = "us-east-1"
  }
}

data "aws_subnet_ids" "public_subnet_ids" {
  vpc_id = data.terraform_remote_state.remote.outputs.vpc_id 
}
data "aws_subnet" "public_subnet" {
  count = "${length(data.aws_subnet_ids.public_subnet_ids.ids)}"
  id    = "${tolist(data.aws_subnet_ids.public_subnet_ids.ids)[count.index]}"
}

output "subnet_cidr_blocks" {
  value = ["${data.aws_subnet.public_subnet.*.id}"]
}