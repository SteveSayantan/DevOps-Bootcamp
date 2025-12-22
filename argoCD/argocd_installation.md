## Installation
- Create the `argocd` namespace and install the ArgoCD controllers inside that.
  ```bash
  kubectl create namespace argocd
  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
  ```
- Check if all the installed Pods are running
  ```bash
  kubectl get pods -n argocd
  ```
  > ArgoCD listens to a custom resource aka **Application** to perform the actions
- To access the ArgoCD UI from browser,

  - we modify the type of the **argocd-server** service to **NodePort**
    ```bash
    kubectl patch svc argocd-server -n argocd -p '{"spec":{"type":"NodePort"}}'
    ``` 
  - Since we're using a **Minikube** cluster named as **test-cluster**, we create a tunnel to expose the **argocd-server** service
    ```bash
    minikube service argocd-server -n argocd --url -p test-cluster
    ```
- Now, we can access the argoCD UI at e.g. `localhost:57506`. Similarly, we can login using the argoCD CLI: `argocd login 127.0.0.1:57506`

## Login Using The UI
- The initial password is kept in the `argocd-initial-admin-secret` secret in `argocd` namespace. We need to retrieve and decode it in **base64** format.
  ```bash
  kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' |base64 -d
  ```
- Enter the usename as `admin` and this retrieved password to log in.


## Creating an Application
- After logging in, click the `+ New App` button
- Give the **Application Name** as **guestbook**, use the **Project** default, and make the sync policy as Automatic
- Connect the https://github.com/argoproj/argocd-example-apps.git repo to Argo CD by setting repository url to the **Repository URL**, leave **revision** as HEAD, and set the path to **guestbook** which is the folder containing k8s manifests.
- Click on `CREATE` button.

> Kubernetes manifests can be specified in several ways e.g., kustomize applications, helm charts, Plain directory of YAML/json manifests etc. 

## Reference
- [ArgocD Example Apps Repository](https://github.com/argoproj/argocd-example-apps)
- [ArgoCD Command Reference](https://argo-cd.readthedocs.io/en/latest/user-guide/commands/argocd/)

## ArgoCD Architecture Models

ArgoCD can be deployed in multiple architectural patterns to manage Kubernetes clusters. The most common patterns are the Standalone and Hub-Spoke models.

### Standalone Model
In a Standalone model, each Kubernetes cluster runs its own dedicated ArgoCD instance. Each instance operates autonomously.

 For example, if we have Dev, QA, and Staging clusters, each cluster would have its own independent Argo CD instance. Each of these localized Argo CD instances monitors the Git repository and deploys changes only onto its respective cluster.
![Standalone Model](https://codefresh.io/wp-content/uploads/2023/07/argo-cd-standalone-web-1.jpg)

#### Advantages
- Each instance is independent. An issue with one ArgoCD instance or cluster will not affect others, limiting the blast radius. Since, the instances are self-contained and require no external network access to other clusters, making it ideal for regulated or high-security environments.
- Low memory/cpu overhead for Argo CD with small impact on each cluster.
- This model is suitable if we have multiple DevOps teams with their own isolated clusters.

#### Disadvantages
- Managing multiple, independent ArgoCD instances (e.g., upgrading ArgoCD versions, duplicating configurations etc.) across a fleet of clusters can be burdensome for operators.
- There is no single, centralized dashboard to view the status of applications across all clusters.
- With every cluster running a separate instance, it can be challenging to enforce configuration consistency across different environments

### Hub-Spoke Model
The Hub-Spoke model works well for managing large numbers of clusters. Here, a central ArgoCD instance deployed exclusively on a k8s cluster (the hub) is used to manage and deploy applications across multiple Kubernetes clusters (the spokes). The hub instance connects to and controls all the spoke clusters.

The centralized Argo CD instance watches the Git repository for changes and then deploys these changes onto multiple Spoke clusters.The Hub cluster acts as the centralized point from which deployments to the Spokes are managed.

This model is well-suited for organizations that have a centralized DevOps team managing all projects and environments.

![Hub-Spoke Model](https://codefresh.io/wp-content/uploads/2023/07/argo-cd-multi-cluster-web-1.jpg)

#### Advantages
- Administrators can manage all applications and clusters from a single, centralized ArgoCD dashboard.
- Less administrative effort is required since there is only one ArgoCD instance to maintain, upgrade, and configure.
- With a single, centralized instance, disaster recovery is simpler and more straightforward.

#### Disadvantages
- A critical failure or misconfiguration in the central hub's ArgoCD instance could potentially affect all connected spoke clusters
- If the hub cluster is compromised, an attacker could gain control over the entire fleet of managed clusters.
- The Hub Argo CD instance becomes resource-intensive/overloaded because it has to manage a huge number of clusters and Kubernetes objects. It requires advanced configuration, such as setting up Argo CD in High Availability (HA) mode and configuring dynamic sharding to operate properly.