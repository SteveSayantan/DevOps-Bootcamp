data "aws_ami" "get_os_ami" {

  owners = ["amazon"]

  filter {
    name   = "name"
    values = [local.ami_map[lower(var.ec2_os)]]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "free-tier-eligible"
    values = ["true"]
  }

  filter {
    name   = "block-device-mapping.delete-on-termination"
    values = ["true"]
  }

  most_recent = true
}

# 1) Default VPC
data "aws_vpc" "default" {
  default = true
}

# 2) All security group IDs in that VPC
data "aws_security_groups" "in_default_vpc" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# 3) Read each SG in detail
data "aws_security_group" "sg" {
  for_each = toset(data.aws_security_groups.in_default_vpc.ids)
  id       = each.value
}

# 4) Read associated SGR IDs
data "aws_vpc_security_group_rules" "sgrs_per_sg" {

  for_each = data.aws_security_group.sg

  filter {
    name   = "group-id"
    values = [each.value.id]
  }

}

# 5) Read each SGR in detail
data "aws_vpc_security_group_rule" "sgr" {

  # 1. Iterate over all instances of aws_vpc_security_group_rules
  # 2. Return the list of id for each of them
  # 3. Collect each list in the same parent list
  # 4. Flatten 
  for_each = toset(flatten([for l in data.aws_vpc_security_group_rules.sgrs_per_sg : l.ids]))

  security_group_rule_id = each.value

}

data "aws_security_group" "default_sg" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}