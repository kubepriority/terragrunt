generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Managed_by  = "Terraform"
      Environment = "Prod"
      map-migrated= "d-server-02dzarjfi0ibj1"
    }
  }
}
EOF
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    key = "${path_relative_to_include()}/terraform.tfstate"
    encrypt        = true
    bucket         = "vpc-terraform-eds-lab-state"
    region         = "us-east-1"
    dynamodb_table = "eds-lab-tf-lock-table"

  }
}