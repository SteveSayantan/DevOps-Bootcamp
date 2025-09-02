## WHY

We create many deployments. Typically, we expose our deployment to the Internet by creating a Service with `type=LoadBalancer`.

Depending on our environment, this usually assigns a random publicly available endpoint to our service that you can access from anywhere in the world. On Google Kubernetes Engine, this is a public IP address:
```bash
$ kubectl get svc
NAME      CLUSTER-IP     EXTERNAL-IP     PORT(S)        AGE
nginx     10.3.249.226   35.187.104.85   80:32281/TCP   1m
```

But dealing with IPs for service discovery isn’t nice, so we register this IP with your DNS provider under a better name—most likely, one that corresponds to our service name. If the IP changes, we update the DNS record accordingly.

ExternalDNS takes care of that last step for us by keeping our DNS records synchronized with our external entry points.

ExternalDNS’ usefulness also becomes clear when we use Ingresses to allow external traffic into your cluster. Via Ingress, we can tell Kubernetes to route traffic to different services based on certain HTTP request attributes, e.g. the Host header:
```bash
$ kubectl get ing
NAME         HOSTS                                      ADDRESS         PORTS     AGE
entrypoint   frontend.example.org,backend.example.org   35.186.250.78   80        1m
```

But there’s nothing that actually makes clients resolve those hostnames to the Ingress’ IP address. Again, we normally have to register each entry with your DNS provider.

ExternalDNS can solve this for you as well.

## WHAT
ExternalDNS is a Kubernetes add-on that automatically manages DNS records for Services and Ingresses. It is a k8s project ( [GitHub Repo](https://github.com/kubernetes-sigs/external-dns) ) itself, however, the cloud providers needs to add their own implementation for the Pods.

It watches the Kubernetes API for Service and Ingress resources continuously, and whenever something changes (like a new LoadBalancer IP or hostname), it updates the corresponding DNS records.

### 🌐 Scenario 1: Ingress + ExternalDNS with Civo DNS

####  🛠️ Setup

* You purchased a domain: `example.com` (from GoDaddy).

* You pointed the **nameservers** of `example.com` to **Civo DNS** (If the NS point elsewhere, ExternalDNS (Civo provider) can’t create records.)

* In your Kubernetes cluster (on Civo):

  * You deployed 2 services:

    * `shopping-service` → accessible at `shop.example.com`

    * `streaming-service` → accessible at `play.example.com`

  * You deployed **nginx-ingress-controller**.

  * You created an **Ingress resource** to route traffic based on hostnames.

* You want DNS records in **Civo DNS Manager** to be created/updated automatically.

---

#### Solution 

- ✅ Step 1: Deploy ExternalDNS (with Civo support)

  ExternalDNS will manage DNS records inside your **Civo DNS manager**. Make sure to add `--domain-filter=example.com`. Without it, ExternalDNS tries to scan zones we don’t intend to manage.

- ✅ Step 2: Ingress with Annotations

  Now create an Ingress for **shopping** and **streaming** apps. The annotation `external-dns.alpha.kubernetes.io/hostname` explicitly tells ExternalDNS which hostnames to manage. ExternalDNS doesn’t require the annotation if we want it to manage all hosts declared in the Ingress. But adding it is a best practice, especially when we want to be explicit about which domains/subdomains ExternalDNS should create.




#### 🎯 Follow-up : Add Food Ordering Service

You created a new service `food-ordering-service`. You want traffic at `eat.example.com` → routed to it.

**Solution:**
- ✅ Update Ingress

  Just extend the same Ingress with the new rules. Also update the annotation.


- Once applied:

  * ExternalDNS sees the new host `eat.example.com`.

  * It automatically creates a DNS record in **Civo DNS Manager** pointing `eat.example.com` → our LoadBalancer’s external IP.



####  🚨 Common Mistakes to Avoid

1. **Nameservers not updated**: If you don’t update GoDaddy NS → Civo’s NS, DNS records won’t resolve.

2. **Missing domain-filter**: ExternalDNS may try to update unrelated domains.

3. **Wrong ingress class**: If `nginx` ingress controller is installed, use `kubernetes.io/ingress.class: nginx`.

--- 

### 🌐 Scenario 2: Managing DNS for Services on Civo with ExternalDNS

#### 🛠️ Setup

* You’ve purchased a domain: **`example.com`** (from GoDaddy).

* You moved DNS management to **Civo DNS**.

* In your Kubernetes cluster (running on **Civo Cloud**):

  * You already have a **shopping service** exposed via a `LoadBalancer`. You want traffic at **`shop.example.com`** to go there.

  * Later, you will add a **streaming service** (also `LoadBalancer`). You want traffic at **`movies.example.com`** to go there.

* You want **ExternalDNS** to automatically manage DNS records in Civo for your services.

#### Solution


- **Step 1: Install ExternalDNS**

  Deploy ExternalDNS in your cluster, configured for **Civo DNS**. Set the `annotationFilter` to `"external-dns.alpha.kubernetes.io/hostname"` to ensure only annotated Services get DNS records, not the other ones.

- **Step 2: Annotate your Shopping Service**

  When we first created the shopping service, we added a Civo DNS `A` record manually. Now, we can switch to ExternalDNS management by annotating the service:

  ```yaml
  # ...
  metadata:
   name: shopping-service
   annotations:
    external-dns.alpha.kubernetes.io/hostname: shop.example.com
  ```

  Once applied, ExternalDNS will see the annotation and ensure `shop.example.com` → [LoadBalancer IP]. Our old manual record in Civo should be deleted, or ExternalDNS will overwrite it.


- **Step 3: Add the Streaming Service**

  When we create the new service, just add the annotation upfront:
  ```yaml
  # ...
  metadata:
   name: streaming-service
   annotations:
    external-dns.alpha.kubernetes.io/hostname: movies.example.com
  ```

  ExternalDNS will automatically create `movies.example.com` in Civo DNS and point it to the LB IP.
