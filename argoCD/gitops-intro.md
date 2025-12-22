# GitOps: A Detailed Overview

This note provides a comprehensive look into GitOps, covering its definition, benefits compared to traditional approaches, fundamental principles, and key advantages.

---

## What is GitOps?

**GitOps uses Git as a single source of truth to deliver applications and infrastructure**. It's a method where the desired state of an application and infrastructure is stored declaratively in a Git repository.

**Key aspects of GitOps include**:

*   **Git as Source of Truth**: All changes to the application configuration or infrastructure (e.g., Kubernetes YAML manifests like `node.yaml`, `pod.yaml`, `deploy.yaml`) are first committed to a Git repository.

*   **Pull Request Mechanism**: Changes are introduced via pull requests, which undergo review by other engineers before being merged into the repository. This standardises the process and provides an audit trail.

*   **Automated Deployment**: A GitOps controller (like Argo CD or Flux CD) actively monitors the Git repository. Upon detecting a merged change, it automatically deploys that change to the target Kubernetes cluster.

*   **Scope Beyond Applications**: While it facilitates application delivery, **GitOps is equally critical for infrastructure delivery and management**, especially in environments with numerous Kubernetes clusters and thousands of resources, e.g. updating node configurations, such as adding a taint, using declarative YAML manifests stored in a Git repository.

The fundamental idea behind GitOps is to extend the reliable tracking and versioning mechanisms used for source code to the deployment and infrastructure management processes.

## Benefits of GitOps as Compared to the Traditional Approach

The traditional approach to managing deployments and infrastructure, particularly in Kubernetes, often lacks proper tracking and auditing mechanisms.

**Traditional Approach Shortcomings**:

*   **No Change Tracking**: In a non-GitOps setup, there's no inherent mechanism to track changes made to a Kubernetes cluster's configuration (e.g., updating a node's taint or resources).

*   **Lack of Versioning and Auditing**: Changes lack version control, making it difficult to understand what was changed, when, and by whom. Debugging or rolling back unwanted changes becomes challenging due to this absence of an audit trail.

*   **Manual or Scripted Deployments**: Deployments typically rely on shell or Python scripts using tools like `kubectl` or Helm, which, while functional, do not provide an integrated tracking mechanism for the deployed state itself.

**GitOps as a Solution**:

*   **Comprehensive Tracking and Versioning**: GitOps brings the robust versioning capabilities of Git to infrastructure and application deployments. Every change is tracked, versioned, and immutable, providing a complete history.

*   **Auditing and Accountability**: By enforcing changes through Git pull requests and reviews, GitOps inherently provides an audit log. You can trace exactly who proposed a change, who approved it, and when it was merged and deployed.

*   **Standardised Deployment Process**: It standardises how changes are made and deployed, reducing variability and potential errors.

*   **Enhanced Security and Reliability**: GitOps continuously reconciles the cluster's actual state with the desired state in Git. This means any manual, out-of-band changes made directly to the cluster are detected and automatically reverted by the GitOps controller, ensuring the cluster always reflects the single source of truth in Git. This capability provides **auto-healing behavior** and **significant security advantages** against unwanted or malicious modifications.

*   **Declarative Consistency**: It ensures that "whatever you see in a git repository is the same configuration that is deployed on your kubernetes cluster".

## Fundamental Principles of GitOps

For any system or tool to align with GitOps, it should adhere to these four core principles:

1.  **Declarative**:
    *   The entire system managed by GitOps must have its desired state **expressed declaratively**. This means defining *what* the desired state is (e.g., using Kubernetes YAML manifests) rather than *how* to achieve it.
    *   The principle ensures that "whatever you see is what you have," meaning the configuration in the Git repository directly represents the deployed state.

2.  **Versioned and Immutable**:
    *   The declarative desired state must be **versioned in Git** (or a similar version control system). This allows for a complete history of changes, easy rollbacks, and understanding of evolutions.

    *   Once a change is committed, it should be **immutable**, meaning the specific version recorded cannot be altered. While the name is "GitOps," the core concept is versioning, and other versioned storage solutions like S3 buckets could also be used.

3.  **Pulled Automatically**:
    *   Changes to the desired state in the Git repository should be **automatically applied** to the system.
    *   This can occur via a "pull" mechanism (where a GitOps controller continuously polls the repository for changes) or a "push" mechanism (using webhooks to trigger deployments upon commits). The key is automatic synchronisation.

4.  **Continuously Reconciled**:
    *   A GitOps controller **continuously observes the actual state** of the deployed system and compares it against the desired state defined in the Git repository.
    *   If any deviation is detected (e.g., a resource was manually changed in the cluster), the GitOps controller will **automatically override the actual state to match the desired state** from Git. Git is always considered the single source of truth.

## Advantages of GitOps

The adoption of GitOps offers several significant advantages:

*   **Security**: GitOps significantly enhances security by preventing and overriding unwanted changes. Because the GitOps controller continuously reconciles the cluster state with Git, any unapproved or malicious changes made directly to the Kubernetes cluster are automatically reverted, ensuring the system's integrity.

*   **Versioning**: All configurations and changes are version-controlled, providing a complete audit trail, facilitating rollbacks, and improving traceability. This is a core concept, not exclusively tied to Git itself, as other versioned platforms can also support GitOps principles.

*   **Auto Upgrades**: GitOps enables automatic deployment of changes. Once a pull request is merged, the GitOps controller automatically pulls and applies the changes, leading to efficient and consistent upgrades.

*   **Auto Healing Behavior**: Through continuous reconciliation, GitOps inherently provides auto-healing capabilities. If an undesirable change occurs (due to human error or external interference), the GitOps controller detects it and automatically restores the system to its desired state as defined in Git.

*   **Consistency and Clarity**: By enforcing a declarative approach and continuous synchronisation, GitOps ensures that the deployed infrastructure and applications are always consistent with the configuration stored in Git.