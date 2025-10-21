# Service Account

## What Are Service Accounts

A **ServiceAccount** is a non-human identity in Kubernetes, used by **Pods or automated components** to authenticate with the Kubernetes API. Unlike human users, ServiceAccounts exist as resource objects within specific namespaces. Each namespace automatically receives a `default` ServiceAccount unless we explicitly create others.

> The default service accounts in each namespace get no permissions by default other than the default API discovery permissions that Kubernetes grants to all authenticated principals if role-based access control (RBAC) is enabled.

Key characteristics:

* **Namespaced**: A ServiceAccount belongs to a specific namespace.
* **Lightweight & portable**: Easy to create and use for workloads, making configuration portable across environments. 

  They are portable because:

  - We can easily ship them with our workloads across environments (dev → staging → prod), as they are namespaced Kubernetes objects.

  - For example, if we deploy the same app in minikube (local dev) and later in EKS (production), we don’t need to reinvent authentication.

  - The ServiceAccount YAML applies to both clusters (though permissions via RBAC may differ).

  - ServiceAccounts integrate seamlessly with workload manifests. So if we bundle them in a Helm chart or Kustomize overlay, the same configuration travels with our app.

* **Different from users**: K8s does not handle user management, it off-loads this responsibility to identity providers. Some Identity providing mechanisms are LDAP, OKTA, SSO etc.

## Why Service Accounts Matter

1. Secure Workload Authentication

   ServiceAccounts provide a secure identity for Pods, especially when they need to interact with the Kubernetes API—such as reading Secrets, creating Jobs, or managing resources.

   Use cases include:

   * Pods needing access to Secrets
   * Cross-namespace interactions like watching Lease objects
   * Workloads accessing external services via identity tokens e.g. an app running in Kubernetes needs to access AWS S3.
   * Authenticating to a private image registry using an imagePullSecret.

2. Fine-Grained Access Control via RBAC

   ServiceAccounts integrate seamlessly with **Role-Based Access Control (RBAC)** to grant least-privilege access, ensuring Pods only have permissions they truly need.

3. Avoid Hardcoding Secrets

   Using ServiceAccounts eliminates the need to embed credentials directly in Pods. Access tokens are dynamically managed and scoped securely.

## How Service Accounts Work

1. Creation

   A ServiceAccount is created either automatically (`default` ServiceAccount) or manually via YAML/`kubectl`.

   ```yaml
   apiVersion: v1
   kind: ServiceAccount
   metadata:
    name: my-app-sa
   ```

1. Assigning to Pods

   We specify the service account in the pod spec:

   ```yaml
   spec:
     serviceAccountName: my-app-sa
   ```

   If omitted, Kubernetes uses the namespace’s `default` ServiceAccount.

   Also, we create a role, which grants access, and then bind the role to the ServiceAccount. RBAC lets us define a minimum set of permissions so that the service account permissions follow the principle of least privilege. Pods that use that service account don't get more permissions than are required to function correctly.

### How Tokens Work

* In Kubernetes v1.22+, Pods receive a **short-lived** (default 1hr), **auto-rotated token** (kubelet rotates the token automatically before it expires) mounted at `/var/run/secrets/kubernetes.io/serviceaccount/token` as a projected volume using `TokenRequest` API.
  - It is meant for authenticating against the Kubernetes API server only.
  - To prevent Kubernetes from automatically injecting credentials for a specified ServiceAccount or the `default` ServiceAccount, set the `automountServiceAccountToken` field in the Pod specification to `false`.

* In older versions, a static token stored in a Secret was auto-mounted.

### Authentication

Requests from our Pod to the API server use these tokens and are authenticated as:
```
system:serviceaccount:<namespace>:<serviceaccount-name>
```

Every service account is automatically part of two groups:

* `system:serviceaccounts`:This is a cluster-wide group that includes all service accounts in the cluster.
* `system:serviceaccounts:<namespace>`:This is a namespace-specific group that includes all service accounts within that namespace.


## Manually retrieve ServiceAccount credentials
If we need the credentials for a ServiceAccount to mount in a non-standard location, or for an audience that isn't the API server, use one of the following methods. 

In both of the cases, it is a good practice to disable the automatic mount of the default token at `/var/run/secrets/kubernetes.io/serviceaccount/token`.

- **TokenRequest API**

  Create a token with `kubectl` for the exsisting ServiceAccount `my-app`, which valid for 1 hour, scoped to audience `vault`.

  ```bash
  kubectl create token my-app --audience vault --duration=1h
  ```
  Or, using the JSON body, we need to make a POST request to the api server. The API server responds with a signed JWT in `.status.token`.

  ```json
  {
    "apiVersion": "authentication.k8s.io/v1",
    "kind": "TokenRequest",
    "spec": {
      "audiences": ["vault"],  // it sets a property on the JWT. Only the systems that validate tokens against "vault" as an accepted audience will accept it. 
      "expirationSeconds": 3600
    }
  }
  ```
  Now, Vault can then validate that token against the K8s API server. However, the app must handle the rotation logic manually. Also, the ServiceAccount must have sufficient permissions (i.e. `create` on `serviceaccounts/token`) to be able to request the token. Hence, we need to create a **Role** and **RoleBinding** as well.

- **Token Volume Projection**  
  Check out this [article](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#launch-a-pod-using-service-account-token-projection).

  Here, Kubernetes mounts a **short-lived token** at `/var/run/secrets/tokens/vault-token` inside the Pod. The application just reads the file. No need to call APIs or handle rotation logic manually.

