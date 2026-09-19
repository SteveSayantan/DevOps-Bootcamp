# Variables

Variables in Terraform are essential for parameterizing and sharing values within our Terraform configurations and modules. They allow us to make our configurations more dynamic, reusable, and flexible.

## Input Variables

Input variables are used to parameterize our Terraform configurations. They allow us to pass values into configurations from outside.

```hcl
variable "example_var" {
  description = "An example input variable"
  type        = string
  default     = "default_value"
}
```

In this example:

- `variable` is used to declare an input variable named `example_var`.
- `description` (Optional) provides a human-readable description of the variable.
- `type` (Optional) specifies the data type of the variable (e.g., `string`, `number`, `list`, `map`, etc.).
- `default` (Optional) provides a default value for the variable.
  > Terraform treats a variable without a default as required. If Terraform can’t find a value for such a variable from any input source, it will stop and prompt us interactively for the value. If we're in a non-interactive context (common in CI) or we pass `-input=false`, Terraform will fail with an error (because it cannot prompt). However, if the variable is declared but never used anywhere, Terraform won’t ask for it—required only matters when Terraform needs its value during evaluation.

For details, refer to the [docs](https://developer.hashicorp.com/terraform/language/block/variable)

We can then use the input variable within configuration like this:

```hcl
resource "example_resource" "example" {
  name = var.example_var
  # other resource configurations
}
```

We reference the input variable using `var.example_var`.

We can use the approaches mentioned [here](https://developer.hashicorp.com/terraform/language/values/variables#assign-values-to-variables) to assign values to variables.

## Output Variables

Output variables allow us to expose values from our module or configuration, making them available for use in other parts of our Terraform setup. 

Here's how we define an output variable for a resource:

```hcl
output "example_output" {
  description = "An example output variable"
  value       = example_resource.example.id
}
```

In this example:

- `output` is used to declare an output variable named `example_output`.
- `description` provides a description of the output variable.
- `value` specifies the value that we want to expose as an output variable. This value can be a resource attribute, a computed value, or any other expression.

For more details, refer to the [docs](https://developer.hashicorp.com/terraform/language/block/output)

We can reference output variables in the root module or in other modules by using the syntax `module.module_name.output_name`, where `module_name` is the name of the module containing the output variable.

For example, if we have an output variable named `example_output` in a module called `example_module`, we can access it in the root module like this:

```hcl
output "root_output" {
  value = module.example_module.example_output
}
```
This allows us to share data and values between different parts of our Terraform configuration and create more modular and maintainable infrastructure-as-code setups.

## References
- [Variables in Terraform](https://developer.hashicorp.com/terraform/language/values/variables)
- [Outputs in Terraform](https://developer.hashicorp.com/terraform/language/values/outputs)
- [Data Sources](https://developer.hashicorp.com/terraform/language/data-sources)
- [For expression](https://developer.hashicorp.com/terraform/language/expressions/for)
- [Anytrue function](https://developer.hashicorp.com/terraform/language/functions/anytrue)
- [Locals block](https://developer.hashicorp.com/terraform/language/values/locals)
- [for_each reference](https://developer.hashicorp.com/terraform/language/meta-arguments/for_each)