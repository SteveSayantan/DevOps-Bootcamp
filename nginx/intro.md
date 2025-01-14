**Nginx** is an open-source, high-performance web server. Originally designed to handle high concurrency, it's known for its event-driven, non-blocking architecture, making it ideal for high-traffic websites.
- **Web Server**: Nginx serves static content (like HTML, CSS, JavaScript) and handles HTTP requests efficiently.
- **Reverse Proxy**: It forwards client requests to backend servers (e.g., Node.js, Python) and returns the response, enhancing security and performance.
- **Load Balancer**: Nginx distributes traffic across multiple servers to optimize resource use and prevent overload.
- **HTTP Cache**: It can cache responses from backend servers to speed up content delivery for repeated requests.

By default, nginx listens to port 80 for http requests.

Static files are served from `/var/www/html` directory.
Important configurations are stored in `/etc/nginx` directory.

### Useful Commands

- `sudo apt install nginx` : To install nginx.
- `sudo systemctl status nginx` : To check the status of nginx service.
- `nginx` : To start nginx service.
- `sudo nginx -t` : Test the Nginx configuration for syntax errors
- `sudo nginx -T` : To  display the entire Nginx configuration (including all included configuration files) in the terminal, along with validating the syntax of the configuration.
- `nginx -s reload` : To reload the server w/o stopping the Nginx service to reflect the changes made to Nginx configuration files.
- `nginx -s quit` : To stop nginx processes with waiting for the worker processes to finish serving current requests.


### Important References

- [Nginx HTTP core module](https://nginx.org/en/docs/http/ngx_http_core_module.html)
- [How nginx processes a request](https://nginx.org/en/docs/http/request_processing.html)

- [NGINX as a WebSocket Proxy](https://www.f5.com/company/blog/nginx/websocket-nginx)

- [Using Free Let’s Encrypt SSL/TLS Certificates with NGINX](https://www.f5.com/company/blog/nginx/using-free-ssltls-certificates-from-lets-encrypt-with-nginx)

- [Setup SSL in Nginx on Ubuntu by ChaiCode](https://docs.chaicode.com/ssl-in-nginx-ubuntu/)

### Terminologies

`/etc/nginx/nginx.conf` is the entry-point for nginx.

An Nginx configuration file contains a set of key-value pairs, with some key-value pairs residing inside a block. 

- Each key-value pair is called a **directive**. E.g.,

  ```nginx
  include /etc/nginx/modules-enabled/*.conf; 
  ```
- Each block is called a **context**. Each context contains directives specific to it. E.g.,

  ```nginx
    http{   # this block is a context
        ...
    }
  ```

### Static Folder Structure
```
/var/www/
└── mysite/
    ├── index.html
    ├── styles.css
    ├── fruits/
    │   ├── apple.png
    │   └── fruit-list.html
    └── vegetables/
        └── potato.html
```
### Serving a simple HTML file

- The **listen** directive in Nginx is used to specify the port number on which the server will accept incoming connections. 
  - Optionally, we can also specify the IP address if our server has multiple IP addresses, and we want to bind Nginx to a specific one.

- Inside the **server** context, we can set the name of the virtual server with **server_name** directive. It defines the domain names or hostnames that this particular server block will respond to. Its default value is `""` (empty string). The *Host* header field ( **that specifies the host and port number of the server to which the request is being sent** ) of the request against the **server_name** entries of the server are checked. If the server name is not found, the request will be processed by the default server.

  - As we haven't mentioned any **server_name**, Nginx fails to find a server block, hence serves the request using the default server (i.e. this one itself,as there's only one server block).

```nginx
# /etc/nginx/conf.d/test.nginx.conf

server{
    listen 80 ;  
    root /var/www/mysite;   # path to the directory containing our static files. 
    # This directory must have executable permission for others
}

```
Test the configuration for syntax errors and reload the server if it is already running.

### Serving an HTML page with CSS

First, we need to link the CSS file to the HTML file. Now, if we reload the server, it would serve the css file but the browser would not be able to parse it because of incorrect mime-type in 'Content-Type' header of the response.

So, we have to specify the mime-type for different files as follows:

```nginx
# /etc/nginx/conf.d/test.nginx.conf
types{
    text/html   html;
    text/css    css;    
}

server{
    ...
}    

```
However, this way of adding mime-types is not practical. To solve this, Nginx comes with a list of default mime-types that we can use instead:

```nginx
# /etc/nginx/conf.d/test.nginx.conf

include mime.types;     # this mime.types file is located inside /etc/nginx itself.

server{
    ...
}

```
However, **mime.types** is already included in /etc/nginx/nginx.conf file.

### Adding routes (Location context)
In Nginx, the location context is used to define how Nginx should process requests based on the URI (Uniform Resource Identifier) of the incoming request. Nginx matches the incoming URI against the location blocks in a particular order.

In a nutshell, it allows us to serve different html files for different endpoints. Refer to the HTTP module of the docs for details.

```nginx
# /etc/nginx/conf.d/test.nginx.conf
   
server{
    listen 80;
    
    location / {
        # root directive sets the root directory for requests. File is served from the path created by
        # appending the incoming URI to the value of the root directive

        root /var/www/mysite;   # The `/var/www/mysite/index.html` file will be sent in response to the “/index.html” (or, "/") request.
    }

    location /fruits {

        root /var/www/mysite;  # for this request, nginx will search this directory.
        index fruit-list.html;  #  Telling nginx that the `/var/www/mysite/fruits/fruit-list.html` file will be sent in response to "/fruits".
        # since, no index.html is present, "/fruits/index.html" will cause a 404 error.
    }
}

```
We can use the **alias** directive to define a replacement for the specified location.

```nginx
# /etc/nginx/conf.d/test.nginx.conf
   
server{
    ...
    location /nutritious-fruits {

        alias /var/www/mysite/fruits;  
        
        index fruit-list.html;      # since, index.html is not present in /var/www/mysite/fruits, so we need to set the index.

        # on request of `/nutritious-fruits/apple.png`, the file '/var/www/mysite/fruits/apple.png' will be sent.
        
        # on request of `/nutritious-fruits`, the file '/var/www/mysite/fruits/fruit-list.html' will be sent.

        # i.e. we don't need to have a separate directory as previous case. Basically, we are using the contents of `/fruits` route for `/nutritious-fruits` as well.
    }
}

```

### try_files Directive
It checks the existence of files in the specified order and uses the first found file for request processing. It's typically used for handling errors, fallback scenarios.

```nginx
# /etc/nginx/conf.d/test.nginx.conf

server{
    listen 80;

    ...

    location /vegetables{

        root /var/www/mysite;

        # The path to a file is constructed appending the file mentioned to the root directive
        try_files $uri $uri/ /vegetables/veggies.html /vegetables/potato.html =404;

        # For any incoming request (say, /vegetables/hello), nginx will search

            # 1. if a static file "/var/www/mysite/vegetables/hello" exists. Otherwise,

            # 2. if the directory "/var/www/mysite/vegetables/hello/" exists (to serve a default file, such as index.html, within that directory). Otherwise,
            
            # 3. if the "/var/www/mysite/vegetables/veggies.html" file exists. Otherwise,

            # 4. if "/var/www/mysite/vegetables/potato.html" exists. If no file is found, we would get a 404 response.
    }
}

```

### Regular Expressions

We need to use ~ or ~* when defining a regular expression location block.

- `~`: Indicates a case-sensitive regular expression.
- `~*`: Indicates a case-insensitive regular expression.

```nginx
# /etc/nginx/conf.d/test.nginx.conf
server{
    listen 80;
    ...
    location ~* /count/[0-9] {
        return 301 /;

        # on request of `/count/2` or `/count/4` or `/count/345` , the user will be redirected.

        # `/count/345` matches because nginx only needs to match a digit after count, it does not care about the rest.
    }
}

```

### How Maching is Done
Nginx matches the incoming URI against the `location` blocks in a particular order.

##### Matching Process:
1. Nginx first tries to match **exact locations** (`=`). This matches the exact URI and takes priority over other matches.
1. Then it looks for the **longest prefix** match (`/`).
1. If no prefix matches, it checks **regular expressions** (`~`, `~*`).
1. Finally, if no match is found, the default **catch-all** location (`/`) is applied. Incoming URIs that don’t match any specific locations will hit this block.

##### Example Combined Configuration:

```nginx
server {
    location = / {
        return 200 "Exact Root Match\n";
    }

    location /images/ {
        return 200 "Images Folder\n";
    }

    location ~ \.php$ {
        return 200 "PHP File\n";
    }

    location / {
        return 200 "Default Location\n";
    }
}
```

- `/` matches the exact root URI.
- `/images/logo.png` matches the `/images/` prefix.
- `/about.php` matches the regex for PHP files.
- Anything else, like `/blog`, hits the default `/` location.



In Nginx, the `^~` modifier is used to tell Nginx to give **priority** to a prefix match over any regular expression matches.

### Purpose of `^~`:
- It ensures that if a prefix match is found with `^~`, **regular expression** location blocks will be skipped, even if they might also match the incoming URI.
- This is useful when you have a prefix match that you want to apply **before any regex matches**, ensuring that regex blocks are not processed unnecessarily.

#### Example:
```nginx
server {
    location ^~ /images/ {
        return 200 "Prefix match for /images/ with ^~\n";
    }

    location ~* \.(jpg|png)$ {
        return 200 "Regex match for images\n";
    }

    location / {
        return 200 "Default catch-all\n";
    }
}
```

#### How Nginx Processes the Request:

- For an incoming URI like `/images/photo.jpg`:
  - **`/images/`** with `^~` is the longest prefix match and has priority over any regex matches.
  - Even though `/photo.jpg` would also match the regular expression `~* \.(jpg|png)$`, Nginx will **not** check regex locations after it finds the `^~` match.
  - Nginx will use the `/images/` block and return:
    ```
    Prefix match for /images/ with ^~
    ```

- For an incoming URI like `/gallery/photo.jpg`:
  - No `^~` match is found because the prefix `/gallery/` doesn’t match `/images/`.
  - Nginx proceeds to check regex locations. The URI matches `~* \.(jpg|png)$`, and it will use that location.







