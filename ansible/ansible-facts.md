## What “gathering facts” actually means

Facts are system information collected by the `setup` module.

Examples:

* OS family
* distribution
* IP addresses
* CPU count
* kernel version
* Python version etc.


We can check them with:

```bash
ansible all -m setup
```

Ansible stores all this inside `ansible_facts` variable.



## ✔️ When does Ansible gather facts?

- **Step 1 — Playbook parse**

  Ansible hasn’t contacted any hosts yet. It only reads YAML, expands imports, loads roles, etc. 
  
  No facts exist. No SSH has happened. Nothing remote has been touched.

  This is **parse time**.


- **Step 2 — Start of play execution**

  When we run:

  ```bash
  ansible-playbook site.yml
  ```

  Ansible begins executing a play for each host.

Before running the **first** task, Ansible does:

```
TASK [Gathering Facts] ********************
```

This runs the equivalent of:

```yaml
- setup:
```

And only *after* that, our tasks begin.

This is **runtime**, not parse time.


### 🧩 Example

Given this playbook:

```yaml
- hosts: web
  tasks:
    - debug:
        msg: "hello"
```

When we run it, the steps actually happen like this:

- **1. PARSE PHASE**

  Ansible does:

  * Read playbook YAML
  * Expand `import_tasks` and `import_role`
  * Build the task graph
  * Load inventory
  * Process static vars
  * Apply tags
  * Load handlers
  * Decide which tasks exist

  At this stage:

  ❌ No facts exist  
  ❌ No remote hosts contacted  
  ❌ No SSH  
  ❌ No variables from tasks  
  ❌ No registered vars  


- **2. RUNTIME PHASE**

  Now Ansible starts host execution.

  The first thing it does is:

  ```
  TASK [Gathering Facts]
  ```

  This is the `setup` module.

  Only after this, the facts like:

  * `ansible_facts['os_family']`
  * `ansible_facts['distribution']`
  * `ansible_default_ipv4.address`

  become available.

  Then it runs our tasks:

  ```
  TASK [debug] ********************
  msg: "hello"
  ```


## ✔️ Practical timeline visualization

```
PLAYBOOK PARSE (no facts)
|
|--- load YAML
|--- expand imports
|--- build task tree
|
RUNTIME STARTS (facts exist after this point)
|
|--- TASK [Gathering Facts]
|--- TASK [task_1]
|--- TASK [task_2]
|--- ...
```

Facts live only in the **runtime** area.


## ✔️ How to *prove* this

Try this playbook:

```yaml
- hosts: localhost
  gather_facts: no
  tasks:
    - debug:
        msg: "{{ ansible_facts['os_family'] }}"
```

This will **fail**:

```
ERROR! 'ansible_facts' is undefined
```

Now try:

```yaml
- hosts: localhost
  gather_facts: yes
  tasks:
    - debug:
        msg: "{{ ansible_facts['os_family'] }}"
```

This works, because gathering facts happened **before** the debug task.

## Reference:
- [Ansible facts](https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_vars_facts.html#ansible-facts)
