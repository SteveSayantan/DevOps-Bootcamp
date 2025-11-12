## Need of Configuration Management

Suppose, there is an organization which has 100 physical servers in their data-center. Out of those, 50 servers use windows, 25 use CentOs and the remaining ones use Ubuntu. Configuration management was the primary activity of sysadmins, and these tasks were typically performed completely manually. This became a very tedious activity.

Key problems included:

* **Software and Dependency Management:** Ensuring that system-level dependencies, packages, and libraries (such as OpenSSH, wget, and curl) were up to date and free from vulnerabilities.

* **Application Environment Setup:** Making sure that application dependencies, like the correct or supported versions of Java, web servers, or application servers, were installed and secure on the virtual machines.

* **Operating System Updates:** Ensuring that the installed distribution version (e.g., Centos) was at least the supported version and up to date. Failure to update the distribution version led to security issues and unsupported packages.

* **General Maintenance:** Performing maintenance tasks and ensuring that servers had the necessary resources, such as CPU and memory, and were available all the time.

**When sysadmins attempted to automate tasks by writing scripts**, they also faced challenges because their infrastructure was highly heterogeneous.

* **Incompatibility Across Platforms:** Organizations had servers of different types, including physical and virtual machines running various operating systems.

    * Simple shell scripts written to automate tasks (like upgrading the Java version) **would fail or not work on Windows machines**.
    * Infrastructure complexity included different Linux distributions, such as Centos, Debian, Alpine, and Ubuntu.

* **Distribution-Specific Commands:** Scripts written for one distribution would fail on another because commands differed. For example, a shell script that used the `yum` command to automate activities would work on Centos but fail on Debian or other Linux distributions.

* **Tedious Workaround:** To complete a simple task, like updating Java, the sysadmin was forced to log into each type of machine (Linux with Debian, Linux with Centos, Alpine, and Windows) and run a *different command* corresponding to that specific operating system or distribution.

After the rise of cloud, the number of servers incresed by 10 times, and the size of each server decreased by 10 times. Now, it is practically impossible to manage each and every server manually.

> Configuration management is a concept that solves this problem of managing the configuration of multiple servers. Some popular tools are Puppet, Chef, Ansible (mostly used) etc.

Ansible is developed by Red Hat. It is written in Python. The configuration code written by the user in the YAML file (known as a Playbook) is taken by Ansible, translated into Python, and then executes the Python modules on the manage nodes. Hence Python must be installed on both the control node and the managed nodes.

## Beyond Configuration Management
Besides configuration management, Ansible can be used for the following major purposes:

1. **Provisioning**

   Just as Terraform can create resources on cloud platforms, Ansible can also provision. This involves creating resources such as EC2 instances, S3 buckets, or virtual machines (for instance, on Azure).


2. **Deployment**

   Ansible is widely used in the deployment phase, particularly within Continuous Integration/Continuous Delivery (CI/CD) pipelines.

   * **Artifact Deployment:** People use Ansible for deploying artifacts onto target servers.
   * **Multi-Target Deployment:** It can help deploy an application to multiple virtual machines or multiple Kubernetes clusters.

3. **Network Automation**

   Network automation is noted as a recent popular use case for Ansible, e.g., we can automate configurations on these appliances, such as automating the setup of a VLAN.

## Puppet vs Ansible

1. Ansible uses **Push** model i.e. the DevOps engineer can write the script in his laptop (i.e. the control node) and execute the Ansible playbook to update the configuration of the instances (i.e. the managed nodes).

   Puppet uses the **Pull** model where each of the instances itself has to pull the configuration from a central location.

1. A significant architectural burden of Puppet and Chef was that they were **not agentless**. To automate target machines (physical or virtual), system administrators had to go to each machine and **install an agent** (a simple software). This installation process was an **additional burden** on the sysadmins.

   But Ansible uses an Agentless model where we only have to mention the IP Addresses / DNS of the instances to be managed in the Inventory file and have Passwordless Authentication enabled to get our job done, i.e. no need to make any configurations on the instances by ourselves. 
   - Besides, there is Dynamic Inventory feature which  enables Ansible automatically detects the instances to be managed without the need of updating the Inventory File. This makes scaling up/down very convenient.

1. Ansible mainly supports Linux, however it also has decent modules for Windows.

    But Puppet lacks support of Windows due to the lack of presence of appropriate modules.

1. The complex style of writing Puppet scripts and Chef cookbooks was a major challenge for system administrators e.g., the configuration files (known as cookbooks in Chef) were often written in **Ruby**. This meant sysadmins had to acquire a new skill set—learning Ruby and the complex style associated with Puppet and Chef—which was difficult. However, Ansible uses YAML for Ansible Playbooks, which is a very common language. We can also write and share our own Ansible modules.

## Shell Script vs Python vs Ansible for Configuration Management

1. Shell Scripting

   - Platform dependent. Does not work on Windows.
   - Even among Linux servers, shell scripts may fail if different Linux distributions use different package managers.

1. Python
   - Python is platform independent, meaning a Python script written for configuration management will work on both Windows and Linux virtual machines.
   - There's a lerning curve. Also, the written Python script requires constant maintenance and timely updates.
   - We still have to manually log into each one to execute the Python program.

1. Ansible
   - Ansible can talk to manage nodes that are Windows or Linux of any distribution.
   - Tasks can be executed in parallel or sequentially across the manage nodes without manual intervention.

## Cons of Ansible

- Configuration management is difficult for windows.
- Debugging is not good.
- It sometimes suffers from performance issues.


## Important Points

- Ansible uses SSH and WinRM protocol to connect to Linux and Windows instances respectively.

- Ansible does not care about the cloud provider. If Ansible can SSH/WinRM into an instance (i.e. perform passwordless authentication ) from our system, it can do its job.

- Control Node (Linux) requires Python. Ansible cannot run on Windows as the control node due to API limitations on the platform. However, we can run Ansible on Windows using the Windows Subsystem for Linux (WSL) or in a container.

- Managed Nodes (Linux) require Python.

- Managed Nodes (Windows) require WinRM (for connection) & PowerShell (for code execution). 
  - The majority of the core Ansible modules are written for a combination of Unix-like machines and other generic services. As these modules are written in Python and use APIs not present on Windows they will not work. 
  - There are dedicated Windows modules that are written in PowerShell and are meant to be run on Windows hosts. For details check out the [docs](https://docs.ansible.com/ansible/latest/os_guide/intro_windows.html#managing-windows-hosts-with-ansible)