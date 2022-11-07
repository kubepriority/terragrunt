###################################################################################
# EKS Module https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master
###################################################################################

resource "aws_eks_addon" "addons" {
  for_each          = { for addon in var.addons : addon.name => addon }
  cluster_name      = module.eks.cluster_id
  addon_name        = each.value.name
  addon_version     = each.value.version
  resolve_conflicts = "OVERWRITE"
}