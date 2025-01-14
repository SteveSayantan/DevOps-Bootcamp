- The entire nginx configuration follows a tree-like / hierarchical structure.

- Each context has its specific settings which can be overwritten in the child context.

- We have **main** context which is the outermost one. The directives present outside any context in `/etc/nginx/nginx.conf` belong to the **main** context. We have the followings in it:

  ```
  main context
    ├── no. of worker processes to run
    ├── user to run the nginx process
    ├── info. about PID
    ├── error log location
    ├── event context
    │   ├── No. of connections per worker process
    │   └── ...
    ├── stream context
    │   ├── TCP/UDP settings
    │   └── ...
    └── http context
        ├── access-log location (for incoming req)
        ├── server context (multiple may exist)
        │   └── location context
        └── upstream context (used for reverse proxy,loadbalancing etc.)
  ```
- Generally, Nginx creates one master process and multiple worker processes.
- Virtual Server: We can host multiple domains from one physical server using multiple server blocks in NGINX config . This feature is called virtual server.

- It is recommended to keep `/etc/nginx/nginx.conf` (contains main, http and event contexts, generally) intact. So, we put our custom configuration files (containing server and upstream context, generally) inside `/etc/nginx/conf.d/` and attach those at the end of **http** context in `/etc/nginx/nginx.conf` using *include* directive.

- In some distros like Ubuntu, there are folders like **modules-enabled**, **site-enabled** for holding config files, but we would stick to the above approach.
  - Hence, we can remove the following lines from `/etc/nginx/nginx.conf` .

    ```nginx
    include /etc/nginx/modules-enabled/*.conf;

    include /etc/nginx/sites-enabled/*;
    ```

- config files are named as follows:
  - cafe.codersgyan.com.conf
  - cornhub.com.conf
    