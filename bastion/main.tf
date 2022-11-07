module "bastion" {
  source  = "infrablocks/bastion/aws"

  vpc_id      = data.terraform_remote_state.remote.outputs.vpc_id
  subnet_ids  = "${tolist(data.aws_subnet_ids.public_subnet_ids.ids)}" 

  component = "eks"
  deployment_identifier = "prd"
  
  ami = ""
  instance_type = "t3.micro"
  
  ssh_public_key_path = "~/.ssh/id_rsa.pub"
  
  allowed_cidrs = ["10.217.0.0/18"]
  egress_cidrs = ["0.0.0.0/0"]
  
  # load_balancer_names = ["lb-12345678"]
  
  minimum_instances = 1
  maximum_instances = 1
  desired_instances = 1
}