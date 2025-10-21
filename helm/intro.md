## What is Helm?
Helm is a package manager for Kubernetes. It is often compared to `apt` for Ubuntu in the Linux operating system, where `apt` manages the installation, updating, and removal of software packages. 

Similarly, Helm allows users to install, update, and uninstall Kubernetes controllers or third-party applications on a Kubernetes cluster. Helm also enables organisations to bundle or package their own applications as Helm charts.

## Why is Helm used?
Kubernetes is a complex system with many moving parts (pods, deployments, services, etc.). Helm simplifies the process by packaging everything into reusable charts. It’s like having a one-click install for your entire application stack instead of manually creating each component.

Helm addresses several challenges faced by DevOps and Site Reliability Engineering (SRE) teams when managing applications and controllers on Kubernetes:

*   **Simplifies Installation and Management:** Without Helm, installing applications like Prometheus or Argo CD on Kubernetes involves creating and applying multiple YAML files (e.g., for namespaces, service accounts, config maps, deployments, stateful sets) in a specific order. This process can be complex and time-consuming. Helm streamlines this by allowing installation with a single `helm install` command, similar to how `apt install` works on Linux.

*   **Reduces Maintenance Overhead:** Managing numerous scripts for installing, upgrading, and uninstalling many different applications across potentially hundreds of servers or Kubernetes clusters becomes a significant maintenance burden. Scripts can become outdated as installation mechanisms change, requiring constant review and testing. Helm eliminates this by standardising these operations through charts.

*   **Handles Dependencies:** Just like `apt` manages dependencies for Linux packages, Helm charts can encapsulate and manage the dependencies required for a Kubernetes application, ensuring everything is installed correctly.

*   **Facilitates Customisation for Different Environments:** Organisations often require different configurations for applications in various environments (e.g., UAT, Production). For instance, a development environment might need two replicas of an application, while production might require three. Without Helm, this would mean maintaining multiple, slightly different YAML files or complex scripting. Helm's `values.yaml` allows for **customising application specifications** (like replica counts or image versions) easily for different environments without altering the core template.

*   **Enables Application Packaging and Sharing:** Helm allows organisations to package their own microservices as charts, which can then be hosted in a central repository. This makes it easy for other teams within the organisation, or even external users, to deploy these applications using simple Helm commands.

> Helm does not require it to be installed on the k8s cluster. It uses the kube-config file to choose the active context and runs command on that cluster.

**Helm Chart**: A Helm chart is a collection of files that describe a set of Kubernetes resources. It acts as a package for your Kubernetes application, similar to a DEB or RPM file in Linux. It encapsulates all the Kubernetes YAML manifests and other resources needed to deploy a specific application.

**Helm Repo**: It is centralized repo for hosting multiple helm charts. It's similar to a package repository in Linux (like APT or YUM repos). A chart repo contains a special file `index.yaml` which acts as the catalog or metadata index for our chart repository. When someone runs `helm repo add myrepo https://myrepo-url`, Helm downloads that index.yaml and uses it to list available charts and versions, resolve URLs when installing a specific chart.

E.g., The Bitnami repository is a popular public repository that contains thousands of commonly used charts like Redis, Spark, and Nginx. Organisations can also create their own private repositories to host their custom application charts

## Components of HELM

* **Chart.yaml:** Metadata about the chart (name, version, owner etc.).

* **templates/**: Directory containing Kubernetes manifests (e.g. Deployment.yaml, Service.yaml etc.). These values may be overridden by users during `helm install` or `helm upgrade`. The content of `NOTES.txt` file inside **templates** directory will be displayed to the users when they run `helm install`.

* **values.yaml:** Used to customize the template files (for deploying on different environments).

* **charts/**: Directory for chart dependencies.

* **README.md:** Optional documentation.


### Commands

1. `helm repo add bitnami https://charts.bitnami.com/bitnami`: Adds the repository hosted on the given url with the name **bitnami** to local helm client.

1. `helm repo list`: Lists the added repos.

1. `helm repo update REPO1 REPO2 ...`: Update information of available charts locally from chart repositories.

1. `helm repo remove REPO1 REPO2 ...`: Remove one or more chart repositories.

1. `helm install happy-panda package_name`: Install the mentioned package with the **release name** as `happy-panda`. A **release** is the deployed instance of the chart (aka package). The **package_name** could be the path to the chart directory/zip or a reference like `bitnami/nginx`.

1. `helm install happy-panda package-name --dry-run --debug`: Simulates an install (talks to Kubernetes API to validate CRDs, namespaces, etc.). Also, prints out rendered YAML and additional debug info.

1. `helm search repo package_name`: Finds the latest version specified package in the locally added repositories. Without the **package_name**, it lists all the available packages. Use `--versions` flag to show all available versions. 

1. `helm list`: Lists currently deployed releases.

1. `helm uninstall release-name`: Uninstalls the `release-name` release from the cluster.

1. `helm create myapp`: This generates a new chart structure under the `myapp` directory.

1. `helm package myapp`: Packages the chart directory `myapp` into a `.tgz` archive which can be shared or stored in a chart repo or OCI registry.

1. `helm repo index`: Generates an index file based on current local directory that contains packaged charts. We can also pass the directory name e.g. `helm repo index foo`.

1. `helm show values package-name`: Displays the contents of the `values.yaml` file for the given chart.

1. `helm upgrade release-name package-path`: This upgrades a release. If the Chart version in Chart.yaml changed (even without template changes), it is treated as a new version → Helm creates a new release revision. However, if the Chart version is unchanged, but templates have been changed, Helm applies changes by creating a new revision with the same chart version.

   - `helm upgrade <release_name> <chart> -f custom-values.yaml`: Helm will merge the new custom-values.yaml file with the chart's default values (values.yaml), and replace the previously used values completely. It means if we omit some keys that were previously set, Helm forgets them during the upgrade. Use `--reuse-values` flag to reuse the previous release's values (stored in the cluster), and merges only the newly provided overrides.


1. `helm history release-name`: Every time we install, upgrade, or rollback a release, Helm saves a new revision in its history. This command will list the history.

1. `helm rollback release-name revision-number`: To rollback to a particular revision for a specific release. The revision number comes from `helm history`.

1. `helm lint package-path`: To run a series of tests to verify that the chart at the given path is well-formed.

1. `helm template package-name`: Lists what resources are going to be created without installing. None of the server-side testing of chart validity (e.g. whether an API is supported) is done.
    - `helm template package-name -s Pod.yaml`:  only show manifests rendered from the **Pod.yaml** template. 

1. `helm get manifest release-name`: prints out all of the Kubernetes resources that were uploaded to the server. Each file begins with `---` to indicate the start of a YAML document, and then is followed by an automatically generated comment line that tells us what template file generated this YAML document.

### Reference
- [HELM Docs](https://helm.sh/docs/)
- [Working with](https://helm.sh/docs/topics/registries/)
- [Chart repo Guide](https://helm.sh/docs/topics/chart_repository/)