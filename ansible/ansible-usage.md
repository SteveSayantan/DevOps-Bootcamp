## Brief
Here, we have two ec2 instances. In one of those, we shall install **ansible**, and perform various tasks in the other instance using **ansible** .

[Ansible Docs](https://docs.ansible.com/ansible/latest/getting_started/index.html)

## Installation in Ubuntu

```
    sudo apt update
    sudo apt install ansible
```

## Ansible Playbook
A script written in Bash is called Bash Script. A script written in Python is called Python Script. Similarly, a file containing Ansible script is called Ansible Playbook.

## Ansible Adhoc Commands
If we need to run some basic commands say, `ls` or `echo hello world`, we don't create a bash file for it. Similarly, for simple tasks, we need not write Ansible Playbooks, we can directly run Ansible CLI commands. Such commands are called [ad-hoc commands](https://docs.ansible.com/ansible/latest/command_guide/intro_adhoc.html) .

## Inventory File

To get started with Ansible, first, we need to create an inventory file. An inventory is a single file with a list of hosts and groups.

The default location for this file is `/etc/ansible/hosts`. We can use it, but, for convenience, we can also specify a different inventory file at the command line using the `-i <path>` option.

e.g., 
- First we create an inventory file in current working dir: `touch inventory`

- we specify hosts in it

  ```bash
  #inventory
    w.x.y.z
    a.b.c.d
  ```

- now, we execute an ad-hoc command: ` ansible -i ./inventory all -m 'shell' -a 'touch testFile.txt' `. *A yellowish output indicates successful execution of an Ansible command.*

  - **all** is a pattern specifying all the hosts in **inventory** , i.e. the command will execute for all of the hosts. For details, check [patterns](https://docs.ansible.com/ansible/latest/inventory_guide/intro_patterns.html#intro-patterns).

  - Instead of **all**, we can also specify a single host, like: ` ansible -i ./inventory w.x.y.z -m 'shell' -a 'touch testFile.txt' `. But the host must reside in **inventory** .

- **-m** flag is used to specify module (As we use shell command, we use 'shell' ). For details, check [all modules](https://docs.ansible.com/ansible/2.9/modules/list_of_all_modules.html) .

- **-a** flag is used to specify the argument/command.

## Grouping hosts in Inventory
To perform actions on a particular set of hosts, we create groups in inventory file.

e.g., here we have two hosts under **dbservers** group and one host under **webservers** group.
```bash
  # inventory
  
  [dbservers]
  a.b.c.d
  e.f.g.h
  [webservers]
  w.x.y.z

```

Now, we can run a command for all the hosts under a particular group (here, **webservers**),

`ansible -i ./inventory webservers -m 'shell' -a 'touch hello.html'`

## Write Playbook
Playbooks are used to perform multiple tasks. In the following playbook, we install nginx and start nginx.

- First, we need to create an yaml file, say *playbook.yml* . It starts with **---** .

- Maintain proper indentation.

  ```yaml
  ---
  - name: Install and Start Nginx  #we can give any name to the playbook

    hosts: all  # execute the playbook for all hosts in inventory

    become: true # for using root privileges

    tasks: # now we specify tasks to be performed

      - name: Install nginx   # we can give any name to the task
        apt:    # we want to use the apt module
          name: nginx   # name of the package
          state: present # to install nginx

      - name: Start nginx  # this is the name our second task
        service:  # we want to use service module
          name: nginx  # we are interested about nginx service
          state: started  # to start the service

  # we can write multiple playbooks in single file as shown

  - name: Second playbook
    ...

  ```

- Now, we execute this playbook in the main server using **ansible-playbook** command:

  `ansible-playbook -i ./inventory playbook.yml`


## Ansible Roles
It is an efficient way to write complex playbooks. 

Let's assume we want to configure Kubernetes using Ansible. If we wish to do that in a single playbook, it will contain 50 to 60 tasks, a lot of variables, certificates, secrets etc. But if we use Ansible Roles, we can easily segregate different logic and maintain a proper structure.

To create a role for Kubernetes:
`ansible-galaxy role init kubernetes`

The above command will create a directory in cwd named **kubernetes** . Following are the contents of that dir:

```bash
ubuntu@ip-172-31-91-41:~/ansible$ ls -l kubernetes/
total 36
-rw-rw-r-- 1 ubuntu ubuntu 1328 Aug  2 12:13 README.md
drwxrwxr-x 2 ubuntu ubuntu 4096 Aug  2 12:13 defaults
drwxrwxr-x 2 ubuntu ubuntu 4096 Aug  2 12:13 files
drwxrwxr-x 2 ubuntu ubuntu 4096 Aug  2 12:13 handlers
drwxrwxr-x 2 ubuntu ubuntu 4096 Aug  2 12:13 meta
drwxrwxr-x 2 ubuntu ubuntu 4096 Aug  2 12:13 tasks
drwxrwxr-x 2 ubuntu ubuntu 4096 Aug  2 12:13 templates
drwxrwxr-x 2 ubuntu ubuntu 4096 Aug  2 12:13 tests
drwxrwxr-x 2 ubuntu ubuntu 4096 Aug  2 12:13 vars

```









 
