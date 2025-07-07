## Brief
Our target is to **ssh** from one server into another one, without any password. This is useful in several use-cases, e.g. setting up ansible etc.

## Workflow

Suppose, we have two servers, namely *host1* and *host2* . We should be able to **ssh** into *host2* from *host1* without password.

In *host1*,
- run `ssh-keygen` . 
- Keep pressing **enter↲** to accept all the default options.
- Now, a bunch of files are created at `/home/user/.ssh` (default location).

  ```bash
    ls /home/ubuntu/.ssh
    >> authorized_keys id_rsa id_rsa.pub known_hosts
  ```

- *id_rsa* is private key which is used to login to machine. Never share this with anyone.
- *id_rsa.pub* is public key which is used for communication with others.

In *host2*,

- perform the same steps as above.
- copy the content of **id_rsa.pub** from *host1* . 
- paste it to **authorized_keys** in *host2* . Make sure that it starts from a newline.

  ```bash
    # authorized_keys in host2

  ...abcdq4w42423 target_key #previous line ends (if any)
  # new public-key starts from a new line
  ssh-ed23uoirut...
  ```

Now, in *host1*, we can simply run `ssh <user_name>@<host2_IP>` to connect to *host2* .
```bash
ssh ubuntu@13.218.232.238
```
To disconnect, use **logout** command.

>A documentation on how to use SSH public key authentication on Linux, click [here](https://www.linode.com/docs/guides/use-public-key-authentication-with-ssh/?tabs=ed25519-recommended%2Cssh-add%2Cusing-ssh-copy-id-recommended)