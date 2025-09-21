1. `minikube start -n 3 -p demo-cluster` : Spins up a cluster named **demo-cluster** with 3 nodes. The default value of `-p` is **minikube** and `-n` is **1**. While creating a cluster, if we want to reuse the existing base image and avoid downloading a new one, use `--base-image` flag.

1. `minikube profile list` : Lists the clusters.

1. `kubectl config current-context` : Display the current context.

1. `kubectl config get-contexts`: Display list of contexts.

1. `minikube ssh -p <cluster_name> -n <node_name>`: ssh into a given node.

1. `minikube ip -p demo-cluster`: Display IP of control plane. Use `-n` flag to get IP of a particular node. The default value of `-p` is **minikube** .

1. `minikube image load my-image:latest`: Load an local image into minikube. Also, set the `imagePullPolicy: Never` in the Kubernetes deployment YAML files, as it will ensure using locally added images instead of trying pull it remotely from the registry.

 

Check out [How to access applications running within minikube](https://minikube.sigs.k8s.io/docs/handbook/accessing/)
