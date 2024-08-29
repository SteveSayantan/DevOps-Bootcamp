## Docker CLI
Let's break down the command `docker run hello-world`,

- **docker** : It refers to the docker cli. It connects to the docker daemon.
- **run** image_name: this command is used to run an image to create a new container.
- **hello-world** : It is the name of the image.

If the **hello-world** image is not present in our local, docker daemon downloads it from online (e.g. Docker Hub). Then it creates a new container from the image and executes it. The output of the container is sent to us via docker-cli by daemon.

If the image is already present, then daemon directly creates the container from that image and executes it.

![flow](../assets/docker-flow.png)

## Docker Image

Docker Images contain a smaller version of Operating System and all the dependecies of our app. Images are built in layers. Each layer is immutable and a collection of files and directories.

Layers receive an ID, calculated via a SHA 256 hash of the layer contents. Thus, if the layer contents change the SHA 256 hash changes as well. If any layer of an image is already present in the local system, it is not downloaded. 