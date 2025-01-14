Nginx provides a simple way to add rate limiting using the `limit_req_zone` and `limit_req` directives. Refer to [http_limit_req_module](https://nginx.org/en/docs/http/ngx_http_limit_req_module.html) for details.

1. In `/etc/nginx/nginx.conf`, add the following to the `http` block:

    ```nginx

    http {
        limit_req_zone $binary_remote_addr zone=one:10m rate=2r/s;

        ...
    }
    ```
    - **`$binary_remote_addr`**: This variable stores the client’s IP address in binary format, which is a more compact representation compared to the standard IP format. Using this helps save memory space, which is important when you are tracking many IP addresses in the shared memory zone.
  
    - **`zone=one`**: 
        - **`zone`** refers to a named shared memory area that Nginx uses to store request data.
        - The name of this zone is `one`. This is an arbitrary name, and you can name it whatever you want (e.g., `zone=clients`, `zone=ratelimit`, etc.).
    
    - **`10m`**: This defines the size of the shared memory zone, which is **10 megabytes** in this example. The size determines how much data (e.g., how many unique IP addresses or other variables) can be stored in this zone. Typically, 1 MB can store rate-limiting information for about 16,000 IP addresses. So, a 10 MB zone could handle approximately 160,000 IP addresses.

    - **`rate=1r/s`**: This sets the rate at which requests are allowed per client IP. In this case, each client can make **1 request per second**.
    
    In Nginx, **shared memory zones** are essential for storing data that needs to be accessed across multiple worker processes. These zones are particularly useful for things like rate limiting, caching, and session tracking, where consistency is needed regardless of which worker process handles a particular request. Without a shared memory zone, each worker would have its own data, leading to inconsistent enforcement of rate limits.

1. Inside the `server` context, add the following:
   ```nginx
    server {
    ...

    location / {
        limit_req zone=one burst=20 nodelay;
        try_files $uri $uri/ =404;
    }

    ...
    }
   ```

   - `zone=one` : This applies the rate limiting defined by the one zone. When a client makes requests to `/`, the `one` zone is consulted to see if the rate limit is being followed.

   - `burst=20` : allows a burst of up to 20 requests beyond the defined rate. So, even if the rate limit is set to 2 requests per second, the burst allows up to 20 requests to be made in a second. By default, the maximum burst size is equal to zero. The requests exceeding the max burst size will be rejected immediately.

   - `nodelay` : means that requests that exceed the rate limit should be rejected immediately rather than delayed.


1. Reload nginx for the changes to take effect.

## nodelay vs delay=number parameters

In Nginx, the `nodelay` and `delay=number` parameters are used with the `limit_req`  directive to control how rate limiting is applied to incoming requests. Here's the difference between them:

1. `nodelay` Parameter:
- **Purpose**: It allows the rate limit to be applied **without delaying** any requests that exceed the rate, as long as they stay within the burst limit.
- **Behavior**: When `nodelay` is specified, Nginx does not slow down (or "throttle") requests to conform to the rate limit but instead allows requests to be processed immediately if they fall within the allowed burst.

#### Example:

```nginx
limit_req_zone $binary_remote_addr zone=one:10m rate=1r/s;

server {
    location / {
        limit_req zone=one burst=5 nodelay;
    }
}
```
- In this example, requests are limited to **1 request per second**, with a **burst** of up to 5 requests. 
- The **`nodelay`** parameter allows these 5 requests to be processed immediately without any delay, even if they exceed the 1r/s rate.

1. `delay=0` (default behavior):
- **Purpose**: It **delays all the requests** that exceed the rate, making them conform to the specified rate limit by spacing them out over time. **0** (default value) signifies all excessive requests are delayed. 

- **Behavior**: Without `nodelay`, Nginx will queue and gradually process requests at the defined rate (e.g., 1 request per second). If requests come in faster than the rate allows, Nginx will delay them, enforcing the rate limit.

#### Example 1:

```nginx
limit_req_zone $binary_remote_addr zone=one:10m rate=1r/s;

server {
    location / {
        limit_req zone=one burst=5;
    }
}
```
- Here, Nginx limits requests to **1 request per second**, with a **burst** of up to 5 requests. 
- Requests exceeding the rate of 1r/s will be **queued and delayed** to fit the rate limit, with the maximum queue size being 5.


#### Example 2

```nginx
limit_req zone=one burst=5 delay=2;
```

- **`delay=2`**: Introduces a delay after the first 2 requests in the burst. The first 2 requests in the burst will be processed immediately, but requests 3 to 5 in the burst will be delayed to fit the rate limit.

### How It Works:
1. **Rate Limiting Zone**: Let's assume the rate limit is set to **1 request per second** (e.g., `rate=1r/s`).
2. **Burst**: A burst of up to 5 requests is allowed. This means Nginx can handle 5 requests that exceed the normal rate of 1 request per second.
3. **Delay**: The first 2 requests in the burst are processed immediately without delay. However, for requests 3 to 5, they will be delayed to conform to the **1 request per second** rate limit.
