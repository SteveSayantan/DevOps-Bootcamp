## Need of Configuration Management

Suppose, there is an organization which has 100 physical servers in their data-center. Out of those, 50 servers use windows, 25 use CentOs and the remaining ones use Ubuntu.

Now, with each of the servers, the system admins have to take care of installing updates, security patches and some other programs (say git ). 

Needless to say it becomes a tedious job as the number of server increases. Previously, the System admins used to write scripts for each type of servers (e.g. powershell script for windows, separate bash scripts for different distros of linux etc. ) and run those on each of the servers to get the job done. But it was getting very challenging. 

After the rise of cloud, the number of servers incresed by 10 times, and the size of each server decreased by 10 times. Now, it is practically impossible to manage each and every server manually.

Configuration management is a concept that solves this problem of managing the configuration of multiple servers. Some popular tools are Puppet, Chef, Ansible (mostly used) etc.

Ansible is developed by Red Hat. It is written in Python

## Puppet vs Ansible

1. Ansible uses **Push** model i.e. the DevOps engineer can write the script in his laptop and execute the Ansible playbook to update the configuration of the instances managed by him.

    Puppet uses the **Pull** model where each of the instances itself has to pull the configuration from a central location.

1. Puppet uses Master-Slave architecture where the instances to be managed have to be configured manually as Slaves for Puppet to make changes in their configuration .

    But Ansible uses an Agentless model where we only have to mention the IP Addresses / DNS of the instances to be managed in the Inventory file and have Passwordless Authentication enabled to get our job done, i.e. no need to make any configurations on the instances by ourselves. 
    - Besides there is Dynamic Inventory feature which  enables Ansible automatically detects the instances to be managed without the need of updating the Inventory File. This makes scaling up/down very convenient.

1. Ansible mainly supports Linux, however it also has decent modules for Windows.

    But Puppet lacks support of Windows due to the lack of presence of appropriate modules.

1. Puppet requires its configuration files to be written in Puppet language which is a new language. However, Ansible uses YAML for Ansible Playbooks, which is a very common language. We can also write and share our own Ansible modules.

## Cons of Ansible

- Configuration management is difficult for windows.
- Debugging is not good.
- It sometimes suffers from performance issues.


## Important Points

- Ansible uses SSH and WinRM protocol to connect to Linux and Windows instances respectively.

- Ansible does not care about the cloud provider. If Ansible can SSH/WinRM into an instance (i.e. perform passwordless authentication ) from our system, it can do its job.