provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}



module "eks" {
  source          = "github.com/terraform-aws-modules/terraform-aws-eks?ref=v15.1.0"
  cluster_name    = "eks-prd"
  cluster_version = "1.21"
  subnets         = data.terraform_remote_state.remote.outputs.private_subnets
  vpc_id          = data.terraform_remote_state.remote.outputs.vpc_id
  enable_irsa     = true
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  tags = {
    eks = "workers-prd"
  }

#  workers_group_defaults = {
#    root_volume_type = "gp3"
#    root_volume_size = 40
#  }
#
# workers_additional_policies = [
#     "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
#     "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
#     "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#  ]
#
#
#  worker_groups = [
#    {
#      name                          = "workers"
#      instance_type                 = "t3a.xlarge"
#      additional_userdata           = "echo Eks nodes"
#      asg_desired_capacity          = 3
#      cluster_name                  = "eks-prd"
#      additional_security_group_ids = [aws_security_group.sg-eks-cluster.id]
#      labels                        = {
#        ingress = "true"
#      }
#    }
#
#  ]
#
}

#resource "aws_eks_addon" "vpc-cni" {
#  cluster_name = "eks-prd"
#  addon_name   = "vpc-cni"
#}
#
#resource "aws_eks_addon" "aws-ebs-csi-driver" {
#  cluster_name = "eks-prd"
#  addon_name   = "aws-ebs-csi-driver"
#}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
