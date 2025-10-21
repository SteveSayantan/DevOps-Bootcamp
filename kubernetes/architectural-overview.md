### Terminologies
1. Cluster: It is the collection of a master node aka control plane and multiple worker nodes. A node is basically a server or a VM. 
   > We can also run K8s in a single node where it acts both as a control plane and a worker node.

1. KubeCTL: Users interact with Kubernetes via KubeCTL. It communicates with the control plane. Users can communicate with KubeCTL in one of the two ways:
   - Declarative: By writing a YAML file. The file will be given to the control plane by KubeCTL.
   - Imperative: Only writing commands in the terminal.

### Cluster Architecture
![Cluster Architecture](https://kubernetes.io/images/docs/kubernetes-cluster-architecture.svg)

### Control Plane Components

- **Control Plane**: It is also known as Master node. It manages the worker nodes in the cluster. It consists of various components:

- **API Server**: It takes care of all the communications in favour of the K8s cluster. We send YAML config files (aka K8s Manifest files) via HTTPS POST request to the endpoint created by it. 
   
  When a request arrives:
   - It is authenticated with the headers passed
   - Authorized using Role Based Access Control (RBAC)
   - Admission Control (security and validation mechanism) intercepts requests and validates based on policies. Two types of Admission Controllers are Mutating Admission Controller and Validating Admission Controller.
   - If the request passes all checks, it is stored in ETCD.
   
- **ETCD**: ETCD is the single source of truth for Kubernetes. It acts as a key-value database that stores info about the state, configuration of the cluster. API server reads/writes to it.

- **Scheduler**: Scheduler is always connected to the API server. It decides which node should run a newly created Pod. It does not create Pods but assigns them to nodes based on resource availability, constraints, and policies. If the request involves creating a new Pod, Scheduler determines:

   - Which Worker Node has enough CPU/memory.
   - If there are node-specific constraints (Node Affinity, Taints & Tolerations).
   - If there are Pod priorities etc.

   The Scheduler updates ETCD with the chosen Worker Node. If no node is available the pod stays in a Pending state until the administrator adds more nodes or frees up resources. 

- **Controllers and Controller Manager**: Controllers are control loops that watch the state of your cluster through the API server, then make or request changes where needed. Each controller tries to move the current cluster state closer to the desired state. K8s has multiple built-in controllers for different purposes e.g., Replicaset controller, Deployment controller, Job controller etc.

   Controller manager is a component in the control plane that embeds/runs the core control loops shipped with Kubernetes. The Controller Manager ensures controllers are running and managing state properly by continuously interacting with the API Server.

- **Cloud Controller Manager**: K8s can be run on any cloud platform. Now, if user requests to create a load balancer or a storage, K8s must understand the underlying cloud provider. K8s translates the user request to API request that the cloud understands using Cloud Control Manager. The cloud controller manager lets you link your cluster into your cloud provider's API, and separates out the components that interact with that cloud platform from components that only interact with your cluster.

   The cloud-controller-manager only runs controllers that are specific to your cloud provider. If you are running Kubernetes on your own premises, or in a learning environment inside your own PC, the cluster does not have a cloud controller manager.

   CCM is opensource and different cloud providers can add support for their cloud platform.

### Data Plane Components
- **Kubelet**: It is present on every worker node. It listens to the API server. Kubelet invokes the CRI which pulls the image, creates the container and starts the container. CRI also invokes CNI. It maintains the pods and makes sure all pods are running. If it fails to allocate resources or pods stop, it reports back to control plane.

- **Kube-proxy**: Kube-proxy maintains network rules on nodes. These network rules allow network communication to your pods from network sessions inside or outside of your cluster. It deals with iptables every time a pod is created.

- **Pod**: It is the smallest scheduling unit in K8s. A pod can contain single or multiple containers. We can't schedule a container without a pod. Containers inside a pod can enjoy shared network (i.e. they can talk to each other using localhost), shared storage. K8s allocates a cluster IP address to the pod, we can access the containerized application running inside it using this IP address. It acts as a wrapper for containers, that defines everything (container image, port, volumes, network etc.) in a YAML config file. This YAML file works as a running specification of the docker containers inside it.

### Objects in Kubernetes
Kubernetes objects are persistent entities in the Kubernetes system. Kubernetes uses these entities to represent the state of our cluster.

Examples include: Pods, Deployments,Namespaces etc.

- **Namespaces** in K8s: A Namespace in Kubernetes is a virtual cluster or logical partition within a physical cluster. It allows us to group and isolate resources (Pods, Services, Deployments, etc.) within the same cluster.

  Kubernetes Namespaces help in organizing, isolating, and controlling access to resources in large clusters. Each Namespace isolates its resources from others. A Namespace is NOT a separate Kubernetes cluster.

  **Use Cases:**

  | Use Case                   | Description                                                         |
  | -------------------------- | ------------------------------------------------------------------- |
  | **Environment separation** | Have separate Namespaces for `dev`, `test`, `staging`, `production` |
  | **Multi-team isolation**   | Team A and Team B can deploy similarly named apps without conflict  |
  | **Access control (RBAC)**  | Limit who can see or modify resources in a given Namespace          |
  | **Resource quotas**        | Prevent one team from consuming too many cluster resources          |

  **Predefined Namespaces in K8s:**

  - `default`: The default namespace for objects **with no other namespace specified**. Used for our general workloads _unless explicitly changed_.

  - `kube-system`: It contains **Kubernetes system components**, such as `kube-dns`, `kube-proxy`, `controller-manager`, `scheduler`, etc.

  - `kube-public`: It contains public resources that **should be readable by all users**, including unauthenticated ones. Rarely used directly.
  
  - `kube-node-lease`: Used for **node heartbeat leases** (to improve node health check performance). Helps the control plane track node liveliness more efficiently.
   

   ✅ Namespaced Resources:

   * Pods
   * Deployments
   * Services
   * ConfigMaps
   * Secrets
   * Ingresses

   ❌ Cluster-wide (non-namespaced) Resources:

   * Nodes
   * PersistentVolumes (PVs)
   * Namespaces themselves
   * ClusterRoles / ClusterRoleBindings
   * StorageClasses
   * CustomResourceDefinitions (CRDs)


### Example: Pod

We can create a Pod in one of the following ways:

- **Imperative command**: `kubectl run nginx --image=nginx --port 80`

   This created a **Pod** running an Nginx container, which by default listens on **port 80**. The `--port` flag in `kubectl run` is **only metadata**, useful for creating Services or documentation. It **does not affect** whether the container listens or accepts connections.

- **Imperative object configuration**: `kubectl apply -f pod.yaml`

  ```yaml
  # pod.yaml
  apiVersion: v1
  kind: Pod
  metadata:
   name: nginx
  spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:  # this is optional, only for metadata. Not specifying a port here DOES NOT prevent that port from being exposed.
        - containerPort: 80
  ```
Since, every container in a Pod shares the network namespace of the Pod, including the IP address and network ports, we can directly execute `curl <POD's_IP>` inside the cluster and successfully receive the **Nginx welcome page**.

In a Pod spec:
- `command` in YAML → overrides ENTRYPOINT.
- `args` in YAML → overrides CMD.

## Important Insights
1. Containers are nothing but linux processes. They use linux **Namespaces** to isolate and run themselves.

1. Namespaces in Linux deals with controlling visibility of resources and access control. Namespaces can make it appear to a process that it has an isolated copy of a given resource.

   To get the list of namespaces for a particular process,
   ```bash
   lsns -p process_id
   ```

1. Cgroups or Control groups are linux mechanism for tracking, grouping and organizing the processes. Every process is tracked with cgroup. Cgroup associates processes with resources. Using it, we can track how much a group of processes are using a particular resource. Cgroup can be used to limit and prioritize what resources are available to group of processes.

   In case of containers, cgroups are responsible for monitoring and metering our resources to make sure we never over-burdern our system with containers. Basically, it helps limit and control the amount of resources we're giving to each container.