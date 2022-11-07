provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

locals {
  name            = "ex-${replace(basename(path.cwd), "_", "-")}"
  cluster_version = "1.23"
  region          = "us-east-1"

  tags = {
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}


module "eks" {
  source          = "github.com/terraform-aws-modules/terraform-aws-eks?ref=v18.8.0"
  cluster_name    = local.name
  cluster_version = local.cluster_version

  vpc_id          = data.terraform_remote_state.remote.outputs.vpc_id
  subnet_ids      = data.terraform_remote_state.remote.outputs.private_subnets
  enable_irsa     = true

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_addons = {
    #coredns = {
    #  resolve_conflicts = "OVERWRITE"
    #}
    kube-proxy = {
      esolve_conflicts        = "OVERWRITE"
    }
    vpc-cni = {
      resolve_conflicts        = "OVERWRITE"
      #service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
    }
  }

}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
