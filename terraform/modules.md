## Modules
Instead of repeatedly provisioning collections of resources with similar configuration, such as networking resources for new development environments, we should write reusable modules to codify them. Terraform modularization is the practice of breaking down large, complex Terraform configurations into smaller, reusable, and logically separated modules. This enhances maintainability, scalability, and collaboration. Modules are downloaded/retrieved during `terraform init`.

Modules we configure using module blocks are called child modules. When we apply a configuration, the root module calls the child module. As a result, Terraform adds the child module's resources to our workspace and manages them as part of the configuration.
> Provider configurations can be defined only in the root Terraform module. The descendant modules can use those providers through inheritance or explicitly via the `providers` argument within a `module` block.

> A module intended to be called by one or more other modules must not contain any `provider` blocks. However, each module must declare its own provider requirements (using `required_providers` block), so that Terraform can ensure that there is a single version of the provider that is compatible with all modules in the configuration. Terraform combines all constraints (as specified in the root and child modules) for that same provider and tries to pick one version that satisfies all of them. If no such version is found, `terraform init` fails.

The advantage of using Terraform modules in our infrastructure as code (IaC) projects lies in improved organization, reusability, and maintainability. Here are the key benefits:

1. **Modularity**: Terraform modules allow us to break down our infrastructure configuration into smaller, self-contained components. This modularity makes it easier to manage and reason about our infrastructure because each module handles a specific piece of functionality, such as an EC2 instance, a database, or a network configuration.

1. **Reusability**: With modules, we can create reusable templates for common infrastructure components. Instead of rewriting similar configurations for multiple projects, we can reuse modules across different Terraform projects. This reduces duplication and promotes consistency in our infrastructure.

1. **Simplified Collaboration**: Modules make it easier for teams to collaborate on infrastructure projects. Different team members can work on separate modules independently, and then these modules can be combined to build complex infrastructure deployments. This division of labor can streamline development and reduce conflicts in the codebase.

1. **Versioning and Maintenance**: Modules can have their own versioning, making it easier to manage updates and changes. When we update a module, we can increment its version, and other projects using that module can choose when to adopt the new version, helping to prevent unexpected changes in existing deployments.

1. **Abstraction**: Modules can abstract away the complexity of underlying resources. For example, an EC2 instance module can hide the details of security groups, subnets, and other configurations, allowing users to focus on high-level parameters like instance type and image ID.

1. **Testing and Validation**: Modules can be individually tested and validated, ensuring that they work correctly before being used in multiple projects. This reduces the risk of errors propagating across our infrastructure.

1. **Scalability**: As our infrastructure grows, modules provide a scalable approach to managing complexity. We can continue to create new modules for different components of our architecture, maintaining a clean and organized codebase.

## References
- [Terraform Module](https://developer.hashicorp.com/terraform/language/modules)