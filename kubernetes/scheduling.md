## Label and Label Selector

- **Label**
  - A Label is a key-value pair in metadata section. It adds meaning to the k8s object.
  - Label is used to identify any item, e.g., we often keep spices in labelled jars.
  - In k8s, any resource (e.g. nodes, pods, deployments etc.)  can be labelled.
  - We can also attach the same label to mutiple resources.
  - `kubectl get pods --show-labels`: shows the labels for the pods.
  - `kubectl label pod foo live=demo`: adds **live=demo** lable to the **foo** pod.


- **Label Selector**
  - Used to select resources based on labels
  - Types:
    - equality-based:
   
      - **Service** uses label selector to specify set of pods:
        ```yaml
        selector:
          component: redis
        ```
      - `kubectl get pod -l app!=testing`: shows pods which does not contain the **app=testing** label.

      - [nodeSelector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector)

    - set-based: e.g. **in**, **notin**, **exists**
      - ```yaml
        selector:
            matchLabels:  # Every single {key,value} in the matchLabels map is equivalent to an element of matchExpressions, whose key field is "key", the operator is "In", and the values array contains only "value"
              component: redis
            matchExpressions:
              - {key: app, operator: In, values: [foo,bar]}
              - {key: env, operator: NotIn, values: [dev]}
        ```
      - `kubectl get pods -l 'app in (test,bootcamp)'`: shows pods containing any or both of the following labels **app=testing**, **app=bootcamp**.

  For more details checkout the official [docs](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)

## Namespace
  - Namespace is used to group resources.
  - Resources can communicate among themselves across namespace by default. However, it can be disabled through configuring network policy.
  - The resource quota, limit ranges are checked during the admission phase.
  - `kubectl config set-context --current --namespace=dev`: sets the current context to **dev** namespace.
  - **kube-node-lease** namespace is responsible for checking the periodic heartbeat of the nodes. It contains **lease** objects. It improves failure detection.

## 🚪 What are Scheduling Gates?

Normally, when we create a Pod:

1. API server accepts it.
2. Scheduler immediately picks it up and tries to assign it to a Node (considering requests, limits, affinity, taints, etc.).

➡️ With **Scheduling Gates**, you can **pause that process**. Pods with a scheduling gate **will not be scheduled** until the gate is removed

### 🛠 Example

Here’s a Pod with a scheduling gate:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gated-pod
spec:
  schedulingGates:
  - name: "example.com/hold"
  containers:
  - name: pause
    image: k8s.gcr.io/pause:3.9
```

* When we create this Pod, the scheduler **ignores it** because of the `schedulingGates`.
* Once some controller (could be our own custom operator) **removes the gate** by modifying the Pod, it becomes eligible for scheduling.

**Difference between Pending, Unschedulable, and Scheduling Gates**

- Pending: Status of a Pod after it’s created but before it runs on a node.  
  Possible reasons:
  - Waiting for the scheduler to assign a node
  - Waiting for an image pull etc.

- Unschedulable: A Pod condition set by the scheduler when it tried scheduling but failed.

- Scheduling Gated: It’s an intentional block placed on a Pod before the scheduler even tries. Until the gates are removed → Pod stays Pending but without any scheduling attempts.


## Pod Topology Spread Constraint
By default, Kubernetes scheduling doesn’t guarantee even Pod distribution.
We could end up with:

* 5 Pods all landing on the same Node or
* All Pods in a single zone

➡️ That’s risky — if that node or zone fails, our whole workload is gone.

> Pod Topology allows us to distribute our Pods evenly across Nodes, Zones, or any other topology domain.

Each constraint tells Kubernetes:

1. *What topology key* to consider (like zone, node, hostname etc.).
2. *How evenly* Pods should be spread.
3. *Which Pods* to compare with (via label selector).
4. *How strictly* to enforce the rule (hard or soft).

### Example
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deploy
spec:
  replicas: 6
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      topologySpreadConstraints:
      - maxSkew: 1
        topologyKey: topology.kubernetes.io/zone
        whenUnsatisfiable: DoNotSchedule
        labelSelector:
          matchLabels:
            app: web
      containers:
      - name: nginx
        image: nginx
```

- **topologyKey**: It is a key of node labels. Nodes that have a label with this key and identical values are considered to be in the same topology. We call each instance of a topology (in other words, a <key, value> pair) a domain.  

  If TopologyKey is "kubernetes.io/hostname", each Node is a domain of that topology. And, if TopologyKey is "topology.kubernetes.io/zone", each zone is a domain of that topology.

- **maxSkew**: describes the maximum degree to which Pods can be unevenly distributed. In other words, 

  > maxSkew = Pods number matched in current topology - min Pod matches in a Topology

- **whenUnsatisfiable**: indicates how to deal with a Pod if it doesn't satisfy the spread constraint:

  * `DoNotSchedule` → strict (Pod will stay Pending)
  * `ScheduleAnyway` → tells the scheduler to still schedule it while prioritizing nodes that minimize the skew.

- **labelSelector** is used to find matching Pods. Pods that match this label selector are counted to determine the number of Pods in their corresponding topology domain.

For more details, checkout [Toplogy Spread Constraint](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints), [Scheduling](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#scheduling), [Introducing PodTopologySpread Blog](https://kubernetes.io/blog/2020/05/introducing-podtopologyspread/)

## NodeAffinity
NodeAffinity is a **scheduling constraint** that controls **which Nodes our Pod can run on**, based on **labels attached to the Nodes**.

Each Node in Kubernetes has labels (key-value pairs). Also, we can attach labels manually. Kubernetes also populates a standard set of labels on all nodes in a cluster.

### 🛠️ NodeAffinity Types

There are **two kinds** of NodeAffinity:

1. **requiredDuringSchedulingIgnoredDuringExecution**

   * *Hard requirement*: Pod **must** run only on nodes that satisfy the rules.
   * If no node matches, the Pod stays unscheduled (Pending).

2. **preferredDuringSchedulingIgnoredDuringExecution**

   * *Soft preference*: Scheduler **tries** to place Pod on a matching node.
   * If no match is found, Pod still runs on any available node.

Check out this example for [scheduling a pod using required node affinity](https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes-using-node-affinity/#schedule-a-pod-using-required-node-affinity) and [scheduling a pod using preffered node affinity](https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes-using-node-affinity/#schedule-a-pod-using-preferred-node-affinity).

Here's an example that demonstrates [scheduling a pod using both required and preffered node affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity)

Read about [Node affinity Weight](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity-weight)

## Priority Class
Priority indicates the importance of a Pod relative to other Pods. If a Pod cannot be scheduled due to lack of resources (CPU, memory, etc.), the scheduler tries to preempt (evict) lower priority Pods to make scheduling of the pending Pod possible.

> Kubernetes already ships with two PriorityClasses: `system-cluster-critical` and `system-node-critical`. These are common classes and are used to ensure that critical components are always scheduled first.

A PriorityClass is a non-namespaced object that defines a mapping from a priority class name to the integer value of the priority. The higher the value, the higher the priority.

> The name of a PriorityClass cannot be prefixed with `system-`.

A PriorityClass object can have any 32-bit integer value smaller than or equal to 1 billion. This means that the range of values for a PriorityClass object is from `-2147483648` to `1000000000` **inclusive**. Larger numbers are reserved for built-in PriorityClasses that represent critical system Pods.

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000000
globalDefault: false # Optional field; indicates that the value of this PriorityClass should be used for Pods without a priorityClassName
description: "This priority class should be used for XYZ service pods only." # optional field
```
Only one PriorityClass with globalDefault set to true can exist in the system. If there is no PriorityClass with globalDefault set, the priority of Pods with no priorityClassName is zero.

After we have one or more PriorityClasses, we can create Pods that specify one of those PriorityClass names in their specifications.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  priorityClassName: high-priority
```
For details, check out the [docs](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/)

## Pod Overhead

## Taints and Tolerations
Taints, unlike **Node affinity**, allow a node to repel a set of pods.

Tolerations are applied to pods. Tolerations allow the scheduler to schedule pods with matching taints. Tolerations allow scheduling but don't guarantee scheduling.

Taints and tolerations work together to ensure that pods are not scheduled onto inappropriate nodes. One or more taints are applied to a node; this marks that the node should not accept any pods that do not tolerate the taints.

Here's how we apply taint on a node:
```bash
kubectl taint nodes node1 key1=value1:NoSchedule
```
The taint has key `key1`, value `value1`, and taint effect `NoSchedule`. This means that no pod will be able to schedule onto node1 unless it has a matching toleration.

**Types of Effect**  
- **NoSchedule**: No new Pods will be scheduled on the tainted node unless they have a matching toleration. Pods currently running on the node are not evicted.

- **PreferNoSchedule**: PreferNoSchedule is a "preference" or "soft" version of NoSchedule. The control plane will try to avoid placing a Pod that does not tolerate the taint on the node. However, the Pod will be placed on the node if it can't be scheduled onto any other node.

- **NoExecute**: This affects pods that are already running. Pods that do not tolerate the taint are evicted immediately.

Now we specify a toleration for a pod in the PodSpec. 

```yaml
tolerations:
- key: "key1"
  operator: "Equal"
  value: "value1"
  effect: "NoSchedule"
```
Since, this toleration "match" the taint created above, thus this pod would be able to schedule onto **node1**.

For further details, check the [docs](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/#concepts)

## Marking a Node as as Unschedulable
Marking a node as unschedulable prevents the scheduler from placing new pods onto that Node but does not affect existing Pods on the Node. This is useful as a preparatory step before a node reboot or other maintenance.

To mark a Node unschedulable, run:
```bash
kubectl cordon $NODENAME
```
## Miscellaneous

Read about [nodeName](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodename)

Read about kube-scheduler, filtering (based on Predicates e.g. required NodeAffinity, NodeSelector, taints-toleration etc.), scoring (based on Priorities e.g. preferred NodeAffinity, imageLocality etc.), binding [here](https://kubernetes.io/docs/concepts/scheduling-eviction/kube-scheduler/#kube-scheduler)

Read about Scheduler Performance Tuning [here](https://kubernetes.io/docs/concepts/scheduling-eviction/scheduler-perf-tuning/)

Read aboug Pod Overhead [here](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-overhead/)