data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Environment"
    values = ["prod"]
  }
}

data "terraform_remote_state" "remote" {
  backend = "s3"
  config = {
    bucket         = "vpc-terraform-trt17-state"
    dynamodb_table = "trt17-tf-lock-table"
    encrypt        = true
    key            = "vpc/terraform.tfstate"
    region         = "sa-east-1"
  }
}

