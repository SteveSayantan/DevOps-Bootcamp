# 🧩 Core Principle - Variable Resolution

✔️ Variables **are** resolved at runtime

BUT

✔️ Some variables **can be interpolated at parse time**

**IF** they do not depend on host facts, loops, or runtime context.


### 🧩 1. Variables that *must* be evaluated at runtime

These include:

* `ansible_facts`
* host-specific variables
* group_vars/host_vars overrides
* registered variables
* loop variables
* results from previous tasks

**These DO NOT exist at parse time.**

Example:

```yaml
- import_tasks: "{{ ansible_facts['os_family'] }}.yml"
```

❌ Does NOT work
Because at parse time, `ansible_facts` isn't loaded.


### 🧩 2. Variables that *can* be interpolated at parse time

These are **plain, static variables**:

* variables set in the same playbook
* variables in `vars:` blocks
* variables in `defaults/` and `vars/` files
* variables from inventory (static)
* literal YAML values

These *do exist* before runtime begins.

### Example A — Works with import_tasks

```yaml
vars:
  taskfile: install.yml

tasks:
  - import_tasks: "{{ taskfile }}"
```

This works **perfectly**, because `taskfile` is static and known at parse time.

### Example B — Also works

```yaml
vars:
  myport: 8080

tasks:
  - debug:
      msg: "{{ myport }}"
```

No problem — nothing runtime-dependent.

### Example C — Variables from inventory are available at parse time too

Inventory:

```ini
[web]
server1 nginx_config=production.conf
```

Playbook:

```yaml
- hosts: web
  tasks:
    - import_tasks: "{{ nginx_config }}"
```

✔️ Works

Because inventory variables are loaded *before* parse time finishes.

### 🧠 So what actually breaks?


#### Using **facts** inside import_tasks

```yaml
- import_tasks: "{{ ansible_facts['distribution'] }}.yml"
```

Fails at parse time as facts are loaded **only at runtime**, after parsing.


#### ❌ Case 2 — Using **registered variables** inside import_tasks

```yaml
- name: get something
  command: echo hi
  register: result

- import_tasks: "{{ result.stdout }}.yml"
```

Fails — because `result` doesn’t exist at parse time.

#### ❌ Case 3 — Using **loop variables** inside import_tasks

```yaml
- import_tasks: "{{ item }}"
  loop:
    - a.yml
    - b.yml
```

Fails — loop expansion happens at runtime, not parse time.


#### ✔️ Case 4 — Using static vars inside import_tasks

```yaml
vars:
  my_file: setup.yml

tasks:
  - import_tasks: "{{ my_file }}"
```

Works fine.
Because this variable is available at parse time.

#### ✔️ Case 5 — Using inventory vars inside import_tasks

Inventory:

```ini
node1 deploy_file=configure.yml
```

Playbook:

```yaml
- hosts: node1
  tasks:
    - import_tasks: "{{ deploy_file }}"
```

Works fine.

Inventory vars are loaded before parse.
