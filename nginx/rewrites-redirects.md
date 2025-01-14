## Rewrite
A rewrite changes the URI of a request internally without informing the client (browser). It allows you to modify the request URL on the server-side.

```nginx

location /blog {
    rewrite ^/blog/(.*)$ /articles/$1 break;    # The (.*) part captures everything after /blog/, and stores it in a variable $1. 
    
    # Without the "()", '.*' will only match but it doesn't capture that part of the string for further use.

}

```
- If a user requests /blog/post1, Nginx internally rewrites it to /articles/post1, serving content from the /articles/ directory instead.

- break: Stops processing and uses the rewritten URI in the same location block.

### last and break flags

In Nginx, the `last` and `break` flags are used in **rewrite** rules to control how Nginx processes the request after applying the rewrite. They determine whether Nginx should continue looking for more matching location blocks or stop further processing. Here’s a simple breakdown:

1. **`last` Flag**

- The `last` flag tells Nginx to **stop rewriting** the URI and reprocess the request using the newly rewritten URI. Nginx will look for a new matching location block based on the rewritten URI.
  
#### Example:

```nginx

server {
    listen 80;

    location /blog {
        rewrite ^/blog/(.*)$ /articles/$1 last;    
    }

    location /articles {
        root /var/www/mysite;
        index index.html;
    }
}
```
- **Request**: `http://example.com/blog/post1`

- **What happens**: 
  - The URI `/blog/post1` is rewritten to `/articles/post1` because of the `rewrite` rule.
  - The `last` flag tells Nginx to stop rewriting and **reprocess** the new URI `/articles/post1` by searching for a new matching location block.
  - Nginx will now look for the `location /articles` block to serve the file.

2. **`break` Flag**

- The `break` flag tells Nginx to stop rewriting the URI **and process the request using the current location block**. It will **not** look for any new location blocks after the rewrite.

#### Example:
```nginx
server {
    listen 80;

    location /blog {
        rewrite ^/blog/(.*)$ /static/$1 break;
        root /var/www/mysite;
    }
}
```
- **Request**: `http://example.com/blog/image.png`

- **What happens**:
  - The URI `/blog/image.png` is rewritten to `/static/image.png`.
  - The `break` flag tells Nginx to **stop processing any further location blocks** and serve the file `/var/www/mysite/static/image.png` from within the **same location block**.

---

## Redirect
A redirect informs the client (browser) that the requested resource has been moved to a new URL. The browser is then redirected to the new URL, either temporarily or permanently.

```nginx
location /old-page {
    return 302 /new-page;   # temporary redirect (Used for URLs that may change again in the future.)
}

location /new-page {
    ...
}
```
or,

```nginx
location /old-page {
    return 302 /new-page;   # permanent redirect
}

location /new-page {
    ...
}
```





