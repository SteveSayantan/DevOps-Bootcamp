## Server Setup and Hardening
- Log in to the instance.

- Upgrade and update the system.

  - Updating retrieves information about the latest versions of the packages from the repositories but doesn't install or upgrade them yet.
  - While Upgrading, the system will compare the installed packages with the versions listed in the updated package database and install the latest ones if available.

    ```bash
    apt update
    apt upgrade
    apt update
    ```
  Always run the apt update command before apt upgrade to ensure that we have the latest packages available.

- Create a non-root user and add it to **sudo** group.
  - create a password for the new user
  - Log in using the newly created user.

- Setup SSH authentication and connect to the server using SSH.

- Disable password login in the server

  - Open `sudo nano /etc/ssh/sshd_config` in vim or nano.
  - Search for **PasswordAuthentication** and change it to *no*. Optionally, we can also change the **PermitRootLogin** to *no* to prevent root user from logging in.
  - restart the ssh service using `sudo systemctl restart ssh`

- Add Inbound and Outbound rules for network.
