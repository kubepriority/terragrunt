data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Environment"
    values = ["prod"]
  }
}

data "terraform_remote_state" "remote" {
  backend = "s3"
  config = {
    bucket         = "vpc-terraform-kubepriority-lab-state"
    dynamodb_table = "kubepriority-lab-tf-lock-table"
    encrypt        = true
    key            = "vpc/terraform.tfstate"
    region         = "us-east-1"
  }
}