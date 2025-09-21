## 🔷 What Is Ingress in Kubernetes?

Ingress is a Kubernetes API object that exposes HTTP and HTTPS routes from outside the cluster to services within the cluster. Traffic routing is controlled by rules defined on the Ingress resource.

Without Ingress, two major problems are faced:

- Lack of advanced, enterprise-level load balancing features (like path-based, host-based routing, sticky sessions, TLS termination, web application firewall, etc.) in Kubernetes Services.

- High cloud provider costs when exposing many services, since each Service of type LoadBalancer often required a separate public static IP, incurring extra charges.

### Components
Ingress in Kubernetes consists of two major components:

- **Ingress Resource** : This is a Kubernetes API object where we declare how traffic should be routed.

- **Ingress Controller** : Only creating an Ingress resource has no effect. In order for the Ingress resource to work, the cluster must have an ingress controller running. Ingress controllers are <u>not started automatically</u> with a cluster. We need to choose the ingress controller implementation that best fits our cluster.

It is a pod or set of pods (created using a Deployment) that listens for Ingress resources and proxies traffic based on them. Some popoular Ingress Controllers are nginx, contour, haproxy, traefik, istio etc. Ingress controllers have additional intelligence built-in to monitor the kubernetes cluster for new ingress resources and modify themselves accordingly.

Kubernetes supports multiple Ingress Controllers running in the same cluster, and we can target a specific controller inside a Ingress resource using `spec.ingressClassName` attribute. As a result, the Ingress would be handled only by the controller registered with that name. The value of `ingressClassName` comes from an **IngressClass** resource that the Ingress Controller registers.

> Ingress doesn’t create or expose a public IP on its own. We need a LoadBalancer/NodePort Service in front of the ingress controller to forward all incoming internet traffic to the ingress controller pods. Without that LoadBalancer Service, our ingress controller pods would only have internal cluster IPs. 

### 🔍 What is the DefaultBackend in an Ingress?
* An Ingress routes HTTP/HTTPS traffic based on *rules* you define: host headers, paths, etc.
* Traffic that **doesn’t match any rule** needs somewhere to go — that somewhere is the *default backend*. 
* If no `.spec.rules` match an incoming request, the `defaultBackend` handles it.

The default backend can be specified:

* In the **Ingress controller’s configuration** (many controllers have a built-in fallback backend).
* Directly in an Ingress resource under `.spec.defaultBackend`.
* If we don’t explicitly define `.spec.defaultBackend` and your Ingress has no matching rules for a request, the behavior depends on the Ingress controller (often a 404 response).

## 🎯 Why Ingress is Useful *Even When* We Have LoadBalancer Service

### ✅ 1. One Entry Point for Many Services

* With `LoadBalancer`, each Service (frontend, API, admin) needs a separate external IP or DNS.
* With `Ingress`, we **only need one LoadBalancer**, which routes traffic internally to the right Services based on rules.

**Without Ingress:**

* `frontend.example.com` → LoadBalancer Service 1
* `api.example.com` → LoadBalancer Service 2
* `admin.example.com` → LoadBalancer Service 3

**With Ingress:**

* One Ingress + one LoadBalancer Service (for exposing the Ingress)
* Handles all three hostnames under one IP/domain.

---

### ✅ 2. Layer 7 Smart Routing

Ingress lets us:

* Route `/api` to API service and `/web` to frontend
* Route `web.example.com` to frontend and `api.example.com` to backend
* Rewrite URLs, redirect HTTP to HTTPS, etc.

This isn’t possible with LoadBalancer Services — since they only support L4 (TCP/UDP) Load Balancing and can’t inspect HTTP headers or paths.

---

### ✅ 3. TLS (HTTPS) Termination Built-in

Ingress controllers support **SSL termination** — we store certificates as Kubernetes secrets, and the controller handles HTTPS for us.

With `LoadBalancer`, we'd have to:

* Terminate TLS inside each pod, **or**
* Use a cloud-specific annotation (e.g., `ssl-cert` in GCP)

Ingress standardizes and simplifies this.

---

### ✅ 4. Cost-Efficient in Cloud

* Each LoadBalancer in AWS/GCP costs money.
* With Ingress, we only create **one LoadBalancer**, even for many Services → **saves cost**.

---

### ✅ 5. Extensibility & Enterprise Features

Ingress Controllers (like NGINX, Traefik, Istio) support:

* Web Application Firewall (WAF)
* Rate limiting
* Authentication
* Caching, compression
* Request/response header manipulation
* Sticky sessions

Though Cloud provider LoadBalancers can support many of these features — but not natively via Kubernetes Service objects. To use those features, we'd need to:
- Configure them outside Kubernetes (manually or via Terraform, etc.)
- Or, use cloud-specific Kubernetes Ingress Controllers (e.g., AWS ALB Ingress Controller).

The **Service** abstraction is deliberately minimal and portable.


## Ingress Examples



