## Intro to K8s API Server

- The API Server exposes multiple endpoints which can be accessed through REST API calls.

- YAML manifests are converted into JSON before sending those to the API server.
Here's the [API Docs](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.34/)

- GVK: Stands for Group Version Kind. GVK uniquely identifies the type of a Kubernetes object. It is commonly used in YAML definitions of resources.
  - **Group**: The API group categorizing the resource. Examples include **apps** (for Deployments, StatefulSets)and **core** (for Pods, Services - which is often omitted for core resources).
  - **Version**: The API version within a specific group. Examples include **v1**, **v1beta1**, **v1alpha1**. This allows for API evolution.
  - **Kind**: The specific type of resource within that API group and version. Examples include Pod, Deployment, Service, ConfigMap.

  A `Deployment` resource in a YAML file would specify its GVK as:
  ```yaml
  apiVersion: apps/v1
  kind: Deployment
  ```
  Here, `apps` is the Group, `v1` is the Version, and `Deployment` is the Kind.

- GVR: Stands for Group Version Resource. GVR uniquely identifies the endpoint for interacting with a specific type of Kubernetes resource through the API. It's used internally by the Kubernetes API server and clients to construct API requests.
  - **Group**: Same as in GVK, the API group the resource belongs to.
  - **Version**: Same as in GVK, the API version within that group.
  - **Resource**: The plural, lowercase name of the resource as it appears in the API endpoint URL. Examples include `pods`, `deployments`, `services`.

  To interact with Pods via the API, the corresponding API endpoint would be `/api/v1/pods` (since, **Pod** is under the **core** group, the group name is omitted). For Deployments, the endpoint is `/apis/apps/v1/deployments`.

## Interacting With API Server

The way we interact with the API server depends entirely on *how our Kubernetes cluster is set up*.

### 🌐 Case 1 — In Killercoda (cloud-like or multi-node setup)

In Killercoda or other multi-node environments (e.g., a real K8s cluster, kind, or GKE), the control plane runs as a **standalone network-accessible process** listening on a *real network interface* — e.g.:

```
https://172.30.1.2:6443
```
That’s a **reachable, routable cluster-internal IP**. We can obtain the IP from the following command

```bash
kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}'
```

When we run `curl` to that IP from inside the cluster, it works fine.

### 💻 Case 2 — In Minikube (local development setup)

Minikube behaves differently because it’s running Kubernetes **inside a virtual machine** or **container environment** on your laptop.

Here’s what happens:

* The **API server actually runs inside the Minikube VM**, listening on port `6443` internally.

* However, our **host machine (your laptop)** can’t directly reach that internal VM IP.

* So Minikube **forwards** the API server port to our host’s loopback interface on a *random local port*, like `127.0.0.1:47232`.

That’s why our kubeconfig shows:

```yaml
server: https://127.0.0.1:47232
```

This means:

> “`kubectl` should connect to the API server via localhost:47232, which Minikube forwards into the cluster.”

So, in this case, if we run `curl` to that IP from inside the cluster, it won't work.

In such cases, we access the **API server from within the Kubernetes cluster** itself — i.e., the *in-cluster service endpoint*.
```
https://kubernetes.default.svc:443
```
That DNS name (`kubernetes.default.svc`) always resolves to the **ClusterIP Service** that points to the API server. This Service is created automatically by Kubernetes itself.

This works perfectly when we’re `curl`ing from a Pod **inside the cluster**.

---

However, when we’re accessing the cluster from outside (e.g., our local laptop), `kubernetes.default.svc` doesn’t resolve.

In those cases, we can use either of the following approaches:
- We must use the external endpoint from our kubeconfig (like https://127.0.0.1:47232 for Minikube, or the public control plane URL in cloud clusters).

- Use a proxy/tunnel
  ```bash
  kubectl proxy
  ```
  and then connect via http://127.0.0.1:8001 (e.g.)