## 🔰 What is a Kubernetes Service?

In Kubernetes, a Service is a method for exposing a network application that is running as one or more Pods in the cluster.

## 🚀 Why Do We Need Services?

In Kubernetes, applications are typically run using Deployments, which in turn create and manage Pods via ReplicaSets.

- A critical characteristic of these Pods is their ephemeral nature. Pods are designed to be short-lived; they can be created and destroyed dynamically to match the desired state of our cluster.

- This ephemerality is common in containerized environments. Even with Kubernetes' auto-healing capability, which ensures that if a Pod goes down, a new one is automatically spun up, a significant challenge arises: the IP address of the new Pod will likely be different from its predecessor. This means the set of Pods for a given application can change from one moment to the next, and we might not even know their individual names or current IP addresses.

- When a Pod restarts and gets a new IP, any connection attempting to reach the old IP would fail, making the application unreachable even though a new Pod might be perfectly healthy. This creates a situation where, from a user's perspective, the application appears "not reachable" or "not working," even though it is technically running in the cluster



✅ **Service solves both problems** by:

The Service API, part of Kubernetes, is an abstraction to help us expose groups of Pods over a network.

* Giving a **stable IP** and **DNS name** to a set of Pods. Instead of clients directly accessing individual Pod IPs, they interact with the Service's stable IP address or name

* Services handle the discovery of Pods dynamically. They achieve this using labels and selectors instead of tracking IP addresses. When Pods are created, they are assigned specific labels (e.g., app: payment). The Service is configured to watch for Pods with these specific labels. If a Pod's IP changes due to a restart, as long as the new Pod has the same label, the Service will automatically discover and include it in its load-balancing pool, ensuring continuous connectivity

* Offering **load balancing** across these Pods.

Service uses endpoints which are basically slices each containing 100 container IPs. The IP tables are updated everytime a pod is created/destroyed.

---


## 🧪 Basic Service Example

Let's say we have Pods with label `app: myapp`. We can create a Service like:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  selector:
    app: myapp
  ports:
    - port: 80
      targetPort: 8080
```

* `port: 80` → What clients use to access the service.
* `targetPort: 8080` → Where the actual Pods are listening.

---

## ⚙️ Modes of Services in Kubernetes

| Mode                      | Purpose                                                                          |
| ------------------------- | -------------------------------------------------------------------------------- |
| **ClusterIP** *(default)* | Accessible **only within the cluster**, on a cluster-internal IP.                |
| **NodePort**              | Exposes service on a **static port on each Node**.                               |
| **LoadBalancer**          | Provisions an **external IP** via a cloud provider.                              |


### ClusterIP

ClusterIP is used when:

- We want internal communication between different components (e.g., frontend → backend, backend → database).

- We don’t need to expose the application to the internet.


**YAML Example: ClusterIP Service**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  type: clusterIP   # we may omit this
  selector:
    app: myapp
  ports:
    - port: 80          # Port exposed by the service
      targetPort: 8080  # Pod's container port

```

#### 🔍 What Happens Behind the Scenes?

Let’s say we have 3 Pods labeled `app: myapp`, each running on port 8080.

When we apply the above Service:

* Kubernetes creates an internal **virtual IP (VIP)**.

* `kube-proxy` sets up rules to **load balance traffic** sent to this VIP across the matching Pods in any of the nodes.

* DNS entry `myapp-service.default.svc.cluster.local` is automatically created in the cluster-dns server.

* Other Pods can just `curl http:// myapp-service.default.svc.cluster.local` or `curl http://myapp-service:80` (from within the same namespace) and get routed to one of the Pods in any node.


### NodePort

A NodePort is a type of Kubernetes Service that exposes a Pod to external traffic by opening a static port on every node in the cluster and routing traffic from that port to any of the target Pods present in any of the nodes. Whenever we create this service, an entry is added to the iptable of each node. 

> NodePort should only be used for testing purpose.

**YAML Example: NodePort Service**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: NodePort
  selector:
    app.kubernetes.io/name: MyApp
  ports:
    - port: 80
      targetPort: 80
      # By default the Kubernetes control plane
      # will allocate a port from a range (default: 30000-32767) 
```

#### 🔍 What Happens Behind the Scenes?

- Kubernetes automatically allocates a port (in the range 30000–32767) on each Node.

- Maps the NodePort to a ClusterIP Service. Here, <u>the **80** port of the service</u> is mapped to port **31563** of the nodes.

  ```bash
  $ kubectl get service nginx
  
  NAME    TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
  my-service   NodePort   10.96.211.93   <none>   80:31563/TCP   12s
  ```

- We can now access our app using `<NodeIP>:<NodePort>` from outside the cluster.

- The ClusterIP Service forwards the traffic to one of the matching Pods. This Pod-level balancing is handled by **kube-proxy**.

  Suppose, the incoming request hits `node-1:NodePort`. Now the **kube-proxy** on **node-1** picks any one of the backend Pods from the matching Service — <u>even if it's on another node</u>. 
  
- Say, the request is forwarded from node-1 to the selected pod on node-3.

- The pod on node-3 processes the request and sends back the response.

This provides robustness and balance as all pods might not be present on every node.


However, K8s does not provide load balancing across nodes before the request hits Kubernetes.

- If our cluster has multiple nodes (_node-1_, _node-2_, _node-3_), NodePort opens the same port on all three nodes.

- But if we manually curl `node-1:31000` every time, then only _node-1_ will forward our request.

- There’s no automatic round-robin between the nodes themselves unless we use an external load balancer to spread requests across nodes.


### LoadBalancer

When we create a Service of type LoadBalancer, Kubernetes provisions an external load balancer (usually from the cloud provider like AWS, GCP, Azure) and maps it to our Service. The Cloud Control Manager plays a major role in the IP address provisioning.

This makes our application accessible from the internet, with:

- A public IP address (or DNS name)

- A cloud-managed, production-ready load balancer

- Automatic health checks and pod distribution behind the scenes

**YAML Example: LoadBalancer Service on AWS**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-web-service
spec:
  type: LoadBalancer
  selector:
    app: my-web
  ports:
    - port: 80
      targetPort: 8080
      # By default the Kubernetes control plane
      # will allocate a port from a range (default: 30000-32767) 
```
Kubernetes creates an AWS ELB. It assigns a public IP/DNS like `a1234567890abcdef.elb.amazonaws.com`

#### 🔍 What Happens Behind the Scenes?

Kubernetes:

- Creates a Service object.

- Internally uses a ClusterIP and a NodePort.

- Then talks to the cloud provider’s API (via the cloud controller manager) to provision a cloud Load Balancer.

- Once the external LB is ready:

  - Traffic from the cloud provider’s load balancer gets forwarded to the NodePort on one of the worker nodes. The cloud LB does external traffic balancing across nodes.

  - Then kube-proxy routes traffic to the healthy, matching Pods (in the same way as mentioned in the previous case).


#### Advantages of Cloud-Managed Load Balancer
| Feature                                | Advantage|
| -------------------------------------- | ---------------|
| **1. Fully Managed by Cloud Provider** | We don’t need to manually install, configure, or maintain the load balancer. The cloud handles everything — provisioning, monitoring, scaling, and fault recovery. |
| **2. Public Accessibility**            | It automatically provides a **public IP or DNS**, making our app globally accessible without extra steps.                                                          |
| **3. Built-in Load Distribution**      | Distributes traffic evenly across Kubernetes worker nodes and then to Pods — ensuring high availability and better performance.                                     |
| **4. Auto Scaling Integration**        | Works seamlessly with Kubernetes Horizontal Pod Autoscaler (HPA) — scaling traffic routing as our application scales.                                              |
| **5. Health Checks**                   | Automatically checks the health of backend nodes and **removes unhealthy nodes** from the routing pool. We don’t have to write these ourselves.                     |
| **6. HTTPS/SSL Termination**           | We can **offload TLS/SSL termination** to the cloud LB (like AWS ELB, GCP GLB), simplifying cert management and reducing Pod overhead.                             |
| **7. Logging & Monitoring**            | Native integration with cloud logging and monitoring tools (e.g., AWS CloudWatch, GCP Operations) for better visibility and debugging.                              |
| **8. DDoS Protection & Firewall**      | Some cloud LBs come with **built-in DDoS protection**, firewall rules, and rate limiting — essential for production-grade apps.                                     |
| **9. Ingress Controller Friendly**     | Can be used behind an **Ingress controller** (like NGINX or Traefik) to expose many services through **a single external IP**.                                      |

### External Name
- Used to communicate with service hosted outside the k8s cluster
- It uses only DNS names, no IP is used.
- Also used to communicate with service in other NS. It abstracts the IP details, Service name etc. of the Service we want to communicate with, only the DNS name is sufficient.

### Headless Service
It's clusterIP service with `clusterIP:None`. used with stateful set. It does not get a clusterIP.