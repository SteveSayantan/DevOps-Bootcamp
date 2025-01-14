## HTTP authentication
HTTP provides a general framework for access control and authentication. The idea is that the a server would challenge a client request, and then the client would provide authentication information. For details, click [here](https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication).

The challenge and response flow works like this:

- The server responds to a client with a 401 (Unauthorized) response status and provides a **WWW-Authenticate** response header containing at least one challenge (authentication procedure). 

- A client that wants to authenticate itself with the server can then do so by including an **Authorization** request header with the credentials.

On receiving the **WWW-Authenticate** header in response, usually a client will present a password prompt to the user. Then, the client will issue the request again including the correct Authorization header.

### Basic Authentication
There are several types of authentication methods (aka challenges) supported by **WWW-Authenticate** header, read about [them](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/WWW-Authenticate).

We shall focus on Basic Authentication method. Read about it [here](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/WWW-Authenticate#basic_authentication).

In short, the workflow will look like:

- The server would send a **WWW-Authenticate** header in the response which looks like `WWW-Authenticate: Basic realm="Some description"` (*realm* is just a string describing a protected area).

- Receving this response, a browser receiving this header would first prompt the user for their username and password, and then re-request the resource: this time including the (encoded) credentials in the **Authorization** header. 
  - For "Basic" authentication the credentials are constructed by first combining the username and the password with a colon (aladdin:opensesame), and then by encoding the resulting string in base64.
  - e.g., the Authorization header might look like this: `Authorization: Basic YWxhZGRpbjpvcGVuc2VzYW1l`.


## Implementation in nginx
Now, we shall implement "Basic" authentication in our nginx server, i.e. if a request does not have the *Authorization* header, nginx will send a 401 response along with a **WWW-Authenticate** header. So that, the browser will prompt the user for their username and password, and then re-request nginx with *Authorization* header.

We shall use two directives from [ngx_http_auth_basic_module](https://nginx.org/en/docs/http/ngx_http_auth_basic_module.html#auth_basic),

- **auth-basic** : The specified parameter is used as a *realm*. 

- **auth_basic_user_file**: Specifies a `.htpasswd` file that stores user names and passwords, in **name:password** format. But the *password* has to be encrypted before it is stored. 

Our configuration file looks like:
```nginx
# /etc/nginx/basic-auth.conf

server{
        listen 80;

        root /var/www/html;

        index index.html index.htm;

        auth_basic "Website under development";
        auth_basic_user_file /etc/nginx/.htpasswd;

        location / {
                auth_basic off;
                try_files $uri $uri/ = 404;
        }

        location /auth {
                try_files $uri $uri/ =404;
        }
}
```
- Now, we need to add the credentials of the users in the `/etc/nginx/.htpasswd` file. To get an encrypted password we use the *openssl* tool.
  - `openssl passwd -apr1`: This command prompts for a password in the cli and returns the encrypted form of it. **-apr1** is the algorithm for encryption.

  - To add the credentials of the first user, run
    ```bash
    echo -n "user1:`openssl passwd -apr1`">>/etc/nginx/.htpasswd
    ```
    **-n** flag removes the trailing newline.

  - To add the credentials of the subsequent users, run
    ```bash
    echo -ne "\nuser2:`openssl passwd -apr1`">>/etc/nginx/.htpasswd
    ```  
    **\n** ensures the subsequent credentials are added in a new line. **-e** flag interprets \n as a newline character. When using **-e** flag, we need to use double quotes.

  - switch to the root user with `sudo su` to avoid permission issues.

  - Now, `/etc/nginx/.htpasswd` file looks like,
    ```
    user1:$apr1$D7cays6T$DdimziR0/LhQYuZq91p991
    user2:$apr1$NY8FX2l1$RckKiptchceITv7dqQGsG0
    ```
- reload nginx to see the effects.