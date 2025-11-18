In Ansible **inventory** file, we can attach variables to:

* **Individual hosts**
* **Groups of hosts**
* **Entire inventory levels** (like all hosts)

## Inventory aliases
The `inventory_hostname` is the unique identifier for a host in Ansible. This identifier can be an IP address or a hostname, but it can also be just an **alias** or short name for the host.

For example, in the following inventory file:

```ini
192.168.10.10
192.168.10.20
```
`inventory_hostname` for a particular host refers to the corresponding IP address. Verify that by executing the following:
```ini
ansible -i inventory.ini -m debug -a="msg='Hello from {{ inventory_hostname }}'"
```

However, in the following inventory file:
```ini
host1 ansible_host=192.168.10.10
host2 ansible_host=192.168.10.20
```

`inventory_hostname` refers to the alias **host1** and **host2** respectively.

## Adding custom variables to inventory

We can define **our own variables** also:

```ini
[web]
web1 ansible_host=192.168.10.10 env=production http_port=80
web2 ansible_host=192.168.10.11 env=staging http_port=8080
```

We can reference these variables in our playbooks:

```yaml
- hosts: web
  tasks:
    - name: Print server environment and port
      debug:
        msg: "Environment: {{ env }}, HTTP Port: {{ http_port }}"
```

Output will differ per host based on what’s defined in the inventory.

## Group Variables
Group variables are a convenient way to apply variables to multiple hosts at once. If a host is a member of multiple groups, Ansible reads variable values from all of those groups. Check [this](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html#how-variables-are-merged) for more info on how variables are merged.

```ini
[web]
web1 ansible_host=192.168.10.10
web2 ansible_host=192.168.10.11

[web:vars]
env=production
http_port=80
```
In the above example, all hosts in the **web** group inherit `env` and `http_port`.

We can apply variables to parent groups (nested groups or groups of groups) as well as to child groups.

```ini
[atlanta]
host1
host2

[raleigh]
host2
host3

[southeast:children]
atlanta
raleigh

[southeast:vars]
some_server=foo.southeast.example.com
halon_system_timeout=30

[usa:children]
southeast
```

## Best practices for larger projects
As our setup grows, mixing variables into the inventory file becomes messy. So Ansible lets us store variables in separate files:

- `group_vars/` — variables for groups

- `host_vars/` — variables for individual hosts

This method helps you organize your variable values more easily.

> Here, the host and group variable files **must use** YAML syntax

The host and group variable files are loaded by searching paths relative to the inventory source or the playbook file. E.g., if our inventory file at `/etc/ansible/hosts` contains a host named **foosball** that belongs to the **raleigh** and **webservers** groups, that host will use variables from the YAML files in the following locations:
```bash
/etc/ansible/group_vars/raleigh # can optionally end in '.yml', '.yaml', or '.json'
/etc/ansible/group_vars/webservers
/etc/ansible/host_vars/foosball
```

## References
- Understand [Variable Precedence](https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable)

- Understand [Precedence Rules](https://docs.ansible.com/projects/ansible/latest/reference_appendices/general_precedence.html#controlling-how-ansible-behaves-precedence-rules)