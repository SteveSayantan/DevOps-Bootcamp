1. `docker run image_name` : creates a new container, pulling the image if needed. Use `--name` flag to assign a name e.g. `docker run --name test node` . Use `-d` flag to run container in background and print container ID.

1. `docker run ubuntu echo Hey` : After creating the container, run *echo Hey* in it. 

1. `docker run -p 127.0.0.1:80:8080/tcp nginx:alpine` : Creates a new container from the image (i.e. **nginx:alpine** ) and binds port 8080 of the container to TCP port 80 on 127.0.0.1 of the host. You can also specify udp and sctp ports. Not specifying an IP address  (i.e., `-p 80:80` instead of `-p 127.0.0.1:80:80`), makes Docker publish the port on all interface (address `0.0.0.0`).

1. `docker container ls` : shows all the container running currently. To see all containers, use `-a` flag.

1. `docker ps` : shows all the container running currently. To see all containers, use `-a` flag.

1. `docker images` : shows all the images present in the local system.

1. `docker pull image_name:tag` : pulls the image with the specified tag from docker hub, e.g. `docker pull ubuntu:16.04`. The default value of tag is *latest* . 

1. `docker run -it image_name:tag` : runs the new container created from the image with an interactive terminal attached to it, thereby stopping the container from exiting immediately after creation. We can optionally specify the tag as `docker run -it ubuntu:16.04` . The default value of tag is *latest* .

1. `docker container exec -it container_id bash` : executes the command *bash* in a running container having id *container_id*. `-it` flag attaches an interactive terminal to it. This command fails if the container isn't running.

1. `docker stop container1_id container2_id ...` : To stop one or more running containers. We can also use the assigned name instead of container id. 

1. `docker rm container1_id container2_id ...` : To remove one or more container. We can also use the assigned name instead of container id.

1. `docker start container1_id container2_id ...` : To start one or more stopped containers. We can also use the assigned name instead of container id. 

1. `docker container inspect container1_id container2_id ...` : To display info on one or more containers. We can also use the assigned name instead of container id.

1. `docker logs container_id` : To fetch the logs of a container. We can also use the assigned name instead of container id. `docker logs --since 5s container_id` shows the logs of the last 5s.

1. `docker container prune` : To remove all stopped containers. Use `-f` flag to avoid prompt.

1. `docker rmi image1_name image2_name ...` : To remove one or more images from the host.

1. `docker commit -m "commit message" container_id new_image_name:tag` : Creates a new image with the given name from the changes done in the container. We can also optionally provide a tag. To run the newly created image, we use `docker run new_image_name:tag`.

1. `docker build -t username/repo_name:tag path` : Starts building an image with the name *username/repo_name*, using the dockerfile present at *path* .We can also optionally provide a tag (defaults as *latest* ). `username` refers to the one associated with dockerhub, `repo_name` refers to the remote repo on dockerhub, where the image will be uploaded. Optionally, we can use `--no-cache` flag with this to invalidate the cache for RUN instruction in dockerfile.




