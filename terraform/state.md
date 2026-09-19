## Terraform State File
Terraform is an Infrastructure as Code (IaC) tool used to define and provision infrastructure resources. The Terraform state file is a crucial component of Terraform that helps it keep track of the resources it manages and their current state. This file, often named `terraform.tfstate`, is a JSON or HCL (HashiCorp Configuration Language) formatted file that contains important information about the infrastructure's current state, attributes, dependencies, and metadata. It also stores dependency relationships and cached attribute values from providers (for performance improvement).

**Advantages of Terraform State file**:

1. **Resource Tracking**: The state file keeps track of all the resources managed by Terraform, including their attributes and dependencies. This ensures that Terraform can accurately update or destroy resources when necessary.

2. **Concurrency Control**: Terraform uses the state file to lock resources, preventing multiple users or processes from modifying the same resource simultaneously. This helps avoid conflicts and ensures data consistency.

3. **Plan Calculation**: Terraform uses the state file to calculate and display the difference between the desired configuration (defined in your Terraform code) and the current infrastructure state. This helps you understand what changes Terraform will make before applying them.

4. **Resource Metadata**: The state file stores metadata about each resource, such as dependency relationships.

**Disadvantages of Storing Terraform State in Version Control Systems (VCS):**

1. **Security Risks**: Sensitive information, such as API keys or passwords, may be stored in the state file if it's committed to a VCS. This poses a security risk because VCS repositories are often shared among team members.

2. **Versioning Complexity**: Managing state files in VCS can lead to complex versioning issues, especially when multiple team members are working on the same infrastructure. 
   > [Remote state](https://developer.hashicorp.com/terraform/language/state/remote) is the recommended solution to this problem. With a fully-featured state backend, Terraform can use remote locking as a measure to avoid two or more different users accidentally running Terraform at the same time, and thus ensure that each Terraform run begins with the most recent updated state.

> We should avoid storing our state in a version control system or other storage solution that does not support Terraform state locking and secure access control, because doing so can result in data loss or exposure of secrets stored in the state file.

### Workflow
During `terraform apply/plan`:

1. Terraform loads the current state (local file or remote backend).
1. It reads our .tf configuration.
1. It does a refresh (by default) — asks the provider for real current values and updates the state with the real infrastructure.
1. It produces a plan: create/update/destroy/replace/no-op.
1. On apply, it executes those actions and writes updated state.

### State Best Practices
State can include DB passwords (if passed as variables to resources), User-data script, Private IPs, internal DNS etc. Hence, we must treat the state file as sensitive.

Best practices include:
- Store remote state in private buckets
- Enable versioning
- Enable server-side encryption
- Block public access
- Configure IAM permissions (in AWS)
  - For the CI/CD:
	  - `s3:ListBucket` on the bucket
	  - `s3:GetObject` and `s3:PutObject` on the state file
	  - `s3:GetObject`, `s3:PutObject`, and s3:DeleteObject on the lock file (e.g., *.tflock)
	
  - For Developers: Devs shouldn't be able to perform `terraform apply` locally. This is crucial to ensure that our production environment remains a true reflection of our version-controlled code. However, they can perform `terraform init` (read backend and download current state), `terraform plan` and `terraform show`.
	  - `s3:ListBucket` on the bucket
	  - `s3:GetObject` on the state file

  - Occasionally, a pipeline will crash midway through a run, leaving a orphaned `.tflock` file in S3 that blocks future automated runs. Because developers are read-only, they cannot run `terraform force-unlock` because that command requires `s3:DeleteObject` permissions to clear the lock. In such scenario, a senior engineer must explicitly assume an elevated role with `s3:DeleteObject` permissions, via the CLI, clear the lock using terraform force-unlock, and immediately drop back down to their standard read-only role.
  
  - Block Public Access to the S3
  
  - Explicitly deny any incoming requests that do not use Secure Transport (`aws:SecureTransport: false`) to force full TLS transit.

> We should only commit our configuration files and `.terraform.lock.hcl`(dependency lock file to track only provider dependencies). Never commit `.terraform/` or state.

## Backend
The backend defines where Terraform stores its state data files. Terraform uses persisted state data to keep track of the resources it manages. We can define a `backend` block to store state in a remote object. This lets multiple people access the state data and work together on that collection of infrastructure resources.

> The configurations that do specify a backend at all, default to the `local` backend.

Learn more about backends in Terraform, [here](https://developer.hashicorp.com/terraform/language/backend)

## 
- create bucket

## References
- [Purpose of Terraform State](https://developer.hashicorp.com/terraform/language/state/purpose)
- [Securing State File](https://developer.hashicorp.com/terraform/language/manage-sensitive-data#state-security-best-practices)