terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}

resource "aws_instance" "demo" {
    ami           = "ami-091138d0f0d41ff90"  # Specify an appropriate AMI ID
    instance_type = "t2.nano"
    tags = {
        Name = "Hello World"
    }
    key_name = "target_key"     # private key to connect to ec2, must exist on aws account

    security_groups = ["launch-wizard-1","default"]    # the default SG of the chosen AZ shall be used, if not specified
}

output "demo_IP" {
  description = "Public IP of created EC2"
  value       = aws_instance.demo.public_ip
}

# Because these settings are not explicitly specified, AWS will behave as follows:
# Availability Zone: any AZ in the chosen region, based on AWS placement decisions.
# Subnet: default subnet of the chosen AZ. Since, for default subnets, **auto-assign public IPV4 address** is enabled, our instance will have an public IP.
