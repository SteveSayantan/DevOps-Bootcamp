resource "aws_instance" "ec2-demo_tf" {

  ami = data.aws_ami.get_os_ami.id

  instance_type = "t2.micro"

  tags = {
    Name = var.ec2_name
  }

  key_name = "target_key" # private key to connect to ec2, must exist on aws account

  vpc_security_group_ids = [data.aws_security_group.default_sg.id, local.ec2_sg_id]

  root_block_device {
   
    # Tags specified here are applied after instance creation via a separate API call.
    # i.e., Terraform calls the AWS API to create the EC2 instance, which initially only requires ec2:RunInstances permission.
    
    # Once the instance is ready, Terraform makes a completely separate, subsequent API call (ec2:CreateTags).
    
    # NOTE: If our IAM user lacks 'ec2:CreateTags' permission, AWS rejects this call, but the Terraform AWS Provider 
    # catches and suppresses this error internally. The root volume will fail to get tagged, but Terraform 
    # will SILENTLY display a successful apply anyway.

    # For this reason, we cannot enforce ABAC policies that say "You can only create a volume if it contains specific tags" using the "root_block_device" block.

    tags = {
      Name = "ebs-demo_tf"
    }
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "allow_ssh"
  }

  # create only if no similar security group exists
  count = length(local.sg_id) > 0 ? 0 : 1
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_rule" {

  # since, we're using the id of the security group, it explicitly creates a dependency 
  # i.e. the security group must be created prior to ingress rule

  count             = length(aws_security_group.allow_ssh)
  security_group_id = aws_security_group.allow_ssh[count.index].id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

locals {

  # Find SGs that have an ingress rule allowing tcp/22 from 0.0.0.0/0
  sg_id = [
    for sgr in data.aws_vpc_security_group_rule.sgr : sgr.security_group_id
    if !sgr.is_egress && sgr.ip_protocol == "tcp" && sgr.from_port == 22 && sgr.from_port == 22 && sgr.cidr_ipv4 == "0.0.0.0/0"
  ]

  ec2_sg_id = length(local.sg_id) > 0 ? local.sg_id[0] : aws_security_group.allow_ssh[0].id
}

locals {
  ami_map = {
    rhel-10   = "RHEL-10.1.*_HVM-*-x86_64-0-Hourly2-GP3"
    ubuntu-24 = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
  }
}


