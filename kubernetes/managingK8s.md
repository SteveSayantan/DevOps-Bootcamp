## Managing the Life Cycle of K8s
Managing the life cycle of K8s involves creation, upgradation, configuration and deletion of the kubernetes cluster in production. 

Platforms like minikube are local kubernetes cluster and can't be used in production. A devops engineer must know how to manage the life cycle of K8s cluster.

## 📌 Kubernetes Distributions: Different Flavors of Kubernetes
Kubernetes is an **open-source** container orchestration system, but different companies have created their own **distributions** that come with additional features, managed services, or lightweight versions.  

### 🔹 1️⃣ Upstream Kubernetes (Vanilla Kubernetes)
This is the **pure, unmodified** open-source Kubernetes project maintained by the **Cloud Native Computing Foundation (CNCF)**.  
✅ **Pros:** Full flexibility, no vendor lock-in. Free to use.  
❌ **Cons:** Requires manual installation, configuration, and maintenance.  

### 🔹 2️⃣ Cloud Provider Kubernetes Distributions (Managed Kubernetes)
These are Kubernetes versions **managed by cloud providers**, where the control plane is **handled by the provider**, and users only manage worker nodes and workloads.  

| **Cloud Provider** | **Kubernetes Distribution** | **Features** |
|--------------------|---------------------------|--------------|
| **AWS**           | Amazon **EKS** (Elastic Kubernetes Service) | Fully managed, integrated with AWS services. |
| **Google Cloud**  | Google **GKE** (Google Kubernetes Engine) | Auto-scaling, security, easy upgrades. |
| **Microsoft Azure** | Azure **AKS** (Azure Kubernetes Service) | Managed Kubernetes with Azure integration. |
| **IBM Cloud**     | IBM **IKS** (IBM Kubernetes Service) | Built-in monitoring, enterprise security. |
| **Oracle Cloud**  | Oracle **OKE** (Oracle Kubernetes Engine) | Optimized for Oracle workloads. |

✅ **Pros:** No need to manage the control plane, easy scaling, security.  
❌ **Cons:** Limited customizability, potential vendor lock-in.  

---

### 🔹 3️⃣ Enterprise & On-Premises Kubernetes Distributions
These are designed for **private data centers**, hybrid cloud setups, or enterprises needing **extra security, compliance, and support**.  

| **Enterprise Kubernetes Distro** | **Provider** | **Key Features** |
|----------------------------------|-------------|------------------|
| **Red Hat OpenShift** | Red Hat | Enterprise-grade security, CI/CD, developer-friendly. |
| **VMware Tanzu Kubernetes Grid** | VMware | Optimized for VMware environments. |
| **Rancher Kubernetes** | SUSE | Simplifies Kubernetes management for multi-cluster environments. |
| **Mirantis Kubernetes Engine (MKE)** | Mirantis | Enterprise Kubernetes with Docker Swarm integration. |
| **Anthos** | Google | Hybrid and multi-cloud Kubernetes management. |

✅ **Pros:** Enterprise support, security, integrated DevOps tools.  
❌ **Cons:** Requires licensing or enterprise agreements.  

---

### 🔹 4️⃣ Lightweight Kubernetes Distributions (Edge & IoT)
These are minimal Kubernetes versions designed for **small-scale environments**, edge computing, and IoT.  

| **Lightweight Kubernetes Distro** | **Best For** | **Key Features** |
|----------------------------------|-------------|------------------|
| **K3s** | Edge & IoT | Lightweight, single binary, runs on low-resource devices. |
| **MicroK8s** | Developers & Testing | Snap-based installation, low footprint. |
| **Minikube** | Local Development | Runs Kubernetes on a laptop/VM for testing. Offers a one-node cluster that works both as a control-plane and a worker node. |
| **Kind** | CI/CD Pipelines | Kubernetes in Docker for testing clusters. |

✅ **Pros:** Lightweight, fast, easy to deploy.  
❌ **Cons:** Not ideal for large-scale production workloads.


## Kubernetes Operations (kOps) - The Kubernetes Installer & Management Tool

### 🔹 What is kOps?
**Kubernetes Operations (kOps)** is an **open-source tool** that helps deploy, manage, and upgrade **highly available Kubernetes clusters** on **cloud providers and bare-metal environments**. It is often called the "**kubectl for clusters**" because it simplifies the entire lifecycle of a Kubernetes cluster.

### ✅ **Key Features of kOps**
✔ **Cluster Installation & Management** – Automates deployment and configuration.  
✔ **Multi-Node, Highly Available Clusters** – Supports production-grade setups.  
✔ **Automatic Cluster Scaling** – Easily scale worker nodes.  
✔ **Upgrades & Rolling Updates** – Safe, in-place updates for clusters.  
✔ **Infrastructure as Code (IaC) Support** – Uses YAML, Terraform, and AWS CloudFormation.  
✔ **Cloud-Native Storage & Networking** – Supports CNI plugins (Calico, Cilium, etc.).


### Kubernetes Installation Using KOPS on EC2

#### Create an EC2 instance or use your personal laptop.

Dependencies required 

1. Python3
2. AWS CLI
3. kubectl

####  Install dependencies

```
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
```

```
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
```

```
sudo apt-get update
sudo apt-get install -y python3-pip apt-transport-https kubectl
```

```
pip3 install awscli --upgrade
```

```
export PATH="$PATH:/home/ubuntu/.local/bin/"
```

#### Install KOPS (our hero for today)

```
curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64

chmod +x kops-linux-amd64

sudo mv kops-linux-amd64 /usr/local/bin/kops
```

#### Provide the below permissions to your IAM user. If you are using the admin user, the below permissions are available by default

1. AmazonEC2FullAccess
2. AmazonS3FullAccess
3. IAMFullAccess
4. AmazonVPCFullAccess

#### Set up AWS CLI configuration on your EC2 Instance or Laptop.

Run `aws configure`

#### Kubernetes Cluster Installation 

Please follow the steps carefully and read each command before executing.

#### Create S3 bucket for storing the KOPS objects.

```
aws s3api create-bucket --bucket kops-abhi-storage --region us-east-1
```

#### Create the cluster 

```
kops create cluster --name=demok8scluster.k8s.local --state=s3://kops-abhi-storage --zones=us-east-1a --node-count=1 --node-size=t2.micro --master-size=t2.micro  --master-volume-size=8 --node-volume-size=8
```

#### Important: Edit the configuration as there are multiple resources created which won't fall into the free tier.

```
kops edit cluster myfirstcluster.k8s.local
```

#### Build the cluster

```
kops update cluster demok8scluster.k8s.local --yes --state=s3://kops-abhi-storage
```

This will take a few minutes to create............

After a few mins, run the below command to verify the cluster installation.

```
kops validate cluster demok8scluster.k8s.local
```
