# ConfigMaps
A ConfigMap is an API object used to store non-confidential data in key-value pairs. Pods can consume ConfigMaps as environment variables, command-line arguments, or as configuration files in a volume.

A ConfigMap allows us to decouple environment-specific configuration from our container images, so that our applications are easily portable.

Unlike most Kubernetes objects that have a spec, a ConfigMap has **data** and **binaryData** fields. These fields accept key-value pairs as their values. Both the data field and the binaryData are optional. The **data** field is designed to contain UTF-8 strings while the **binaryData** field is designed to contain binary data as base64-encoded strings.

> The data stored in a ConfigMap cannot exceed 1 MiB.

There are four different ways that we can use a ConfigMap to configure a container inside a Pod:

- Inside a container command and args (Mount and use)
- Environment variables for a container
- Add a file in read-only volume, for the application to read
- Write code to run inside the Pod that uses the Kubernetes API to read a ConfigMap (Interact with K8s programatically)

### Mounted ConfigMaps are updated automatically
If we modify a ConfigMap, our application needs to be restarted. The changes aren't synced automatically. Only in case of volume mount (without subpath), the ConfigMap changes are reflected in the mounted filesystem. This can be configured using `configMapAndSecretChangeDetectionStrategy` field in the KubeletConfiguration struct.

### Immutability

For clusters that extensively use ConfigMaps (at least tens of thousands of unique ConfigMap to Pod mounts), preventing changes to their data has the following advantages:

- protects us from accidental (or unwanted) updates that could cause applications outages
- improves performance of our cluster by significantly reducing load on kube-apiserver, by closing watches for ConfigMaps marked as immutable.

We can create an immutable ConfigMap by setting the immutable field to true. For example:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  ...
data:
  ...
immutable: true
```
Once a ConfigMap is marked as immutable, it is not possible to revert this change nor to mutate the contents of the data or the binaryData field. We can only delete and recreate the ConfigMap. Because existing Pods maintain a mount point to the deleted ConfigMap, it is recommended to recreate these pods.

## Examples

1. **Environment variables for a container**

   Here's our ConfigMap:

   ```yaml
   apiVersion: v1
   kind: ConfigMap
   metadata:
   name: bootcamp-configmap
   data:
    username: "saiyam"
    database_name: "exampledb"
   ```
    We can use these values as environment variables

    ```yaml
    # pod.yaml
    ...
    spec:
    containers:
    - name: mysql
        image: mysql:5.7
        env:
        - name: MYSQL_USER
            valueFrom:
            configMapKeyRef:
                name: bootcamp-configmap
                key: username
        - name: MYSQL_DATABASE
            valueFrom:
            configMapKeyRef:
                name: bootcamp-configmap
                key: database_name
    ...
    ```
1. **Add a file in read-only volume**

   First, we create two ConfigMaps, one for Development and the other one for Production.

   ```yaml
   apiVersion: v1
   kind: ConfigMap
   metadata:
    name: app-config-dev
    data:
        settings.properties: |
            # Development Configuration
            debug=true
            database_url=http://dev-db.example.com
            featureX_enabled=false
  
   ---

   apiVersion: v1
   kind: ConfigMap
   metadata:
   name: app-config-prod
   data:
    settings.properties: |
        # Production Configuration
        debug=false
        database_url=http://prod-db.example.com
        featureX_enabled=true
   ```
   Now, we can mount one of these as a volume to a Pod as shown below:

   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   ...
   template:
       ...
        spec:
        containers:
        ...  
            volumeMounts:
            - name: config-volume
              mountPath: /etc/config
              readOnly: true
        volumes:
        - name: config-volume
            configMap:
            name: app-config-dev  # for production, we need to change this to app-config-prod
   ```
   Mounting the ConfigMap as a volume would create a file with the same name as the key, here `settings.properties` at the mount path in the container, here `/etc/config`. The file would contain the value of the corresponding key.

   Here's another example from the [docs](https://kubernetes.io/docs/concepts/configuration/configmap/#configmaps-and-pods)

1. **Write code to run inside the Pod that uses the Kubernetes API to read a ConfigMap**

   Here's a demo python program that uses K8s api to read a ConfigMap, when run inside a Pod.

   ```python
   from kubernetes import client, config

    def main():
        config.load_incluster_config()

        v1 = client.CoreV1Api()
        config_map_name = 'app-config'
        namespace = 'default'

        try:
            config_map = v1.read_namespaced_config_map(config_map_name, namespace)
            print("ConfigMap data:")
            for key, value in config_map.data.items():
                print(f"{key}: {value}")
        except client.exceptions.ApiException as e:
            print(f"Exception when calling CoreV1Api->read_namespaced_config_map: {e}")

    if __name__ == '__main__':
        main()
   ```
   And the manifest for setup:

    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
    name: app-config
    namespace: default
    data:
    example.property: "Hello, world!"
    another.property: "Just another example."

    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
    name: config-reader-deployment
    namespace: default
    spec:
    replicas: 1
    selector:
        matchLabels:
        app: config-reader
    template:
        metadata:
        labels:
            app: config-reader
        spec:
        containers:
        - name: config-reader
            image: ttl.sh/hindi-boot:1h
            imagePullPolicy: Always

    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
    namespace: default
    name: config-reader
    rules:
    - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["get", "list", "watch"]

    ---
    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
    name: read-configmaps
    namespace: default
    subjects:
    - kind: ServiceAccount
    name: default 
    namespace: default
    roleRef:
    kind: Role
    name: config-reader
    apiGroup: rbac.authorization.k8s.io
    ```
    After applying the manifest, run `kubectl logs -l app=config-reader` to get the logs.

---

# Secrets
A Secret is an object that contains a small amount of sensitive data such as a password, a token, or a key. Such information might otherwise be put in a Pod specification or in a container image. Using a Secret means that we don't need to include confidential data in our application code.

Secrets are similar to ConfigMaps but are specifically intended to hold confidential data.

> Kubernetes Secrets are, by default, stored unencrypted in the API server's underlying data store (etcd). Anyone with API access can retrieve or modify a Secret, and so can anyone with access to etcd.

In order to safely use Secrets, take at least the following steps:

- Enable Encryption at Rest for Secrets.

- Enable or configure RBAC rules with least-privilege access to Secrets.

- Restrict Secret access to specific containers.

- Consider using external Secret store providers (e.g. External Secrets Operator, Secret Store CSI Driver, Sealed Secret etc.)

## Built-in Secret types

1. **Opaque Secrets** (Default)

   `Opaque` is the default Secret type if we don't explicitly specify a type in a Secret manifest. When we create a Secret using kubectl, we must use the generic subcommand to indicate an **Opaque** Secret type. For example, the following command creates an empty Secret of type **Opaque**:

   ```bash
   kubectl create secret generic opaque-secret --from-literal=password=supersecret
   ```
   OR, we can apply the following manifest

   ```yaml
   apiVersion: v1
   kind: Secret
   metadata:
     name: my-opaque-secret
   type: Opaque
   data:
     password: c3VwZXJzZWNyZXQ=  # base64 encoded value of 'supersecret'
   ```
To encode in base64, we use

```bash
echo -n supersecret | base64
```

To decrypt it:

```bash
kubectl get secret opaque-secret  # The DATA column in the o/p shows the number of data items stored

kubectl get secret opaque-secret -o yaml

echo password | base64 -d
```
However, we can't store these manifests in the version control. 

1. **Basic authentication Secret**

    The `kubernetes.io/basic-auth` type is provided for storing credentials needed for basic authentication. When using this Secret type, the data field of the Secret must contain one of the following two keys:

    - `username`: the user name for authentication
    - `password`: the password or token for authentication

    Both values for the above two keys are base64 encoded strings.

    Example:

    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
    name: secret-basic-auth
    type: kubernetes.io/basic-auth
    data:
     username: YWRtaW4=          # base64 encoded value of 'admin'
     password: dDBwLVNlY3JldA==  # base64 encoded value of 't0p-Secret'
    ```

    We can also use the following command,

    ```bash
    kubectl create secret generic my-basic-auth-secret \
    --from-literal=username=myuser \
    --from-literal=password=mypassword \
    --type=kubernetes.io/basic-auth
    ```

    > The basic authentication Secret type is provided only for convenience. We can create an `Opaque` type containing the above fields for basic authentication. However, using the defined and public Secret type (`kubernetes.io/basic-auth`) helps other people to understand the purpose of our Secret, and sets a convention for what key names to expect.

1. **SSH authentication Secrets**

   The builtin type `kubernetes.io/ssh-auth` is provided for storing data used in SSH authentication. When using this Secret type, we will have to specify a ssh-privatekey key-value pair in the `data` (or stringData) field as the SSH credential to use.

    Example:

    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
    name: secret-ssh-auth
    type: kubernetes.io/ssh-auth
    data:
    
        ssh-privatekey: | # to preserve the multi-line format of the key
        UG91cmluZzYlRW1vdGljb24lU2N1YmE=...   
    ```
    Or, we can use the following command,

    ```bash
    kubectl create secret generic my-ssh-key-secret \
    --from-file=ssh-privatekey=/path/to/.ssh/id_rsa \
    --type=kubernetes.io/ssh-auth
    ```
    > The SSH authentication Secret type is provided only for convenience. We can create an `Opaque` type to store the credentials used for SSH authentication. However, using the defined and public Secret type (`kubernetes.io/ssh-auth`) helps other people to understand the purpose of our Secret, and sets a convention for what key names to expect.

1. **TLS Secrets**

    The kubernetes.io/tls Secret type is for storing a certificate and its associated key that are typically used for TLS.

    One common use for TLS Secrets is to configure encryption in transit for an Ingress, but we can also use it with other resources or directly in our workload. When using this type of Secret, the `tls.key` and the `tls.crt` key must be provided in the data (or stringData) field of the Secret configuration, although the API server doesn't actually validate the values for each key.

    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
    name: secret-tls
    type: kubernetes.io/tls
    data:
        # values are base64 encoded, which obscures them but does NOT provide
        # any useful level of confidentiality
        # Replace the following values with our own base64-encoded certificate and key.
        tls.crt: "REPLACE_WITH_BASE64_CERT" 
        tls.key: "REPLACE_WITH_BASE64_KEY"
    ```
    Or, we can use the following command,

    ```bash
    kubectl create secret tls my-tls-secret \
      --cert=path/to/cert/file \
      --key=path/to/key/file
    ```
    The public/private key pair must exist before hand. The public key certificate for `--cert` must be `.PEM` encoded and must match the given private key for `--key`.

    > The TLS Secret type is provided only for convenience. We can create an Opaque type for credentials used for TLS authentication. However, using the defined and public Secret type (`kubernetes.io/tls`) helps ensure the consistency of Secret format in our project. The API server verifies if the required keys are set for a Secret of this type.

1. **Docker config Secrets**

    If we are creating a Secret to store credentials for accessing a container image registry, we must use `kubernetes.io/dockerconfigjson` for the `type` value for that Secret. The Secret `data` field must contain a `.dockerconfigjson` key for which the value is the content of a base64 encoded `~/.docker/config.json` file.

    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
        name: secret-demo-dockercfg
    type: kubernetes.io/dockercfg
    data:
        .dockercfg: |   # this is a base64 encoded Docker config file in JSON
            eyJhdXRocyI6eyJodHRwczovL2V4YW1wbGUvdjEvIjp7ImF1dGgiOiJvcGVuc2VzYW1lIn19fQo=    
    ```
    Sample Docker configuration file:

    ```json
    {
        "auths": {
            "my-registry.example:5000": { 
                
                "username": "tiger",
                "password": "pass1234",
                "email": "tiger@acme.example",
                "auth": "dGlnZXI6cGFzczEyMzQ="
            }
        }
    }
    ```
    The `auth` key contains the username and password concatenated with a `:`, encoded using base64. (e.g., ` echo -n tiger:pass1234 | base64`).

    We can encode the above Docker config file by executing the following command and use the output as the value for `.dockerconfigjson` key.

    ```bash
    base64 docker-config-demo.json
    ```


    Or, we can simply use this command to create a Secret of type `kubernetes.io/dockerconfigjson`

    ```bash
    kubectl create secret docker-registry secret-demo-dockercfg \
    --docker-server=<docker-registry-server> \
    --docker-username=<docker-user> \
    --docker-password=<docker-password> \
    --docker-email=<docker-email>
    ```


## Using Secrets
Secrets can be mounted as data volumes or exposed as environment variables to be used by a container in a Pod.

1. **Using Secrets as environment variables**

    To use a Secret in an environment variable in a Pod, for each container in our Pod specification, we add an environment variable for each Secret key that we want to use to the `env[].valueFrom.secretKeyRef` field.

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
    name: mysql
    spec:
    ...
        spec:
        containers:
        - name: mysql
            image: mysql:5.7
            env:
                - name: MYSQL_ROOT_PASSWORD
                  valueFrom:
                    secretKeyRef:
                        name: mysql-root-pass  # use this secret
                        key: password           # pick the value of this key from the secret
                
                - name: MYSQL_PASSWORD
                  valueFrom:
                    secretKeyRef:
                        name: mysql-user-pass
                        key: password
        ...

    ```
1. **Using Secrets as files from a Pod**

    Refer to [Create a Pod that has access to the secret data through a Volume](https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/#create-a-pod-that-has-access-to-the-secret-data-through-a-volume)

1. **Fetching container images from a private repository**

    We can use an existing Docker config secret to pull images from a private repo.

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
        name: private-reg
    spec:
        containers:
        - name: private-reg-container
          image: <our-private-image>
        imagePullSecrets:  # it specifies that Kubernetes should get the credentials from a Secret named secret-demo-dockercfg
        - name: secret-demo-dockercfg
    ```
