## Create Foo Chart
- Initialize a helm chart
  ```bash
  helm create my-foo-app
  ````

- Create a `Pod.yaml` in **templates/**.
  ```yaml
  apiVersion: v1
  kind: Pod
  metadata:
   name: {{ .Release.Name }}
  spec:
   containers:
    - name: {{ .Release.Name }}
      image: {{ .Values.image.repository }}:{{ .Values.image.tag }}
      imagePullPolicy: {{ .Values.image.pullPolicy }}
      args:
      - "-listen=:{{ .Values.containerPort }}"
      - "-text={{ .Values.message }}"
      ports:
      - containerPort: {{ .Values.containerPort }}
  ```

- Create the corresponding **values.yaml**
  ```yaml
  image:
   repository: hashicorp/http-echo
   # This sets the pull policy for images.
   pullPolicy: IfNotPresent
   # Overrides the image tag whose default is the chart appVersion.
   tag: latest
  containerPort: 5000
  message: Hello from Foo Service
  ```
- Edit the **Chart.yaml**
  ```yaml
  apiVersion: v2
  name: my-foo-app
  description: A Helm chart for installing http-echo web-server that echos back a message

  type: application

  version: 1.0.0

  appVersion: "latest"
  ```
- Install the chart
  ```bash
  helm install foo ./my-foo-app -n foo-ns --create-namespace
  ```
## Create Bar Chart
- Initialize a helm chart
  ```bash
  helm create my-bar-app
  ````

- Create a `Pod.yaml` in **templates/**.
  ```yaml
  apiVersion: v1
  kind: Pod
  metadata:
   name: {{ .Release.Name }}
  spec:
   containers:
    - name: {{ .Release.Name }}
      image: {{ .Values.image.repository }}:{{ .Values.image.tag }}
      imagePullPolicy: {{ .Values.image.pullPolicy }}
      args:
      - "-listen=:{{ .Values.containerPort }}"
      - "-text={{ .Values.message }}"
      ports:
      - containerPort: {{ .Values.containerPort }}
  ```

- Create the corresponding **values.yaml**
  ```yaml
  image:
   repository: hashicorp/http-echo
   # This sets the pull policy for images.
   pullPolicy: IfNotPresent
   # Overrides the image tag whose default is the chart appVersion.
   tag: latest
  containerPort: 5000
  message: Hello from Bar Service
  ```
- Edit the **Chart.yaml**
  ```yaml
  apiVersion: v2
  name: my-bar-app
  description: A Helm chart for installing http-echo web-server that echos back a message

  type: application

  version: 1.0.0

  appVersion: "latest"
  ```
- Install the chart
  ```bash
  helm install bar ./my-bar-app -n bar-ns --create-namespace
  ```

- Create a folder `my-helm-repo`
  ```bash
  mkdir my-helm-repo/
  ```
- Package `my-foo-app` and place it under `my-helm-repo`.
  ```bash
  helm package my-foo-app/ -d my-helm-repo/
  ```

- Package `my-bar-app` and place it under `my-helm-repo`.
  ```bash
  helm package my-bar-app/ -d my-helm-repo/
  ```
- List the contents of `my-helm-repo`

  ```bash
  controlplane:~$ ls -l my-helm-repo/
  total 8
  -rw-r--r-- 1 root root 848 Oct  8 09:55 my-bar-app-1.0.0.tgz
  -rw-r--r-- 1 root root 849 Oct  8 09:53 my-foo-app-1.0.0.tgz
  ```

### Using Docker Hub (OCI Registry)

- Login to Docker Hub using credentials. Enter the password when prompted.

  ```bash
  helm registry login -u username registry.hub.docker.com
  ```
- Push the archived chart to Docker Hub. Here, it will be pushed to a repository named `my-bar-app` with the tag `1.0.0`. Since the repository does not exist initially, Docker Hub will create it. 

  ```bash
  helm push ./my-helm-repo/my-bar-app-1.0.0.tgz oci://registry.hub.docker.com/username
  ```
  Now, we can use the chart as follows. If the `--version` flag is omitted, the latest version is used.
  ```bash
  helm install bar oci://registry-1.docker.io/username/my-bar-app --version 1.0.0
  ```
  In future, if we push another version of this chart (say, `my-bar-app-1.0.1.tgz` ), we would use
  ```bash
  helm push ./my-helm-repo/my-bar-app-1.0.1.tgz oci://registry.hub.docker.com/username
  ```
  It will be stored into **my-bar-app** repository with a new tag (e.g., `1.0.1`).

- Similarly, the following command will push the `my-foo-app` chart to Docker Hub and place it inside `my-foo-app` repository with the tag `1.0.0`.
  ```bash
  helm push ./my-helm-repo/my-foo-app-1.0.0.tgz oci://registry.hub.docker.com/username
  ```

### Using GitHub
In this approach, we create a GitHub repo that will be used as a Chart repository to host multiple packaged charts.

- First, we need to create a GitHub repo (say, **helm-repo**).

- Run the following to create an `index.yaml` file inside **my-helm-repo**.

  ```bash
  helm repo index ./my-helm-repo --url https://yourusername.github.io/helm-repo  # using the GH Pages URL of the GitHub repo !!!
  ```
  The `index.yaml` looks like as follows:
  ```yaml
  apiVersion: v1
  entries:
    my-bar-app:
    - apiVersion: v2
      appVersion: latest
      created: "2025-10-08T19:24:30.5231683+05:30"
      description: A Helm chart for installing http-echo web-server that echos back
        a message
      digest: d43f657bbb14e820af2ae1f2f9c0f54323de209532d54aac04706000d5e86a5c
      name: my-bar-app
      type: application
      urls:
      - https://yourusername.github.io/helm-repo/my-bar-app-1.0.0.tgz
      version: 1.0.0
    my-foo-app:
    - apiVersion: v2
      appVersion: latest
      created: "2025-10-08T19:24:30.5331638+05:30"
      description: A Helm chart for installing http-echo web-server that echos back
        a message
      digest: c84936256635c31effa04a7645e7df7caaa5f350870c08d92572c78363e4adea
      name: my-foo-app
      type: application
      urls:
      - https://yourusername.github.io/helm-repo/my-foo-app-1.0.0.tgz
      version: 1.0.0
  generated: "2025-10-08T19:24:30.5161726+05:30"
  ```
- Simply push the contents of **my-helm-repo** to GitHub. After that, enable GitHub Pages for that repository. Under **Source**, select the `main` branch and `/ (root)` folder and click on **Save**.

  It is important as Helm expects a public web server (like GitHub Pages) that serves our packaged charts and index.yaml file at plain HTTPS URLs.

- Now, we can use these charts using the GitHub Pages URL:
  ```bash
  helm repo add myrepo https://yourusername.github.io/helm-repo/
  helm search repo myrepo --versions
  helm install foo myrepo/my-foo-app
  ```

### Updating an existing chart

- Suppose, we update the **message** in `values.yaml` our **my-bar-app** application as follows:

  ```yaml
  image:
   repository: hashicorp/http-echo
   # This sets the pull policy for images.
   pullPolicy: IfNotPresent
   # Overrides the image tag whose default is the chart appVersion.
   tag: latest
  containerPort: 5000
  message: Hello from New Bar Service
  ```
- Update the **version** in `Chart.yaml` 
  ```yaml
  apiVersion: v2
  appVersion: latest
  description: A Helm chart for installing http-echo web-server that echos back a message
  name: my-bar-app
  type: application
  version: 1.0.1
  ```
- Again package **my-bar-app** and keep the archive in **my-helm-repo**

  ```bash
  helm package my-bar-app/ -d my-helm-repo/
  ```

- List the contents of `my-helm-repo`

  ```bash
  controlplane:~$ ls -l my-helm-repo/
  total 8
  -rw-r--r-- 1 root root 869 Oct  8 10:55 my-bar-app-1.0.1.tgz
  -rw-r--r-- 1 root root 848 Oct  8 09:55 my-bar-app-1.0.0.tgz
  -rw-r--r-- 1 root root 849 Oct  8 09:53 my-foo-app-1.0.0.tgz
  ```

- Now, create the `index.yaml` again to include the new version.
  ```bash
  helm repo index ./my-helm-repo --url https://stevesayantan.github.io/helm-repo --merge ./my-helm-repo/index.yaml
  ```

- Updated `index.yaml` looks like:

  ```yaml
  apiVersion: v1
  entries:
    my-bar-app:
    - apiVersion: v2
      [...]
      urls:
      - https://stevesayantan.github.io/helm-repo/my-bar-app-1.0.1.tgz
      version: 1.0.1
    - apiVersion: v2
      [...]
      version: 1.0.0
    my-foo-app:
      [...]
  ```
- Commit and push the changes.

- Update the helm repo.
  ```bash
  helm repo update myrepo
  ```
- List all the versions
  ```bash
  controlplane:~$ helm search repo --versions
  NAME                    CHART VERSION   APP VERSION     DESCRIPTION                                       
  myrepo/my-bar-app       1.0.1           latest          A Helm chart for installing http-echo web-serve...
  myrepo/my-bar-app       1.0.0           latest          A Helm chart for installing http-echo web-serve...
  myrepo/my-foo-app       1.0.0           latest          A Helm chart for installing http-echo web-serve...
  ```