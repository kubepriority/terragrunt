# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  backend "s3" {
    bucket         = "vpc-terraform-kubepriority-state"
    dynamodb_table = "kubepriority-tf-lock-table"
    encrypt        = true
    key            = "./terraform.tfstate"
    region         = "us-east-1"
  }
}
