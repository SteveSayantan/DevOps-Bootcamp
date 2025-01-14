### WHAT
Usually, when we create a Dockerfile from a base image (say Ubuntu), our images contain a lot of system libraries and files those are not required to run our app. 

However, these extra files and libraries are required to download our dependencies or build our app.

To handle this issue, docker has introduced **Multi-stage builds** where the Dockerfile is divided into multiple parts.

### HOW
- In the first stage, we choose a rich base image and install all our dependencies effortlessly.

- In the second stage, we copy only the installed dependencies and execute those using a very minimalistic base image.

We can have multiple stages as per our requirement.

As a result, we can separate the build process from the runtime environment, resulting in a smaller image size that only includes the dependencies and libraries required to run our application.

In multi-stage builds, until we selectively copy something, nothing will be added to the resultant docker image from the previous stages. Only the final stage is added by default.

Because, in multi-stage Dockerfile, the final stage is the default target for building. This means that if we don't explicitly specify a target stage using the **--target** flag in the docker build command, Docker will automatically build the last stage by default. We could use the **--target** flag to build one of the previous stages.

### Distroless Images

It is a very minimalistic and light-weight docker image that only contains the dependencies needed to run a specific application, such as runtime libraries and the application binary itself. e.g., a Python Distroless image only contains Python runtime that is sufficient to run the app.

So when we use distroless images, we are free from the os related vulnerabilities that comes with any distro.

### Resources

- Multi-stage build [docs](https://docs.docker.com/build/building/multi-stage/) 

- Find distroless images [here](https://github.com/GoogleContainerTools/distroless)

### Example 1
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

### Example 2

```dockerfile
# syntax=docker/dockerfile:1.4

# 1. For build React app
FROM node:lts AS development

# Set working directory
WORKDIR /app


COPY package.json /app/package.json
COPY package-lock.json /app/package-lock.json

# Same as npm install
RUN npm ci

COPY . /app

ENV CI=true
ENV PORT=3000

# this CMD instruction will not be executed in the container made of the final image
CMD [ "npm", "start" ]   # unless, we use "--target development" flag in the build command.

FROM development AS build

RUN npm run build

# 2. For Nginx setup
FROM nginx:alpine

# Copy config nginx
COPY --from=build /app/.nginx/nginx.conf /etc/nginx/conf.d/default.conf

WORKDIR /usr/share/nginx/html

# Remove default nginx static assets
RUN rm -rf ./*

# Copy static assets from builder stage
COPY --from=build /app/build .

# Containers run nginx with global directives and daemon off
ENTRYPOINT ["nginx", "-g", "daemon off;"]

```