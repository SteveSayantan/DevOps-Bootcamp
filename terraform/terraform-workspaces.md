## Introduction
Terraform workspaces (aka CLI Workspaces) lets us manage multiple deployments of the same configuration. For example, suppose, we have created a module that creates the following resources:

- VPC (or uses an existing one)
- EC2 
- security groups, IAM roles, etc.

We have to create similar resources (with very few changes) for three environments i.e. Dev, Stage and Prod (say). Without workspaces, we typically end up copying the same root module into multiple folders which involves lots of duplication. 

This is, because, a Terraform project uses a single State file that records the infrastructure information for wherever the code was last executed. If we subsequently attempt to deploy the same project to a Staging environment—even with a different variable file (like stage.tfvars) to change minor details like an EC2 instance size—Terraform will not create a separate Staging environment. Instead, because it relies on that single State file, it assumes we are trying to change our existing infrastructure and will attempt to modify, override, or delete the Development resources we just created to match the Staging configuration.

Terraform workspaces solve this problem by automatically creating and maintaining a separate, unique State file for each environment. When we create multiple workspaces (such as Dev, Stage, and Prod), Terraform generates dedicated folders under a directory named `terraform.tfstate.d`, with each folder containing an isolated State file for that specific environment. Because these State files no longer overlap, we only need to write your Terraform project/configuration once. We can seamlessly switch between workspaces, ensuring that only the State file for our active workspace is updated. This allows us to safely deploy independent, non-conflicting infrastructure—such as a **t2.micro** instance for Development and a **t2.xlarge** instance for Production—using a single project paired with environment-specific variables.
> Workspaces are convenient because they let us create different sets of infrastructure with the same working copy of our configuration and the same plugin and module caches.

## Workflow
> Every initialized working directory starts with one workspace named `default`.

The workflow for managing multi-environment infrastructure with Terraform Workspaces involves the following key steps:

*   **Define Configuration:** Define the resources we want Terraform to create.

*   **Create Workspaces:** Initialize new, isolated environments (such as Dev, Stage, or Prod) using the command `terraform workspace new <environment_name>`. This automatically generates dedicated folders for each environment's state file under a directory named `terraform.tfstate.d`.

*   **Select a Workspace:** Switch between our environments using the command `terraform workspace select <environment_name>`. We can verify which workspace is currently active by running `terraform workspace show`.

*   **Configure Environment-Specific Variables:** To apply different configurations for each environment (e.g., deploying a `t2.micro` instance in Dev and a `t2.xlarge` in Prod), we may follow two approaches:

    *   **Separate Variable Files:** Create distinct variable files for each environment (like `dev.tfvars` or `stage.tfvars`) and pass them during execution using `terraform apply -var-file=<filename>`.

    *   **Dynamic Lookup:** Define a map of string variables in our configuration and use the `lookup()` function combined with the built-in `terraform.workspace` variable. This setup automatically detects our active workspace and fetches the corresponding values for that specific environment, eliminating the need to pass separate variable files manually.

    For example,
    ```hcl
    variable "instance_type" {
      description = "value"
      type = map(string)

      default = {
        "dev" = "t2.micro"
        "stage" = "t2.medium"
        "prod" = "t2.xlarge"
      }
    }

    module "ec2_instance" {
      source = "./modules/ec2_instance"
      ami = var.ami
      instance_type = lookup(var.instance_type, terraform.workspace, "t2.micro")
    }
    ```

* **Execute the Deployment:** Run `terraform init` followed by `terraform apply`. Terraform will read our configurations and create or update the infrastructure, recording the changes exclusively in the isolated state file for our currently active workspace. 

>  Because we are managing multiple environments from a single project, we must be extremely careful and double-check our active workspace before running destructive commands like `terraform destroy`. Executing a destroy command while accidentally in the wrong workspace can wipe out critical environments like Production.

## References
- [Backend Configuration](https://developer.hashicorp.com/terraform/language/state/workspaces)
- [Managing Workspaces](https://developer.hashicorp.com/terraform/cli/workspaces)
- [Workspace Command](https://developer.hashicorp.com/terraform/cli/commands/workspace)
- [Lookup Function](https://developer.hashicorp.com/terraform/language/functions/lookup)