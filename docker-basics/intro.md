## WHY
Imagine we're developing a killer web app that has three main components - a React frontend, a Python API, and a PostgreSQL database. If we wanted to work on this project, we'd have to install Node, Python, and PostgreSQL.

How do we make sure we have the same versions as the other developers on your team or the production?

How do we ensure the version of Python (or Node or the database) your app needs isn't affected by what's already on your machine? How do we manage potential conflicts?

The solution is containers. For any details, head over to the [docs](https://docs.docker.com/).

## WHAT

Simply put, containers are isolated processes for each of your app's components. Each component - the frontend React app, the Python API engine, and the database - runs in its own isolated environment, completely isolated from everything else on your machine.

Here's what makes them awesome. Containers are:

- Self-contained: Each container has everything it needs to function with no reliance on any pre-installed dependencies on the host machine.

- Isolated: Since containers are run in isolation, they have minimal influence on the host and other containers, increasing the security of your applications.

- Independent: Each container is independently managed. Deleting one container won't affect any others.

- Portable: Containers can run anywhere! The container that runs on your development machine will work the same way in a data center or anywhere in the cloud!


## Containers vs VMs

Virtual machines (VMs) are an abstraction of physical hardware turning one server into many servers, with the help of hypervisor. They contain entire operating system with its own kernel, hardware drivers, binaries and applications. Spinning up a VM only to isolate a single application is a lot of overhead.

Containers are an abstraction at the app layer that packages code and dependencies together. Multiple containers can run on the same machine and share the host OS kernel with other containers, each running as isolated processes in user space. Thereby allowing you to run more applications on less infrastructure.

We can also run containers on physical servers with an OS. But, containers and VMs used together provide a great deal of flexibility in deploying and managing app.

![container vs vm](../assets/container&vm.png)


## Why are containers light-weight?
An operating system consists of two separate layers: the Kernel (the core) and the User Space (the files and tools).

- Kernel handles memory, CPU scheduling, I/O, and networking.
- The User Space includes the files and tools e.g. package managers (apt, yum), commands (ls, cd, bash) and libraries (glibc, openssl) etc.

Containers are lightweight because they do not package the kernel inside them. Rather, they share the host operating system's kernel while still providing isolation for the application and its dependencies inside the container from processes or resources outside the container. This results in a smaller footprint compared to traditional virtual machines, as the containers do not need to include a full operating system. Additionally, Docker containers are designed to be minimal, only including what is necessary for the application to run, further reducing their size. VMs, on the other hand, emulate an entire operating system with dedicated kernel, including all its libraries, utilities, and system files, resulting in a much larger size.

**What's Not Shared**
- User-space components like system libraries, utilities, and shell tools.
- Application dependencies (e.g., Python, Node.js, Java runtimes).
- Our application code itself.

Each container packages just enough of these components to run the application reliably, without affecting other containers or the host system.

> Docker uses a Linux kernel feature called **chroot (change root)** along with **namespaces**. It locks the containerized application inside that specific folder structure. As a result, the containerized bash shell can only see `/bin/ls` inside its designated folder. It cannot see the host's actual files.

#### CGroup and Namespace
- Namespaces: Docker containers use Linux namespaces to create isolated environments for the container's processes. Namespaces provide isolation for resources such as the file system, process ID, and network.

- Control groups (cgroups): Docker containers use cgroups to limit and control the amount of resources, such as CPU, memory, and I/O, that a container can access.

> The host's kernel handles system calls from the container, which is how the container accesses the host's resources, such as CPU, memory, and I/O.

> Docker containers can access (explicitly) the host file system using bind mounts, which allow the container to read and write files in the host file system.

## Containerization vs Virtualization

### Virtualization
- Virtualization allows you to split a physical server into several virtual machines (VMs), each acting like a separate computer with its operating system, applications and allocated resources e.g. memory, processing power, storage, network.

- Each virtual machine is isolated from the others.

- This allows you to optimize resource utilization, improve scalability by easily adding, configuring, removing virtual machines as needed.

- The hypervisor is a software component that manages multiple virtual machines in a computer. It ensures that each virtual machine gets the allocated resources and does not interfere with the operation of other virtual machines. There are two types of hypervisors.
  - A type 1 hypervisor, or bare-metal hypervisor, is a hypervisor program installed directly on the computer’s hardware instead of the operating system. Therefore, type 1 hypervisors have better performance, e.g., **Microsoft Hyper-V**

  - Also known as a hosted hypervisor, the type 2 hypervisor is installed on an operating system. Type 2 hypervisors are suitable for end-user computing, e.g., **Oracle VirtualBox**

### Containerization
- Containerization involves bundling an application’s code with all the files and libraries it needs to run on any infrastructure. Containers abstracts the host operating system.

- Each container shares the same operating system kernel but is isolated from other containers.

- A host can support many containers concurrently.

- Containers use a container engine or container runtime. This is software that acts as an intermediary agent between the containers and the operating system, providing and managing system resources that the application needs. Docker is the most popular open-source container engine.

## Architectural Overview

![docker_components](../assets/docker_components.png)

- Runtime: It allows to start and stop containers. It has two layers:

  - runc : Works with OS, starts and stops containers, handles low-level operation.

  - containerd : Manages high-level stuff e.g. pulling data from network.

- Engine: Docker Engine is an open source containerization technology for building and containerizing our applications.

- Orchestration: Used to manage containers.

### Client-Server Mechanism

![docker_client-server](../assets/docker_arch.JPG)

Docker Engine uses a client-server architecture consisting of:

- Docker daemon (**dockerd**): This long-running daemon process listens to the API requests being made through the Docker client, creates,manages Docker objects such as images, containers, networks, and volumes.

- Docker client (**docker**): This is a CLI tool we use to interact with Docker. When we run a command using docker, the client sends the command to the daemon which does the heavy lifting of building, running, and distributing your Docker containers. The Docker client can communicate with more than one daemon.

The Docker client talks to the Docker daemon process using Docker APIs which specify interfaces that programs can use to talk to and instruct the Docker daemon.

## Images

To share our application with someone else, we can simply create a Dockerfile. It describes steps to create a Docker image. These images can be used to create containers in any environment. These images can also be stored online at Docker Hub.

When we run docker image you get docker containers. The container will have the application with all its dependencies.

## Registry and Repository
An image registry is a centralized location to store Docker images. It can be either public or private. Docker Hub is a public registry that anyone can use. When you pull an image, Docker by default looks for it in the public registry and saves the image on your local system. You can also store images on your local machine or push them to the public registry.

A repository is a collection of related container images within a registry. Think of it as a folder where you organize your images based on projects. Each repository contains one or more container images.

![registry_vs_repository](../assets/registry-vs-repository.JPG)

## Open Container Initiative
There are many container runtimes e.g. **containerd**, **runc**, **rkt**, **lxc**, **cri-o** etc. The Open Container Initiative (OCI) is a Linux Foundation project to design open standards for containers.

OCI currently contains two specifications: 
- the Runtime Specification (defines how to run the OCI image bundle as a container) 

- the Image Specification (defines how to create an OCI Image, which includes an image manifest, a filesystem (layer) serialization, and an image configuration).

- Refer to [this article](https://medium.com/@avijitsarkar123/docker-and-oci-runtimes-a9c23a5646d6), for more info.

## Resources
- [How Containers Work](https://k8studio.io/tutorials/container-architecture-namespaces-cgroups-overlayfs/)
- [Introduction to Linux containers](https://sergioprado.blog/introduction-linux-containers/)
- [How Docker Works Under the Hood with the Linux Kernel](https://medium.com/@nimetha.21/how-docker-works-under-the-hood-with-the-linux-kernel-17026e5c70b7)
