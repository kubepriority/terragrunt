# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  backend "s3" {
    bucket         = "vpc-terraform-eds-lab-state"
    dynamodb_table = "eds-lab-tf-lock-table"
    encrypt        = true
    key            = "vpc/terraform.tfstate"
    region         = "us-east-1"
  }
}
