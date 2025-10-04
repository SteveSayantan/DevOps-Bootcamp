# **Deploying and Testing Ingress in Kubernetes with Minikube**

## **Introduction**
Ingress in Kubernetes is a powerful way to manage external access to services inside a cluster. Instead of exposing each service with its own external IP or NodePort, Ingress provides a centralized entry point to route traffic based on defined rules. In this blog, we’ll go step by step through creating a simple Ingress setup using **Minikube**, deploying services, and configuring routing rules.

---

## **Cluster Setup**
### Command:
```bash
minikube start -p test-cluster -n 3
```
This command starts a Minikube cluster named `test-cluster` with **3 nodes**. Having multiple nodes allows us to simulate a real Kubernetes cluster environment.

```powershell
PS C:\Users\steve> kubectl get nodes

NAME               STATUS   ROLES           AGE     VERSION
test-cluster       Ready    control-plane   9d      v1.33.1
test-cluster-m02   Ready    <none>          9d      v1.33.1
test-cluster-m03   Ready    <none>          2d16h   v1.33.1
```

## **Namespace Creation**

### Command:
```bash
kubectl create ns test-ingress
```
We create a namespace `test-ingress` to logically separate our Ingress-related resources from the rest of the cluster.

## **Deploying the Foo Service**
### Command:
```bash
kubectl run foo -n test-ingress --port 5678 --image=hashicorp/http-echo --labels="app=foo" -- "-text=Hello from Foo Service"
```
This creates a pod named `foo`, with the label `app=foo` using the lightweight **http-echo** image. It listens on port `5678` and responds with the text *“Hello from Foo Service”*.


Expose it as a service:
```bash
kubectl expose pod foo -n test-ingress --port=80 --target-port=5678
```
This creates a service named `foo` that maps external port `80` to container port `5678`.


## **Deploying the Bar Service**

Similarly, we deploy another echo service (`bar`) that responds with *“Hello from Bar Service”*. `kubectl expose` creates a service accessible within the cluster.

### Commands:

```bash
kubectl run bar -n test-ingress --port 5678 --image=hashicorp/http-echo --labels="app=bar" -- "-text=Hello from Bar Service"

kubectl expose pod bar -n test-ingress --port=80 --target-port=5678

```

## **Creating a Default Service**

### Commands:
```bash
kubectl run default-svc -n test-ingress --port 5678 --image=hashicorp/http-echo --labels="app=default" -- "-text=Path does not exist" "-status-code=404"

kubectl expose pod default-svc -n test-ingress --port=80 --target-port=5678

```
This service acts as a **fallback handler** when requests don’t match any path. It returns *“Path does not exist”* with HTTP status code **404**.



## **Creating an Ingress Resource**

### Command:
```bash
kubectl create ingress example-ingress -n test-ingress --class=nginx --rule="/foo=foo:80" --rule="/bar=bar:80" --default-backend=default-svc:80
```

Also, we can use the equivalent manifest,

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  namespace: test-ingress
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /foo
        pathType: Prefix
        backend:
          service:
            name: foo
            port:
              number: 80
      - path: /bar
        pathType: Prefix
        backend:
          service:
            name: bar
            port:
              number: 80
  defaultBackend:
    service:
      name: default-svc
      port:
        number: 80
```
This defines an **Ingress** named `example-ingress` that:
- Routes `/foo` → `foo` service.
- Routes `/bar` → `bar` service.
- Uses `default-svc` as the fallback backend.

## **Deploying Ingress Controller**
### Command:
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.13.2/deploy/static/provider/baremetal/deploy.yaml
```
This installs the **bare-metal NGINX Ingress Controller** of type **NodePort** in **ingress-nginx** namespace, which is required to enforce Ingress rules. Since we're using minikube, we choose the bare-metal ingress controller.

The [cloud-one](https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.13.2/deploy/static/provider/cloud/deploy.yaml) expects a cloud LB e.g. AWS ELB, GCP LB etc. which doesn’t exist in bare-metal setups e.g. minikube, kilercoda. Using it in this case might cause unexpected behavior as no external LB is available to route traffic.


```powershell
PS C:\Users\steve> kubectl get all -n ingress-nginx
NAME                                            READY   STATUS    RESTARTS        AGE
pod/ingress-nginx-controller-59cc89c559-qntqr   1/1     Running   1 (3d16h ago)   3d16h

NAME                                         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
service/ingress-nginx-controller             NodePort    10.111.9.81     <none>        80:32112/TCP,443:32289/TCP   3d17h
service/ingress-nginx-controller-admission   ClusterIP   10.101.133.17   <none>        443/TCP                      3d17h

NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/ingress-nginx-controller   1/1     1            1           3d17h

NAME                                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/ingress-nginx-controller-59cc89c559   1         1         1       3d16h
replicaset.apps/ingress-nginx-controller-5d7d9d875c   0         0         0       3d17h
```

## **Customizing Ingress Controller**
We need to make some changes to the ingress controller so that it uses the **default-svc** as default backend instead of its default one.

### Add Default Backend:

1. Edit the **ingress-nginx-controller** Deployment and set the value of the `--default-backend-service` flag to the name of the newly created error backend.

   ```bash
   kubectl edit deploy ingress-nginx-controller -n ingress-nginx
   ```
   Add the flag:
   ```yaml
   apiVersion: apps/v1
   kind: Deployment
    [...]
   spec:
      [...]
        spec:
          containers:
          - args:
            [...]
            - --default-backend-service=test-ingress/default-svc # flag added
   ```
   This ensures unmatched requests are routed to our default service.

2. Edit the `ingress-nginx-controller` ConfigMap and create the key `custom-http-errors` with a value of `404,503`.

   ```bash
   kubectl edit cm ingress-nginx-controller -n ingress-nginx
   ```
   Add key as shown below:
   ```yaml
   apiVersion: v1
   kind: ConfigMap
   metadata:
     [...]
   data:
     custom-http-errors: '404,503'
   ```
   This allows NGINX to handle and customize error responses.


## **Accessing the Ingress**
To access the Ingress controller from our local system, we can follow this approach:

### Execute:
```bash
minikube service ingress-nginx-controller -n ingress-nginx --url -p test-cluster
```
This provides a localhost URL (e.g., http://127.0.0.1:58493) that can be accessed from our browser.
```powershell
PS C:\Users\steve> minikube service ingress-nginx-controller -n ingress-nginx --url -p test-cluster
http://127.0.0.1:58493
http://127.0.0.1:58494
! Because you are using a Docker driver on windows, the terminal needs to be open to run it.
```

Testing the paths `/foo`, `/bar`, and an invalid path will demonstrate:
- `/foo` → *Hello from Foo Service*
- `/bar` → *Hello from Bar Service*
- `/invalid` → *Path does not exist (404)*

```powershell
PS C:\Users\steve> curl.exe -s -w "%{method} %{http_code}\n" 127.0.0.1:58493/foo
Hello from Foo Service
GET 200
PS C:\Users\steve> curl.exe -s -w "%{method} %{http_code}\n" 127.0.0.1:58493/bar
Hello from Bar Service
GET 200
PS C:\Users\steve> curl.exe -s -w "%{method} %{http_code}\n" 127.0.0.1:58493/invalid
Path does not exist
GET 404
PS C:\Users\steve> curl.exe -s -w "%{method} %{http_code}\n" 127.0.0.1:58493
Path does not exist
GET 404
```

This hands-on walkthrough shows how Ingress simplifies external access and routing in Kubernetes clusters. 🚀

## Reference
- [Ingress-Nginx Docs](https://kubernetes.github.io/ingress-nginx/)


