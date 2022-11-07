# aws eks describe-addon-versions

variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))

  default = [
    {
      name    = "aws-ebs-csi-driver"
      version = "v1.11.4-eksbuild.1"
    },
    {
      name    = "kube-proxy"
      version = "v1.23.8-eksbuild.2"
    },
    {
      name    = "vpc-cni"
      version = "v1.11.4-eksbuild.1"
    },
    {
      name    = "coredns"
      version = "v1.8.7-eksbuild.3"
    }
  ]
}