## Storage Requirements

1. K8s doesn't give data persistance out of the box.

1. We need a storage that doesn't depend on pod lifecycle. A new pod will read the existing data from the storage.

1. Storage must be available on all nodes.

1. Storage needs to survive even if the cluster crashes.

1. PV's are not namespaced, they are available to the whole cluster.

## Local vs Remote Volume

Local Volume can't survive cluster crash. 

For DB, we must use remote volume type.

PVs are resources like CPU, RAM. So, it needs to be present in the cluster when the pod that depends on it is created. PV takes the actual storage from local disk, external nfs server or cloud storage. Kubernetes Admin is responsible for configuring the storage and create PV components from these storage backends.

PVC claims a volume with specified capacity and some additional characteristics. Whichever PV matches those criteria will be used.

Now, we need to specify the PVC name in the Pod, so that all the containers in it can access to the storage. Claims must be in the same namespace as the pod.

Pod requests the volume through PVC --> Claim tries to find a volume in the cluster --> Volume has the actual storage backend

Once the volume is available:
Volumes are mounted to the Pod --> Now, that volume can be mounted to the container/containers inside the Pod. A pod can use multiple volumes of different types simultaneously.


### ConfigMap and Secret

- Both of them are local volumes.
- Not created via PV and PVC.
- Managed by k8s.

### Storage Class
SC provisions PVs dynamically, when PVC claims it. The storage backend is specified using the `provisioner` attribute. Each storage-backend has its own **provisioner**. We need to configure parameters for storage we want to request for PV. It is an abstraction over the underlying storage provider and the parameters for that storage.

---

# K8s Volume

K8s volume is a way to store data. It can be considered as a directory with data. Any number of volumes can be attached to a pod. For any type of volume, data is persisted across **container** restarts.

Nowadays, storage providers (e.g. aws,longhorn etc.) provide their own storage driver that implement CSI (Container Storage Interface). We need to install them separately.

## Remote Storage
- It is actually  used in production. 
- It is present outside the k8s cluster. It is safe from Data loss and Disaster.
- It is managed by the cluster provider (EKS,GKE etc.), they have their own CSI driver.


## Ephemeral Storage
- It is a temporary storage. It's lifetime is linked to a specific Pod.
- When a pod ceases to exist, Kubernetes destroys ephemeral volumes.

### EmptyDir
- It is a temporary storage.

- When a Pod that uses **emptyDir** volume is assigned to a node, an **emptyDir** volume is created on the node. But it is deleted when the pod is removed/restarted.

- On the Node, the **emptyDir** is located at `/var/lib/kubelet/pods/pod_uid/volumes/kubernetes.io~empty-dir/`.

  We can get the **pod_uid** using `kubectl get pod pod_name -o yaml`

- Data persists till pod persist. It follows pod lifecycle.

- The storage is allocated from node ephemeral storage.

- Can be used to store cache, temp files, share space between cotainers.

Example:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: emptydir-pod
spec:
  containers:
    - name: busybox
      image: busybox
      command: ['sh', '-c', 'echo "Writing data to /data/emptydir-volume..."; echo "Hello from Kubesimplify" > /data/emptydir-volume/hello.txt; sleep 3600']
      volumeMounts:
        - name: temp-storage
          mountPath: /data/emptydir-volume
  volumes:
    - name: temp-storage

    # type of storage 
      emptyDir: {}      # this would use the node storage e.g. disk, SSD etc.
    
      # or,

      emptyDir: {
        medium: memory  # this would use the RAM instead of disk space on the node i.e. mounts a tmpfs (RAM-backed filesystem)
      }     
```


## Persistent Volume and Persistent Volume Claim

### Persistent Volume

- The lifecycles of PVs are independent of the pod lifecycle.

- PV is an abstaction over the actual storage e.g. S3 bucket, NFS server, disk etc.

### Persistent Volume Claim

A persistentVolumeClaim volume is used to mount a PersistentVolume into a Pod. PersistentVolumeClaims are a way for users to "claim" durable storage (such as an iSCSI volume) without knowing the details of the particular cloud environment.


A PV can be provisioned in the following ways:

  - Static Provisioning: PV is manually created by us. After that, we create a PVC.

  - Dynamic Provisioning: We need to install a storage class which will create the PV for us.
    e.g. Every cloud-managed K8s-cluster has its own storage classes and CSI drivers installed. When we create PVC, it will dynamically create PV.

    Example:

    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: mysql
    spec:
      ports:
      - port: 3306
        name: mysql
      clusterIP: None
      selector:
        app: mysql
    ---
    apiVersion: apps/v1
    kind: StatefulSet
    metadata:
      name: mysql
    spec:
      serviceName: mysql
      replicas: 2
      selector:
        matchLabels:
          app: mysql
      template:
        metadata:
          labels:
            app: mysql
        spec:
          containers:
          - name: mysql
            image: mysql:8.0
            ports:
            - containerPort: 3306
              name: mysql
            env:
            - name: MYSQL_ROOT_PASSWORD
              value: "password"
            volumeMounts:
            - name: mysql-persistent-storage
              mountPath: /var/lib/mysql
      volumeClaimTemplates:
      - metadata:
          name: mysql-persistent-storage
        spec:
          accessModes: [ "ReadWriteOnce" ]
          storageClassName: "local-path"    # assume this storage class is already installed on the cluster
          resources:
            requests:
              storage: 10Gi
    ```
    In the above example, the storage class creates
    - a PV.
    - After successful creation of a PV, the PVC ( specified as **volumeClaimTemplates** ) is bound to it.
    - The PVC is mounted to the pod.

    This entire process is repeated for every replica (here, twice).


### What is Reclaim Policy ?  

The reclaim policy for a PersistentVolume tells the cluster what to do with the volume after it has been released of its claim.

- Retain: The Retain reclaim policy allows for manual reclamation of the resource. When the PersistentVolumeClaim is deleted, the PersistentVolume still exists and the volume is considered "released". But it is not yet available for another claim because the previous claimant's data remains on the volume. An administrator can manually reclaim the volume with the following steps.
  - Delete the PersistentVolume. The associated storage asset in external infrastructure still exists after the PV is deleted.
  - Manually clean up the data on the associated storage asset accordingly.
  - Manually delete the associated storage asset.

- Recycle (**Deprecated**): The volume is scrubbed with a basic `rm -rf /volume/*` and made available again. Rarely used today. Most admins stick to Retain or Delete.

- Delete: Deletion removes both the PersistentVolume object from Kubernetes, as well as the associated storage asset in the external infrastructure. Volumes that were dynamically provisioned inherit the reclaim policy of their StorageClass, which defaults to Delete.

Check out [How to manual recover/reassign a PV](https://stackoverflow.com/a/64673820)

### What are Access Modes ?

A PersistentVolume can be mounted on a host in any way supported by the resource provider. Providers will have different capabilities and each PV's access modes are set to the specific modes supported by that particular volume. For example, NFS can support multiple read/write clients, but a specific NFS PV might be exported on the server as read-only.

A PVC will only bind to a PV that supports its requested accessModes and requested storage.

The access modes are:

- **ReadWriteOnce**

  The volume can be mounted as read-write by a single node. ReadWriteOnce access mode still can allow multiple pods to access (read from or write to) that volume when the pods are running on the same node. For single pod access, please see ReadWriteOncePod.

- **ReadOnlyMany**

  The volume can be mounted as read-only by many nodes.

- **ReadWriteMany**

  The volume can be mounted as read-write by many nodes.

- **ReadWriteOncePod**

  The volume can be mounted as read-write by a single Pod. Use ReadWriteOncePod access mode if you want to ensure that only one pod across the whole cluster can read that PVC or write to it.

### Types of Persistent Volume

#### hostPath
A hostPath volume mounts a file or directory from the host node's filesystem into your Pod. hostPath volume usage is not treated as ephemeral storage usage. We need to monitor the disk usage ourselves. It is a type of persistent volume.

Useful for:
- Accessing resources from the host.

> It is not affected by Pod restart.

Risks:
- If the Pod restarts on a different node, that host path may not exist or contain needed data.
- Containers gain access to node’s filesystem—can be risky if misused
- Kubernetes scheduler doesn’t ensure Pods and data stay together.

Check the different types of hostPath volume [here](https://kubernetes.io/docs/concepts/storage/volumes/#hostpath-volume-types)

> Suitable for single node testing only; WILL NOT WORK in a multi-node cluster because the data will not be synced across multiple nodes.

Example:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hostpath-pod
spec:
  containers:
    - name: busybox
      image: busybox
      command: ['sh', '-c', 'echo "Writing data to /data/hostpath-volume..."; echo "Hello from Kubesimplify" > /data/hostpath-volume/hello.txt; sleep 3600']
      volumeMounts:
        - name: host-storage
          mountPath: /data/hostpath-volume
  volumes:
    - name: host-storage
      hostPath:
        path: /tmp/hostpath
        type: DirectoryOrCreate   # If nothing exists at the given path, an empty directory will be created there
```

#### Local
A local volume represents a mounted local storage device such as a disk, partition or directory. It’s managed via PVs and PVCs and integrated with the scheduler and Kubernetes’ binding mechanisms. 

Local volumes can only be used as a statically created PersistentVolume. Dynamic provisioning is not supported.

It provides:

  * **Node-aware scheduling**: Kubernetes scheduler ensures the Pod using the Local PV is placed on the correct node that has that storage.

  * **Better abstraction for stateful workloads**: Can be used with `StatefulSet` to manage per-node storage gracefully.


**Ideal Use Cases** include:

  * Stateful apps requiring high I/O and low latency using local disk.
  * Applications needing guaranteed data-locality—local SSDs, NVMe, etc.

Check out the cons of **local** volume [here](https://kubernetes.io/blog/2018/04/13/local-persistent-volumes-beta/#disclaimer)

Read more about local volumes [here](https://kubernetes.io/blog/2018/04/13/local-persistent-volumes-beta/)

#### NFS

We can take a VM, install NFS on it. Then we can expose one of it's directory and use that in PVC.

An nfs volume allows an existing NFS (Network File System) share to be mounted into a Pod. Unlike emptyDir, which is erased when a Pod is removed, the contents of an nfs volume are preserved and the volume is merely unmounted. This means that an NFS volume can be pre-populated with data, and that data can be shared between pods. NFS can be mounted by multiple writers simultaneously.


### Important Points to Remember

- **Volume access modes do not enforce write protection once the storage has been mounted. Even if the access modes are specified as ReadWriteOnce, ReadOnlyMany, or ReadWriteMany, they don’t set any constraints on the volume.**

  ✔️ This means Kubernetes **does not police the read/write behavior** at runtime.
Instead, it delegates enforcement to the **underlying storage system**. The actual enforcement of read-only or single-writer constraints is the responsibility of the underlying storage system or CSI driver.

  👉 Example:

  * You create a PV with `ReadOnlyMany`.
  * PVC binds successfully.
  * A Pod mounts that PVC.
  * If the underlying storage (say, an NFS server) actually allows writes, the Pod **can still write to it** — Kubernetes doesn’t block it. Otherwise, the underlying storage system is responsible to throw runtime errors during the write operation. 

  So, `ROX` is really just a *contract* for matching, not a hard enforcement mechanism.
  

- **If the access modes are specified as ReadWriteOncePod, the volume is constrained and can be mounted on only a single Pod**

  ✔️ This is the **exception** — new in Kubernetes 1.22+.

  `ReadWriteOncePod` (RWO-Pod) means:

    * The volume can be attached to a **single Pod only**, across the entire cluster.
    * Kubernetes itself enforces this.
    * If another Pod tries to mount the same PVC → Kubernetes scheduler will block it.


## Storage Classes

A **StorageClass** represents a *“class”* of storage available for dynamic provisioning in your cluster. It is like a **profile** or **template** that describes how Kubernetes should provision storage resources. It abstracts away infrastructure-specific details so devs can declare just what they need, not how to get it.

Suppose we are running an **e-commerce application** on Kubernetes with multiple components:

* **Frontend** (React/Node.js) → no storage needed.
* **Database** (PostgreSQL) → needs reliable, durable storage.
* **Caching** (Redis) → needs fast SSD-based storage.
* **Logs** (Elasticsearch) → needs lots of disk space, not necessarily SSD.

Now, if we were to **manually provision PersistentVolumes (PVs)** for each use case, we would need to:

* Create AWS EBS volumes (or GCP Persistent Disks, or Civo volumes).
* Configure them with different performance/replication options.
* Manage lifecycle (create, attach, delete).

That’s too much manual work. 🚫


**✅ Solution with StorageClass**

We can define **multiple StorageClasses**, each representing a “class” of storage, e.g.

- StorageClass for Database (Postgres)
- StorageClass for Caching (Redis)
- StorageClass for Logs (Elasticsearch)

Now, developers can simply request storage by class (db-storage, cache-storage)  and Kubernetes generates a matching PV on-the-fly. The dev doesn’t care how it’s created. 

### Key Fields of a StorageClass

A StorageClass involves several critical fields:

| Field                      | Purpose|
| -------------------------- | ----------|
| `provisioner`          | Which volume plugin to use (e.g., AWS, GCE, NFS, CSI driver). Required.        |
| `parameters`           | Provider-specific settings (like volume type, IOPS).                           |
| `reclaimPolicy`        | What happens to storage when the PVC is deleted (`Delete` or `Retain`).        |
| `allowVolumeExpansion` | Whether PVCs can grow the volume size after creation.                          |
| `mountOptions`         | Mount flags like `nfsvers=4.1` or `discard`. These options are used when mounting a storage on Linux. Check out [this article](https://www.ibm.com/docs/en/aix/7.2.0?topic=m-mount-command).                                   |
| `volumeBindingMode`    | Controls when the PV is bound to PVC: `Immediate` or `WaitForFirstConsumer`. Read about it [here](https://kubernetes.io/docs/concepts/storage/storage-classes/#volume-binding-mode).  |
| `allowedTopologies`    | Restricts which zones or nodes the PV can be provisioned in. |


