### WHAT
docker compose is a tool by Docker Inc . It is used to manage multi-container apps.

### WHY
The applications that can be set up in one container, can be easily handled as only one Dockerfile is present. 

But in real-life applications, there are multiple micro-services are involved and each of them is setup in a separate container. E.g., an application could use one container for database, one for caching, one for payment, one for load-balancing etc. We need to manage networks, all of the flags needed to connect containers to those networks, the internal dependencies among them, e.g., the payment application can only run only when the DB is running etc. Also, the cleanup is more complicated. 

In such cases, running `docker run` for each container while considering the above points can be troublesome for a large project.

Using docker compose we can do these very easily only using two commands `docker-compose up` and `docker-compose down`. It a declarative tool - we simply define it and go. Compose simplifies the control of your entire application stack, making it easy to manage services, networks, and volumes in a single, comprehensible YAML configuration file. Then, with a single command, you create and start all the services from your configuration file.

For details, check out the [docs](https://docs.docker.com/compose/)

### HOW
For using docker compose, we need to still write Dockerfiles. Additionally, we create a YAML file (**compose.yaml**) that builds and runs our containers using our Dockerfiles (or sometimes from images).

Each container for a service joins the default network created by Compose and is both reachable by other containers on that network, and discoverable by the service's name.


For examples of docker-compose, checkout [this](https://github.com/docker/awesome-compose)

### USECASES
The following are some common usecases of docker compose:

- Makes local development easier
- For setting up CI/CD at local level
- For testing some changes quickly


