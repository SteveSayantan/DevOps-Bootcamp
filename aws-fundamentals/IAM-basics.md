# IAM

AWS IAM (Identity and Access Management) is a service provided by Amazon Web Services (AWS) that helps us manage access to our AWS resources. It's like a security system for our AWS account.

- IAM allows us to create and manage users, groups, and roles. Users represent individual people or entities who need access to our AWS resources. Groups are collections of users with similar access requirements, making it easier to manage permissions. Roles are used to grant temporary access to external entities or services.

- With IAM, we can control and define permissions through policies. Policies are written in JSON format and specify what actions are allowed or denied on specific AWS resources. These policies can be attached to IAM entities (users, groups, or roles) to grant or restrict access to AWS services and resources.

- IAM follows the principle of least privilege, meaning users and entities are given only the necessary permissions required for their tasks, minimizing potential security risks. IAM also provides features like multi-factor authentication (MFA) for added security and an audit trail to track user activity and changes to permissions.

- By using AWS IAM, we can effectively manage and secure access to our AWS resources, ensuring that only authorized individuals have appropriate permissions and actions are logged for accountability and compliance purposes.

Overall, IAM is an essential component of AWS security, providing granular control over access to our AWS account and resources, reducing the risk of unauthorized access and helping maintain a secure environment.

## Components of IAM 

- Users: IAM users represent individual people or entities (such as applications or services) that interact with our AWS resources. Each user has a unique name and security credentials (password or access keys) used for authentication and access control.

- Groups: IAM groups are collections of users with similar access requirements. Instead of managing permissions for each user individually, we can assign permissions to groups, making it easier to manage access control. Users can be added or removed from groups as needed.

- Roles: IAM roles are used to grant temporary access to AWS resources. It doesn’t have permanent credentials. Instead, it issues temporary security tokens through AWS STS (Security Token Service). E.g., We launch an EC2 instance that needs to access S3. Instead of putting access keys in code (bad idea), we attach an IAM Role to the instance. The role gives temporary credentials to the instance, allowing it to read/write S3.

- Policies: IAM policies are JSON documents that define permissions. Policies specify the actions that can be performed on AWS resources and the resources to which the actions apply. Policies can be attached to users, groups, or roles to control access. IAM provides both AWS managed policies (predefined policies maintained by AWS) and customer managed policies (policies created and managed by us).
