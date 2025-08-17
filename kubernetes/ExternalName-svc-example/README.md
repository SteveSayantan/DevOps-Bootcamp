## Summary
Here, we are trying to connect to a postgres database in a namespace from a python application in another namespace using ExternalName service.

### Steps
1. Create database and app namespaces.
   ```bash
   kubectl create ns database-ns
   kubectl create ns application-ns
   ```
1. Create the database deployment and service
   ```bash
   kubectl apply -f db.yaml
   kubectl apply -f db_svc.yaml
   ```
1. Create ExternalName service
   ```bash
   kubectl apply -f extername-db_svc.yaml
   ```
1. Create application to access the service
   ```bash
   docker build --no-cache --platform=linux/amd64 -t ttl.sh/demo-img:1h .
   docker push ttl.sh/demo-img:1h 
   ```
   **ttl.sh** is a open-source docker image repository. Know more about  [here](https://ttl.sh/)

1. Create the application pod: (Make sure the `spec.containers.image` is on a par with the image name)
   ```bash
   kubectl apply -f apppod.yaml
   ```
1. Check the pod logs to see if the connection was successful 

   ```bash
   kubectl logs my-application -n application-ns
   ```
Any request to the ExternalName service would be forwarded to `spec.externalName` mentioned in the manifest.