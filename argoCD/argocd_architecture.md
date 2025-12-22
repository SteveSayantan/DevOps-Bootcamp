# GitOps Tools and Argo CD Architecture

## List of Popular GitOps Tools
Some of the popular GitOps tools currently available in the market include:

*   **Argo CD**: Identified as one of the best and most popular GitOps tools.

*   **Flux CD**: Also a popular GitOps tool and a Cloud Native Computing Foundation (CNCF) graduated project, similar to Argo CD.

*   **Jenkins X**: Another tool in the GitOps space.


## Brief History of Argo CD
Argo CD was **initially created by engineers at Applatix**, who later open-sourced it. The entire Argo project, which includes Argo CD, Argo Rollouts, Argo Events, Argo Workflows, and Argo Notifications, is now open-sourced. Applatix was subsequently acquired by Intuit.

Argo CD has a large number of **active contributors** from various companies such as Applatix, BlackRock, Codefresh, Intuit, and Red Hat. It is a **CNCF graduated project**, similar to Flux CD.

## Working Principle of Argo CD
At a high level, Argo CD, like other GitOps tools, aims to **maintain synchronisation between Git (or any version control system) and Kubernetes**. It treats **Git as the single source of truth**.

The working principle involves:

1.  **Retrieving Manifests**: Argo CD picks declarative YAML manifests (e.g., for applications, deployments) from the Git repository.

1.  **Deployment**: It deploys these manifests onto the Kubernetes cluster.

1.  **Continuous Reconciliation**: After deployment, Argo CD continuously monitors the state between Git and Kubernetes. This continuous monitoring is a core reconciliation logic.

1.  **Auto-Healing**: If any manual changes are made directly to the Kubernetes cluster that deviate from the Git state, Argo CD will detect these changes and automatically correct them, bringing the cluster back in line with the Git repository's desired state. This provides an auto-healing capability that traditional deployment methods often lack.

Essentially, Argo CD ensures that **what is defined in Git is always what is running in Kubernetes**.

## Components and Architecture of Argo CD

The robust architecture of Argo CD is built using several microservices, which work together to provide its functionality:

1.  **Repo Server**:
    *   This component's primary role is to **connect to Git and retrieve the state of the Git repository**. It acts as one microservice within the GitOps application that interacts with the version control system.

2.  **Application Controller**:
    *   This microservice is responsible for **communicating with Kubernetes to obtain the cluster's current state**.

    *   It **compares the state received from the Repo Server (Git's state) with the actual state of Kubernetes**.

    *   If a difference is detected, the Application Controller **syncs the Kubernetes cluster according to the manifests from Git**, ensuring consistency.

    *   The Application Controller relies on Redis for caching the state.

3.  **API Server**:
    *   The API Server is the component that **users interact with**.

    *   It provides the interface for users to communicate with Argo CD via its **User Interface (UI) or Command Line Interface (CLI)**.
    
    *   It also handles **authentication**, supporting features like **Single Sign-On (SSO)** and integration with existing OIDC (OpenID Connect) providers.

4.  **Dex**:
    *   **Dex is a lightweight OIDC proxy server** that comes by default with Argo CD installations.

    *   Its purpose is to **provide SSO capabilities for the API Server**, allowing integration with various external identity providers like Google, Facebook, or other corporate authentication systems.

5.  **Redis**:
    *   **Redis is used for caching information** within the Argo CD system.

    *   This caching is crucial because components like the Application Controller are stateful sets, meaning they need to maintain and quickly access information about the cluster's state and past events, especially if they restart.

This architectural breakdown illustrates that Argo CD involves multiple interconnected microservices working beneath the surface to provide a robust and reliable GitOps system.

## References
- [ArgoCD Architectural Overview](https://argo-cd.readthedocs.io/en/stable/operator-manual/architecture/)
- [ArgoCD Component Architecture](https://argo-cd.readthedocs.io/en/stable/developer-guide/architecture/components/#component-architecture)
