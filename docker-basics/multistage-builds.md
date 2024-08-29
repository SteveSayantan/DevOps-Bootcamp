### WHAT
Usually, when we create a Dockerfile from a base image (say Ubuntu), our images contain a lot of system libraries and files those are not required to run our app. 

However, these extra files and libraries are required to download our dependencies or build our app.

To handle this issue, docker has introduced **Multi-stage builds** where the Dockerfile is divided into multiple parts.

### HOW
- In the first stage, we choose a rich base image and install all our dependencies effortlessly.

- In the second stage, we copy only the installed dependencies and execute those using a very minimalistic base image.

We can have multiple stages as per our requirement.

As a result, we can separate the build process from the runtime environment, resulting in a smaller image size that only includes the dependencies and libraries required to run our application.

In multi-stage, the build stages of Dockefile size, will not be added to the docker image, only the final stage, where we pass certain commands to run our application with a specific runtime is added.

### Distroless Images

It is a very minimalistic and light-weight docker image that only contains the dependencies needed to run a specific application, such as runtime libraries and the application binary itself. e.g., a Python Distroless image only contains Python runtime that is sufficient to run the app.

So when we use distroless images, we are free from the os related vulnerabilities that comes with any distro.

### Resources

- Multi-stage build [docs](https://docs.docker.com/build/building/multi-stage/) 

- Find distroless images [here](https://github.com/GoogleContainerTools/distroless)

### Example
The following example demonstrates a multi-staged build for a GO app:

```dockerfile
#########################
# BASE IMAGE
########################

FROM ubuntu AS build  # we give an alias to this stage using AS

RUN apt-get update && apt-get install -y golang-go

ENV GO111MODULE=off

COPY . .

RUN CGO_ENABLED=0 go build -o /app .

############################################
# HERE STARTS THE MAGIC OF MULTI STAGE BUILD
############################################

FROM scratch  # scratch is the minimalistic distroless image till date  

# Copy the compiled binary from the build stage
COPY --from=build /app /app

# Set the entrypoint for the container to run the binary
ENTRYPOINT ["/app"]

```