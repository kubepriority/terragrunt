
resource "aws_security_group" "sg-eks-cluster" {
  name        = "SG-EKS-PRD"
  description = "Cluster communication with worker nodes"
  vpc_id      = data.terraform_remote_state.remote.outputs.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
 }
}

