## ResourceQuota
When several users or teams share a cluster with a fixed number of nodes, there is a concern that one team could use more than its fair share of resources.

Resource quotas are a tool for administrators to address this concern.

A resource quota, defined by a ResourceQuota object, provides constraints that limit aggregate resource consumption <u>per namespace</u>. A ResourceQuota can also limit the quantity of objects that can be created in a namespace by API kind, as well as the total amount of infrastructure resources that may be consumed by API objects found in that namespace.

> Changes to quota does not affect already created resources

The resource quota is checked during admission phase.

### How ResourceQuota Works

1. **For CPU and Memory**

   * If a `ResourceQuota` includes **CPU** or **Memory** (in `requests.*` or `limits.*`), then **every Pod in that namespace must specify those values**. Otherwise, it would be **Rejected** by the API server. This is because **CPU/Memory** are considered *fundamental compute resources*. Kubernetes enforces them strictly when quotas are set.

2. **For Other Resources (like ephemeral-storage, PVCs, Services, etc.)**

   * If a `ResourceQuota` includes resources like `requests.ephemeral-storage` or `persistentvolumeclaims`, Kubernetes **does not enforce that every Pod must set them**.
   * Instead, quota is only checked **if the Pod actually specifies them**.
   * Pods *without those fields* are simply **ignored** in quota calculations. This is becaus resources like storage, PVCs, services, configmaps, etc. are *optional extras*. If a Pod doesn’t declare them, it just doesn’t count towards the quota.

### 🔹 Requests vs Limits in Kubernetes

Every **container** in a Pod can specify:

* **Resource Requests** → the *minimum* amount of CPU/Memory it is guaranteed to get.
* **Resource Limits** → the *maximum* amount of CPU/Memory it is allowed to use.

Kubernetes uses these values in two ways:

1. **Scheduling (Requests)**

   * When you create a Pod, the scheduler places it on a Node that has at least enough *requested* resources available.
   * Example: if our Pod requests `500m` CPU and `256Mi` memory, it won’t be scheduled onto a node that doesn’t have at least that much free.

2. **Runtime Enforcement (Limits)**

   * If the node where a Pod is running has enough of a resource available, it's possible (and allowed) for a container to use more resource than its request for that resource specifies.  
   * When we specify a resource limit for a container, the kubelet enforces those limits so that the running container is not allowed to use more of that resource than the limit we set.
   * If it tries to use more CPU → throttled.
   * If it tries to use more memory → killed (OutOfMemoryKilled).

> For a particular resource, a Pod resource request/limit is the sum of the resource requests/limits of that type for each container in the Pod.

### Example ResourceQuota

1. Limit CPU and Memory
   ```yaml
   apiVersion: v1
   kind: ResourceQuota
   metadata:
    name: compute-resources
    namespace: dev-team
   spec:
    hard: # the hard field specifies the hard limits (upper bounds) for resource usage in a namespace.

      # Total CPU requests across all Pods <= 0.2CPU
      requests.cpu: "200m" # equivalent to 0.2; 1.0 CPU = 1000m CPU i.e.  1 physical CPU core, or 1 virtual core
      requests.memory: 1Gi # Total Memory requests ≤ 1Gi

      limits.cpu: "4"  # Total CPU limits ≤ 4
      limits.memory: 2Gi # Total Memory limits ≤ 2Gi
   ```
    Now, in a Pod Spec we can specify as follows:
   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
    name: cpu-mem-demo
    namespace: dev-team
   spec:
    containers:
    - name: demo-container
      image: nginx
      resources:
       requests:
        cpu: "0.1"  # 0.1 CPU or 100m CPU core guaranteed
        memory: "128Mi" # 128Mi RAM guaranteed
      limits:
        cpu: "1"  # Can use at most 1 full CPU core
        memory: "256Mi" # Can use at most 256Mi RAM
   ```
   We can specify resource requests and limits at the Pod level also. Refer to [this](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#pod-level-resource-specification)

1. Limit Number of Pods and Secrets
   ```yaml
   apiVersion: v1
   kind: ResourceQuota
   metadata:
    name: compute-resources
    namespace: dev-team
   spec:
    hard:
      pods: "2" # Max 2 pods
      secrets: "1" # Max 1 secret
   ```

For further details, refer to the [docs](https://kubernetes.io/docs/concepts/policy/resource-quotas/). Also, read about Resource Management for Pods and Containers from [here](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)

#### Container-level requests/limits override Pod-level

When we create a pod with the following manifest:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-resources-demo
  namespace: pod-resources-example
spec:
  resources:
    limits:
      cpu: "1"
      memory: "25Mi"
    requests:
      cpu: "1"
      memory: "10Mi"
  containers:
  - name: pod-resources-demo-ctr-1
    image: nginx
    resources:
      limits:
        cpu: "0.85"
        memory: "60Mi"
      requests:
        cpu: "0.5"
        memory: "30Mi"
```
The resultant pod will have the specs as below:

```
  Limits:
    cpu:     850m
    memory:  60Mi
  Requests:
    cpu:     500m
    memory:  30Mi
```

So, we can conclude that **Container-level requests/limits override Pod-level**.

## LimitRanges
Within a namespace, a Pod can consume as much CPU and memory as is allowed by the ResourceQuotas that apply to that namespace. As a cluster operator, or as a namespace-level administrator, we might also be concerned about making sure that a single object cannot monopolize all available resources within a namespace.

A LimitRange is a policy to constrain the resource allocations (limits and requests) that you can specify for each applicable object kind (Container or Pod or PersistentVolumeClaim) in a namespace.

### 🔹 Anatomy of a LimitRange

A LimitRange can control three things:

- Default values (applied if not specified in Pod spec).

- Minimum values (must request at least this much).

- Maximum values (can’t request more than this).

### Examples

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: cpu-resource-constraint
spec:
  limits:
  - default: # this section defines default limits
      cpu: 500m
    defaultRequest: # this section defines default requests
      cpu: 500m

    # max and min define the limit range
    max:    # the minimum amount of a resource that must be requested or limited
      cpu: "1"
    min:    # the maximum amount of a resource allowed to request or limit
      cpu: 100m
    type: Container 
```
We can also define **LimitRange** for `type:Pod` and `type:PersistentVolumeClaim`. Refer to the [examples](https://kubernetes.io/docs/concepts/policy/limit-range/#what-s-next)