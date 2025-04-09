## Preface

### Immutable Infrastructure
Immutable infrastructure is a modern approach where infrastructure components (servers, VMs, containers, etc.) are never modified once they are deployed. 
Instead of updating or patching existing instances, new instances with the desired state are created, and the old ones are discarded. Check out this [article](https://www.digitalocean.com/community/tutorials/what-is-immutable-infrastructure)

### Monolith Architecture
A monolithic architecture is a single-tier application where all components—UI, business logic, and database operations—are tightly integrated into one large codebase.
Monolythic applications are faster than any microservice architecture.

A typical monolithic app consists of:
1. Presentation Layer (UI) → Frontend (HTML, CSS, JS, React, etc.)
1. Business Logic Layer → Backend logic (Node.js, Java, Python, etc.)
1. Data Layer → Database operations (MySQL, PostgreSQL, etc.)

📌 *All these layers are tightly coupled in a single codebase and deployed as one unit.*

**Advantages:**  
✅ Simple Development & Deployment → Easy to build, run, and test locally.  
✅ Performance Benefits → No network latency between services (since everything runs in one process).

**Disadvantages:**  
❌ Scalability Challenges → Scaling requires deploying the entire app, even if only one part needs more resources.  
❌ Slow Deployment & Updates → A small change requires redeploying the whole system.  
❌ Tight Coupling & Low Flexibility → Changes in one module can affect the entire application.

### Microservices Architecture
Microservices architecture is a software design approach where an application is broken into small, independent services, each handling a specific business function. 
These services communicate via APIs and can be deployed, scaled, and updated independently.

A typical e-commerce microservices system may have:  
🔹 User Service → Manages user authentication & profiles  
🔹 Product Service → Handles product catalog  
🔹 Order Service → Manages orders etc.

**Advantages:**  
✅ Independently Deployable → Each service is developed, deployed, and scaled separately.  
✅ Business-Oriented → Each microservice represents a specific business function (e.g., Authentication, Orders, Payments).  
✅ Polyglot Development → Each microservice can use different programming languages, databases, and frameworks.  
✅ Scalability → Each service scales independently.  
✅ Faster Development → Teams work on separate microservices in parallel.  
✅ Resilience → One failing service doesn't crash the entire system.

**Disadvantages:**  
❌ Increased Complexity → More services to manage  
❌ Latency in Communication → REST APIs add delay

### Orchestrators
When number of microservices increase, it gets difficult to manage those. An orchestrator is a tool or system that 
automates and manages the deployment, scaling, networking, and lifecycle of applications in a distributed environment.

An orchestrator handles:  
✅ Automated Deployment → Deploying, managing applications.  
✅ Scaling → Adding or removing instances based on demand.  
✅ Load Balancing → Distributing traffic across instances.  
✅ Self-Healing → Restarting failed services automatically.  
✅ Networking → Enabling communication between services.  
✅ Resource Optimization → Efficiently using CPU, memory, and storage.

🔹 Kubernetes is the most widely used orchestrator today for managing cloud-native applications.

### Cloud Native Application
A cloud-native application is designed to run efficiently in cloud environments by leveraging containers, microservices, Kubernetes, DevOps, and automation.

**Key Characteristics of Cloud-Native Applications:**  
✅ Microservices-Based → Built as small, independent services instead of a monolithic architecture.  
✅ Containerized → Each service runs in a lightweight container (Docker, Podman).  
✅ Dynamically Orchestrated → Kubernetes automatically manages deployment, scaling, and recovery.  
✅ API-Driven → Services communicate via REST, gRPC, or event-driven messaging.  
✅ Scalable & Resilient → Can handle traffic spikes and failures without downtime.  
✅ DevOps & CI/CD → Uses continuous integration and deployment for rapid updates.  
✅ Immutable Infrastructure → New versions replace old ones without modifying running instances.

## Introduction to Kubernetes
- Kubernetes is a Cloud Native Computing Foundation (CNCF) graduated project. It is the first graduated project of CNCF.
- As per the **official definition**, it is an open source container orchestration engine for automating deployment, scaling, and management of containerized applications.
- **K8s** as an abbreviation results from counting the eight letters between the "K" and the "s".
- K8s is declarative in nature i.e. we just tell it to do some stuff and it takes care of the rest by itself.

### Beyond Orchestration
Apart from the features of an orchestrator, it also provide several other features:

Kubernetes is a **container platform, an ecosystem, and a framework** for **building, deploying, scaling, and managing applications efficiently.**

#### 1️⃣ Kubernetes as an Infrastructure Abstraction Layer
💡 **Kubernetes allows applications to run anywhere without caring about the underlying infrastructure.**  

✅ **Runs on Any Environment:**  
- 🏢 **On-Premises** → Bare metal, VMs  
- ☁️ **Public Cloud** → AWS, GCP, Azure  
- ☁️ **Hybrid & Multi-Cloud** → Combines cloud & on-prem  

✅ **Decouples Applications from Infrastructure:**  
- Developers don’t need to worry about servers.  
- Kubernetes dynamically schedules workloads where resources are available.  

---

#### 2️⃣ Kubernetes as a Self-Healing System

✅ **Basic Orchestration (Self-Healing as an Orchestrator)**  
As an orchestrator, Kubernetes ensures that applications **stay in their desired state** by:  
- Restarting failed containers.  
- Rescheduling workloads if a node crashes.  
- Replacing unhealthy pods based on liveness and readiness probes.  

💡 **These are fundamental orchestration tasks—keeping workloads running and healthy.**  

🚀 **Beyond Orchestration: Self-Healing as an Intelligent System**  

Kubernetes takes self-healing **beyond traditional orchestration** by:  

1. **Declarative Desired State Management**  
   - Uses **control loops** to constantly check if the system matches the desired state.  
   - Example: If a deployment specifies 5 replicas and 2 crash, Kubernetes will **automatically** bring them back.  
   
2. **Automated Rollbacks**  
   - If a deployment update causes failures, Kubernetes **automatically rolls back** to the last stable version.  
   - Traditional orchestrators do not handle rollbacks intelligently.  

3. **Pod Disruption Budgets (PDBs) & Auto-Rescheduling**  
   - Prevents too many pods from going down at once.  
   - Reschedules workloads in case of **node failures** dynamically.  

4. **Cluster-Level Self-Healing**  
   - Kubernetes ensures **nodes** are healthy, not just pods.  
   - If a worker node fails, Kubernetes reschedules pods to another node dynamically.  

📌 **Traditional orchestrators simply restart failed services, but Kubernetes implements a full-scale self-healing architecture across applications, deployments, and infrastructure.**  

---

#### 3️⃣ Kubernetes as a DevOps & CI/CD Enabler 
Kubernetes integrates seamlessly with DevOps practices:  
✅ **GitOps** → Manage infrastructure & apps declaratively (ArgoCD, Flux).  
✅ **CI/CD Pipelines** → Automate builds & deployments (Jenkins, GitHub Actions).  
✅ **Progressive Delivery** → Blue-Green, Canary deployments.  
✅ **Infrastructure as Code** → Manage K8s using YAML, Terraform, Helm.  

💡 **Kubernetes is the foundation for modern DevOps workflows.**  

---

#### 4️⃣ Kubernetes as a Secure, Multi-Tenant Platform 
🔐 **Security Features Beyond Orchestration:**  
- **Role-Based Access Control (RBAC)** → Fine-grained permissions.  
- **Pod Security Policies** → Enforce security best practices.  
- **Secrets Management** → Securely store credentials & API keys.  
- **Network Policies** → Restrict communication between pods.  

📌 **Unlike traditional orchestrators, Kubernetes ensures secure multi-tenancy for teams.**  

---

#### 5️⃣ Kubernetes as an Ecosystem for Cloud-Native Apps  
Kubernetes **isn't just a tool—it’s an ecosystem** that integrates with:  
🚀 **Serverless Computing** → KNative, OpenFaaS  
📦 **Service Mesh** → Istio, Linkerd  
📊 **Monitoring & Logging** → Prometheus, Grafana, ELK  
🔀 **Distributed Databases** → Cassandra, CockroachDB  

💡 **Kubernetes extends beyond orchestration to support the full cloud-native stack.** 

---

### History
Before Kubernetes, Google was already managing massive-scale workloads using containerized applications. They built two internal systems:
- Borg: A cluster management system that ran millions of containers per week.
- Omega: A second-generation system, Omega, improved on Borg with better scheduling and flexibility. 

In June 2014, Google open-sourced Kubernetes as an independent project.
- Kubernetes was inspired by Borg and Omega, but designed for everyone, not just Google.
- In 2015, Kubernetes was donated to the Cloud Native Computing Foundation (CNCF), backed by the Linux Foundation.
- CNCF ensured Kubernetes remained vendor-neutral and community-driven.

## References
- Important article, [Kubernetes and Docker](https://kubernetes.io/blog/2020/12/02/dont-panic-kubernetes-and-docker/)

- [Docker docs](https://kubernetes.io/docs/concepts/overview/)