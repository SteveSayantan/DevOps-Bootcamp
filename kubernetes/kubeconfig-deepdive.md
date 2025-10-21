All the communication the K8s server through `kubectl` uses `kubeconfig` file located at `~/.kube/config` (default). It is a YAML configuration file that tells `kubectl` (and other Kubernetes clients) how to connect to a cluster — including which cluster, which user credentials, and which context to use.

We can have multiple kubeconfig files as well. For further details check out [this](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/#the-kubeconfig-environment-variable)

Components of the **kubeconfig** file:
- **clusters**: This section defines Kubernetes API servers we can connect to. There can be multiple clusters.

  Each entry has:
  * **name** – unique name for the cluster.
  * **cluster** – contains:
    * `server`: URL of the API server (control plane).
    * `certificate-authority` or `certificate-authority-data`: CA certificate used to verify the server’s certificate.
    * `insecure-skip-tls-verify`: (optional) skips certificate verification (use only for testing).
- **users**: Defines **authentication information** for users, service accounts, or automation tools. There can be multiple users.

  Each user can authenticate in several ways:

  * Client certificates (x509)
  * Bearer tokens
  * OIDC tokens 
- **contexts**: A context is a combination of cluster + user + optional namespace. This tells `kubectl` which cluster to talk to, who to authenticate as, and where (namespace).  By default, the `kubectl` command-line tool uses parameters from the current context to communicate with the cluster.

- **current-context**: Specifies the default context kubectl uses (if no --context flag is passed).

- **preferences**: Rarely used; holds user interface preferences for kubectl. Usually left empty.
