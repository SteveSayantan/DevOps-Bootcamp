## EKS User Access Management
An EKS Access Entry is a native AWS feature that maps AWS IAM identities (users or roles) directly to Kubernetes permissions inside an EKS cluster.

Its main role is to replace the legacy aws-auth ConfigMap, providing a completely API-driven and automated way to manage cluster access.

Here, instead of having access entry for each IAM user, we create an IAM role that users can assume.

However, only having the access entry is not enough, we also need to associate eks access policy with it.

So, the flow looks like:
1. Create a role
2. Register the IAM Role as an EKS Access Entry
3. Associate one (or more) eks access policies with the Access Entry

## AMI Type and Instance Type
If we leave the `ami_type` parameter blank or omitted, the configuration behaves based on a split fallback mechanism between the Terraform EKS module and AWS itself.

The selection logic works through the following order of operations:

1. The official AWS EKS Terraform Module does not pass a completely empty value to AWS. Instead, its submodules provide a pre-configured fallback default value. For modern versions of the module, the default value is explicitly hardcoded to `AL2023_x86_64_STANDARD`. Check out [this](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest/submodules/eks-managed-node-group?tab=inputs) 

2. If we bypass the module and construct a node group directly via raw AWS resources, the AWS EKS Control Plane uses its own automated internal fallback logic based on the `instance_types` array we provide: 

   * If we provide an instance type: AWS scans the `instance_types` field (e.g., **t3.medium**). It detects the underlying hardware architecture (**x86_64**) and automatically provisions the latest recommended version of Amazon Linux for x86 optimized for our specific cluster's Kubernetes version.

   * If we provide no instance type: AWS defaults the hardware type to standard **t3.medium** instances. Check out [this](https://docs.aws.amazon.com/cli/latest/reference/eks/create-nodegroup.html)
   
     Consequently, it falls back to provisioning the default x86 Amazon Linux AMI.

### References:
- [Access policy permissions](https://docs.aws.amazon.com/eks/latest/userguide/access-policy-permissions.html)
- [Associate access policies with access entries](https://docs.aws.amazon.com/eks/latest/userguide/access-policies.html)