## Docker CLI
Let's break down the command `docker run hello-world`,

- **docker** : It refers to the docker cli. It connects to the docker daemon.
- **run** image_name: this command is used to run an image to create a new container.
- **hello-world** : It is the name of the image.

If the **hello-world** image is not present in our local, docker daemon downloads it from online (e.g. Docker Hub). Then it creates a new container from the image and executes it. The output of the container is sent to us via docker-cli by daemon.

If the image is already present, then daemon directly creates the container from that image and executes it.

![flow](../assets/docker-flow.png)

## Dockerfile
A Dockerfile is a text-based document that's used to create a container image. It provides instructions to the image builder on the commands to run, files to copy, startup command, and more.

## Docker Image
A Docker Image that is a standardized package, contains a smaller version of Operating System and all binaries, config files, and other dependencies of our app. Images are built in layers. Each image is immutable, we can only add changes on top of it or create a new image.

Each layer is immutable as well. Each layer in an image contains a set of filesystem changes - additions, deletions, or modifications. Layers receive an ID, calculated via a SHA 256 hash of the layer contents. Layers can be reused between images, i.e. if any layer of an image is already present in the local system, it is not downloaded.

#### Caching
When you run the docker build command to create a new image, Docker executes each instruction in your Dockerfile, creating a layer for each command and in the order specified. 

Subsequent builds after the initial are faster due to the caching mechanism, as long as the commands and context remain unchanged. Docker caches the intermediate layers generated during the build process. When you rebuild the image without making any changes to the Dockerfile or the source code, Docker can reuse the cached layers, significantly speeding up the build process.

Here are a few examples of situations that can cause cache to be invalidated:

- Any changes to the command of a RUN instruction invalidates that layer. Docker detects the change and invalidates the build cache if there's any modification to a RUN command in your Dockerfile.

- Any changes to files copied into the image with the COPY or ADD instructions. Docker keeps an eye on any alterations to files within our project directory. Whether it's a change in content or properties like permissions, Docker considers these modifications as triggers to invalidate the cache.

- Once one layer is invalidated, all following layers are also invalidated. If any previous layer, including the base image or intermediary layers, has been invalidated due to changes, Docker ensures that subsequent layers relying on it are also invalidated. This keeps the build process synchronized and prevents inconsistencies.