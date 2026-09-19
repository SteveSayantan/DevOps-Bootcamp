# Multiple Providers

We can use multiple providers in one single terraform project. For example,


1. Create a `providers.tf` file in the root directory of our Terraform project.

2. In the `providers.tf` file, define the AWS and Azure providers. For example:

   ```
   terraform {
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "~> 3.0"
      }
      azurerm = {
        source  = "hashicorp/azurerm"
        version = ">= 2.0, < 3.0"
      }
    }
   }
   ```

3. In our other Terraform configuration files, we can then use the aws and azurerm providers to create resources in AWS and Azure, respectively,

   ```
   resource "aws_instance" "example" {
     ami = "ami-0123456789abcdef0"
     instance_type = "t2.micro"
   }

   resource "azurerm_virtual_machine" "example" {
     name = "example-vm"
     location = "eastus"
     size = "Standard_A1"
   }
   ```
