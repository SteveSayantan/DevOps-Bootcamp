# MySQL in Kubernetes

## Steps to Deploy

- First install the Custom Resource Definition (CRD) used by MySQL Operator for Kubernetes:
  ```
  kubectl apply -f https://raw.githubusercontent.com/mysql/mysql-operator/trunk/deploy/deploy-crds.yaml
  ```

- Next deploy MySQL Operator for Kubernetes, which also includes RBAC definitions
  ```
  kubectl apply -f https://raw.githubusercontent.com/mysql/mysql-operator/trunk/deploy/deploy-operator.yaml
  ```

- Create a namespace to hold InnoDB resources.
  ```
  kubectl create ns inno-cluster
  ```

- To create an InnoDB Cluster with kubectl, first create a secret containing credentials for a new MySQL root user in the newly created namespace:

  ```
  kubectl create secret generic mypwds --from-literal=rootUser=root --from-literal=rootHost=% --from-literal=rootPassword="password" -n inno-cluster 
  ```
  `%` means allow connections from anywhere.

- Use that newly created secret to configure a new MySQL InnoDB Cluster. Refer to [this](./my-inno-cluster.yaml) file for the manifest.


  Install using
  ```
  kubectl apply -f my-inno-cluster.yaml
  ```
## Scaling Up/Down

- To scale up/down the server instances, we either modify the **instances** field in `my-inno-cluster.yaml` and apply it. Or, we can use the following command:
  ```
  kubectl patch innodbcluster mycluster -n inno-cluster --type merge -p '{"spec":{"instances":3}}'
  ```

## Connection
We shall connect using the ports exposed by the Service created by our InnoDBCluster resource. This Service sends incoming connections to the MySQL Router.

1. Run the following to create a new pod :
   ```
   kubectl run --rm -it myshell --image=container-registry.oracle.com/mysql/community-operator:9.6.0-2.2.7 -- mysqlsh
   ```

1. Now connect to the InnoDB Cluster from within MySQL Shell's interface:
   ```
   MySQL JS>  \connect root@mycluster
   ```
   Here, `mycluster` is the name of the Service. The `root@mycluster` shorthand works as it assumes port 3306 (supports read/write) and the same namespace as the Pod. Use `root@mycluster:6447` to connect to **read-only** mode.

   If the Pod is in a different namespace than the Service, we need to use FQDN of the Service i.e.`mycluster.{namespace}.svc.cluster.local`, e.g.,
   ```
   MySQL JS>  \connect root@mycluster.inno-cluster.svc.cluster.local:6447
   ```

For more details, check out [docs](https://dev.mysql.com/doc/mysql-operator/en/mysql-operator-connecting.html).

Also, we can use `minikube service` command to expose the Service to any program running on the host operating system. Refer to the [minikube docs](https://minikube.sigs.k8s.io/docs/handbook/accessing/) for details.

## Cleanup

While cleaning up, make sure to remove the **PVC**s and **PV**s created by the **InnoDBCluster**. Here, as we are using the **local-path** storage class that comes with a reclaim policy of **Delete**, we can simply delete the PVCs to delete the PVs.


## References:
- [MySQL Operator Docs](https://dev.mysql.com/doc/mysql-operator/en/mysql-operator-introduction.html)

---

# Fundamentals

## What Is MySQL Group Replication?

**Group Replication** is the distributed consensus and replication engine inside MySQL that powers **InnoDB Cluster**.

It is:

* Multi-member
* Fault-tolerant
* Based on majority voting
* Built on a Paxos-like consensus protocol

Each MySQL instance is a **group member**. Together they form a replication group.

When we deploy:

```yaml
spec:
  instances: 3
```

We are creating a distributed system, not “3 copies of MySQL.”

This entirely lives inside the MySQL process.

It handles:

- Synchronous replication

- Majority quorum

- Primary election

- Transaction certification

- Split-brain prevention

It ensures:

Data consistency and distributed agreement inside MySQL. It does not handle Kubernetes objects e.g. PV, StatefulSets etc.


### How Replication Actually Works

When a client writes:

```sql
INSERT INTO orders ...
```

Here’s what happens internally:

1. Write happens on the PRIMARY.
2. Transaction is sent to all replicas.
3. Replicas validate the transaction.
4. A majority must acknowledge/agree.
5. Only then is the transaction committed. Otherwise, the transaction is rolled back everywhere.

This is **synchronous replication**, not async.

Meaning:

* No replica lag.
* No “eventual consistency.”
* No silent divergence.
* No split-brain.

It either commits everywhere (majority) or nowhere.

If one member dies → election happens internally.
If quorum lost → writes stop.

It does not create processes.
It governs database behavior.

## What Is Quorum?

**Quorum = Majority of members required to make decisions.**

Formula:

```
quorum = floor(N/2) + 1
```

Where:

* N = number of members


#### Example 1: 3 Members

```
floor(3/2) + 1 = 2
```

We need at least 2 nodes alive.

If 1 dies:

* 2 remain
* Quorum preserved
* System continues

If 2 die:

* 1 remains
* No majority
* Writes stop

The cluster protects data consistency by refusing to operate.


#### Example 2: 2 Members

```
floor(2/2) + 1 = 2
```

Need both alive.

If 1 dies:

* 1 remains
* 1 < 2
* No quorum
* Cluster stops writes

This is why 2-node clusters are logically useless for HA.


### Why Quorum Exists

To prevent **split-brain**.

Split-brain is when two partitions both think they are primary and accept writes independently.

That leads to:

* Data corruption
* Irreconcilable divergence
* Career-altering outages

Quorum prevents that by requiring majority agreement before committing anything.

No majority → no writes.

It prefers downtime over corruption.

### Election of Primary

In single-primary mode (default):

* One member is PRIMARY.
* Others are SECONDARY.

If primary crashes:

1. Remaining members detect failure.
2. Majority votes.
3. New primary elected automatically.

All this happens inside Group Replication.

The Operator just watches and ensures topology remains correct.


### Failure Scenarios

#### Node crash (1 of 3)

* Cluster continues.
* Primary may change.
* Router reroutes traffic.

#### Network partition (1 isolated)

* Isolated node can't talk to the other two. Loses quorum (as 1 < quorum (2) )
* It stops accepting writes.
* Majority side continues.

Again: consistency > availability.


### Why This Matters in Kubernetes

Kubernetes restarts pods.
Nodes disappear.
Network glitches happen.

Group Replication ensures:

* No split-brain during node failure.
* Safe primary re-election.
* Data consistency preserved.

Without quorum logic, HA in Kubernetes would be cosmetic.

---
## MySQL Operator

The **MySQL Operator** is a Kubernetes controller.

It manages:

* StatefulSets
* Pod lifecycle
* PVC creation
* Router deployment
* Backups via `MySQLBackup`
* Scaling up/down
* Rolling upgrades
* Re-joining failed members
* Cluster bootstrap
* TLS config

It ensures:

> The desired cluster topology exists and remains healthy in Kubernetes.


The Operator keeps the *deployment* consistent.


### What Happens If We Don’t Use the Operator?

We would need to:

1. Create StatefulSet manually.
2. Bootstrap first MySQL instance.
3. Initialize InnoDB Cluster using MySQL Shell.
4. Add members one by one.
5. Configure Router manually.
6. Handle pod restart reconciliation.
7. Detect crash loops.
8. Re-add failed members.
9. Handle certificate distribution.
10. Automate backups.

Every time a pod restarts, we’d need logic to:

* Detect if it's safe to rejoin
* Determine cluster state
* Reconfigure replication if needed

That is not trivial.


### Example: Node Failure Scenario

Let’s say:

* MySQL pod on node-2 dies.
* Kubernetes reschedules it on node-3.

Group Replication alone cannot:

* Create new PVC
* Ensure correct server_id
* Automatically rejoin cluster safely
* Patch Router metadata

The Operator:

* Detects missing member
* Recreates pod
* Ensures correct configuration
* Waits for cluster state
* Rejoins it safely using MySQL Shell logic

It closes the automation gap.

### Scaling Scenario

We change:

```yaml
spec:
  instances: 5
```

Apply.

Operator:

* Adds 2 new MySQL pods
* Bootstraps them correctly
* Joins them to cluster
* Updates Router topology

Group Replication doesn’t magically provision infrastructure.


### Upgrade Scenario

You update MySQL version.

Operator:

* Drains
* Rolls pods one by one
* Maintains quorum
* Avoids downtime

Without operator, that’s a manual orchestration dance with serious risk.


Basically the Operator performs **Kubernetes-level automation and lifecycle management**. The Operator contains the orchestration logic to glue MySQL Shell + Group Replication + Kubernetes together.

## Number of MySQL Instances

### Case 1: `instances: 1`

If we define:

```yaml
spec:
  instances: 1
```

#### What happens?

* No quorum logic involved.
* No majority voting.
* No fault tolerance.
* No automatic failover.

We effectively get:

* A single MySQL instance
* Managed by the Operator
* Router still works
* Backups still work
* Rolling upgrades still work

But this is **not** an HA cluster.

#### Failure Scenario

If that pod dies:

* Database is down.
* No replica exists.
* No election possible.

This is acceptable for:

* Dev environments
* CI
* Testing
* Low critical workloads

It is not acceptable for production HA.


### Case 2: `instances: 2`

This is where people make expensive mistakes.

If we define:

```yaml
spec:
  instances: 2
```

Group Replication requires **majority quorum**:

```
Majority = floor(N/2) + 1
```

For 2 nodes:

```
floor(2/2) + 1 = 2
```

So quorum = 2.

Meaning:

* If either node fails → only 1 remains.
* 1 < 2 → no quorum.
* Cluster goes read-only or stops accepting writes.

You have zero fault tolerance.

Two nodes look redundant. But they are not.

They are a trap.


### Case 3: `instances: 3` (Correct HA)

For 3 nodes:

```
floor(3/2) + 1 = 2
```

Quorum = 2.

If 1 node dies:

* 2 remain
* 2 ≥ quorum
* Cluster continues operating
* New primary elected automatically

This is the minimum safe HA configuration.


### Why Oracle Recommends Odd Numbers

Because:

* Quorum voting requires strict majority.
* Even numbers create deadlock risk.
* Odd numbers avoid split-brain.

Valid production sizes:

* 3 (minimum HA)
* 5 (higher resilience)
* 7 (rare unless very large scale)

### Deeper Distributed Systems Reality

Even-numbered clusters are usually pointless.

E.g., with 4 members:

```
quorum = 3
```

We can still only lose 1 node safely.

Same fault tolerance as 3 members.

But with:

* More network chatter
* More storage
* More complexity

So scaling to 4 on 3 nodes is architecturally inefficient (because even member count)

### Why having multiple MySQL instances on a Single Node is not Recommended

If we schedule more than one MySQL instances on a single node, it reduces fault tolerance. If that node dies, we lose all MySQL instances running on that node at once.
